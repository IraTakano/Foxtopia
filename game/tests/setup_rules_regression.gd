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
		"colonists_per_faction": 9}
	assert(not harsh.validate_setup(too_many)["ok"])
	var expanded_crew := GameModel.new()
	root.add_child(expanded_crew)
	var expanded_people: Array = []
	for i in range(8):
		expanded_people.append({"name": "Person %d" % i})
	expanded_people[0]["traits"] = ["pyromaniac", "fast_walker", "ugly"]
	expanded_people[0]["childhood"] = "vatgrown_soldier"
	expanded_people[0]["starting_relationships"] = {"7": "friend"}
	var reference_cargo := {"silver": 800, "medicine": 30, "wood": 300,
		"stone": 450, "food": 44, "spear": 1, "jacket": 1, "tshirt": 1, "pants": 1}
	var fake_cargo := {"seed": "invalid-cargo", "scenario_id": "landfall",
		"faction_specs": [{"site_id": "site_1", "starting_cargo": {"pistol": 1}}]}
	assert(not expanded_crew.validate_setup(fake_cargo)["ok"], "Items absent from Foxtopia must not be available as starting cargo")
	var expanded_start := expanded_crew.start_new_game({"seed": "expanded-crew", "scenario_id": "landfall",
		"colonists_per_faction": 8, "faction_specs": [{"site_id": "site_1", "players": [1],
			"colonist_count": 8, "starting_cargo": reference_cargo,
			"colonists": expanded_people}]})
	assert(not expanded_start.has("error"), "Eight colonists should be valid")
	assert(expanded_crew.state["colonists"].size() == 8)
	assert(expanded_crew.state["colonists"][0]["childhood"] == "vatgrown_soldier")
	assert(expanded_crew.state["colonists"][0]["traits"].has("ugly"))
	assert(expanded_crew.state["colonists"][0]["relationship_types"].get("colonist_1_8") == "friend")
	for item_id in reference_cargo:
		assert(int(expanded_crew.state["factions"][0]["inventory"].get(item_id, -1)) == int(reference_cargo[item_id]),
			"New game discarded %s" % item_id)
	var restored_crew := GameModel.new()
	root.add_child(restored_crew)
	assert(restored_crew.load_game(expanded_crew.serialize_game()))
	assert(restored_crew.state["colonists"].size() == 8)
	assert(restored_crew.state["colonists"][0]["childhood"] == "vatgrown_soldier")
	assert(restored_crew.state["colonists"][0]["traits"] == ["pyromaniac", "fast_walker", "ugly"])
	assert(restored_crew.state["colonists"][0]["relationship_types"].get("colonist_1_8") == "friend")
	for item_id in reference_cargo:
		assert(int(restored_crew.state["factions"][0]["inventory"].get(item_id, -1)) == int(reference_cargo[item_id]),
			"Save/load discarded %s" % item_id)
	var restored_people: Array = restored_crew.state["colonists"]
	for i in range(6):
		restored_people[i]["x"] = i * 8
		restored_people[i]["y"] = 0
	restored_people[6]["x"] = 24
	restored_people[6]["y"] = 24
	restored_people[7]["x"] = 25
	restored_people[7]["y"] = 24
	restored_crew.state["time"] = 30
	restored_crew.call("_tick_social")
	assert(int(restored_people[6]["relationships"].get(str(restored_people[7]["id"]), 0)) > 0,
		"Expanded crew members must be able to socialize")
	print("SETUP_RULES_REGRESSION_OK")
	quit()
