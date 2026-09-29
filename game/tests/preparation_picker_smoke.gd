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
	assert((input.hair.option as OptionButton).item_count == 4)
	(input.hair.option as OptionButton).select(2)
	(input.hair.option as OptionButton).item_selected.emit(2)
	assert(int((main.get("character_specs") as Array)[0]["hair_index"]) == 2)
	(input.body_type.option as OptionButton).select(1)
	(input.body_type.option as OptionButton).item_selected.emit(1)
	assert(int((main.get("character_specs") as Array)[0]["body_type"]) == 1)
	(input.childhood.option as OptionButton).select(1)
	(input.childhood.option as OptionButton).item_selected.emit(1)
	assert(str((main.get("character_specs") as Array)[0]["childhood"]) == "town_child")
	var add_trait := _find_option(main, "+  Add trait")
	assert(add_trait != null)
	var quick_index := -1
	for i in range(add_trait.item_count):
		if add_trait.get_item_text(i).begins_with("Quick"):
			quick_index = i
	assert(quick_index > 0)
	add_trait.item_selected.emit(quick_index)
	assert((main.get("character_specs") as Array)[0]["trait_ids"].has("quick"))
	var remove := _find_remove(main)
	assert(remove != null)
	remove.pressed.emit()
	assert(not (main.get("character_specs") as Array)[0]["trait_ids"].has("hardworking"))
	input = (main.get("_character_inputs") as Array)[0]
	(input.skills.build.level as SpinBox).value = 7
	main.call("_save_character_inputs")
	assert(int((main.get("character_specs") as Array)[0]["skills"]["build"]) == 7)
	main.call("_set_starting_gear", "shirt", "none")
	main.call("_set_starting_gear", "pants", "none")
	assert(str((main.get("character_specs") as Array)[0]["starting_gear"]["shirt"]) == "none")
	main.call("_switch_preparation_tab", "relationships")
	var bond_picker := _find_option(main, "None")
	assert(bond_picker != null, "The relationships page needs a direct bond picker")
	bond_picker.item_selected.emit(6)
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
