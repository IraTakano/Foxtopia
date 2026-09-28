extends SceneTree

func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var preview_a := model.preview_world("mvp-test")
	var preview_b := model.preview_world("mvp-test")
	assert(JSON.stringify(preview_a) == JSON.stringify(preview_b), "World generation changed for same seed")
	assert(preview_a["sites"].size() == 16)
	model.start_new_game({"seed":"mvp-test", "mode":"competitive",
		"colonists_per_faction":2, "player_count":2})
	assert(model.state["factions"].size() == 2)
	assert(model.state["colonists"].size() == 4)
	assert(model.state["maps"].size() == 2)
	assert(model.get_snapshot(2)["maps"].size() == 1)
	var colonist: Dictionary = model.state["colonists"][0]
	var site_id: String = str(colonist["site_id"])
	var map_data: Dictionary = model.state["maps"][site_id]
	var tree: Dictionary = {}
	for resource in map_data["resources"]:
		if resource["kind"] == "tree": tree = resource; break
	assert(not tree.is_empty())
	var bad_owner := model.issue_command(2, {"type":"set_work_priority",
		"colonist_id":colonist["id"], "work":"chop", "priority":1})
	assert(not bad_owner["ok"], "Other faction modified a colonist")
	assert(model.issue_command(1, {"type":"customize_colonist", "colonist_id":colonist["id"],
		"appearance":{"hair_color":"#123456"}})["ok"])
	assert(colonist["appearance"]["hair_color"] == "#123456")
	var designation := model.issue_command(1, {"type":"designate", "site_id":site_id,
		"x":tree["x"], "y":tree["y"], "kind":"chop", "priority":1})
	assert(designation["ok"], str(designation))
	var order_id: String = str(designation["order_id"])
	assert(model.issue_command(1, {"type":"set_order_priority", "order_id":order_id,
		"priority":9})["ok"])
	assert(model.issue_command(1, {"type":"direct", "colonist_id":colonist["id"],
		"action":"work", "target_id":order_id})["ok"])
	for i in range(120): model.tick(1.0)
	var completed := false
	for order in model.state["orders"]:
		if order["id"] == order_id: completed = order["status"] == "done"
	assert(completed, "Manual work did not finish")
	var trade := model.issue_command(1, {"type":"trade_offer", "to_faction":"faction_2",
		"give":{"wood":2}, "receive":{"stone":1}})
	assert(trade["ok"], str(trade))
	assert(model.issue_command(2, {"type":"trade_accept", "offer_id":trade["offer_id"]})["ok"])
	assert(model.state["caravans"].size() > 0)
	for i in range(200): model.tick(1.0)
	var trade_done := false
	for offer in model.state["trade_offers"]:
		if offer["id"] == trade["offer_id"]: trade_done = offer["status"] == "completed"
	assert(trade_done, "Trade caravan did not arrive")
	var saved := model.serialize_game()
	var restored := GameModel.new()
	root.add_child(restored)
	assert(restored.load_game(saved))
	assert(int(restored.state["time"]) == int(model.state["time"]))
	var systems := GameModel.new()
	root.add_child(systems)
	systems.start_new_game({"seed":"systems", "mode":"solo", "colonists_per_faction":3})
	var built := systems.issue_command(1, {"type":"designate", "site_id":"site_1",
		"x":27, "y":25, "kind":"build_research_bench", "priority":1})
	assert(built["ok"])
	for i in range(35): systems.tick(1.0)
	var has_bench := false
	for structure in systems.state["maps"]["site_1"]["structures"]:
		if structure["kind"] == "research_bench": has_bench = true
	assert(has_bench, "Research bench was not built")
	assert(systems.issue_command(1, {"type":"set_research", "project":"farming"})["ok"])
	for i in range(80): systems.tick(1.0)
	assert(systems.state["factions"][0]["research"]["unlocked"].has("farming"), "Research did not complete")
	var npc: Dictionary = {}
	for caravan in systems.state["caravans"]:
		if caravan["kind"] == "npc": npc = caravan
	assert(not npc.is_empty(), "NPC caravan did not visit")
	var npc_trade := systems.issue_command(1, {"type":"npc_trade", "caravan_id":npc["id"],
		"buy":{"food":1}, "sell":{"stone":2}})
	assert(npc_trade["ok"], str(npc_trade))
	for i in range(36): systems.tick(1.0)
	var warned := false
	var raided := false
	for event in systems.state["events"]:
		if event["kind"] == "raid_warning": warned = true
		if event["kind"] == "raid": raided = true
	assert(warned and raided, "Raid warning or raid did not occur")
	print("MODEL_SMOKE_TEST_OK")
	quit()
