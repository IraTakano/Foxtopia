extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _first_bond_menu(main: Node) -> MenuButton:
	return main.find_child("PreparationBondPicker_c_0_c_1", true, false) as MenuButton

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
	DisplayServer.window_set_size(Vector2i(1440, 900))
	root.content_scale_size = Vector2i(1440, 900)
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	var people: Array = main.get("character_specs")
	for person in people:
		assert((person as Dictionary).get("starting_relationships", {}).is_empty(), "New colonists must not have preset family roles")
	main.call("_switch_preparation_tab", "relationships")
	assert(main.find_child("PreparationFamilyGraph", true, false) == null)
	assert(main.find_child("PreparationColonyPair_0_1", true, false) != null)
	var bond_menu := _first_bond_menu(main)
	assert(bond_menu != null)
	var ada_name := str(people[0].get("name", ""))
	var baran_name := str(people[1].get("name", ""))
	assert(bond_menu.get_popup().get_item_text(0).contains(ada_name))
	assert(bond_menu.get_popup().get_item_text(0).contains(baran_name))
	assert(bond_menu.get_popup().get_item_text(1).find(baran_name) < bond_menu.get_popup().get_item_text(1).find(ada_name))
	await _capture_if_requested("relationships-neutral-1440")
	bond_menu.get_popup().id_pressed.emit(1)
	assert(main.call("_preparation_family_relation", 0, 1) == "child", "Ada should be selectable as Baran's child")
	assert(main.call("_preparation_family_relation", 0, 2) == "none")
	assert(main.call("_preparation_family_relation", 1, 2) == "none", "Another colonist must not become a spouse")
	people = main.get("character_specs")
	assert(int(people[1]["chronological_age"]) >= int(people[0].get("chronological_age", people[0]["age"])) + 16)
	assert(main.find_child("PreparationRelationshipPickerReverse", true, false) != null)
	await _capture_if_requested("relationships-child-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	main.call("_show_characters")
	await _capture_if_requested("relationships-child-960")
	print("PREPARATION_RELATIONSHIP_DIRECTION_OK")
	quit()
