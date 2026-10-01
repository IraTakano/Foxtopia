extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture(label: String) -> void:
	var folder := OS.get_environment("PREPARATION_RELATIONSHIP_CAPTURE_DIR")
	if folder.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(folder)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(label + ".png")) == OK)


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
	assert(main.find_child("PreparationFamilyGraph", true, false) == null, "The duplicate family graph must be gone")
	assert(main.find_child("PreparationColonyPairGrid", true, false) != null)
	assert(main.find_child("PreparationColonyPair_0_1", true, false) != null)
	assert(main.find_child("PreparationColonyPair_0_2", true, false) != null)
	assert(main.find_child("PreparationColonyPair_1_2", true, false) != null)
	assert(main.find_child("PreparationWorldSource", true, false) != null)
	assert(main.find_child("PreparationWorldTarget", true, false) != null)
	var first_picker := main.find_child("PreparationBondPicker_c_0_c_1", true, false) as MenuButton
	assert(first_picker != null)
	assert(main.find_child("PreparationRelationshipPickerForward", true, false) == null)
	await _capture("relationships-v019-neutral-1440")
	first_picker.get_popup().id_pressed.emit(1) # First colonist is the second colonist's child.
	assert(main.call("_preparation_family_relation", 0, 1) == "child")
	assert(main.call("_preparation_family_relation", 1, 2) == "none", "A child link must not create an unrelated marriage")
	assert(main.call("_preparation_family_relation", 0, 2) == "none")
	assert(main.find_child("PreparationRelationshipPickerReverse", true, false) != null)
	assert(main.find_child("PreparationBondPicker_c_0_c_2", true, false) != null)
	assert(main.call("_set_starting_relation", 0, 1, "parent"), "The selected bond must be directly editable")
	assert(main.call("_preparation_family_relation", 0, 1) == "parent")
	assert(main.call("_set_starting_relation", 0, 1, "child"))
	assert(main.call("_set_starting_relation", 2, 0, "parent"))
	assert(main.call("_set_starting_relation", 1, 2, "partner"))
	assert(main.call("_set_external_relation", "w:0", "c:0", "grandparent"))
	assert(main.call("_set_external_relation", "w:1", "w:2", "friend"))
	assert(main.call("_preparation_relation_between", "c:0", "w:0") == "grandchild")
	assert(not main.call("_can_set_preparation_relation", "w:1", "c:0", "parent"), "Third parent must be blocked")
	main.call("_switch_preparation_tab", "relationships")
	assert(main.find_child("PreparationColonyPair_1_2", true, false) != null)
	assert(main.find_child("PreparationWorldBond_2", true, false) != null)
	await _capture("relationships-v019-linked-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	await process_frame
	(main as Control).size = Vector2(960, 540)
	main.call("_switch_preparation_tab", "relationships")
	var frame := main.find_child("PreparationFrame", true, false) as Control
	await _capture("relationships-v019-linked-960")
	assert(frame != null)
	assert(frame.get_global_rect().position.x >= 0.0)
	assert(frame.get_global_rect().position.y >= 0.0)
	assert(frame.get_global_rect().end.x <= 960.0)
	assert(frame.get_global_rect().end.y <= 540.0)
	var model := GameModel.new()
	root.add_child(model)
	var setup: Dictionary = main.call("_game_setup_config")
	setup["point_limit_enabled"] = false
	assert(bool(model.validate_setup(setup).get("ok", false)), "Colony and world bonds must validate")
	model.start_new_game(setup)
	var colonists: Array = model.state["colonists"]
	var world_people: Array = model.state["world_people"]
	assert(str(colonists[0]["relationship_types"].get(str(world_people[0]["id"]), "")) == "grandchild")
	assert(str(world_people[0]["relationship_types"].get(str(colonists[0]["id"]), "")) == "grandparent")
	assert(str(world_people[1]["relationship_types"].get(str(world_people[2]["id"]), "")) == "friend")
	var world_remove := main.find_child("PreparationBondRemove_w_1_w_2", true, false) as Button
	assert(world_remove != null, "World relationship must have a remove button")
	world_remove.pressed.emit()
	assert(main.call("_preparation_relation_between", "w:1", "w:2") == "none")
	assert(main.call("_preparation_relation_between", "w:0", "c:0") == "grandparent", "Removing one world bond must preserve another")
	var colony_remove := main.find_child("PreparationBondRemove_c_0_c_1", true, false) as Button
	assert(colony_remove != null, "Each colony pair must have a remove button")
	colony_remove.pressed.emit()
	assert(main.call("_preparation_family_relation", 0, 1) == "none")
	assert(main.call("_preparation_family_relation", 0, 2) == "child", "Removing one colony bond must preserve another")
	assert(main.call("_preparation_family_relation", 1, 2) == "partner", "Removing a parent link must not remove an unrelated partner")
	main.call("_remove_prepared_colonist", 2)
	assert(main.call("_preparation_relation_between", "w:5", "c:1") == "partner", "Moving to World must preserve bonds")
	main.call("_restore_world_colonist", 5)
	assert(main.call("_preparation_family_relation", 1, 2) == "partner", "Restoring from World must restore colony bond")
	for bond in main.get("external_relationships"):
		assert(not (str(bond["from"]).begins_with("c:") and str(bond["to"]).begins_with("c:")))
	print("PREPARATION_RELATIONSHIP_V019_OK")
	quit()
