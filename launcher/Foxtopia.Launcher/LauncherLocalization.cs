using System.Text.Json;

namespace Foxtopia.Launcher;

internal static class LauncherLocalization
{
    public static string ReadLanguage(string installRoot)
    {
        // An in-game change takes precedence over the original Setup choice.
        try
        {
            var settingsPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
                "Godot", "app_userdata", "Foxtopia", "settings.json");
            if (File.Exists(settingsPath))
            {
                using var settings = JsonDocument.Parse(File.ReadAllText(settingsPath));
                if (settings.RootElement.TryGetProperty("language", out var value))
                {
                    var selected = Normalize(value.GetString());
                    if (selected is not null) return selected;
                }
            }
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException or JsonException) { }

        try
        {
            var path = Path.Combine(installRoot, "launcher-language.ini");
            if (File.Exists(path))
            {
                foreach (var line in File.ReadLines(path))
                {
                    var pair = line.Split('=', 2);
                    if (pair.Length == 2 && pair[0].Trim().Equals("Language", StringComparison.OrdinalIgnoreCase))
                    {
                        var selected = Normalize(pair[1].Trim());
                        if (selected is not null) return selected;
                    }
                }
            }
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException) { }
        return "en";
    }

    private static string? Normalize(string? value) => value?.ToLowerInvariant() switch
    {
        "en" or "english" => "en",
        "tr" or "turkish" => "tr",
        "pl" or "polish" => "pl",
        _ => null
    };

    public static string Text(string language, string key, params object[] args)
    {
        var template = (language, key) switch
        {
            ("tr", "checking") => "Güncellemeler kontrol ediliyor…",
            ("tr", "downloading") => "{0} indiriliyor…",
            ("tr", "preparing") => "Güncelleme hazırlanıyor…",
            ("tr", "complete") => "Güncelleme tamamlandı.",
            ("tr", "missing_game") => "Oyun dosyası bulunamadı.",
            ("tr", "start_failed") => "Oyun başlatılamadı.",
            ("tr", "update_failed") => "Güncelleme kurulamadı. Mevcut sürüm açılacak.\n\n{0}",
            ("pl", "checking") => "Sprawdzanie aktualizacji…",
            ("pl", "downloading") => "Pobieranie {0}…",
            ("pl", "preparing") => "Przygotowywanie aktualizacji…",
            ("pl", "complete") => "Aktualizacja ukończona.",
            ("pl", "missing_game") => "Nie znaleziono pliku gry.",
            ("pl", "start_failed") => "Nie można uruchomić gry.",
            ("pl", "update_failed") => "Nie można zainstalować aktualizacji. Zostanie uruchomiona obecna wersja.\n\n{0}",
            (_, "checking") => "Checking for updates…",
            (_, "downloading") => "Downloading {0}…",
            (_, "preparing") => "Preparing update…",
            (_, "complete") => "Update complete.",
            (_, "missing_game") => "Game file was not found.",
            (_, "start_failed") => "Could not start the game.",
            (_, "update_failed") => "Could not install the update. The current version will start.\n\n{0}",
            _ => key
        };
        return args.Length == 0 ? template : string.Format(template, args);
    }
}
