extends RefCounted
class_name FoxtopiaSettings

## Player preferences live outside save files so they apply to every colony.

const SAVE_PATH := "user://settings.json"
const MODES := ["fullscreen", "borderless", "windowed"]
const LANGUAGES := ["en", "tr", "pl"]
const DEFAULT_KEYBINDS := {
	"pause": KEY_SPACE, "speed_1": KEY_1, "speed_2": KEY_2,
	"speed_3": KEY_3, "draft": KEY_R, "clear_order": KEY_C,
	"pan_up": KEY_W, "pan_down": KEY_S, "pan_left": KEY_A,
	"pan_right": KEY_D, "zoom_in": KEY_PAGEDOWN, "zoom_out": KEY_PAGEUP,
	"tab_orders": KEY_TAB, "tab_work": KEY_F1, "tab_schedule": KEY_F2,
	"tab_health": KEY_F3, "tab_research": KEY_F6, "tab_world": KEY_F8,
	"previous_colonist": KEY_COMMA, "next_colonist": KEY_PERIOD,
	"focus_colonist": KEY_F,
}

var window_mode := "fullscreen"
var display_index := 0
var resolution := Vector2i(1600, 900)
var master_volume := 0.85
var music_volume := 0.70
var effects_volume := 0.85
var language := "en"
var autosave_interval_minutes := 5
var autosave_count := 3
var keybinds: Dictionary = DEFAULT_KEYBINDS.duplicate()


static func resolution_options(screen_index: int = -1) -> Array[Vector2i]:
	# Offer standard sizes that fit the selected display. Add its actual
	# native and usable sizes below so unusual displays are represented.
	var standard: Array[Vector2i] = [
		Vector2i(960, 540), Vector2i(1024, 600), Vector2i(1024, 768),
		Vector2i(1152, 864), Vector2i(1280, 720), Vector2i(1280, 800),
		Vector2i(1280, 960), Vector2i(1280, 1024), Vector2i(1360, 768),
		Vector2i(1366, 768), Vector2i(1440, 900), Vector2i(1536, 864),
		Vector2i(1600, 900), Vector2i(1600, 1200), Vector2i(1680, 1050),
		Vector2i(1920, 1080), Vector2i(1920, 1200), Vector2i(2048, 1152),
		Vector2i(2560, 1080), Vector2i(2560, 1440), Vector2i(2560, 1600),
		Vector2i(3440, 1440), Vector2i(3840, 1600), Vector2i(3840, 2160),
		Vector2i(4096, 2160), Vector2i(5120, 1440), Vector2i(5120, 2160),
		Vector2i(5120, 2880), Vector2i(6016, 3384), Vector2i(6144, 3456),
		Vector2i(7680, 4320),
	]
	if DisplayServer.get_name() == "headless":
		return standard
	var screen := DisplayServer.window_get_current_screen() if screen_index < 0 else _validated_display_index(screen_index, DisplayServer.get_screen_count())
	var native := DisplayServer.screen_get_size(screen)
	var usable := DisplayServer.screen_get_usable_rect(screen).size
	var available: Array[Vector2i] = []
	for size in standard:
		if size.x <= native.x and size.y <= native.y:
			available.append(size)
	if native.x >= 960 and native.y >= 540 and not available.has(native):
		available.append(native)
	if usable.x >= 960 and usable.y >= 540 and not available.has(usable):
		available.append(usable)
	available.sort_custom(func(a: Vector2i, b: Vector2i):
		return a.x * a.y < b.x * b.y if a.x * a.y != b.x * b.y else a.x < b.x)
	return available


static func _validated_display_index(index: int, screen_count: int) -> int:
	return index if index >= 0 and index < screen_count else 0


static func load_settings() -> FoxtopiaSettings:
	var settings := FoxtopiaSettings.new()
	if not FileAccess.file_exists(SAVE_PATH):
		settings.language = _installed_language()
		return settings
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return settings
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		settings._read_dictionary(parsed)
	return settings


static func _installed_language() -> String:
	# Setup writes this next to the launcher. The game executable lives two
	# folders below it, under versions/<version>/.
	if OS.has_feature("editor"):
		return "en"
	var install_root := OS.get_executable_path().get_base_dir().get_base_dir().get_base_dir()
	var config := ConfigFile.new()
	if config.load(install_root.path_join("launcher-language.ini")) != OK:
		return "en"
	match str(config.get_value("Locale", "Language", "english")).to_lower():
		"turkish", "tr": return "tr"
		"polish", "pl": return "pl"
		_: return "en"


func save_settings() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(to_dictionary(), "  "))
	return true


func to_dictionary() -> Dictionary:
	var safe_resolution := _validated_resolution(resolution)
	return {
		"schema": 1,
		"window_mode": _validated_mode(window_mode),
		"display_index": _validated_display_index(display_index, maxi(1, DisplayServer.get_screen_count())),
		"resolution": [safe_resolution.x, safe_resolution.y],
		"master_volume": clampf(master_volume, 0.0, 1.0),
		"music_volume": clampf(music_volume, 0.0, 1.0),
		"effects_volume": clampf(effects_volume, 0.0, 1.0),
		"language": _validated_language(language),
		"autosave_interval_minutes": clampi(autosave_interval_minutes, 0, 60),
		"autosave_count": clampi(autosave_count, 1, 20),
		"keybinds": _validated_keybinds(keybinds),
	}


