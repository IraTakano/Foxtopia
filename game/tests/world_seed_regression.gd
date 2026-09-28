extends SceneTree

func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	for index in range(12):
		var seed_text := "world-coverage-%d" % index
		var world: Dictionary = model.preview_world(seed_text)
		assert(world == model.preview_world(seed_text), "World seed is not deterministic")
		var tiles: Array = world["tiles"]
		var water := tiles.count("water")
		var land_ratio := 1.0 - float(water) / float(tiles.size())
		assert(land_ratio > 0.12 and land_ratio < 0.75, "World lacks a land and sea balance")
		var positions: Dictionary = {}
		for site in world["sites"]:
			var key := "%d:%d" % [int(site["x"]), int(site["y"])]
			assert(not positions.has(key), "Two settlements share one world tile")
			positions[key] = true
			assert(tiles[int(site["y"]) * int(world["width"]) + int(site["x"])] != "water")
	print("WORLD_SEED_REGRESSION_OK")
	quit()
