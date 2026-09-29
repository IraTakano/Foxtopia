extends SceneTree


func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var world: Dictionary = model.preview_world("naming-social")
	var site_id := ""
	for site in world.get("sites", []):
		if str(site.get("kind", "")) == "vacant":
			site_id = str(site.get("id", ""))
			break
	assert(not site_id.is_empty())
	var setup := {"seed": "naming-social", "mode": "solo", "scenario_id": "homesteaders",
		"point_limit_enabled": false, "faction_specs": [{"site_id": site_id, "players": [1],
			"colonists": [{"name": "Ari"}, {"name": "Bea"}]}]}
	assert(bool(model.validate_setup(setup).get("ok", false)))
	model.start_new_game(setup)
	var people: Array = model.state["colonists"]
	var faction: Dictionary = model.state["factions"][0]
	for step in 60:
		people[0]["x"] = 0
		people[0]["y"] = 0
		people[1]["x"] = 49
		people[1]["y"] = 49
		model.tick(1.0)
	assert(not bool(faction.get("name_prompted", false)), "Distant colonists must not name the colony without a social interaction")
	for step in 30:
		people[0]["x"] = 24
		people[0]["y"] = 24
		people[1]["x"] = 25
		people[1]["y"] = 24
		model.tick(1.0)
	assert(bool(faction.get("name_prompted", false)), "Nearby colonists must name their colony after talking")
	print("NAMING_SOCIAL_REGRESSION_OK")
	quit()
