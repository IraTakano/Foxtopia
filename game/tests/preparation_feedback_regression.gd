extends SceneTree

const PreparationNamePool = preload("res://scripts/ui/preparation_name_pool.gd")
const PreparationPawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")
const PreparationRules = preload("res://scripts/model/preparation_rules.gd")
const CLASSIC_SKILLS := ["shooting", "melee", "social", "animals", "medical", "cooking", "construction", "plants", "mining", "artistic", "crafting", "intellectual"]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	assert(PreparationNamePool.FEMALE_NAMES.split(",").size() >= 6000)
	assert(PreparationNamePool.MALE_NAMES.split(",").size() >= 6000)
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	var seen := {}
	for index in range(1000):
		var identity: Dictionary = main.call("_pick_prepared_name", "female")
		var first := str(identity["first"]).to_lower()
		assert(not seen.has(first), "Name picker repeated a first name before exhausting the pool")
		assert(str(identity["nick"]).to_lower() != first, "Nickname must be a separate generated field")
		assert(str(identity["last"]).to_lower() != first)
		seen[first] = true
	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	var childhood_menu := input.childhood.row.get_child(2).get_child(0) as Button
	childhood_menu.pressed.emit()
	var choice_dialog := main.find_child("PreparationOptionDialog", true, false)
	assert(choice_dialog != null)
	var filter_menu := choice_dialog.find_child("PreparationChoiceFilter", true, false) as MenuButton
	var details := choice_dialog.find_child("PreparationChoiceDetails", true, false) as Label
	assert(filter_menu != null and filter_menu.get_popup().item_count > 4)
	assert(details.text.contains("Growing") and details.text.contains("+1"))
	filter_menu.get_popup().id_pressed.emit(3)
	var filter_chip_found := false
	for candidate in choice_dialog.find_children("*", "Label", true, false):
		if (candidate as Label).text.contains("Shooting +"):
			filter_chip_found = true
	assert(filter_chip_found)
	choice_dialog.queue_free()
	main.set("_preparation_appearance_category", 4)
	main.call("_show_characters")
	main.call("_set_preparation_clothing", 2)
	var spec: Dictionary = (main.get("character_specs") as Array)[0]
	assert(spec["starting_gear"]["apparel"] == "none")
	assert(spec["starting_gear"]["shirt"] == "none" and spec["starting_gear"]["pants"] == "none")
	var bare: Dictionary = main.call("_spec_appearance", spec)
	var bare_svg: String = PreparationPawnArt._pawn_svg(bare)
	assert(PreparationPawnArt._texture(bare_svg) != null)
	main.call("_set_preparation_clothing", 1)
	spec = (main.get("character_specs") as Array)[0]
	var jacket: Dictionary = main.call("_spec_appearance", spec)
	assert(PreparationPawnArt._texture(PreparationPawnArt._pawn_svg(jacket)) != null)
	assert(bare_svg != PreparationPawnArt._pawn_svg(jacket))
	main.set("_preparation_appearance_category", 6)
	main.call("_show_characters")
	var swatch: Button = null
	for candidate in main.find_children("*", "Button", true, false):
		if (candidate as Button).tooltip_text.contains("Edit selected color"):
			swatch = candidate as Button
			break
	assert(swatch != null)
	swatch.pressed.emit()
	var wheel := main.find_child("PreparationColorWheel", true, false)
	assert(wheel != null and (wheel as Control).custom_minimum_size.x < 230)
	wheel.emit_signal("color_changed", Color("#56a4c1"))
	spec = (main.get("character_specs") as Array)[0]
	assert(spec["starting_gear"]["apparel_color"] == "#56a4c1")
	var roster_portrait: Node = (main.get("_roster_buttons") as Array)[0].get_node("RosterPortrait")
	assert(str(roster_portrait.get("appearance")["apparel_color"]) == "#56a4c1")
	assert(PreparationPawnArt._texture(PreparationPawnArt._pawn_svg(roster_portrait.get("appearance"))) != null)
	main.call("_reset_preparation_skills")
	spec = (main.get("character_specs") as Array)[0]
	for skill in CLASSIC_SKILLS:
		assert(int(spec["skills"].get(skill, -1)) == 0, "Skill reset must clear the editable base level")
	var modifiers: Dictionary = PreparationRules.skill_modifiers(str(spec["childhood"]), str(spec["adulthood"]), spec["trait_ids"], spec["condition_ids"])
	var reset_input: Dictionary = (main.get("_character_inputs") as Array)[0]
	for skill in CLASSIC_SKILLS:
		assert(int(reset_input.skills[skill]["index"]) == maxi(0, int(modifiers.get(skill, 0))))
	main.call("_switch_preparation_tab", "relationships")
	assert(main.call("_can_set_starting_relation", 0, 2, "parent"))
	assert(main.call("_set_starting_relation", 0, 2, "parent"))
	assert(main.call("_set_starting_relation", 1, 2, "parent"))
	var people: Array = main.get("character_specs")
	assert(int(people[0]["chronological_age"]) >= int(people[2].get("chronological_age", people[2]["age"])) + 16)
	assert(main.call("_preparation_family_relation", 0, 2) == "parent")
	assert(main.call("_preparation_family_relation", 1, 2) == "parent")
	main.call("_show_characters")
	assert(main.find_child("PreparationFamilyGraph", true, false) == null)
	assert(main.find_child("PreparationRelationshipPickerForward", true, false) != null, "Both parent links must be shown as editable arrows")
	assert(main.find_child("PreparationColonyPair_0_2", true, false) != null)
	assert(main.find_child("PreparationColonyPair_1_2", true, false) != null)
	var prepared: Dictionary = main.call("_game_setup_config")
	var model := GameModel.new()
	root.add_child(model)
	assert(bool(model.validate_setup(prepared).get("ok", false)))
	print("PREPARATION_FEEDBACK_REGRESSION_OK")
	quit()
