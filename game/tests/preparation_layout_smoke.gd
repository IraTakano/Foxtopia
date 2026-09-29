extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

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
	await process_frame
	var roster := main.find_child("PreparationRoster", true, false) as Control
	var appearance := main.find_child("PreparationAppearance", true, false) as Control
	var apparel := main.find_child("PreparationApparel", true, false) as Control
	var backstory := main.find_child("PreparationBackstory", true, false) as Control
	var traits := main.find_child("PreparationTraitsHealth", true, false) as Control
	var skills := main.find_child("PreparationSkills", true, false) as Control
	assert(roster != null and appearance != null and apparel != null and backstory != null and traits != null and skills != null)
	assert(roster.global_position.x < appearance.global_position.x)
	assert(appearance.global_position.x < backstory.global_position.x)
	assert(backstory.global_position.x < skills.global_position.x)
	assert(traits.global_position.y > backstory.global_position.y)
	assert(skills.get_global_rect().end.x < 1440.0)
	assert(main.find_child("PreparationPointLimitToggle", true, false) != null)
	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	(input.first_name as LineEdit).text = "Adelaide"
	(input.name as LineEdit).text = "Ada"
	(input.last_name as LineEdit).text = "River"
	input.chronological_age.call("set_value", 45)
	var build: Dictionary = input.skills["construction"]
	build.level.call("set_value", 8)
	(build.passion_button as Button).pressed.emit()
	assert(int(build["index"]) == 8)
	main.call("_save_character_inputs")
	var edited: Dictionary = (main.get("character_specs") as Array)[0]
	assert(str(edited["first_name"]) == "Adelaide" and str(edited["last_name"]) == "River")
	assert(int(edited["passions"]["construction"]) == 1)
	assert(int(edited["skills"]["build"]) == 8)
	main.call("_remove_prepared_colonist", 2)
	assert(int(main.get("colonist_count")) == 2)
	assert((main.get("world_character_specs") as Array).size() == 1)
	main.call("_restore_world_colonist", 0)
	assert(int(main.get("colonist_count")) == 3)
	main.call("_select_character_editor", 0)
	main.call("_set_starting_gear", "shirt", "none")
	edited = (main.get("character_specs") as Array)[0]
	assert(str(edited["starting_gear"]["shirt"]) == "none")
	assert(str(edited["first_name"]) == "Adelaide")
	main.call("_set_starting_gear", "shirt", "tshirt")
	main.call("_switch_preparation_tab", "relationships")
	var graph := main.find_child("PreparationFamilyGraph", true, false)
	assert(graph != null)
	var add_bond: MenuButton = null
	for button in graph.find_children("*", "MenuButton", true, false):
		if (button as MenuButton).tooltip_text.contains("Add bond"):
			add_bond = button as MenuButton
			break
	assert(add_bond != null and add_bond.get_popup().item_count > 0)
	add_bond.get_popup().id_pressed.emit(0)
	assert(str((main.get("character_specs") as Array)[0]["starting_relationships"].get("1", "")) == "parent")
	graph = main.find_child("PreparationFamilyGraph", true, false)
	var has_confirmed_link := false
	for edge in graph.get("edges"):
		if bool(edge["active"]):
			has_confirmed_link = true
	assert(has_confirmed_link)
	main.call("_set_starting_gear", "apparel", "jacket")
	main.call("_set_starting_gear", "hat", "brim_hat")
	var specs: Array = main.get("character_specs")
	var spec: Dictionary = specs[0]
	var gear: Dictionary = spec["starting_gear"]
	gear["apparel_color"] = "#9d6b51"
	spec["starting_gear"] = gear
	specs[0] = spec
	main.set("character_specs", specs)
	var prepared: Dictionary = main.call("_game_setup_config")
	var model = load("res://scripts/model/game_model.gd").new()
	root.add_child(model)
	assert(bool(model.validate_setup(prepared).get("ok", false)))
	model.start_new_game(prepared)
	var pawn: Dictionary = model.state["colonists"][0]
	assert(str(pawn["appearance"]["apparel"]) == "jacket")
	assert(str(pawn["appearance"]["hat"]) == "brim_hat")
	assert(str(pawn["equipment"]["hat"]) == "brim_hat")
	assert(str(pawn["appearance"]["apparel_color"]) == "#9d6b51")
	assert(str(pawn["first_name"]) == "Adelaide" and str(pawn["last_name"]) == "River")
	assert(int(pawn["passions"]["construction"]) == 1)
	assert(int(pawn["skills"]["construction"]) == 8)
	assert(int(pawn["skills"]["build"]) == 8)
	assert(int(pawn["chronological_age"]) == 45)
	print("PREPARATION_LAYOUT_SMOKE_OK")
	quit()
