# Display, audio and language preferences

The game's default language is English. Player preferences are independent of
colony save files and are stored in `user://settings.json`.

```gdscript
const SettingsScript = preload("res://scripts/ui/settings.gd")
const I18n = preload("res://scripts/ui/i18n.gd")

var preferences = SettingsScript.load_settings()

func _ready() -> void:
	preferences.apply_settings()
	print(I18n.t("menu.single_player", preferences.language))
```

Settings are changed by assigning fields and then applying and saving them:

```gdscript
preferences.window_mode = "borderless" # fullscreen, borderless, windowed
preferences.resolution = Vector2i(1920, 1080)
preferences.master_volume = 0.8 # each volume is a linear value from 0 to 1
preferences.music_volume = 0.6
preferences.effects_volume = 0.9
preferences.language = "pl" # en, tr, pl
preferences.apply_settings()
if not preferences.save_settings():
	push_warning("Could not save player preferences.")
```

`SettingsScript.resolution_options()` provides choices for the options screen.
Resolution is used in windowed mode; fullscreen follows the monitor. On
Windows, `fullscreen` uses Godot's exclusive fullscreen mode and `borderless`
uses regular fullscreen. Music players should route to the `Music` audio bus;
sound effects should route to `Effects`. `apply_settings()` creates either bus
if it is missing, and all buses feed `Master`.

Call `I18n.t(key, preferences.language)` for visible UI strings. Format values
are passed as a dictionary: `I18n.t("game.day", preferences.language,
{"day": 3})`. The language picker can use `I18n.language_options()`. After a
language change, rebuild the currently open screen so its labels update.
Unknown or untranslated keys use the English source text. `I18n.missing_keys`
can be used in tests to check the catalogs.

The catalogs cover the main game UI. Event messages and generated names in the
simulation model still need to be converted to message keys before the entire
game can switch languages consistently. They should be localized when the
related gameplay screens are updated.
