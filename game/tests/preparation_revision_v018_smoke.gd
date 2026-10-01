extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture_if_requested(file_name: String) -> void:
	var capture_dir := OS.get_environment("PREPARATION_V018_CAPTURE_DIR")
	if capture_dir.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(capture_dir.path_join(file_name)) == OK)


func _find_button(main: Node, hint: String) -> Button:
	for button in main.find_children("*", "Button", true, false):
		if (button as Button).tooltip_text.contains(hint):
			return button as Button
	return null


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
	main.call("_show_characters")
	await process_frame
	await _capture_if_requested("preparation-v018-1440.png")
	main.call("_switch_preparation_tab", "equipment")
	await _capture_if_requested("equipment-v018-1440.png")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	(main as Control).size = Vector2(960, 540)
	main.call("_show_characters")
	await process_frame
	var frame := main.find_child("PreparationFrame", true, false) as Control
	assert(frame != null)
	assert(frame.get_global_rect().position.x >= 0.0)
	assert(frame.get_global_rect().position.y >= 0.0)
	assert(frame.get_global_rect().end.x <= 960.0)
	assert(frame.get_global_rect().end.y <= 540.0)
	await _capture_if_requested("equipment-v018-960.png")
	main.call("_switch_preparation_tab", "characters")
	await _capture_if_requested("preparation-v018-960.png")
	DisplayServer.window_set_size(Vector2i(1440, 900))
	root.content_scale_size = Vector2i(1440, 900)
	(main as Control).size = Vector2(1440, 900)
	main.call("_show_characters")
	await process_frame
	var toggle := main.find_child("PreparationPointLimitToggle", true, false) as Button
	var tabs := main.find_child("PreparationTabs", true, false) as Control
	assert(toggle != null and tabs != null)
	assert(toggle.get_global_rect().end.y <= tabs.get_global_rect().position.y + 2.0,
		"The point-limit hit target must not be covered by the tabs")
	var bottom_hit := toggle.get_global_rect().end - Vector2(5, 3)
	var click_down := InputEventMouseButton.new()
	click_down.button_index = MOUSE_BUTTON_LEFT
	click_down.position = bottom_hit
	click_down.pressed = true
	root.push_input(click_down, true)
	var click_up := InputEventMouseButton.new()
	click_up.button_index = MOUSE_BUTTON_LEFT
	click_up.position = bottom_hit
	click_up.pressed = false
	root.push_input(click_up, true)
	await process_frame
	assert(not bool(main.get("point_limit_enabled")), "Bottom of point-limit toggle must be clickable")
	main.set("point_limit_enabled", true)
	main.call("_show_characters")

	var digits := RegEx.new()
	assert(digits.compile("[0-9]") == OK)
	var seen := {}
	for index in range(160):
		var nickname := str(main.call("_pick_prepared_nickname", "Ada", false))
		assert(not seen.has(nickname))
		assert(digits.search(nickname) == null)
		seen[nickname] = true

	var model := GameModel.new()
	root.add_child(model)
	var budget := model.preparation_budget("landfall")
	var differing_ages := 0
	for index in range(24):
		main.call("_randomize_prepared_colonist")
		var spec: Dictionary = (main.get("character_specs") as Array)[0]
		if int(spec["chronological_age"]) != int(spec["age"]):
			differing_ages += 1
		assert(int(spec["chronological_age"]) >= int(spec["age"]))
		assert(int(main.call("_preparation_spent_for_specs", main.get("character_specs"))) <= budget)
	assert(differing_ages >= 12)
	for index in range(8):
		main.call("_randomize_preparation_skills")
		assert(int(main.call("_preparation_spent_for_specs", main.get("character_specs"))) <= budget)
	for kind in ["backstory", "traits", "health"]:
		for index in range(5):
			main.call("_randomize_preparation_choices", kind)
			assert(int(main.call("_preparation_spent_for_specs", main.get("character_specs"))) <= budget)

	assert((main.call("_preparation_condition_names") as Array).size() == 8)
	main.set("_preparation_appearance_category", 2)
	main.call("_show_characters")
	await process_frame
	var first_swatch := _find_button(main, "Edit selected color")
	assert(first_swatch != null)
	first_swatch.call("set_picked_color", Color("#a97861"))
	assert(str((main.get("character_specs") as Array)[0]["skin_color"]) == "#a97861")
	assert(bool((main.get("character_specs") as Array)[0]["skin_color_custom"]))
	var copy_button := _find_button(main, "Copy this color")
	assert(copy_button != null)
	copy_button.pressed.emit()
	main.call("_select_character_editor", 1)
	await process_frame
	var second_swatch := _find_button(main, "Edit selected color")
	assert(second_swatch != null)
	var second_color := str((main.get("character_specs") as Array)[1]["skin_color"])
	assert((second_swatch.get("color") as Color).to_html(false) == Color(second_color).to_html(false))
	var paste_button := _find_button(main, "Paste copied color")
	assert(paste_button != null)
	paste_button.pressed.emit()
	assert(str((main.get("character_specs") as Array)[1]["skin_color"]) == "#a97861")
	main.call("_select_character_editor", 0)
	await process_frame
	first_swatch = _find_button(main, "Edit selected color")
	assert((first_swatch.get("color") as Color).to_html(false) == "a97861")
	first_swatch.pressed.emit()
	var sampler := _find_button(main, "Pick a color from the screen")
	assert(sampler != null)
	sampler.pressed.emit()
	assert((main.get_node("PreparationColorDialog") as Control).visible)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	main.call("_input", escape)
	assert(main.get("_preparation_sample_target") == null)
	assert((main.get_node("PreparationColorDialog") as Control).visible)

	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	var level: Control = input.skills["shooting"]["level"]
	var track: Control = level.get("track")
	assert(track != null)
	var track_click := InputEventMouseButton.new()
	track_click.button_index = MOUSE_BUTTON_LEFT
	track_click.pressed = true
	track_click.position = Vector2(track.size.x * 0.75, track.size.y * 0.5)
	track.call("_gui_input", track_click)
	assert(int(input.skills["shooting"]["index"]) == 15)

	print("PREPARATION_REVISION_V018_OK")
	quit()
