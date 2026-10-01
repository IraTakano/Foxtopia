extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")
const PreparationPresetStore = preload("res://scripts/ui/preparation_preset_store.gd")
const PreparationPawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")


func _initialize() -> void:
	assert(PreparationRules.BACKSTORY_SKILLS.has("unknown"))
	assert(PreparationRules.skill_modifiers("unknown", "unknown", [], []).is_empty())
	assert(PreparationRules.incapable_of("unknown", "unknown", [], []).is_empty())
	assert(int(PreparationRules.effective_skills({"shooting": 0}, "unknown", "unknown", [], [])["shooting"]) == 0)
	var kind_effects := PreparationRules.trait_effects("kind")
	assert(int(kind_effects["kind_words_mood"]) == 5)
	assert(int(kind_effects["kind_words_opinion"]) == 15)
	assert(is_equal_approx(PreparationRules.health_pain({"wounds": [{"kind": "cut", "severity": 4.0}], "conditions": []}), 0.05))
	assert(PreparationRules.pain_mood_penalty(0.05) == -5)
	assert(PreparationRules.pain_mood_penalty(0.20) == -10)
	var base := {}
	for skill in GameModel.CLASSIC_SKILL_IDS:
		base[skill] = 5
	var traits := ["hardworking", "curious", "pyromaniac", "ugly", "kind"]
	var conditions := ["asthma", "bad_back", "scar"]
	var modified := PreparationRules.effective_skills(base, "vatgrown_soldier", "scholar", traits, conditions)
	assert(int(modified["shooting"]) == 7)
	assert(int(modified["construction"]) == 5)
	assert(int(modified["intellectual"]) == 7)
	assert(int(modified["social"]) == 5)
	var disabled := PreparationRules.incapable_of("vatgrown_soldier", "scholar", traits, conditions)
	assert(disabled.has("social") and disabled.has("medical") and disabled.has("haul") and disabled.has("firefighting"))
	var model := GameModel.new()
	root.add_child(model)
	var prepared := {"name": "Rule Test", "age": 25, "chronological_age": 35,
		"childhood": "vatgrown_soldier", "adulthood": "scholar", "sex": "female",
		"traits": traits, "health_conditions": conditions, "skills": base,
		"starting_gear": {"hat": "brim_hat", "hat_color": "#ff0066"}}
	var config := {"seed": "preparation-rules", "scenario_id": "hard_landing", "colonists_per_faction": 1,
		"point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "players": [1], "colonist_count": 1, "colonists": [prepared]}]}
	assert(model.validate_setup(config)["ok"])
	model.start_new_game(config)
	assert(model.state["colonists"].size() == 1)
	var person: Dictionary = model.state["colonists"][0]
	assert(int(person["skills"]["shooting"]) == 7)
	assert(int(person["skills"]["build"]) == 5)
	assert(int(person["work_priorities"]["haul"]) == 0 and int(person["work_priorities"]["treat"]) == 0)
	assert(not model.issue_command(1, {"type": "set_work_priority", "colonist_id": person["id"], "work": "haul", "priority": 5})["ok"])
	assert(str(person["appearance"]["hat_color"]) == "#ff0066")
	var family_people := [
		{"name": "Mother", "sex": "female", "age": 50, "starting_relationships": {"2": "parent"}},
		{"name": "Father", "sex": "male", "age": 48, "starting_relationships": {"2": "parent"}},
		{"name": "Child", "sex": "female", "age": 20}]
	var family_setup := {"seed": "family-rules", "scenario_id": "landfall", "colonists_per_faction": 3,
		"point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "colonist_count": 3, "colonists": family_people}]}
	assert(model.validate_setup(family_setup)["ok"])
	family_people[1]["sex"] = "female"
	assert(not model.validate_setup(family_setup)["ok"], "The same child cannot be assigned two mothers")
	family_people[1]["sex"] = "male"
	family_people[2]["age"] = 40
	assert(not model.validate_setup(family_setup)["ok"], "Parents must be old enough")
	var base_visual := {"sex": "female", "body_type": 0, "head_type": 0, "hair": "bob", "hat": "brim_hat", "hat_color": "#ff0066"}
	var other_visual := base_visual.duplicate(true)
	other_visual["sex"] = "male"
	other_visual["body_type"] = 1
	other_visual["head_type"] = 1
	assert(PreparationPawnArt._pawn_svg(base_visual) != PreparationPawnArt._pawn_svg(other_visual))
	var recolored_hat := base_visual.duplicate(true)
	recolored_hat["hat_color"] = "#00ff66"
	assert(PreparationPawnArt._pawn_svg(base_visual) != PreparationPawnArt._pawn_svg(recolored_hat))
	var nonce := str(Time.get_ticks_msec())
	var first_slot := "rule_test_a_" + nonce
	var second_slot := "rule_test_b_" + nonce
	assert(PreparationPresetStore.save_slot("character", first_slot, {"name": "Alpha"}))
	assert(PreparationPresetStore.save_slot("character", second_slot, {"name": "Beta"}))
	assert(str(PreparationPresetStore.load_slot("character", first_slot).get("data", {}).get("name", "")) == "Alpha")
	assert(str(PreparationPresetStore.load_slot("character", second_slot).get("data", {}).get("name", "")) == "Beta")
	assert(PreparationPresetStore.save_slot("character", first_slot, {"name": "Updated"}))
	assert(str(PreparationPresetStore.load_slot("character", first_slot).get("data", {}).get("name", "")) == "Updated")
	assert(PreparationPresetStore.delete_slot("character", first_slot))
	assert(PreparationPresetStore.delete_slot("character", second_slot))
	print("PREPARATION_RULES_REGRESSION_OK")
	quit()
