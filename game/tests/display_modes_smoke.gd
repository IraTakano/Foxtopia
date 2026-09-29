extends SceneTree

const SettingsScript = preload("res://scripts/ui/settings.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Run this test with a visible Windows display.")
		quit(1)
		return
	var settings := SettingsScript.new()
	settings.display_index = maxi(0, DisplayServer.get_screen_count() - 1)
	var selected_screen := settings.display_index
	var offered_resolutions := SettingsScript.resolution_options(selected_screen)
	var native_resolution := DisplayServer.screen_get_size(selected_screen)
	var usable_resolution := DisplayServer.screen_get_usable_rect(selected_screen).size
	assert(offered_resolutions.has(native_resolution))
	if usable_resolution.x >= 960 and usable_resolution.y >= 540:
		assert(offered_resolutions.has(usable_resolution))
	for offered in offered_resolutions:
		assert(offered.x <= native_resolution.x and offered.y <= native_resolution.y)
	assert(root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_EXPAND)
	settings.window_mode = "borderless"
	settings.resolution = Vector2i(1280, 720)
	settings.apply_settings()
	await process_frame
	assert(DisplayServer.window_get_current_screen() == selected_screen)
	var restored := SettingsScript.new()
	restored._read_dictionary(settings.to_dictionary())
	assert(restored.display_index == selected_screen)
	assert(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	assert(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
	assert(DisplayServer.window_get_size() == Vector2i(1280, 720))
	assert(root.get_texture().get_image().get_size() == DisplayServer.window_get_size())
	var screen_size := DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	if screen_size.x >= 1920 and screen_size.y >= 1080:
		settings.resolution = Vector2i(1920, 1080)
		settings.apply_settings()
		await process_frame
		assert(DisplayServer.window_get_size() == Vector2i(1920, 1080))
		assert(root.get_texture().get_image().get_size() == DisplayServer.window_get_size())
	settings.window_mode = "fullscreen"
	settings.apply_settings()
	await process_frame
	assert(DisplayServer.window_get_current_screen() == selected_screen)
	assert(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	assert(DisplayServer.window_get_size() == screen_size)
	settings.window_mode = "windowed"
	settings.resolution = Vector2i(1024, 768)
	settings.apply_settings()
	await process_frame
	var expected_window := Vector2i(mini(1024, screen_size.x), mini(768, screen_size.y))
	assert(not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
	assert(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED)
	assert(DisplayServer.window_get_current_screen() == selected_screen)
	assert(settings.resolution == expected_window)
	assert(DisplayServer.window_get_size() == expected_window)
	assert(root.get_texture().get_image().get_size() == DisplayServer.window_get_size())
	settings.display_index = DisplayServer.get_screen_count() + 10
	settings.apply_settings()
	assert(settings.display_index == 0)
	assert(DisplayServer.window_get_current_screen() == 0)
	print("DISPLAY_MODES_SMOKE_OK")
	quit()
