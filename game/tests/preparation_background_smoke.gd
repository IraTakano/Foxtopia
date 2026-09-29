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
	input.childhood["index"] = 2
	input.adulthood["index"] = 3
	main.call("_save_character_inputs")
	var prepared: Dictionary = main.call("_game_setup_config")
	var person: Dictionary = prepared["faction_specs"][0]["colonists"][0]
	assert(person["childhood"] == "apprentice" and person["adulthood"] == "scholar")
	assert(int(person["skills"]["construction"]) == 5)
	input.skills["construction"].level.call("set_value", 8)
	main.call("_save_character_inputs")
	prepared = main.call("_game_setup_config")
	person = prepared["faction_specs"][0]["colonists"][0]
	assert(int(person["skills"]["construction"]) == 8)
	assert(int(person["skills"]["build"]) == 8)
	(input.hair_color as ColorPickerButton).color = Color("#704934")
	main.call("_save_character_inputs")
	prepared = main.call("_game_setup_config")
	person = prepared["faction_specs"][0]["colonists"][0]
	assert(str(person["appearance"]["hair_color"]) == "#704934")
	print("PREPARATION_BACKGROUND_SMOKE_OK")
	quit()
