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


func _assert_arrows(main: Node, pair_name: String, forward_text: String, reverse_text: String) -> void:
	var pair := main.find_child(pair_name, true, false)
	assert(pair != null, "Relationship pair must be visible")
	for direction in ["Forward", "Reverse"]:
		var picker := pair.find_child("PreparationRelationshipPicker" + direction, true, false) as MenuButton
		assert(picker != null, "%s relationship arrow must be visible" % direction)
		var arrow := picker.get_child(0) as Control
		assert(arrow != null)
		var caption := arrow.get_child(0) as Label
		assert(caption != null)
		assert(caption.text == (forward_text if direction == "Forward" else reverse_text),
			"%s arrow must show its pawn's reciprocal role" % direction)


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
	var people: Array = main.get("character_specs")
	people[0]["sex"] = "female"
	people[1]["sex"] = "female"
	assert(main.call("_set_starting_relation", 0, 1, "parent"))
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationColonyPair_0_1", "Mother", "Daughter")
	await _capture("relationships-mother-daughter-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	(main as Control).size = Vector2(960, 540)
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationColonyPair_0_1", "Mother", "Daughter")
	await _capture("relationships-mother-daughter-960")
	var preferences: Object = main.get("preferences")
	preferences.set("language", "tr")
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationColonyPair_0_1", "Anne", "Kız")
	preferences.set("language", "en")
	assert(main.call("_set_starting_relation", 0, 1, "child"))
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationColonyPair_0_1", "Daughter", "Mother")
	assert(main.call("_set_starting_relation", 0, 1, "grandparent"))
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationColonyPair_0_1", "Grandmother", "Granddaughter")
	assert(main.call("_set_external_relation", "w:0", "c:0", "parent"))
	main.call("_switch_preparation_tab", "relationships")
	_assert_arrows(main, "PreparationFocusedBond_w_0_c_0", "Mother" if str((main.get("world_character_specs") as Array)[0].get("sex", "")) == "female" else "Father", "Daughter")
	print("PREPARATION_RELATIONSHIP_RECIPROCAL_OK")
	quit()
