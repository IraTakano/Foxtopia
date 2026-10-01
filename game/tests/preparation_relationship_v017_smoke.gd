extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture_if_requested(label: String) -> void:
	var capture_dir := OS.get_environment("PREPARATION_RELATIONSHIP_CAPTURE_DIR")
	if capture_dir.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(capture_dir)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.save_png(capture_dir.path_join(label + ".png")) == OK)


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
	main.call("_switch_preparation_tab", "relationships")
	assert(main.find_child("PreparationFamilyGraph", true, false) == null)
	assert(main.find_child("PreparationColonyPair_0_1", true, false) != null)
	var bond_picker := main.find_child("PreparationBondPicker_c_0_c_1", true, false) as MenuButton
	assert(bond_picker != null and bond_picker.get_popup().item_count > 1)
	var people: Array = main.get("character_specs")
	var first_name: String = main.call("_prepared_display_name", people[0])
	var second_name: String = main.call("_prepared_display_name", people[1])
	assert(bond_picker.get_popup().get_item_text(0).contains(first_name))
	assert(bond_picker.get_popup().get_item_text(1).find(second_name) < bond_picker.get_popup().get_item_text(1).find(first_name))
	assert(main.call("_set_starting_relation", 1, 0, "parent"))
	assert(main.call("_set_starting_relation", 2, 0, "parent"))
	assert(main.call("_can_set_starting_relation", 0, 1, "parent"), "Direct parent link must be editable")
	assert(main.call("_set_starting_relation", 1, 2, "partner"))
	assert(not main.call("_can_set_starting_relation", 0, 2, "partner"), "A child cannot marry a parent")
	main.call("_add_prepared_colonist")
	assert(main.call("_set_starting_relation", 0, 3, "parent"))
	assert(not main.call("_can_set_starting_relation", 3, 1, "parent"), "Indirect parent cycle must be blocked")
	assert(main.call("_set_starting_relation", 0, 3, "none"))
	assert(main.call("_set_starting_relation", 3, 0, "grandparent"))
	assert(main.call("_preparation_family_relation", 0, 3) == "grandchild")
	assert(main.call("_can_set_starting_relation", 0, 3, "parent"), "Direct grandparent link must be editable")
	var model := GameModel.new()
	root.add_child(model)
	var setup: Dictionary = main.call("_game_setup_config")
	setup["point_limit_enabled"] = false
	var setup_validation: Dictionary = model.validate_setup(setup)
	assert(bool(setup_validation.get("ok", false)), "Grandparent and spouse selections must survive game validation")
	model.start_new_game(setup)
	var actual_people: Array = model.state["colonists"]
	var grandchild_id := str(actual_people[0]["id"])
	var grandparent_id := str(actual_people[3]["id"])
	assert(str(actual_people[3]["relationship_types"].get(grandchild_id, "")) == "grandparent")
	assert(str(actual_people[0]["relationship_types"].get(grandparent_id, "")) == "grandchild")
	main.call("_switch_preparation_tab", "relationships")
	assert(main.find_child("PreparationColonyPair_0_3", true, false) != null, "Every colony pair must be shown")
	assert(main.find_child("PreparationBondRemove_c_1_c_2", true, false) != null, "Spouse link belongs in Colony Relationships")
	assert(main.find_child("PreparationOtherRelations", true, false) != null)
	await _capture_if_requested("relationships-v017-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	main.call("_switch_preparation_tab", "relationships")
	await _capture_if_requested("relationships-v017-960")
	assert(main.call("_set_starting_relation", 3, 0, "none"))
	assert(not main.call("_can_set_starting_relation", 3, 0, "parent"), "A child may have at most two parents")
	main.call("_switch_preparation_tab", "relationships")
	var parent_remove := main.find_child("PreparationBondRemove_c_0_c_1", true, false) as Button
	assert(parent_remove != null)
	parent_remove.pressed.emit()
	assert(main.call("_preparation_family_relation", 1, 0) == "none", "A parent must be removable from the bond list")
	assert(main.call("_preparation_family_relation", 1, 2) == "partner", "Removing one relation should retain others")
	print("PREPARATION_RELATIONSHIP_V017_OK")
	quit()
