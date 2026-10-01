extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _find_button(main: Node, hint: String) -> Button:
	for node in main.find_children("*", "Button", true, false):
		var button := node as Button
		if button.tooltip_text.contains(hint):
			return button
	return null


func _capture(name: String) -> void:
	var folder := OS.get_environment("PREPARATION_V019_CAPTURE_DIR")
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
	var old_gear_preview: Dictionary = main.call("_spec_appearance", {"sex": "female", "starting_gear": {"apparel": "none"}})
	assert(str(old_gear_preview["shirt"]) == "tshirt" and str(old_gear_preview["pants"]) == "pants", "Missing legacy clothing slots disagree with visible selectors")
	main.set("_preparation_appearance_category", 6)
	main.call("_show_characters")
	main.call("_set_preparation_apparel", 1)
	var spec: Dictionary = (main.get("character_specs") as Array)[0]
	assert(str((spec["starting_gear"] as Dictionary)["apparel"]) == "jacket")
	await _capture("appearance-v019-coat-1440")
	main.set("_preparation_appearance_category", 2)
	main.call("_show_characters")
	await process_frame
	var swatch := _find_button(main, "Edit selected color")
	var copy := _find_button(main, "Copy this color")
	var paste := _find_button(main, "Paste copied color")
	assert(swatch != null and copy != null and paste != null)
	assert(copy.get_parent() == swatch.get_parent() and paste.get_parent() == swatch.get_parent())
	assert(copy.get_global_rect().end.y < swatch.get_global_rect().position.y)
	assert(copy.get_global_rect().end.x < paste.get_global_rect().position.x)
	await _capture("appearance-v019-color-1440")
	swatch.pressed.emit()
	var dialog := main.find_child("PreparationColorDialog", true, false) as Control
	assert(dialog != null and dialog.visible)
	var selected := dialog.find_child("PreparationSelectedColorLabel", true, false) as Label
	var preview := dialog.find_child("PreparationSelectedColorPreview", true, false) as Control
	assert(selected != null and preview != null)
	swatch.call("set_picked_color", Color("#b48a63"))
	assert(selected.text.contains("#B48A63"))
	var sample := _find_button(main, "Pick a color from the screen")
	assert(sample != null)
	sample.pressed.emit()
	assert(dialog.visible, "Sampling must leave the color wheel open")
	var overlay := main.find_child("PreparationColorSamplingOverlay", true, false) as Control
	assert(overlay != null and overlay.mouse_filter == Control.MOUSE_FILTER_STOP)
	assert(overlay.z_index > dialog.z_index)
	await _capture("appearance-v019-picker-1440")
	var point_toggle := main.find_child("PreparationPointLimitToggle", true, false) as Button
	assert(point_toggle != null)
	var point_limit_before := bool(main.get("point_limit_enabled"))
	var click_position := point_toggle.get_global_rect().get_center()
	var click_down := InputEventMouseButton.new()
	click_down.button_index = MOUSE_BUTTON_LEFT
	click_down.position = click_position
	click_down.pressed = true
	root.push_input(click_down, true)
	var click_up := InputEventMouseButton.new()
	click_up.button_index = MOUSE_BUTTON_LEFT
	click_up.position = click_position
	click_up.pressed = false
	root.push_input(click_up, true)
	await process_frame
	assert(bool(main.get("point_limit_enabled")) == point_limit_before, "Sampling must block underlying buttons")
	assert(main.get("_preparation_sample_target") == null)
	assert(dialog.visible)
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	(main as Control).size = Vector2(960, 540)
	main.call("_show_characters")
	await _capture("appearance-v019-color-960")
	assert((main.call("_hair_options_for_sex", "female") as Array) != (main.call("_hair_options_for_sex", "male") as Array))
	print("PREPARATION_APPEARANCE_V019_OK")
	quit()