func apply_settings() -> void:
	window_mode = _validated_mode(window_mode)
	display_index = _validated_display_index(display_index, maxi(1, DisplayServer.get_screen_count()))
	language = _validated_language(language)
	resolution = _validated_resolution(resolution)
	master_volume = clampf(master_volume, 0.0, 1.0)
	music_volume = clampf(music_volume, 0.0, 1.0)
	effects_volume = clampf(effects_volume, 0.0, 1.0)
	autosave_interval_minutes = clampi(autosave_interval_minutes, 0, 60)
	autosave_count = clampi(autosave_count, 1, 20)
	keybinds = _validated_keybinds(keybinds)
	TranslationServer.set_locale(language)
	_apply_audio()
	if DisplayServer.get_name() == "headless":
		return
	var screen := display_index
	# Leave fullscreen before moving; the selected monitor owns the next mode.
	if DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if DisplayServer.window_get_current_screen() != screen:
		DisplayServer.window_set_current_screen(screen)
	var screen_rect := Rect2i(DisplayServer.screen_get_position(screen), DisplayServer.screen_get_size(screen))
	var usable_rect := DisplayServer.screen_get_usable_rect(screen)
	match window_mode:
		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			resolution = Vector2i(mini(resolution.x, screen_rect.size.x), mini(resolution.y, screen_rect.size.y))
			DisplayServer.window_set_size(resolution)
			var bounds := usable_rect if resolution.x <= usable_rect.size.x and resolution.y <= usable_rect.size.y else screen_rect
			DisplayServer.window_set_position(bounds.position + (bounds.size - resolution) / 2)
		"windowed":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			resolution = Vector2i(mini(resolution.x, screen_rect.size.x), mini(resolution.y, screen_rect.size.y))
			DisplayServer.window_set_size(resolution)
			var decorated := DisplayServer.window_get_size_with_decorations()
			DisplayServer.window_set_position(usable_rect.position + Vector2i(maxi(0, (usable_rect.size.x - decorated.x) / 2), maxi(0, (usable_rect.size.y - decorated.y) / 2)))
	var rendered_size := screen_rect.size if window_mode == "fullscreen" else resolution
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		# Small windows need a smaller design canvas so controls remain readable.
		# EXPAND keeps every aspect ratio filled without side bars.
		tree.root.content_scale_size = Vector2i(1280, 720) if rendered_size.x < 1450 or rendered_size.y < 800 else Vector2i(1440, 900)


func _read_dictionary(data: Dictionary) -> void:
	window_mode = _validated_mode(str(data.get("window_mode", window_mode)))
	display_index = _validated_display_index(int(data.get("display_index", display_index)), maxi(1, DisplayServer.get_screen_count()))
	var stored_resolution: Variant = data.get("resolution", [])
	if stored_resolution is Array and stored_resolution.size() == 2:
		resolution = _validated_resolution(Vector2i(int(stored_resolution[0]), int(stored_resolution[1])))
	master_volume = clampf(float(data.get("master_volume", master_volume)), 0.0, 1.0)
	music_volume = clampf(float(data.get("music_volume", music_volume)), 0.0, 1.0)
	effects_volume = clampf(float(data.get("effects_volume", effects_volume)), 0.0, 1.0)
	language = _validated_language(str(data.get("language", language)))
	autosave_interval_minutes = clampi(int(data.get("autosave_interval_minutes", autosave_interval_minutes)), 0, 60)
	autosave_count = clampi(int(data.get("autosave_count", autosave_count)), 1, 20)
	keybinds = _validated_keybinds(data.get("keybinds", {}))


func _validated_keybinds(value: Variant) -> Dictionary:
	var result := DEFAULT_KEYBINDS.duplicate()
	if not value is Dictionary:
		return result
	var used: Dictionary = {}
	for action in DEFAULT_KEYBINDS:
		var code := int(value.get(action, DEFAULT_KEYBINDS[action]))
		if code <= 0 or code in [KEY_ESCAPE, KEY_F11] or used.has(code):
			code = int(DEFAULT_KEYBINDS[action])
			if used.has(code):
				for fallback in DEFAULT_KEYBINDS.values():
					if not used.has(int(fallback)):
						code = int(fallback)
						break
		result[action] = code
		used[code] = true
	return result


func _apply_audio() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("Effects", effects_volume)


func _set_bus_volume(bus_name: String, level: float) -> void:
	var index := AudioServer.get_bus_index(StringName(bus_name))
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, &"Master")
	AudioServer.set_bus_volume_linear(index, maxf(level, 0.0001))
	AudioServer.set_bus_mute(index, level <= 0.0)


func _validated_mode(value: String) -> String:
	return value if MODES.has(value) else "fullscreen"


func _validated_language(value: String) -> String:
	return value if LANGUAGES.has(value) else "en"


func _validated_resolution(value: Vector2i) -> Vector2i:
	return Vector2i(clampi(value.x, 960, 16384), clampi(value.y, 540, 8640))
