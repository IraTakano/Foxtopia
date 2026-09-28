extends SceneTree

const WorldView = preload("res://scripts/ui/world_view.gd")
const TerrainPreview = preload("res://scripts/ui/terrain_preview.gd")


func _initialize() -> void:
	var model := GameModel.new()
	root.add_child(model)
	var seed_text := "site-preview-regression"
	var normal := model.preview_world(seed_text)
	var dry := model.preview_world(seed_text, {"rainfall": 0.0})
	var wet := model.preview_world(seed_text, {"rainfall": 1.0})
	var cold := model.preview_world(seed_text, {"temperature": 0.0})
	var hot := model.preview_world(seed_text, {"temperature": 1.0})
	var sparse := model.preview_world(seed_text, {"population": 0.0})
	var crowded := model.preview_world(seed_text, {"population": 1.0})
	var small := model.preview_world(seed_text, {"coverage": 0.25})
	var large := model.preview_world(seed_text, {"coverage": 0.75})
	assert(dry["rainfall_map"] != wet["rainfall_map"])
	assert(cold["temperature_map"] != hot["temperature_map"])
	assert(sparse["sites"].size() < crowded["sites"].size())
	assert(small["tiles"].count("water") > large["tiles"].count("water"))
	for coverage in [0.25, 0.50, 0.75]:
		var coverage_world := model.preview_world(seed_text, {"coverage": coverage, "population": 1.0})
		var seen: Dictionary = {}
		for site in coverage_world["sites"]:
			var key := "%d:%d" % [int(site["x"]), int(site["y"])]
			assert(not seen.has(key))
			seen[key] = true
			assert(coverage_world["tiles"][int(site["y"]) * int(coverage_world["width"]) + int(site["x"])] != "water")
	var site_id := str(normal["sites"][0]["id"])
	var info := model.describe_site(normal, site_id)
	assert(not info.is_empty())
	assert(info.has("rainfall") and info.has("temperature") and info.has("terrain"))
	var local_preview := model.preview_local_map(normal, site_id)
	assert(local_preview["terrain"].size() == 2500)
	var spec := {"id": "faction_1", "name": "Test colony", "settlement_name": "Test site",
		"players": [1], "site_id": site_id, "colonists": [{}]}
	var started := model.start_new_game({"seed": seed_text, "mode": "solo",
		"colonists_per_faction": 1, "faction_specs": [spec], "point_limit_enabled": false})
	assert(started.has("maps"), str(started))
	var playable: Dictionary = model.state["maps"][site_id]
	assert(playable["terrain"] == local_preview["terrain"])
	assert(playable["resources"] == local_preview["resources"])
	var occupied: Dictionary = {}
	for site in normal["sites"]:
		occupied["%d:%d" % [int(site["x"]), int(site["y"])]] = true
	var custom_id := ""
	for y in range(3, int(normal["height"]) - 3):
		for x in range(3, int(normal["width"]) - 3):
			if normal["tiles"][y * int(normal["width"]) + x] != "water" and not occupied.has("%d:%d" % [x, y]):
				custom_id = "tile_%d_%d" % [x, y]
				break
		if not custom_id.is_empty(): break
	assert(not custom_id.is_empty())
	var custom_preview := model.preview_local_map(normal, custom_id)
	assert(custom_preview["terrain"].size() == 2500)
	spec["site_id"] = custom_id
	started = model.start_new_game({"seed": seed_text, "mode": "solo",
		"colonists_per_faction": 1, "faction_specs": [spec], "point_limit_enabled": false})
	assert(started.has("maps"), str(started))
	assert(model.state["maps"][custom_id]["terrain"] == custom_preview["terrain"])
	var world_view := WorldView.new()
	root.add_child(world_view)
	world_view.size = Vector2(800, 800)
	world_view.set_preview(normal, site_id)
	var tile := Vector2i(int(info["x"]), int(info["y"]))
	var position: Vector2 = world_view._project(float(tile.x) + 0.5, float(tile.y) + 0.5)
	assert(world_view._tile_from_point(position) == tile)
	world_view.rotate_by(PI * 0.3)
	world_view.rotate_by(-PI * 0.3)
	world_view.rotate_by(0.0, 0.25)
	world_view.rotate_by(0.0, -0.25)
	position = world_view._project(float(tile.x) + 0.5, float(tile.y) + 0.5)
	assert(world_view._tile_from_point(position) == tile)
	var drag_start := InputEventMouseButton.new()
	drag_start.button_index = MOUSE_BUTTON_LEFT
	drag_start.pressed = true
	drag_start.position = position
	world_view._gui_input(drag_start)
	var drag_move := InputEventMouseMotion.new()
	drag_move.position = position + Vector2(32, 15)
	drag_move.relative = Vector2(32, 15)
	world_view._gui_input(drag_move)
	var drag_end := InputEventMouseButton.new()
	drag_end.button_index = MOUSE_BUTTON_LEFT
	drag_end.pressed = false
	drag_end.position = drag_move.position
	world_view._gui_input(drag_end)
	assert(absf(world_view.globe_rotation) > 0.01)
	assert(absf(world_view.globe_tilt) > 0.01)
	var terrain_preview := TerrainPreview.new()
	root.add_child(terrain_preview)
	terrain_preview.set_map(local_preview)
	assert(terrain_preview.map_data["terrain"] == playable["terrain"])
	print("WORLD_PREVIEW_REGRESSION_OK")
	quit()
