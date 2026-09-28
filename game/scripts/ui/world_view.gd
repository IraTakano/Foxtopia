extends Control

signal site_selected(site_id: String)

const WATER := Color("#3b7385")
const FOREST := Color("#527f59")
const PLAIN := Color("#93ad75")
const ROCK := Color("#9a9788")

var preview: Dictionary = {}
var selected_site_id := ""
var zoom := 1.0
var _site_at_tile: Dictionary = {}
var _hover_tile := Vector2i(-1, -1)


func _ready() -> void:
	custom_minimum_size = Vector2(580, 430)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true


func set_preview(data: Dictionary, selected_id: String = "") -> void:
	preview = data
	selected_site_id = selected_id
	_site_at_tile.clear()
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		_site_at_tile["%d:%d" % [int(site.get("x", -1)), int(site.get("y", -1))]] = site
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := _radius()
	draw_rect(Rect2(Vector2.ZERO, size), Color("#11191e"))
	for index in 115:
		var p := Vector2(float((index * 769 + 281) % 1009) / 1009.0 * size.x, float((index * 383 + 719) % 991) / 991.0 * size.y)
		if p.distance_to(center) > radius * 1.08:
			draw_circle(p, 0.7 if index % 5 else 1.3, Color("#d4dfd6", 0.23 if index % 3 else 0.44))
	draw_circle(center, radius * 1.025, Color("#537886", 0.25))
	draw_circle(center, radius, Color("#2b6273"))
	var columns := int(preview.get("width", 64))
	var rows := int(preview.get("height", 40))
	var tiles: Array = preview.get("tiles", [])
	if columns <= 0 or rows <= 0:
		return
	# The exact poles collapse to a single point. Leave the thin polar cap to
	# the ocean disc so every terrain polygon has valid, visible geometry.
	for y in range(1, rows - 1):
		for x in columns:
			var kind := _terrain_at(x, y, tiles, columns, rows)
			var longitude := ((float(x) + 0.5) / float(columns) - 0.5) * PI
			var latitude := ((float(y) + 0.5) / float(rows) - 0.5) * PI
			var facing := maxf(0.0, cos(longitude) * cos(latitude))
			var color := _tile_color(kind, x, y).darkened((1.0 - facing) * 0.34)
			var polygon := PackedVector2Array([_project(float(x), float(y)), _project(float(x + 1), float(y)), _project(float(x + 1), float(y + 1)), _project(float(x), float(y + 1))])
			if polygon[0].distance_to(polygon[1]) < 0.12 or polygon[2].distance_to(polygon[3]) < 0.12:
				continue
			draw_colored_polygon(polygon, color)
			if kind != "water":
				var edge_color := Color("#dcc7a0", 0.69 * facing)
				if _terrain_at(x - 1, y, tiles, columns, rows) == "water":
					draw_line(polygon[0], polygon[3], edge_color, 1.8)
				if _terrain_at(x + 1, y, tiles, columns, rows) == "water":
					draw_line(polygon[1], polygon[2], edge_color, 1.8)
				if _terrain_at(x, y - 1, tiles, columns, rows) == "water":
					draw_line(polygon[0], polygon[1], edge_color, 1.8)
				if _terrain_at(x, y + 1, tiles, columns, rows) == "water":
					draw_line(polygon[3], polygon[2], edge_color, 1.8)
				_draw_land_detail(kind, x, y, facing, color, polygon)
			elif (x * 19 + y * 31) % 29 == 0 and facing > 0.45:
				var water_center := (polygon[0] + polygon[2]) * 0.5
				draw_line(water_center + Vector2(-2, 0), water_center + Vector2(2, 0), Color("#9fc1bd", 0.24), 0.8)
	_draw_grid(columns, rows)
	_draw_sites()
	var selected_tile := _selected_tile()
	if selected_tile.x >= 0:
		_draw_tile_marker(selected_tile, Color("#f3dc9b"), 10.0)
	if _hover_tile.x >= 0 and _hover_tile != selected_tile and _is_selectable(_hover_tile):
		_draw_tile_marker(_hover_tile, Color("#e8e1bb", 0.8), 6.0)
	draw_arc(center, radius, 0.0, TAU, 128, Color("#a0bec1", 0.43), 2.0)


func _draw_land_detail(kind: String, x: int, y: int, facing: float, color: Color, polygon: PackedVector2Array) -> void:
	if facing < 0.34 or (x * 13 + y * 17) % 3 != 0:
		return
	var middle := (polygon[0] + polygon[2]) * 0.5
	var scale := minf(polygon[0].distance_to(polygon[1]), polygon[0].distance_to(polygon[3]))
	if scale < 4.0:
		return
	if kind == "forest":
		var crown := clampf(scale * 0.17, 1.2, 2.7)
		draw_circle(middle + Vector2(-crown * 0.75, -crown * 0.3), crown, color.darkened(0.26))
		draw_circle(middle + Vector2(crown * 0.65, crown * 0.1), crown * 0.82, color.lightened(0.16))
	elif kind == "rocky":
		var peak := clampf(scale * 0.30, 2.0, 4.1)
		draw_colored_polygon(PackedVector2Array([middle + Vector2(-peak, peak * 0.55), middle + Vector2(0, -peak), middle + Vector2(peak, peak * 0.55)]), color.lightened(0.16))
		draw_line(middle + Vector2(0, -peak), middle + Vector2(peak, peak * 0.55), color.darkened(0.18), 0.75)
	elif (x + y) % 2 == 0:
		draw_line(middle + Vector2(-1.4, 0.8), middle + Vector2(1.5, -0.6), color.lightened(0.18), 0.7)


