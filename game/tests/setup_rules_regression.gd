extends SceneTree


func _initialize() -> void:
	var hard := GameModel.new()
	root.add_child(hard)
	hard.start_new_game({"seed": "rules-regression", "scenario_id": "hard_landing",
		"storyteller_id": "gentle", "difficulty_id": "peaceful", "colonists_per_faction": 1,
		"faction_specs": [{"site_id": "site_1", "players": [1],
			"starting_cargo": {"wood": 19, "stone": 0, "food": 22, "medicine": 0,
				"silver": 8, "spear": 1, "jacket": 1},
			"colonists": [{"name": "Mara"}]}]})
	assert(hard.state["scenario_id"] == "hard_landing")
	assert(hard.state["colonists_per_faction"] == 1)
	assert(hard.state["colonists"].size() == 1)
	assert(hard.state["factions"][0]["inventory"]["wood"] == 19)
	assert(hard.state["factions"][0]["inventory"]["stone"] == 0)
	var first_id := str(hard.state["colonists"][0]["id"])
	assert(hard.issue_command(1, {"type": "set_schedule", "colonist_id": first_id, "hour": 8, "activity": "sleep"})["ok"])
	assert(not hard.issue_command(1, {"type": "set_schedule", "colonist_id": first_id, "hour": 24, "activity": "sleep"})["ok"])
	hard.tick(1.0)
	assert(hard.state["colonists"][0]["resting"], "Scheduled sleep was ignored")
	assert(hard.issue_command(1, {"type": "direct", "colonist_id": first_id, "action": "move", "x": 28, "y": 25})["ok"])
	hard.tick(1.0)
	assert(not hard.state["colonists"][0]["resting"], "Manual order did not override sleep schedule")
	for second in 298:
		hard.tick(1.0)
	assert(hard.state["raiders"].is_empty(), "Peaceful difficulty spawned raiders")
	var harsh := GameModel.new()
	root.add_child(harsh)
	harsh.start_new_game({"seed": "harsh-regression", "scenario_id": "landfall",
		"storyteller_id": "steady", "difficulty_id": "harsh", "colonists_per_faction": 3})
	assert(harsh.state["factions"][0]["inventory"]["wood"] == 12)
	assert(harsh.call("_event_period", "raid") < 150)
	for second in 100:
		harsh.tick(1.0)
	assert(harsh.state["raiders"].size() >= 2, "Harsh difficulty did not increase raids")
	var homestead := GameModel.new()
	root.add_child(homestead)
	homestead.start_new_game({"seed": "homestead-crew-regression", "scenario_id": "homesteaders"})
	assert(homestead.state["colonists_per_faction"] == 2)
	assert(homestead.state["colonists"].size() == 2)
	var invalid := {"seed": "invalid-choice", "scenario_id": "missing",
		"faction_specs": [{"site_id": "site_1"}]}
	assert(not harsh.validate_setup(invalid)["ok"])
	var edited_crew := {"seed": "editable-crew", "scenario_id": "hard_landing",
		"colonists_per_faction": 2}
	assert(harsh.validate_setup(edited_crew)["ok"])
	var too_many := {"seed": "invalid-crew", "scenario_id": "hard_landing",
		"colonists_per_faction": 4}
	assert(not harsh.validate_setup(too_many)["ok"])
	print("SETUP_RULES_REGRESSION_OK")
	quit()
