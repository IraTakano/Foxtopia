extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var net := root.get_node("/root/Net")
	var spec := {"name": "Remote colony", "site_id": "site_1", "colonist_count": 1,
		"colonists": [{"name": "Ari", "age": 25, "chronological_age": 25}],
		"world_characters": [
			{"name": "Mara", "first_name": "Mara", "sex": "female", "age": 50,
				"chronological_age": 50, "appearance": {"hair": "long", "body_type": 1,
					"untrusted_field": "discard"}, "untrusted_field": "discard"},
			"malformed person",
			{"name": "Tomas", "sex": "male", "age": 28}],
		"external_relationships": [
			{"from": "w:0", "to": "c:0", "relation": "parent", "untrusted_field": "discard"},
			{"from": "w:0", "to": "w:2", "relation": "friend"},
			{"from": "w:1", "to": "c:0", "relation": "friend"},
			{"from": "w:2", "to": "c:0", "relation": "invalid"}]}
	var cleaned: Dictionary = net.call("_clean_setup", spec)
	assert(cleaned["world_characters"].size() == 2)
	assert(cleaned["external_relationships"] == [
		{"from": "w:0", "to": "c:0", "relation": "parent"},
		{"from": "w:0", "to": "w:1", "relation": "friend"}],
		"Remote bonds must retain their endpoints after invalid world entries are removed")
	assert(not cleaned["world_characters"][0].has("untrusted_field"))
	assert(not cleaned["world_characters"][0]["appearance"].has("untrusted_field"))
	assert(net.call("_clean_setup", cleaned) == cleaned, "Client and host sanitization must be idempotent")
	var legacy: Dictionary = net.call("_clean_setup", {"colonists": [{"name": "Old pawn"}]})
	assert(legacy["world_characters"].is_empty() and legacy["external_relationships"].is_empty(),
		"Older setup payloads must still be accepted")
	var model := GameModel.new()
	root.add_child(model)
	var config := {"seed": "network-world-relationships", "scenario_id": "hard_landing",
		"colonists_per_faction": 1, "point_limit_enabled": false,
		"faction_specs": [cleaned]}
	assert(bool(model.validate_setup(config).get("ok", false)),
		"Sanitized remote setup must pass the game model's validation")
	var started: Dictionary = model.start_new_game(config)
	assert(not started.has("error"), "Sanitized remote setup must start a game")
	assert(model.state["world_people"].size() == 2)
	var colony_person: Dictionary = model.state["colonists"][0]
	var parent: Dictionary = model.state["world_people"][0]
	var friend: Dictionary = model.state["world_people"][1]
	assert(parent["relationship_types"].get(colony_person["id"]) == "parent")
	assert(colony_person["relationship_types"].get(parent["id"]) == "child")
	assert(parent["relationship_types"].get(friend["id"]) == "friend")
	print("NETWORK_PREPARATION_WORLD_RELATIONSHIPS_OK")
	quit()
