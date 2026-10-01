extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture(name: String) -> void:
	var folder := OS.get_environment("PREPARATION_PAWN_CAPTURE_DIR")
	if folder.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(folder)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(name + ".png")) == OK)


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1440, 900))
	root.content_scale_size = Vector2i(1440, 900)
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_advance_to_lobby")
	await process_frame
	var overlay: Control = main.get("_naming_overlay")
	assert(is_instance_valid(overlay))
	var edits := overlay.find_children("*", "LineEdit", true, false)
	(edits[0] as LineEdit).text = "Art Colony"
	(edits[1] as LineEdit).text = "Art Settlement"
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == "Name our home":
			button.pressed.emit()
			break
	assert(main.get("screen") == "game")
	await _capture("pawn-map-restored-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	(main as Control).size = Vector2(960, 540)
	await _capture("pawn-map-restored-960")
	print("PREPARATION_PAWN_MAP_OK")
	quit()
