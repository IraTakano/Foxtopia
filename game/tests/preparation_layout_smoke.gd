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
	var baseline_setup: Dictionary = main.call("_game_setup_config")
	baseline_setup["point_limit_enabled"] = true
	var budget_model := GameModel.new()
	root.add_child(budget_model)
	assert(budget_model.validate_setup(baseline_setup)["ok"], "The scenario crew must fit its own point budget")
	var roster := main.find_child("PreparationRoster", true, false) as Control
	var appearance := main.find_child("PreparationAppearance", true, false) as Control
	var portrait := main.find_child("PreparationPortrait", true, false) as Control
	var backstory := main.find_child("PreparationBackstory", true, false) as Control
	var traits := main.find_child("PreparationTraitsHealth", true, false) as Control
	var skills := main.find_child("PreparationSkills", true, false) as Control
	assert(roster != null and appearance != null and portrait != null and backstory != null and traits != null and skills != null)
	assert(roster.global_position.x < appearance.global_position.x)
	assert(appearance.global_position.x < backstory.global_position.x)
	assert(backstory.global_position.x < skills.global_position.x)
	assert(traits.global_position.y > backstory.global_position.y)
	assert(skills.get_global_rect().end.x < 1440.0)
	assert(main.find_child("PreparationPointLimitToggle", true, false) != null)
	var world_header := main.find_child("PreparationWorldHeader", true, false) as Button
	var world_section := main.find_child("PreparationWorldSection", true, false) as Control
	assert(world_header != null and world_section != null and not world_section.visible)
	world_header.pressed.emit()
	assert(world_section.visible)
	world_header.pressed.emit()
	assert(not world_section.visible)
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
	# The empty Hat slot has no editable material color. Hair does.
	main.set("_preparation_appearance_category", 1)
	main.call("_show_characters")
	var rgb_sliders := main.find_children("*", "HSlider", true, false)
	assert(rgb_sliders.size() == 3)
	var previous_hair_color := str(edited["hair_color"])
	(rgb_sliders[0] as HSlider).value = 0
	edited = (main.get("character_specs") as Array)[0]
	assert(str(edited["hair_color"]) != previous_hair_color)
	var color_swatch: Button = null
	for candidate in main.find_children("*", "Button", true, false):
		if (candidate as Button).tooltip_text.contains("Edit selected color"):
			color_swatch = candidate as Button
			break
	assert(color_swatch != null)
	color_swatch.pressed.emit()
	var color_dialog := main.find_child("PreparationColorDialog", true, false) as Control
	assert(color_dialog != null)
	var drag_header := color_dialog.get_child(0).get_child(0) as Control
	var start_x := color_dialog.position.x
	var pointer := InputEventMouseButton.new()
	pointer.button_index = MOUSE_BUTTON_LEFT
	pointer.pressed = true
	pointer.global_position = color_dialog.global_position + Vector2(20, 10)
	drag_header.gui_input.emit(pointer)
	var move := InputEventMouseMotion.new()
	move.global_position = pointer.global_position + Vector2(-70, 30)
	drag_header.gui_input.emit(move)
	assert(color_dialog.position.x < start_x, "Color editor should be draggable")
	main.call("_remove_prepared_colonist", 2)
	assert(int(main.get("colonist_count")) == 2)
	assert((main.get("world_character_specs") as Array).size() == 6)
	main.call("_restore_world_colonist", 5)
	assert(int(main.get("colonist_count")) == 3)
	assert((main.get("world_character_specs") as Array).size() == 5)
	main.call("_select_character_editor", 0)
	main.call("_set_starting_gear", "shirt", "none")
	edited = (main.get("character_specs") as Array)[0]
	assert(str(edited["starting_gear"]["shirt"]) == "none")
	assert(str(edited["first_name"]) == "Adelaide")
	main.call("_set_starting_gear", "shirt", "tshirt")
	main.call("_switch_preparation_tab", "relationships")
	assert(main.find_child("PreparationFamilyGraph", true, false) == null)
	var add_bond := main.find_child("PreparationBondPicker_c_0_c_1", true, false) as MenuButton
	assert(add_bond != null and add_bond.get_popup().item_count > 0)
	add_bond.get_popup().id_pressed.emit(0)
	assert(str((main.get("character_specs") as Array)[0]["starting_relationships"].get("1", "")) == "parent")
	assert(main.find_child("PreparationColonyPair_0_1", true, false) != null)
	var unlink_parent := main.find_child("PreparationBondRemove_c_0_c_1", true, false) as Button
	assert(unlink_parent != null)
	unlink_parent.pressed.emit()
	assert(main.call("_preparation_family_relation", 0, 1) == "none")
	var relationship_pickers := main.find_children("PreparationRelationshipPicker*", "MenuButton", true, false)
	assert(relationship_pickers.is_empty())
	main.call("_set_starting_relation", 0, 1, "friend")
	main.call("_show_characters")
	relationship_pickers = main.find_children("PreparationRelationshipPicker*", "MenuButton", true, false)
	assert(relationship_pickers.size() >= 2 and relationship_pickers.size() % 2 == 0)
	for picker in relationship_pickers:
		assert((picker as MenuButton).custom_minimum_size.x >= 100.0)
		assert((picker as MenuButton).get_popup().item_count == 9)
	(relationship_pickers[0] as MenuButton).get_popup().id_pressed.emit(7)
	assert(str((main.get("character_specs") as Array)[0]["starting_relationships"].get("1", "")) == "friend")
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
	for _extra in range(5):
		main.call("_add_prepared_colonist")
	assert(int(main.get("colonist_count")) == 8)
	main.call("_add_prepared_colonist")
	assert(int(main.get("colonist_count")) == 8)
	var expanded_setup: Dictionary = main.call("_game_setup_config")
	expanded_setup["point_limit_enabled"] = false
	assert(bool(model.validate_setup(expanded_setup).get("ok", false)))
	expanded_setup["point_limit_enabled"] = true
	assert(not model.validate_setup(expanded_setup)["ok"], "Point limits must apply to the whole crew and cargo")
	main.call("_switch_preparation_tab", "equipment")
	var cargo_before := int((main.get("starting_cargo") as Dictionary).get("food", 0))
	var food_row := main.find_child("PreparationCatalogRow_food", true, false) as Button
	assert(food_row != null)
	var double_click := InputEventMouseButton.new()
	double_click.button_index = MOUSE_BUTTON_LEFT
	double_click.pressed = true
	double_click.double_click = true
	food_row.gui_input.emit(double_click)
	assert(int((main.get("starting_cargo") as Dictionary).get("food", 0)) == cargo_before + 1)
	print("PREPARATION_LAYOUT_SMOKE_OK")
	quit()
