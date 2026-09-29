extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _find_option(node: Node, first_text: String) -> OptionButton:
	if node is OptionButton and (node as OptionButton).item_count > 0 and (node as OptionButton).get_item_text(0) == first_text:
		return node
	for child in node.get_children():
		var found := _find_option(child, first_text)
		if found != null:
			return found
	return null

func _find_menu(node: Node, caption: String) -> MenuButton:
	if node is MenuButton and ((node as MenuButton).text.contains(caption) or (node as MenuButton).tooltip_text.contains(caption)):
		return node
	for child in node.get_children():
		var found := _find_menu(child, caption)
		if found != null:
			return found
	return null

func _find_remove(node: Node) -> Button:
	if node is Button and (node as Button).tooltip_text == "Remove":
		return node
	for child in node.get_children():
		var found := _find_remove(child)
		if found != null:
			return found
	return null

func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	(input.hair.row.get_child(3) as Button).pressed.emit()
	(input.hair.row.get_child(3) as Button).pressed.emit()
	assert(int((main.get("character_specs") as Array)[0]["hair_index"]) == 2)
	(input.body_type.row.get_child(3) as Button).pressed.emit()
	assert(int((main.get("character_specs") as Array)[0]["body_type"]) == 1)
	(input.childhood.row.get_child(3) as Button).pressed.emit()
	assert(str((main.get("character_specs") as Array)[0]["childhood"]) == "town_child")
	var add_trait := _find_menu(main, "Add trait")
	assert(add_trait != null)
	add_trait.get_popup().id_pressed.emit(3)
	assert((main.get("character_specs") as Array)[0]["trait_ids"].has("quick"))
	var remove := _find_remove(main)
	assert(remove != null)
	remove.pressed.emit()
	assert(not (main.get("character_specs") as Array)[0]["trait_ids"].has("hardworking"))
	input = (main.get("_character_inputs") as Array)[0]
	input.skills.construction.level.call("set_value", 7)
	main.call("_save_character_inputs")
	assert(int((main.get("character_specs") as Array)[0]["skills"]["build"]) == 7)
	main.call("_set_starting_gear", "shirt", "none")
	main.call("_set_starting_gear", "pants", "none")
	assert(str((main.get("character_specs") as Array)[0]["starting_gear"]["shirt"]) == "none")
	main.call("_switch_preparation_tab", "relationships")
	var add_bond := _find_menu(main, "Add relationship")
	assert(add_bond != null)
	add_bond.get_popup().id_pressed.emit(0)
	var bond_picker := _find_menu(main, "Change relationship")
	assert(bond_picker != null)
	bond_picker.get_popup().id_pressed.emit(6)
	assert(str((main.get("character_specs") as Array)[0]["starting_relationships"]["1"]) == "sibling")
	var prepared: Dictionary = main.call("_game_setup_config")
	var model = load("res://scripts/model/game_model.gd").new()
	root.add_child(model)
	assert(bool(model.validate_setup(prepared).get("ok", false)))
	var result: Dictionary = model.start_new_game(prepared)
	assert(result.has("colonists"))
	var pawn: Dictionary = model.state["colonists"][0]
	assert(str(pawn["appearance"]["shirt"]) == "none")
	assert(str(pawn["appearance"]["pants"]) == "none")
	print("FT050_SMOKE_OK")
	quit()
