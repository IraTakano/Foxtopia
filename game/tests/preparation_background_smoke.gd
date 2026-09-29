extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	var input: Dictionary = (main.get("_character_inputs") as Array)[0]
	input.childhood["index"] = 2 # Apprentice
	input.adulthood["index"] = 3 # Scholar
	main.call("_save_character_inputs")
	var specs: Array = main.get("character_specs")
	assert((specs[0] as Dictionary).get("skills", {}) == {}, "Untouched skills must stay automatic")
	var prepared: Dictionary = main.call("_game_setup_config")
	var person: Dictionary = prepared["faction_specs"][0]["colonists"][0]
	assert(person["skills"] == {})
	var prepared_model := GameModel.new()
	root.add_child(prepared_model)
	prepared_model.start_new_game(prepared)
	var prepared_person: Dictionary = prepared_model.state["colonists"][0]
	var baseline: Dictionary = prepared.duplicate(true)
	baseline["faction_specs"][0]["colonists"][0]["childhood"] = "town_child"
	baseline["faction_specs"][0]["colonists"][0]["adulthood"] = "farmer"
	var baseline_model := GameModel.new()
	root.add_child(baseline_model)
	baseline_model.start_new_game(baseline)
	var baseline_person: Dictionary = baseline_model.state["colonists"][0]
	assert(int(prepared_person["skills"]["build"]) == int(baseline_person["skills"]["build"]) + 1)
	assert(int(prepared_person["skills"]["research"]) == int(baseline_person["skills"]["research"]) + 2)
	input.skills["build"]["index"] = 8 # Explicit level 7; 0 is automatic.
	main.call("_save_character_inputs")
	specs = main.get("character_specs")
	assert((specs[0] as Dictionary)["skills"] == {"build": 7}, "Only a chosen skill should override background aptitude")
	input.skills["build"]["index"] = 0
	main.call("_save_character_inputs")
	specs = main.get("character_specs")
	assert((specs[0] as Dictionary)["skills"] == {}, "Auto must restore the background aptitude")
	var hair_choices: Array = input.palettes[0]["buttons"]
	(hair_choices[2] as Button).pressed.emit()
	specs = main.get("character_specs")
	assert(int((specs[0] as Dictionary)["hair_color_index"]) == 2, "Palette selection must update appearance")
	print("PREPARATION_BACKGROUND_SMOKE_OK")
	quit()