func _draw_grid(columns: int, rows: int) -> void:
	for x in range(0, columns + 1, 8):
		var points := PackedVector2Array()
		for step in range(0, rows + 1, 2):
			points.append(_project(float(x), float(step)))
		if points.size() > 1:
			draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)
	for y in range(0, rows + 1, 6):
		var points := PackedVector2Array()
		for step in range(0, columns + 1, 2):
			points.append(_project(float(step), float(y)))
		if points.size() > 1:
			draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)


func _draw_sites() -> void:
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		var kind := str(site.get("kind", "vacant"))
		if kind == "vacant":
			continue
		var p := _project(float(site.get("x", 0)) + 0.5, float(site.get("y", 0)) + 0.5)
		var fill := Color("#8ad0b1") if kind == "friendly" else Color("#dc8b77") if kind == "hostile" else Color("#efd495")
		draw_circle(p + Vector2(0, 1.5), 6.5, Color("#172126", 0.92))
		draw_circle(p, 4.0, fill)
		draw_line(p + Vector2(0, -4), p + Vector2(0, -16), Color("#1d2c2e"), 2.0)
		draw_colored_polygon(PackedVector2Array([p + Vector2(1, -16), p + Vector2(12, -12), p + Vector2(1, -8)]), fill)


func _draw_tile_marker(tile: Vector2i, color: Color, radius: float) -> void:
	var p := _project(float(tile.x) + 0.5, float(tile.y) + 0.5)
	draw_circle(p, 3.0, color)
	draw_arc(p, radius, 0.0, TAU, 26, Color("#162725", 0.85), 4.0)
	draw_arc(p, radius, 0.0, TAU, 26, color, 2.0)


func _radius() -> float:
	return minf(size.x * 0.46, size.y * 0.49) * zoom


func _project(tile_x: float, tile_y: float) -> Vector2:
	var columns := maxf(1.0, float(preview.get("width", 64)))
	var rows := maxf(1.0, float(preview.get("height", 40)))
	var longitude := (tile_x / columns - 0.5) * PI
	var latitude := (tile_y / rows - 0.5) * PI
	return size * 0.5 + Vector2(sin(longitude) * cos(latitude), sin(latitude)) * _radius()


func _tile_from_point(point: Vector2) -> Vector2i:
	var normalized := (point - size * 0.5) / _radius()
	if normalized.length_squared() >= 0.985:
		return Vector2i(-1, -1)
	var latitude := asin(clampf(normalized.y, -1.0, 1.0))
	var cos_latitude := cos(latitude)
	if cos_latitude < 0.02:
		return Vector2i(-1, -1)
	var longitude := asin(clampf(normalized.x / cos_latitude, -1.0, 1.0))
	var columns := int(preview.get("width", 64))
	var rows := int(preview.get("height", 40))
	return Vector2i(clampi(int(floor((longitude / PI + 0.5) * columns)), 0, columns - 1), clampi(int(floor((latitude / PI + 0.5) * rows)), 0, rows - 1))


func _terrain_at(x: int, y: int, tiles: Array, columns: int, rows: int) -> String:
	if x < 0 or x >= columns or y < 0 or y >= rows:
		return "water"
	var index := y * columns + x
	return str(tiles[index]) if index < tiles.size() else "water"


func _tile_color(kind: String, x: int, y: int) -> Color:
	var base := WATER
	match kind:
		"forest": base = FOREST
		"rocky": base = ROCK
		"grass", "plains": base = PLAIN
	var variation := float((x * 37 + y * 67 + x * y * 11) % 17) / 17.0
	return base.lightened((variation - 0.5) * 0.075)


func _selected_tile() -> Vector2i:
	if selected_site_id.begins_with("tile_"):
		var parts := selected_site_id.split("_")
		if parts.size() == 3 and parts[1].is_valid_int() and parts[2].is_valid_int():
			return Vector2i(int(parts[1]), int(parts[2]))
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		if str(site.get("id", "")) == selected_site_id:
			return Vector2i(int(site.get("x", -1)), int(site.get("y", -1)))
	return Vector2i(-1, -1)


func _is_selectable(tile: Vector2i) -> bool:
	if tile.x < 0 or tile.y < 0:
		return false
	var columns := int(preview.get("width", 64))
	var rows := int(preview.get("height", 40))
	if _terrain_at(tile.x, tile.y, preview.get("tiles", []), columns, rows) == "water":
		return false
	var existing: Dictionary = _site_at_tile.get("%d:%d" % [tile.x, tile.y], {})
	return existing.is_empty() or str(existing.get("kind", "vacant")) == "vacant"


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var tile := _tile_from_point(event.position)
		if tile != _hover_tile:
			_hover_tile = tile
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clampf(zoom * (1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12), 0.75, 1.65)
			queue_redraw()
			accept_event()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		var tile := _tile_from_point(event.position)
		if not _is_selectable(tile):
			return
		var existing: Dictionary = _site_at_tile.get("%d:%d" % [tile.x, tile.y], {})
		selected_site_id = str(existing.get("id", "tile_%d_%d" % [tile.x, tile.y]))
		queue_redraw()
		site_selected.emit(selected_site_id)
		accept_event()
