extends Control

## The same 50x50 terrain data is used here and by the playable map.
## This is an overview of the selected tile, not a second world generator.
var map_data: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(260, 260)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true


func set_map(data: Dictionary) -> void:
	map_data = data
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#10191b"))
	var columns := int(map_data.get("width", 0))
	var rows := int(map_data.get("height", 0))
	var terrain: Array = map_data.get("terrain", [])
	if columns <= 0 or rows <= 0 or terrain.size() < columns * rows:
		return
	var side := minf(size.x - 10.0, size.y - 10.0)
	var origin := (size - Vector2.ONE * side) * 0.5
	var cell := Vector2(side / float(columns), side / float(rows))
	var biome := str(map_data.get("biome", "plains"))
	for y in range(rows):
		for x in range(columns):
			var kind := str(terrain[y * columns + x])
			var color := _terrain_color(kind, biome, x, y)
			draw_rect(Rect2(origin + Vector2(float(x) * cell.x, float(y) * cell.y), cell + Vector2.ONE * 0.35), color)
	for resource in map_data.get("resources", []):
		var x := int(resource.get("x", -1))
		var y := int(resource.get("y", -1))
		if x < 0 or y < 0 or x >= columns or y >= rows:
			continue
		var center := origin + Vector2((float(x) + 0.5) * cell.x, (float(y) + 0.5) * cell.y)
		match str(resource.get("kind", "")):
			"tree": draw_circle(center, maxf(1.1, cell.x * 0.42), Color("#2f533c", 0.88))
			"stone": draw_circle(center, maxf(0.8, cell.x * 0.26), Color("#c4c1ac", 0.83))
			"berry": draw_circle(center, maxf(0.8, cell.x * 0.25), Color("#ba795f", 0.9))
	var start := origin + Vector2(25.5 * cell.x, 25.5 * cell.y)
	draw_arc(start, maxf(4.0, cell.x * 1.15), 0.0, TAU, 24, Color("#251d17"), 3.0)
	draw_arc(start, maxf(4.0, cell.x * 1.15), 0.0, TAU, 24, Color("#e7d298"), 1.5)
	draw_rect(Rect2(origin, Vector2.ONE * side), Color("#8c9b94", 0.72), false, 1.0)


func _terrain_color(kind: String, biome: String, x: int, y: int) -> Color:
	var color := Color("#718f68")
	match biome:
		"forest": color = Color("#59785b")
		"arid": color = Color("#a99668")
		"tundra": color = Color("#8b9b91")
		"rocky": color = Color("#818a78")
	if kind == "water":
		color = Color("#496f7e")
	elif kind == "rock_ground":
		color = Color("#777e78")
	elif kind == "dirt":
		color = Color("#927b5b") if biome == "arid" else Color("#96846b")
	var variation := float((x * 37 + y * 17 + x * y * 3) % 11) / 11.0
	return color.lightened((variation - 0.5) * 0.07)
