extends SceneTree


func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var world := model.preview_world("regression-world")
	var matching := 0
	var comparisons := 0
	var water_tiles := 0
	for y in range(int(world["height"])):
		for x in range(int(world["width"]) - 1):
			var index: int = y * int(world["width"]) + x
			if world["tiles"][index] == "water": water_tiles += 1
			if world["tiles"][index] == world["tiles"][index + 1]: matching += 1
			comparisons += 1
	assert(float(matching) / float(comparisons) > 0.72, "World terrain lacks coherent regions")
	assert(float(water_tiles) / float(comparisons) > 0.08, "World generation needs lakes or seas")
	var free_tile := ""
	for y in range(int(world["height"])):
		for x in range(int(world["width"])):
			if world["tiles"][y * int(world["width"]) + x] == "water": continue
			var occupied := false
			for site in world["sites"]:
				if int(site["x"]) == x and int(site["y"]) == y: occupied = true; break
			if not occupied:
				free_tile = "tile_%d_%d" % [x, y]
				break
		if not free_tile.is_empty(): break
	assert(not free_tile.is_empty())
	var expensive_skills := {}
	for skill in GameModel.CLASSIC_SKILL_IDS:
		expensive_skills[skill] = 20
	var invalid := {"seed": "regression-world", "scenario_id": "hard_landing", "point_limit_enabled": true,
		"faction_specs": [{"site_id": free_tile,
		"colonists": [{"traits": ["hardworking", "calm", "quick"], "skills": expensive_skills}]}]}
	assert(not model.validate_setup(invalid)["ok"], "Point limit was not enforced")
	invalid["point_limit_enabled"] = false
	assert(model.validate_setup(invalid)["ok"], "Point limit toggle did not work")
	assert(model.preparation_points({"traits": ["curious"], "skills": {"combat": 8}}) > model.preparation_points({}),
		"Skill increases were not charged to preparation points")
	assert(model.preparation_points({"starting_gear": {"weapon": "spear", "apparel": "jacket"}}) > model.preparation_points({}),
		"Starting gear was not charged to preparation points")
	var prepare_spec := {"seed": "regression-world", "mode": "solo", "scenario_id": "homesteaders", "colonists_per_faction": 2,
		"point_limit_enabled": false, "faction_specs": [{"site_id": free_tile, "players": [1],
			"colonists": [{"name": "Alex", "age": 42, "childhood": "apprentice",
				"adulthood": "scholar", "starting_gear": {"weapon": "spear", "apparel": "jacket"},
				"starting_relationships": {"1": "partner"}}, {"name": "Bea"}]}]}
	assert(model.validate_setup(prepare_spec)["ok"])
	var prepare_model := GameModel.new()
	root.add_child(prepare_model)
	prepare_model.start_new_game(prepare_spec)
	var prepared_first: Dictionary = prepare_model.state["colonists"][0]
	var prepared_second: Dictionary = prepare_model.state["colonists"][1]
	assert(prepared_first["age"] == 42 and prepared_first["childhood"] == "apprentice")
	assert(prepared_first["adulthood"] == "scholar")
	assert(prepared_first["equipment"] == {"weapon": "spear", "apparel": "jacket"})
	var baseline_spec: Dictionary = prepare_spec.duplicate(true)
	baseline_spec["faction_specs"][0]["colonists"][0]["childhood"] = "town_child"
	baseline_spec["faction_specs"][0]["colonists"][0]["adulthood"] = "farmer"
	var baseline_model := GameModel.new()
	root.add_child(baseline_model)
	baseline_model.start_new_game(baseline_spec)
	var baseline_first: Dictionary = baseline_model.state["colonists"][0]
	assert(int(prepared_first["skills"]["build"]) == int(baseline_first["skills"]["build"]) + 1)
	assert(int(prepared_first["skills"]["research"]) == int(baseline_first["skills"]["research"]) + 2)
	assert(prepared_first["relationships"][prepared_second["id"]] == 65)
	assert(prepared_second["relationships"][prepared_first["id"]] == 65)
	assert(prepared_second["relationship_types"][prepared_first["id"]] == "partner")
	var prepared_loaded := GameModel.new()
	root.add_child(prepared_loaded)
	assert(prepared_loaded.load_game(prepare_model.serialize_game()))
	assert(prepared_loaded.state["colonists"][0]["equipment"]["weapon"] == "spear")
	assert(prepared_loaded.state["colonists"][0]["relationship_types"][prepared_second["id"]] == "partner")
	prepare_spec["faction_specs"][0]["colonists"][0]["age"] = 17
	assert(not model.validate_setup(prepare_spec)["ok"], "Underage prepared colonist was accepted")
	prepare_spec["faction_specs"][0]["colonists"][0]["age"] = 42
	prepare_spec["faction_specs"][0]["colonists"][0]["starting_gear"]["weapon"] = "rifle"
	assert(not model.validate_setup(prepare_spec)["ok"], "Invalid gear was accepted")
	prepare_spec["faction_specs"][0]["colonists"][0]["starting_gear"]["weapon"] = "spear"
	prepare_spec["faction_specs"][0]["colonists"][1]["starting_relationships"] = {"0": "rival"}
	assert(not model.validate_setup(prepare_spec)["ok"], "Conflicting starting relationships were accepted")
	var setup := {"seed": "regression-world", "mode": "competitive", "scenario_id": "hard_landing", "colonists_per_faction": 1,
		"faction_specs": [{"site_id": free_tile, "players": [1],
			"colonists": [{"name": "Alex", "sex": "male", "gender": "nonbinary",
				"health_conditions": ["scar"], "traits": ["kind", "timid"]}]}]}
	var started := model.start_new_game(setup)
	assert(not started.is_empty() and model.state["maps"].has(free_tile), "Arbitrary land tile was rejected")
	var person: Dictionary = model.state["colonists"][0]
	assert(person["sex"] == "male" and person["gender"] == "nonbinary")
	assert((person["health"]["conditions"] as Array).has("scar"))
	person["health"]["wounds"] = [{"kind": "cut", "severity": 3.0}, {"kind": "cut", "severity": 8.0}]
	model.tick(1.0)
	assert((person["health"]["wound_summary"] as Array)[0]["count"] == 2)
	assert((person["health"]["wound_summary"] as Array)[0]["severity_label"] == "moderate")
	var map_data: Dictionary = model.state["maps"][free_tile]
	assert((map_data.get("zones", []) as Array).size() == 1)
	var filter_result := model.issue_command(1, {"type": "set_zone_filter", "zone_id": "zone_1",
		"accepts": ["wood"]})
	assert(filter_result["ok"])
	var stone_drop := {"id": "test_stone", "kind": "stone", "amount": 4, "x": 23, "y": 25}
	map_data["drops"].append(stone_drop)
	assert(not model.issue_command(1, {"type": "direct", "colonist_id": person["id"],
		"action": "haul", "target_id": stone_drop["id"]})["ok"], "Zone filter ignored")
	assert(model.issue_command(1, {"type": "set_zone_filter", "zone_id": "zone_1",
		"accepts": ["wood", "stone"]})["ok"])
	var original_stone := int(model.state["factions"][0]["inventory"]["stone"])
	assert(model.issue_command(1, {"type": "direct", "colonist_id": person["id"],
		"action": "haul", "target_id": stone_drop["id"]})["ok"])
	model.tick(1.0)
	assert(not (person.get("carrying", {}) as Dictionary).is_empty(), "Item was not picked up")
	assert(int(model.state["factions"][0]["inventory"]["stone"]) == original_stone,
		"Item entered inventory before reaching stockpile")
	for i in range(12): model.tick(1.0)
	assert((person.get("carrying", {}) as Dictionary).is_empty())
	assert(int(model.state["factions"][0]["inventory"]["stone"]) == original_stone + 4)
	var late_spec := {"site_id": "site_2", "colonists": [{"name": "Visitor"}]}
	var joined := model.add_late_player(23, late_spec)
	assert(joined["ok"], str(joined))
	assert((model.get_snapshot(23)["maps"] as Dictionary).size() == 1)
	assert(model.issue_command(23, {"type": "set_work_priority", "colonist_id": "colonist_2_1",
		"work": "build", "priority": 1})["ok"])
	model.remove_player(23)
	assert(not model.issue_command(23, {"type": "set_work_priority", "colonist_id": "colonist_2_1",
		"work": "build", "priority": 1})["ok"])
	var save_id := "regression_%d" % Time.get_ticks_usec()
	assert(model.save_game(save_id))
	var found_save := false
	for save in model.list_saved_games():
		if save["id"] == save_id: found_save = true
	assert(found_save, "Saved game did not appear in slot list")
	var reloaded := GameModel.new()
	root.add_child(reloaded)
	assert(reloaded.load_game(save_id))
	assert(reloaded.state["maps"].has(free_tile))
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://saves/%s.json" % save_id))
	var raid_model := GameModel.new()
	root.add_child(raid_model)
	raid_model.start_new_game({"seed": "raid-regression", "mode": "solo", "scenario_id": "hard_landing", "colonists_per_faction": 1})
	for i in range(150): raid_model.tick(1.0)
	assert(not raid_model.state["raiders"].is_empty())
	var raider: Dictionary = raid_model.state["raiders"][0]
	assert(raider["phase"] == "preparing")
	var spawn := Vector2i(int(raider["x"]), int(raider["y"]))
	assert(spawn.x in [0, 49] or spawn.y in [0, 49], "Raid did not enter from map edge")
	for i in range(5): raid_model.tick(1.0)
	assert(Vector2i(int(raider["x"]), int(raider["y"])) == spawn, "Raider moved before preparation ended")
	for i in range(16): raid_model.tick(1.0)
	assert(raider["phase"] == "attacking", "Raider failed to leave preparation phase")
	var coop := GameModel.new()
	root.add_child(coop)
	coop.start_new_game({"seed": "coop-regression", "mode": "coop", "scenario_id": "hard_landing", "colonists_per_faction": 1})
	assert(coop.add_late_player(45)["ok"])
	assert(coop.issue_command(45, {"type": "set_work_priority", "colonist_id": "colonist_1_1",
		"work": "chop", "priority": 2})["ok"])
	print("MODEL_REGRESSION_OK")
	quit()
