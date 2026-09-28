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
	assert(root.content_scale_aspect == Window.CONTENT_SCALE_ASPECT_EXPAND)
	settings.window_mode = "borderless"
	settings.resolution = Vector2i(1280, 720)
	settings.apply_settings()
	await process_frame
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
	settings.window_mode = "windowed"
	settings.resolution = Vector2i(1024, 768)
	settings.apply_settings()
	await process_frame
	assert(not DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
	assert(DisplayServer.window_get_size() == Vector2i(1024, 768))
	assert(root.get_texture().get_image().get_size() == DisplayServer.window_get_size())
	print("DISPLAY_MODES_SMOKE_OK")
	quit()
