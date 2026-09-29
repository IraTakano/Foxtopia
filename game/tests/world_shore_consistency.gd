extends SceneTree


func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var width := 10
	var height := 10
	var tiles: Array = []
	var elevations: Array = []
	var rainfall: Array = []
	var temperatures: Array = []
	for _index in range(width * height):
		tiles.append("plains")
		elevations.append(150)
		rainfall.append(1000)
		temperatures.append(18.0)
	tiles[3 * width + 2] = "water"
	for y in range(6, 10):
		for x in range(6, 10):
			tiles[y * width + x] = "water"
	var world_data := {
		"seed": "shore-consistency", "width": width, "height": height,
		"tiles": tiles, "elevation": elevations,
		"rainfall_map": rainfall, "temperature_map": temperatures,
		"sites": [],
	}
	world_data["water_bodies"] = model._classify_water_bodies(tiles, width, height)
	assert(world_data["water_bodies"][3 * width + 2] == "lake")
	assert(world_data["water_bodies"][6 * width + 6] == "ocean")
	var lake_site := model.describe_site(world_data, "tile_2_4")
	assert(lake_site["shore_type"] == "lakeshore")
	assert(lake_site["shore_direction"] == "north")
	assert(not lake_site["coastal"] and lake_site["lakeshore"])
	var ocean_site := model.describe_site(world_data, "tile_5_6")
	assert(ocean_site["shore_type"] == "coast")
	assert(ocean_site["shore_direction"] == "east")
	assert(ocean_site["coastal"] and not ocean_site["lakeshore"])
	var inland_site := model.describe_site(world_data, "tile_2_5")
	assert(inland_site["shore_type"] == "inland")
	assert(inland_site["shore_direction"].is_empty())
	assert(model.preview_local_map(world_data, "tile_2_5")["terrain"].count("water") == 0)
	assert(model.preview_local_map(world_data, "tile_2_4")["terrain"].count("water") > 0)
	assert(model.preview_local_map(world_data, "tile_5_6")["terrain"].count("water") > 0)
	# Saves made before water-body metadata was added must report the same shore.
	world_data.erase("water_bodies")
	assert(model.describe_site(world_data, "tile_2_4")["shore_type"] == "lakeshore")
	assert(model.describe_site(world_data, "tile_5_6")["shore_type"] == "coast")
	var generated := model.preview_world("shore-consistency")
	assert(generated["water_bodies"].size() == generated["tiles"].size())
	print("WORLD_SHORE_CONSISTENCY_OK")
	quit()
