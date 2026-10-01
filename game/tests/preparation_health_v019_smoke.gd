extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")


func _initialize() -> void:
	var safe := {"health_injuries": [
		{"kind": "cut_deep", "body_part": "right_leg", "count": 1},
		{"kind": "bruise", "body_part": "left_arm", "count": 2}]}
	assert(PreparationRules.preparation_injury_error(safe).is_empty())
	assert(PreparationRules.prepared_injuries(safe).size() == 3)
	assert(PreparationRules.prepared_injuries(safe)[1]["body_part"] == "left_arm")
	assert(PreparationRules.injury_capacity_factors({"wounds": PreparationRules.prepared_injuries(safe)})["moving"] < 1.0)
	assert(PreparationRules.injury_capacity_factors({"wounds": PreparationRules.prepared_injuries(safe)})["manipulation"] < 1.0)
	assert(PreparationRules.injury_work_factor({"wounds": PreparationRules.prepared_injuries(safe)}, "haul") < PreparationRules.injury_work_factor({"wounds": PreparationRules.prepared_injuries(safe)}, "research"))

	assert(not PreparationRules.preparation_injury_error({"health_injuries": [{"kind": "cut_light", "body_part": "head", "count": 4}]}).is_empty())
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [{"kind": "cut_deep", "body_part": "head", "count": 1}]}).is_empty())
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [
		{"kind": "cut_light", "body_part": "left_arm", "count": 3},
		{"kind": "bruise", "body_part": "right_arm", "count": 3},
		{"kind": "burn", "body_part": "torso", "count": 1}]}).is_empty())
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [
		{"kind": "cut_deep", "body_part": "left_arm", "count": 1},
		{"kind": "cut_deep", "body_part": "right_arm", "count": 1},
		{"kind": "cut_light", "body_part": "torso", "count": 1}]}).is_empty())
	assert(not PreparationRules.preparation_injury_error({"health_conditions": ["scar"], "health_injuries": [
		{"kind": "burn", "body_part": "left_arm", "count": 1},
		{"kind": "burn", "body_part": "right_arm", "count": 1},
		{"kind": "cut_deep", "body_part": "torso", "count": 1},
		{"kind": "bruise", "body_part": "head", "count": 1}]}).is_empty())

	var model := GameModel.new()
	root.add_child(model)
	assert(model.preparation_points({"health_injuries": [{"kind": "bruise", "body_part": "left_leg", "count": 1}]}) > model.preparation_points({"health_injuries": [{"kind": "cut_light", "body_part": "left_leg", "count": 1}]}))
	assert(model.preparation_points({"health_injuries": [{"kind": "cut_light", "body_part": "left_leg", "count": 1}]}) > model.preparation_points({"health_injuries": [{"kind": "cut_deep", "body_part": "left_leg", "count": 1}]}))
	var setup := {"seed": "preparation-health-v019", "scenario_id": "homesteaders",
		"colonists_per_faction": 2, "point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "colonist_count": 2,
			"colonists": [
				{"name": "New", "age": 30, "health_injuries": safe["health_injuries"]},
				{"name": "Legacy", "age": 31, "health_conditions": ["cut_light"]}]}]}
	assert(model.validate_setup(setup)["ok"])
	var unsafe_setup: Dictionary = setup.duplicate(true)
	unsafe_setup["faction_specs"][0]["colonists"][0]["health_injuries"] = [{"kind": "cut_deep", "body_part": "head", "count": 1}]
	assert(not model.validate_setup(unsafe_setup)["ok"], "Unsafe preparation must not start a game")
	model.start_new_game(setup)
	var current: Dictionary = model.state["colonists"][0]
	var legacy: Dictionary = model.state["colonists"][1]
	assert(current["health"]["wounds"].size() == 3)
	assert(is_equal_approx(float(current["health"]["hp"]), 72.0))
	assert(is_equal_approx(float(current["health"]["pain"]), 0.35))
	assert((current["health"]["wounds"] as Array)[0]["body_part"] == "right_leg")
	assert((legacy["health"]["wounds"] as Array)[0]["body_part"] == "left_arm")
	assert((legacy["health"]["wounds"] as Array)[0]["source_condition"] == "cut_light")
	model.tick(1.0)
	var summary: Array = current["health"]["wound_summary"]
	assert(summary.any(func(entry: Variant): return str(entry["body_part"]) == "left_arm" and str(entry["kind"]) == "bruise" and int(entry["count"]) == 2))
	assert(float(current["health"]["pain"]) < 0.35)
	print("PREPARATION_HEALTH_V019_OK")
	quit()
