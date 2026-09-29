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
	var inputs: Array = main.get("_character_inputs")
	var first: Dictionary = inputs[0]
	(first["name"] as LineEdit).text = "Mara"
	first["age"].call("set_value", 34)
	main.call("_save_character_inputs")
	main.call("_set_starting_gear", "weapon", "spear")
	main.call("_set_starting_relation", 0, 1, "friend")
	main.call("_switch_preparation_tab", "relationships")
	main.call("_switch_preparation_tab", "equipment")
	var cargo: Dictionary = main.get("starting_cargo")
	cargo["wood"] = 37
	main.set("starting_cargo", cargo)
	main.call("_save_preparation_preset")
	var specs: Array = main.get("character_specs")
	(specs[0] as Dictionary)["name"] = "Changed"
	main.set("character_specs", specs)
	cargo["wood"] = 1
	main.set("starting_cargo", cargo)
	main.call("_load_preparation_preset")
	specs = main.get("character_specs")
	assert(str(specs[0]["name"]) == "Mara")
	assert(int((main.get("starting_cargo") as Dictionary).get("wood", 0)) == 37)
	main.call("_advance_to_lobby")
	await process_frame
	assert(main.get("screen") == "game")
	var data: Dictionary = main.call("_snapshot")
	var people: Array = data.get("colonists", [])
	assert(people.size() >= 3)
	var pawn: Dictionary = people[0]
	assert(str(pawn.get("name", "")) == "Mara")
	assert(int(pawn.get("age", 0)) == 34)
	assert(str(pawn.get("equipment", {}).get("weapon", "")) == "spear")
	assert(str(pawn.get("relationship_types", {}).get(str(people[1].get("id", "")), "")) == "friend")
	assert(int((main.call("_local_resources", data) as Dictionary).get("wood", 0)) == 37)
	print("PREPARATION_UI_SMOKE_OK")
	quit()
