using System.Text.Json.Serialization;

namespace Foxtopia.Launcher;

internal sealed class LauncherConfig
{
    [JsonPropertyName("repository")]
    public string Repository { get; set; } = "";

    [JsonPropertyName("manifestAsset")]
    public string ManifestAsset { get; set; } = "Foxtopia-update.json";

    [JsonPropertyName("archiveAsset")]
    public string ArchiveAsset { get; set; } = "Foxtopia-win-x64.zip";

    [JsonPropertyName("gameExecutable")]
    public string GameExecutable { get; set; } = "Foxtopia.exe";
}

internal sealed class InstallState
{
    [JsonPropertyName("version")]
    public string Version { get; set; } = "";

    [JsonPropertyName("directory")]
    public string Directory { get; set; } = "";
}

internal sealed class ReleaseManifest
{
    [JsonPropertyName("schemaVersion")]
    public int SchemaVersion { get; set; }

    [JsonPropertyName("version")]
    public string Version { get; set; } = "";

    [JsonPropertyName("archive")]
    public string Archive { get; set; } = "";

    [JsonPropertyName("sha256")]
    public string Sha256 { get; set; } = "";

    [JsonPropertyName("gameExecutable")]
    public string GameExecutable { get; set; } = "";
}

internal sealed class GitHubRelease
{
    [JsonPropertyName("tag_name")]
    public string TagName { get; set; } = "";

    [JsonPropertyName("assets")]
    public List<GitHubAsset> Assets { get; set; } = [];
}

internal sealed class GitHubAsset
{
    [JsonPropertyName("name")]
    public string Name { get; set; } = "";

    [JsonPropertyName("browser_download_url")]
    public string DownloadUrl { get; set; } = "";

    [JsonPropertyName("digest")]
    public string? Digest { get; set; }

    [JsonPropertyName("size")]
    public long Size { get; set; }
}

internal enum UpdateOutcome
{
    NoRepository,
    AlreadyCurrent,
    InstalledNewer,
    UnknownVersionOrder,
    Updated,
    NoRelease,
    Failed
}
