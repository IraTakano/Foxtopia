extends SceneTree

const SettingsScript = preload("res://scripts/ui/settings.gd")
const I18n = preload("res://scripts/ui/i18n.gd")


func _initialize() -> void:
	var settings = SettingsScript.new()
	assert(settings.language == "en")
	assert(settings.window_mode == "fullscreen")
	assert(SettingsScript._validated_display_index(1, 2) == 1)
	assert(SettingsScript._validated_display_index(7, 2) == 0)
	assert(SettingsScript.resolution_options().has(Vector2i(1024, 768)))
	assert(SettingsScript.resolution_options().has(Vector2i(3840, 2160)))
	assert(SettingsScript.resolution_options().has(Vector2i(7680, 4320)))
	settings.language = "pl"
	settings.window_mode = "borderless"
	settings.display_index = 999
	settings.master_volume = 0.42
	settings.apply_settings()
	var data: Dictionary = settings.to_dictionary()
	assert(data["language"] == "pl")
	assert(data["window_mode"] == "borderless")
	assert(data["display_index"] == 0)
	assert(is_equal_approx(float(data["master_volume"]), 0.42))
	assert(I18n.ENGLISH.size() == I18n.TURKISH.size())
	assert(I18n.ENGLISH.size() == I18n.POLISH.size())
	assert(I18n.missing_keys("tr").is_empty())
	assert(I18n.missing_keys("pl").is_empty())
	assert(I18n.t("game.day", "pl", {"day": 3}) == "Dzień 3")
	assert(I18n.t("menu.settings", "tr") == "Ayarlar")
	assert(I18n.t("menu.settings", "unsupported") == "Options")
	print("SETTINGS_I18N_SMOKE_OK")
	quit()
