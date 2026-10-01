extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")


func _initialize() -> void:
	for condition_id in ["cut_light", "cut_deep", "bruise", "burn"]:
		assert(GameModel.HEALTH_CONDITION_COSTS.has(condition_id))
		assert(not PreparationRules.condition_injury(condition_id).is_empty())
	assert(is_equal_approx(PreparationRules.wound_pain(PreparationRules.condition_injury("cut_light")), 0.05))
	assert(is_equal_approx(PreparationRules.wound_pain(PreparationRules.condition_injury("cut_deep")), 0.20))
	assert(is_equal_approx(PreparationRules.wound_pain(PreparationRules.condition_injury("bruise")), 0.075))
	assert(is_equal_approx(PreparationRules.wound_pain(PreparationRules.condition_injury("burn")), 0.15))
	assert(PreparationRules.pain_mood_penalty(0.05) == -5)
	assert(PreparationRules.pain_mood_penalty(0.20) == -10)
	assert(PreparationRules.pain_work_factor(0.20) < PreparationRules.pain_work_factor(0.05))
	assert(PreparationRules.TRAIT_SKILLS.is_empty(), "Traits must not add arbitrary training levels")
	assert(PreparationRules.CONDITION_SKILLS.is_empty(), "Injuries must not change training levels")

	var model := GameModel.new()
	root.add_child(model)
	var setup := {"seed": "preparation-health-v018", "scenario_id": "homesteaders",
		"colonists_per_faction": 2, "point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "colonist_count": 2,
			"colonists": [
				{"name": "Light", "age": 30, "health_conditions": ["cut_light"]},
				{"name": "Deep", "age": 31, "health_conditions": ["cut_deep"]}]}]}
	assert(model.validate_setup(setup)["ok"])
	model.start_new_game(setup)
	var light: Dictionary = model.state["colonists"][0]
	var deep: Dictionary = model.state["colonists"][1]
	assert(is_equal_approx(float(light["health"]["hp"]), 96.0))
	assert(is_equal_approx(float(deep["health"]["hp"]), 84.0))
	assert(is_equal_approx(float(light["health"]["pain"]), 0.05))
	assert(is_equal_approx(float(deep["health"]["pain"]), 0.20))
	assert(float(deep["health"]["bleeding"]) > float(light["health"]["bleeding"]))
	model.tick(1.0)
	assert(float(light["health"]["pain"]) < 0.05)
	assert(float(deep["health"]["pain"]) < 0.20)
	assert((deep["health"]["wound_summary"] as Array)[0]["severity_label"] == "severe")

	var social_model := GameModel.new()
	root.add_child(social_model)
	var social_setup := {"seed": "preparation-social-v018", "scenario_id": "landfall",
		"colonists_per_faction": 3, "point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "colonist_count": 3,
			"colonists": [
				{"name": "Kind", "age": 30, "traits": ["kind"]},
				{"name": "Ugly", "age": 30, "traits": ["ugly"]},
				{"name": "Other", "age": 30, "traits": ["night_owl"]}]}]}
	assert(social_model.validate_setup(social_setup)["ok"])
	social_model.start_new_game(social_setup)
	var kind: Dictionary = social_model.state["colonists"][0]
	var ugly: Dictionary = social_model.state["colonists"][1]
	var other: Dictionary = social_model.state["colonists"][2]
	for tick_time in [30, 60, 90]:
		social_model.state["time"] = tick_time
		social_model._tick_social()
	assert(int(kind["relationships"][str(ugly["id"])]) > 0, "Kind must ignore beauty penalty")
	assert(int(other["relationships"][str(ugly["id"])]) < 0, "Ugly applies a one-time opinion penalty")
	var before_words: int = int(ugly["relationships"].get(str(kind["id"]), 0))
	social_model.state["time"] = 180
	social_model._tick_social()
	assert(int(ugly["relationships"][str(kind["id"])]) >= before_words + 15)
	assert((ugly["needs"]["thoughts"] as Array).any(func(thought: Variant): return str(thought.get("label", "")).begins_with("Kind words")))
	social_model.state["time"] = 100
	social_model._update_mood(other)
	assert((other["needs"]["thoughts"] as Array).any(func(thought: Variant): return str(thought.get("label", "")) == "Night owl in daylight" and int(thought.get("value", 0)) == -10))
	social_model.state["time"] = 400
	social_model._update_mood(other)
	assert((other["needs"]["thoughts"] as Array).any(func(thought: Variant): return str(thought.get("label", "")) == "Night owl at night" and int(thought.get("value", 0)) == 16))
	print("PREPARATION_HEALTH_TRAITS_V018_OK")
	quit()
