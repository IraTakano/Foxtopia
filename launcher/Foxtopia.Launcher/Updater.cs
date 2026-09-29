using System.IO.Compression;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace Foxtopia.Launcher;

internal sealed class Updater(string installRoot, LauncherConfig config, string? fixtureDirectory = null)
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        WriteIndented = true
    };

    private static readonly Regex RepositoryPattern = new(
        @"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", RegexOptions.CultureInvariant);

    private readonly string _root = Path.GetFullPath(installRoot);
    public string UiLanguage { get; } = LauncherLocalization.ReadLanguage(installRoot);
    private readonly LauncherConfig _config = config;
    private readonly string? _fixtureDirectory = fixtureDirectory;

    public InstallState ReadState()
    {
        var path = Path.Combine(_root, "current.json");
        var state = JsonSerializer.Deserialize<InstallState>(File.ReadAllText(path), JsonOptions)
            ?? throw new InvalidDataException("current.json is empty.");
        if (!IsSafeDirectoryName(state.Directory) || string.IsNullOrWhiteSpace(state.Version))
            throw new InvalidDataException("current.json contains an invalid version directory.");
        return state;
    }

    public string GetGamePath(InstallState state)
    {
        if (!IsSafeFileName(_config.GameExecutable))
            throw new InvalidDataException("The configured game executable is invalid.");
        return Path.Combine(_root, "versions", state.Directory, _config.GameExecutable);
    }

    public async Task<UpdateOutcome> CheckAndInstallAsync(Action<string, int?> report, CancellationToken cancellationToken)
    {
        var installed = ReadState();
        if (_fixtureDirectory is null && string.IsNullOrWhiteSpace(_config.Repository))
            return UpdateOutcome.NoRepository;

        report(LauncherLocalization.Text(UiLanguage, "checking"), null);
        ReleaseInfo? release;
        try
        {
            release = _fixtureDirectory is null
                ? await LoadGitHubReleaseAsync(cancellationToken)
                : await LoadFixtureReleaseAsync(cancellationToken);
        }
        catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
        {
            Log($"No published release: {ex.Message}");
            return UpdateOutcome.NoRelease;
        }

        if (release is null)
            return UpdateOutcome.NoRelease;
        var gamePresent = File.Exists(GetGamePath(installed));
        if (release.Version == installed.Version && gamePresent)
            return UpdateOutcome.AlreadyCurrent;

        var versionOrder = ReleaseVersion.Compare(release.Version, installed.Version);
        if (versionOrder is null && release.Version != installed.Version)
        {
            Log($"Update skipped: cannot order installed tag {installed.Version} and release tag {release.Version}.");
            return UpdateOutcome.UnknownVersionOrder;
        }
        if (versionOrder < 0)
        {
            Log($"Update skipped: installed {installed.Version} is newer than release {release.Version}.");
            return UpdateOutcome.InstalledNewer;
        }
        if (versionOrder == 0 && gamePresent)
            return UpdateOutcome.AlreadyCurrent;

        ValidateManifest(release);
        report(LauncherLocalization.Text(UiLanguage, "downloading", release.Version), 0);
        var updatesRoot = Path.Combine(_root, "updates");
        var versionsRoot = Path.Combine(_root, "versions");
        Directory.CreateDirectory(updatesRoot);
        Directory.CreateDirectory(versionsRoot);

        var id = Guid.NewGuid().ToString("N");
        var archivePath = Path.Combine(updatesRoot, $"{id}.zip");
        var stagingPath = Path.Combine(versionsRoot, $".staging-{id}");
        var finalDirectory = $"{SafeVersion(release.Version)}-{id[..8]}";
        var finalPath = Path.Combine(versionsRoot, finalDirectory);

        try
        {
            await DownloadArchiveAsync(release, archivePath, report, cancellationToken);
            CheckDigest(archivePath, release.Manifest.Sha256, "archive manifest");
            if (!string.IsNullOrWhiteSpace(release.ArchiveDigest))
                CheckDigest(archivePath, release.ArchiveDigest, "GitHub asset");

            report(LauncherLocalization.Text(UiLanguage, "preparing"), null);
            ExtractVerifiedZip(archivePath, stagingPath);
            var executable = Path.Combine(stagingPath, _config.GameExecutable);
            if (!File.Exists(executable))
                throw new InvalidDataException($"Release archive is missing {_config.GameExecutable}.");

            Directory.Move(stagingPath, finalPath);
            SaveStateAtomically(new InstallState { Version = release.Version, Directory = finalDirectory });
            Log($"Installed release {release.Version} in {finalDirectory}.");
            report(LauncherLocalization.Text(UiLanguage, "complete"), 100);
            return UpdateOutcome.Updated;
        }
        finally
        {
            try { if (File.Exists(archivePath)) File.Delete(archivePath); }
            catch (IOException ex) { Log($"Temporary archive cleanup skipped: {ex.Message}"); }
            catch (UnauthorizedAccessException ex) { Log($"Temporary archive cleanup skipped: {ex.Message}"); }
            try { if (Directory.Exists(stagingPath)) Directory.Delete(stagingPath, recursive: true); }
            catch (IOException ex) { Log($"Staging cleanup skipped: {ex.Message}"); }
            catch (UnauthorizedAccessException ex) { Log($"Staging cleanup skipped: {ex.Message}"); }
        }
    }

    public void CleanupOldVersions()
    {
        try
        {
            var current = ReadState();
            var versionsRoot = Path.Combine(_root, "versions");
            if (!Directory.Exists(versionsRoot)) return;
            var old = new DirectoryInfo(versionsRoot).GetDirectories()
                .Where(directory => directory.Name != current.Directory && !directory.Name.StartsWith(".staging-", StringComparison.Ordinal))
                .OrderByDescending(directory => directory.CreationTimeUtc)
                .Skip(1);
            foreach (var directory in old)
            {
                try { directory.Delete(recursive: true); }
                catch (IOException) { /* A directly launched old game may still be using this version. */ }
                catch (UnauthorizedAccessException) { }
            }
        }
        catch (Exception ex) { Log($"Old-version cleanup skipped: {ex.Message}"); }
    }

    public void Log(string message)
    {
        try
        {
            var logs = Path.Combine(_root, "logs");
            Directory.CreateDirectory(logs);
            var path = Path.Combine(logs, "launcher.log");
            if (File.Exists(path) && new FileInfo(path).Length > 2_000_000)
                File.Move(path, Path.Combine(logs, "launcher.previous.log"), overwrite: true);
            File.AppendAllText(path, $"{DateTimeOffset.UtcNow:O} {message}{Environment.NewLine}");
        }
        catch { /* Logging must never stop the game. */ }
    }

    private async Task<ReleaseInfo> LoadFixtureReleaseAsync(CancellationToken cancellationToken)
    {
        var directory = Path.GetFullPath(_fixtureDirectory!);
        var manifestBytes = await File.ReadAllBytesAsync(Path.Combine(directory, _config.ManifestAsset), cancellationToken);
        var manifest = DeserializeManifest(manifestBytes);
        return new ReleaseInfo(manifest.Version, manifest, Path.Combine(directory, _config.ArchiveAsset), null, null);
    }

    private async Task<ReleaseInfo?> LoadGitHubReleaseAsync(CancellationToken cancellationToken)
    {
        if (!RepositoryPattern.IsMatch(_config.Repository))
            throw new InvalidDataException("Repository must be owner/name.");
        var components = _config.Repository.Split('/');
        if (components.Any(component => component is "." or ".."))
            throw new InvalidDataException("Repository contains an invalid name.");

        using var http = NewHttpClient(TimeSpan.FromSeconds(12));
        var endpoint = $"https://api.github.com/repos/{components[0]}/{components[1]}/releases/latest";
        using var response = await http.GetAsync(endpoint, cancellationToken);
        if (response.StatusCode == HttpStatusCode.NotFound) return null;
        response.EnsureSuccessStatusCode();
        await using var responseStream = await response.Content.ReadAsStreamAsync(cancellationToken);
        var release = await JsonSerializer.DeserializeAsync<GitHubRelease>(responseStream, JsonOptions, cancellationToken)
            ?? throw new InvalidDataException("GitHub returned an empty release.");
        if (!IsSafeVersion(release.TagName))
            throw new InvalidDataException("Release tag contains unsafe characters.");
        var manifestAsset = release.Assets.SingleOrDefault(asset => asset.Name == _config.ManifestAsset)
            ?? throw new InvalidDataException($"Release is missing {_config.ManifestAsset}.");
        var archiveAsset = release.Assets.SingleOrDefault(asset => asset.Name == _config.ArchiveAsset)
            ?? throw new InvalidDataException($"Release is missing {_config.ArchiveAsset}.");
        if (manifestAsset.Size is <= 0 or > 64_000)
            throw new InvalidDataException("Release manifest size is invalid.");
        ValidateDownloadUrl(manifestAsset.DownloadUrl, _config.Repository);
        ValidateDownloadUrl(archiveAsset.DownloadUrl, _config.Repository);
        if (archiveAsset.Size is <= 0 or > 5_000_000_000)
            throw new InvalidDataException("Release archive size is invalid.");

        using var manifestResponse = await http.GetAsync(manifestAsset.DownloadUrl, cancellationToken);
        manifestResponse.EnsureSuccessStatusCode();
        var manifestBytes = await manifestResponse.Content.ReadAsByteArrayAsync(cancellationToken);
        if (manifestBytes.Length > 64_000)
            throw new InvalidDataException("Release manifest is too large.");
        if (!string.IsNullOrWhiteSpace(manifestAsset.Digest))
            CheckDigest(manifestBytes, manifestAsset.Digest, "GitHub manifest asset");
        var manifest = DeserializeManifest(manifestBytes);
        return new ReleaseInfo(release.TagName, manifest, archiveAsset.DownloadUrl,
            archiveAsset.Size, archiveAsset.Digest);
    }

    private void ValidateManifest(ReleaseInfo release)
    {
        var manifest = release.Manifest;
        if (manifest.SchemaVersion != 1 || manifest.Version != release.Version ||
            manifest.Archive != _config.ArchiveAsset || manifest.GameExecutable != _config.GameExecutable ||
            !IsSha256(manifest.Sha256) || !IsSafeVersion(manifest.Version))
            throw new InvalidDataException("Release manifest does not match the selected release.");
    }

    private async Task DownloadArchiveAsync(ReleaseInfo release, string path,
        Action<string, int?> report, CancellationToken cancellationToken)
    {
        await using var destination = new FileStream(path, FileMode.CreateNew, FileAccess.Write, FileShare.None, 1024 * 1024, useAsync: true);
        Stream source;
        HttpClient? http = null;
        HttpResponseMessage? response = null;
        try
        {
            if (_fixtureDirectory is null)
            {
                http = NewHttpClient(TimeSpan.FromMinutes(10));
                response = await http.GetAsync(release.ArchiveSource, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
                response.EnsureSuccessStatusCode();
                source = await response.Content.ReadAsStreamAsync(cancellationToken);
            }
            else
            {
                source = new FileStream(release.ArchiveSource, FileMode.Open, FileAccess.Read, FileShare.Read);
            }
            await using (source)
            {
                var buffer = new byte[1024 * 1024];
                long copied = 0;
                int count;
                while ((count = await source.ReadAsync(buffer, cancellationToken)) != 0)
                {
                    copied += count;
                    if (copied > 5_000_000_000)
                        throw new InvalidDataException("Release archive exceeds the size limit.");
                    await destination.WriteAsync(buffer.AsMemory(0, count), cancellationToken);
                    if (release.ArchiveLength is > 0)
                        report(LauncherLocalization.Text(UiLanguage, "downloading", release.Version), (int)Math.Min(99, copied * 100 / release.ArchiveLength.Value));
                }
                if (release.ArchiveLength is > 0 && copied != release.ArchiveLength)
                    throw new InvalidDataException("Downloaded archive length does not match GitHub metadata.");
            }
        }
        finally
        {
            response?.Dispose();
            http?.Dispose();
        }
    }

    private static void ExtractVerifiedZip(string zipPath, string destination)
    {
        Directory.CreateDirectory(destination);
        var root = Path.GetFullPath(destination) + Path.DirectorySeparatorChar;
        long totalUncompressed = 0;
        using var zip = ZipFile.OpenRead(zipPath);
        foreach (var entry in zip.Entries)
        {
            totalUncompressed += entry.Length;
            if (totalUncompressed > 8_000_000_000)
                throw new InvalidDataException("Release archive expands beyond the size limit.");
            if ((entry.ExternalAttributes >> 16 & 0xF000) == 0xA000)
                throw new InvalidDataException("Release archive contains a symbolic link.");
            var fullPath = Path.GetFullPath(Path.Combine(destination, entry.FullName.Replace('/', Path.DirectorySeparatorChar)));
            if (!fullPath.StartsWith(root, StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Release archive contains an unsafe path.");
            if (entry.FullName.EndsWith('/'))
            {
                Directory.CreateDirectory(fullPath);
                continue;
            }
            Directory.CreateDirectory(Path.GetDirectoryName(fullPath)!);
            entry.ExtractToFile(fullPath, overwrite: false);
        }
    }

    private void SaveStateAtomically(InstallState state)
    {
        var path = Path.Combine(_root, "current.json");
        var temporary = path + "." + Guid.NewGuid().ToString("N") + ".tmp";
        try
        {
            File.WriteAllText(temporary, JsonSerializer.Serialize(state, JsonOptions), Encoding.UTF8);
            File.Move(temporary, path, overwrite: true);
        }
        finally { if (File.Exists(temporary)) File.Delete(temporary); }
    }

    private static ReleaseManifest DeserializeManifest(byte[] bytes) =>
        JsonSerializer.Deserialize<ReleaseManifest>(bytes, JsonOptions)
        ?? throw new InvalidDataException("Release manifest is empty.");

    private static HttpClient NewHttpClient(TimeSpan timeout)
    {
        var client = new HttpClient { Timeout = timeout };
        client.DefaultRequestHeaders.UserAgent.ParseAdd("FoxtopiaLauncher/1.0");
        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/vnd.github+json"));
        return client;
    }

    private static void ValidateDownloadUrl(string url, string repository)
    {
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps ||
            uri.Host != "github.com" ||
            !uri.AbsolutePath.StartsWith($"/{repository}/releases/download/", StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException("Release asset URL is outside the selected GitHub repository.");
    }

    private static bool IsSafeDirectoryName(string value) =>
        !string.IsNullOrWhiteSpace(value) && value is not "." and not ".." &&
        value.IndexOfAny(Path.GetInvalidFileNameChars()) < 0 &&
        !value.Contains('/') && !value.Contains('\\');

    private static bool IsSafeFileName(string value) => IsSafeDirectoryName(value);
    private static bool IsSafeVersion(string value) =>
        value.Length is > 0 and <= 70 && Regex.IsMatch(value, @"^[A-Za-z0-9][A-Za-z0-9._-]*$");
    private static string SafeVersion(string version) => version.Replace('.', '_');
    private static bool IsSha256(string value) => Regex.IsMatch(value, @"^[a-fA-F0-9]{64}$");

    private static void CheckDigest(string file, string expected, string label)
    {
        using var stream = File.OpenRead(file);
        var actual = Convert.ToHexString(SHA256.HashData(stream));
        CheckDigestText(actual, expected, label);
    }

    private static void CheckDigest(byte[] bytes, string expected, string label) =>
        CheckDigestText(Convert.ToHexString(SHA256.HashData(bytes)), expected, label);

    private static void CheckDigestText(string actual, string expected, string label)
    {
        var clean = expected.StartsWith("sha256:", StringComparison.OrdinalIgnoreCase) ? expected[7..] : expected;
        if (!IsSha256(clean) || !actual.Equals(clean, StringComparison.OrdinalIgnoreCase))
            throw new InvalidDataException($"SHA-256 verification failed for {label}.");
    }

    private sealed record ReleaseInfo(string Version, ReleaseManifest Manifest,
        string ArchiveSource, long? ArchiveLength, string? ArchiveDigest);
}
