using System.Diagnostics;
using System.Text.Json;
using System.Windows.Forms;

namespace Foxtopia.Launcher;

internal static class Program
{
    [STAThread]
    private static int Main(string[] args)
    {
        ApplicationConfiguration.Initialize();

        if (args.Length == 4 && args[0] == "--test-fixture" && args[2] == "--install-root")
            return RunFixture(args[1], args[3]);

        using var mutex = new Mutex(initiallyOwned: true, @"Local\KlausennGames_Foxtopia_Launcher", out var firstInstance);
        if (!firstInstance) return 0;

        var installRoot = AppContext.BaseDirectory;
        var uiLanguage = LauncherLocalization.ReadLanguage(installRoot);
        try
        {
            var config = ReadConfig(installRoot);
            var updater = new Updater(installRoot, config);
            Application.Run(new UpdateWindow(updater));

            var state = updater.ReadState();
            var gamePath = updater.GetGamePath(state);
            if (!File.Exists(gamePath))
                throw new FileNotFoundException(LauncherLocalization.Text(uiLanguage, "missing_game"), gamePath);
            var process = Process.Start(new ProcessStartInfo(gamePath)
            {
                WorkingDirectory = Path.GetDirectoryName(gamePath)!,
                UseShellExecute = false
            }) ?? throw new InvalidOperationException(LauncherLocalization.Text(uiLanguage, "start_failed"));
            process.WaitForExit();
            updater.CleanupOldVersions();
            return process.ExitCode;
        }
        catch (Exception ex)
        {
            try { new Updater(installRoot, new LauncherConfig()).Log($"Launcher error: {ex}"); }
            catch { }
            MessageBox.Show(ex.Message, "Foxtopia", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
    }

    private static int RunFixture(string fixtureDirectory, string installRoot)
    {
        try
        {
            var config = ReadConfig(installRoot);
            var updater = new Updater(installRoot, config, fixtureDirectory);
            var outcome = updater.CheckAndInstallAsync((_, _) => { }, CancellationToken.None)
                .GetAwaiter().GetResult();
            File.WriteAllText(Path.Combine(installRoot, "test-result.json"),
                JsonSerializer.Serialize(new { outcome = outcome.ToString(), version = updater.ReadState().Version }));
            return 0;
        }
        catch (Exception ex)
        {
            Directory.CreateDirectory(installRoot);
            File.WriteAllText(Path.Combine(installRoot, "test-result.json"),
                JsonSerializer.Serialize(new { outcome = "Failed", error = ex.Message }));
            return 1;
        }
    }

    private static LauncherConfig ReadConfig(string root) =>
        JsonSerializer.Deserialize<LauncherConfig>(File.ReadAllText(Path.Combine(root, "launcher-config.json")))
        ?? throw new InvalidDataException("launcher-config.json is empty.");
}

internal sealed class UpdateWindow : Form
{
    private readonly Updater _updater;
    private readonly Label _status;
    private readonly ProgressBar _progress;

    public UpdateWindow(Updater updater)
    {
        _updater = updater;
        Text = "Foxtopia";
        Width = 440;
        Height = 155;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        StartPosition = FormStartPosition.CenterScreen;
        MaximizeBox = false;
        MinimizeBox = false;
        ShowInTaskbar = true;

        _status = new Label { Left = 22, Top = 22, Width = 380, Text = LauncherLocalization.Text(updater.UiLanguage, "checking") };
        _progress = new ProgressBar { Left = 22, Top = 54, Width = 380, Height = 20, Style = ProgressBarStyle.Marquee };
        Controls.Add(_status);
        Controls.Add(_progress);
    }

    protected override async void OnShown(EventArgs e)
    {
        base.OnShown(e);
        try
        {
            var outcome = await Task.Run(() => _updater.CheckAndInstallAsync(Report, CancellationToken.None));
            _updater.Log($"Update check: {outcome}.");
        }
        catch (HttpRequestException ex)
        {
            _updater.Log($"Update network error: {ex.Message}");
        }
        catch (TaskCanceledException ex)
        {
            _updater.Log($"Update timed out: {ex.Message}");
        }
        catch (Exception ex)
        {
            _updater.Log($"Update failed: {ex}");
            MessageBox.Show(this,
                LauncherLocalization.Text(_updater.UiLanguage, "update_failed", ex.Message),
                "Foxtopia", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        finally { Close(); }
    }

    private void Report(string message, int? percentage)
    {
        if (!IsHandleCreated || IsDisposed) return;
        BeginInvoke(() =>
        {
            if (IsDisposed) return;
            _status.Text = message;
            _progress.Style = percentage.HasValue ? ProgressBarStyle.Continuous : ProgressBarStyle.Marquee;
            if (percentage.HasValue) _progress.Value = Math.Clamp(percentage.Value, 0, 100);
        });
    }
}
