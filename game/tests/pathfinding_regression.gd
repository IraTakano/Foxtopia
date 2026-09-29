extends SceneTree


func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var started := model.start_new_game({"seed": "pathfinding-regression", "mode": "solo",
		"scenario_id": "hard_landing", "colonists_per_faction": 1})
	assert(not started.is_empty())
	var colonist: Dictionary = model.state["colonists"][0]
	var site_id: String = str(colonist["site_id"])
	var map_data: Dictionary = model.state["maps"][site_id]
	var grass: Array = []
	grass.resize(GameModel.LOCAL_SIZE * GameModel.LOCAL_SIZE)
	grass.fill("grass")
	map_data["terrain"] = grass
	map_data["structures"] = []
	map_data["resources"] = []
	colonist["x"] = 5
	colonist["y"] = 5
	colonist["traits"] = []
	for wall_y in range(3, 7):
		map_data["structures"].append({"id": "barrier_%d" % wall_y, "kind": "wall", "x": 7, "y": wall_y})

	# A greedy mover oscillates at (6, 5) and (6, 6) instead of going around the wall.
	var move_result := model.issue_command(1, {"type": "direct", "action": "move",
		"colonist_id": colonist["id"], "x": 9, "y": 5})
	assert(move_result["ok"], str(move_result))
	var arrived := false
	for _step in range(16):
		model.tick(1.0)
		assert(not _is_wall(map_data, int(colonist["x"]), int(colonist["y"])), "Colonist crossed a wall")
		if int(colonist["x"]) == 9 and int(colonist["y"]) == 5:
			arrived = true
			break
	assert(arrived, "Direct move failed to navigate around a wall")

	# Autonomous construction must use the same route finder.
	colonist["x"] = 5
	colonist["y"] = 5
	colonist["manual"] = {}
	colonist["resting"] = false
	colonist["needs"]["rest"] = 100.0
	var designated := model.issue_command(1, {"type": "designate", "kind": "build_bed",
		"site_id": site_id, "x": 9, "y": 5})
	assert(designated["ok"], str(designated))
	var order_id: String = str(designated["order_id"])
	var finished := false
	for _step in range(30):
		model.tick(1.0)
		assert(not _is_wall(map_data, int(colonist["x"]), int(colonist["y"])), "Builder crossed a wall")
		for order in model.state["orders"]:
			if str(order["id"]) == order_id and order["status"] == "done": finished = true
		if finished: break
	assert(finished, "Autonomous builder did not navigate around a wall")

	# An enclosed destination is rejected immediately instead of leaving a manual order stuck forever.
	for direction in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		map_data["structures"].append({"id": "enclosure_%d_%d" % [direction.x, direction.y],
			"kind": "wall", "x": 12 + direction.x, "y": 12 + direction.y})
	var unreachable := model.issue_command(1, {"type": "direct", "action": "move",
		"colonist_id": colonist["id"], "x": 12, "y": 12})
	assert(not unreachable["ok"], "Enclosed destination was accepted")
	assert((colonist["manual"] as Dictionary).is_empty(), "Rejected destination left a manual order")

	# A wall built after an order is issued invalidates the cached route.
	map_data["structures"] = []
	colonist["x"] = 5
	colonist["y"] = 5
	assert(model.issue_command(1, {"type": "direct", "action": "move",
		"colonist_id": colonist["id"], "x": 10, "y": 5})["ok"])
	model.tick(1.0)
	for wall_y in range(3, 7):
		map_data["structures"].append({"id": "new_barrier_%d" % wall_y,
			"kind": "wall", "x": 7, "y": wall_y})
	arrived = false
	for _step in range(18):
		model.tick(1.0)
		assert(not _is_wall(map_data, int(colonist["x"]), int(colonist["y"])), "Colonist crossed a new wall")
		if int(colonist["x"]) == 10 and int(colonist["y"]) == 5:
			arrived = true
			break
	assert(arrived, "Route was not recalculated after a new wall appeared")

	# Hauling chooses a reachable stockpile even when a closer one is enclosed.
	map_data["structures"] = []
	for direction in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		map_data["structures"].append({"id": "stockpile_wall_%d_%d" % [direction.x, direction.y],
			"kind": "wall", "x": 8 + direction.x, "y": 8 + direction.y})
	map_data["zones"] = [
		{"id": "enclosed", "kind": "stockpile", "x": 8, "y": 8, "width": 1, "height": 1,
			"accepts": ["wood"]},
		{"id": "reachable", "kind": "stockpile", "x": 10, "y": 5, "width": 1, "height": 1,
			"accepts": ["wood"]},
	]
	map_data["drops"] = [{"id": "route_wood", "x": 5, "y": 6, "kind": "wood", "amount": 4}]
	colonist["x"] = 5
	colonist["y"] = 5
	colonist["manual"] = {}
	colonist["carrying"] = {}
	var initial_wood: int = int(model.state["factions"][0]["inventory"].get("wood", 0))
	var haul_result := model.issue_command(1, {"type": "direct", "action": "haul",
		"colonist_id": colonist["id"], "target_id": "route_wood"})
	assert(haul_result["ok"], str(haul_result))
	var delivered := false
	for _step in range(15):
		model.tick(1.0)
		if int(model.state["factions"][0]["inventory"].get("wood", 0)) == initial_wood + 4:
			delivered = true
			break
	assert(delivered, "Hauling got stuck on a closer but enclosed stockpile")
	print("PATHFINDING_REGRESSION_OK")
	quit()


func _is_wall(map_data: Dictionary, x: int, y: int) -> bool:
	for structure in map_data["structures"]:
		if structure["kind"] == "wall" and int(structure["x"]) == x and int(structure["y"]) == y:
			return true
	return false
