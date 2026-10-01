extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture_if_requested(file_name: String) -> void:
	var capture_dir := OS.get_environment("PREPARATION_REVISION_CAPTURE_DIR")
	if capture_dir.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(capture_dir.path_join(file_name)) == OK)


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
	await _capture_if_requested("preparation-v017-1440.png")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	main.call("_show_characters")
	await _capture_if_requested("preparation-v017-960.png")
	var model := GameModel.new()
	root.add_child(model)
	var initial_setup: Dictionary = main.call("_game_setup_config")
	var initial_faction: Dictionary = initial_setup["faction_specs"][0]
	var initial_remaining := model.preparation_budget("landfall") - model.preparation_total_points(initial_faction["colonists"], initial_faction["starting_cargo"])
	assert(initial_remaining > 0 and initial_remaining < 600, "The default crew should leave a modest usable point allowance")
	print("PREPARATION_DEFAULT_POINTS_REMAINING=%d" % initial_remaining)
	var first_spec: Dictionary = (main.get("character_specs") as Array)[0]
	assert(str(first_spec["nickname"]) != str(first_spec["first_name"]))
	for attempt in range(30):
		var identity: Dictionary = main.call("_pick_prepared_name", "female")
		assert(str(identity["nick"]) != str(identity["first"]))
		assert(not str(identity["nick"]).is_empty())

	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	(input.first_name as LineEdit).text = "Adeline"
	(input.name as LineEdit).text = ""
	main.call("_refresh_character_editor")
	first_spec = (main.get("character_specs") as Array)[0]
	assert(str(first_spec["nickname"]).is_empty())
	assert(str(first_spec["name"]) == "Adeline")
	assert(str(((main.get("_roster_buttons") as Array)[0] as Button).get_node("RosterName").text) == "Adeline")
	var setup: Dictionary = main.call("_game_setup_config")
	assert(str(setup["faction_specs"][0]["colonists"][0]["name"]) == "Adeline")

	(input.first_name as LineEdit).grab_focus()
	var blank_click := InputEventMouseButton.new()
	blank_click.button_index = MOUSE_BUTTON_LEFT
	blank_click.pressed = true
	blank_click.position = Vector2.ZERO
	main.call("_input", blank_click)
	assert((input.first_name as LineEdit) != root.gui_get_focus_owner())

	var specs: Array = main.get("character_specs")
	specs[0]["childhood"] = "unknown"
	specs[0]["adulthood"] = "unknown"
	specs[0]["trait_ids"] = []
	specs[0]["condition_ids"] = []
	main.set("character_specs", specs)
	main.call("_show_characters")
	input = (main.get("_character_inputs") as Array)[0]
	assert(int(input.childhood["index"]) == 4 and int(input.adulthood["index"]) == 4)
	var childhood_menu := input.childhood.row.get_child(2).get_child(0) as Button
	childhood_menu.mouse_entered.emit()
	var hover := main.get_node_or_null("PreparationEntryHover") as PanelContainer
	assert(hover != null)
	assert(str(hover.get_node("PreparationEntryHoverText").text).contains("no skill or work effects"))
	childhood_menu.mouse_exited.emit()
	assert(main.get_node_or_null("PreparationEntryHover") == null)
	childhood_menu.pressed.emit()
	assert(main.get_node_or_null("PreparationOptionDialog") != null)
	main.get_node("PreparationOptionDialog").queue_free()
	await process_frame

	main.set("_preparation_appearance_category", 2)
	main.call("_show_characters")
	assert(main.find_children("*", "HSlider", true, false).size() == 3)
	var swatch: Button = null
	for button in main.find_children("*", "Button", true, false):
		if (button as Button).tooltip_text.contains("Edit selected color"):
			swatch = button as Button
			break
	assert(swatch != null)
	swatch.pressed.emit()
	var wheel := main.find_child("PreparationColorWheel", true, false)
	assert(wheel != null)
	wheel.emit_signal("color_changed", Color("#a97861"))
	first_spec = (main.get("character_specs") as Array)[0]
	assert(str(first_spec["skin_color"]) == "#a97861")

	setup = main.call("_game_setup_config")
	assert(bool(model.validate_setup(setup).get("ok", false)))
	assert(model.preparation_budget("landfall") < 3500)
	var zero := model.preparation_points({"skills": {"combat": 0}})
	var five := model.preparation_points({"skills": {"combat": 5}})
	var ten := model.preparation_points({"skills": {"combat": 10}})
	assert(ten - zero > 2 * (five - zero))
	assert(model.preparation_points({"traits": ["lazy", "timid", "ugly"], "health_conditions": ["asthma", "bad_back", "scar"]}) >= 180)
	print("PREPARATION_REVISION_V017_OK")
	quit()
