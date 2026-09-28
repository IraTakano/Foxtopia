extends Control

signal map_pressed(tile: Vector2i, colonist_id: String, enemy_id: String, mouse_button: int)

const PawnVisual = preload("res://scripts/ui/pawn_visual.gd")

const TILE_SIZE := 27.0
const MIN_ZOOM := 0.45
const MAX_ZOOM := 2.1

var map_data: Dictionary = {}
var units: Array = []
var raiders: Array = []
var caravans: Array = []
var orders: Array = []
var selected_ids: Array[String] = []
var camera_offset := Vector2.ZERO
var zoom := 0.95
var _dragging := false
var _drag_start := Vector2.ZERO
var _offset_start := Vector2.ZERO
var _tile_hover := Vector2i(-1, -1)
var _grass_texture: Texture2D
var _tree_texture: Texture2D
var _pine_texture: Texture2D
var _stone_texture: Texture2D

var _grass_colors := [
	Color("#6a916a"), Color("#72986e"), Color("#789b73"),
	Color("#648864"), Color("#75956b"), Color("#6d926c")
]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	custom_minimum_size = Vector2(500, 400)
	_grass_texture = load("res://assets/grass.png")
	_tree_texture = load("res://assets/tree.svg")
	_pine_texture = load("res://assets/pine.svg")
	_stone_texture = load("res://assets/stone.svg")


func set_world(local_map: Dictionary, colonists: Array, enemies: Array, visiting_caravans: Array, active_orders: Array, selected: Array[String]) -> void:
	map_data = local_map
	units = colonists
	raiders = enemies
	caravans = visiting_caravans
	orders = active_orders
	selected_ids = selected
	queue_redraw()


func focus_tile(tile: Vector2i) -> void:
	var scale := TILE_SIZE * zoom
	camera_offset = size * 0.5 - Vector2(tile) * scale
	queue_redraw()


func _tile_at(screen_point: Vector2) -> Vector2i:
	return Vector2i((screen_point - camera_offset) / (TILE_SIZE * zoom))


func _pos_for(x: int, y: int) -> Vector2:
	return camera_offset + Vector2(x, y) * TILE_SIZE * zoom


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_WHEEL_UP and mouse.pressed:
			_zoom_at(mouse.position, 1.12)
			accept_event()
			return
		if mouse.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse.pressed:
			_zoom_at(mouse.position, 1.0 / 1.12)
			accept_event()
			return
		if mouse.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = mouse.pressed
			_drag_start = mouse.position
			_offset_start = camera_offset
			accept_event()
			return
		if mouse.pressed and (mouse.button_index == MOUSE_BUTTON_LEFT or mouse.button_index == MOUSE_BUTTON_RIGHT):
			var tile := _tile_at(mouse.position)
			var w := int(map_data.get("width", 50))
			var h := int(map_data.get("height", 50))
			if tile.x >= 0 and tile.y >= 0 and tile.x < w and tile.y < h:
				map_pressed.emit(tile, _unit_at(tile), _enemy_at(tile), mouse.button_index)
				accept_event()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _dragging:
			camera_offset = _offset_start + motion.position - _drag_start
			queue_redraw()
		else:
			var next_tile := _tile_at(motion.position)
			if next_tile != _tile_hover:
				_tile_hover = next_tile
				queue_redraw()


func _zoom_at(pivot: Vector2, factor: float) -> void:
	var old_zoom := zoom
	zoom = clampf(zoom * factor, MIN_ZOOM, MAX_ZOOM)
	camera_offset = pivot - (pivot - camera_offset) * (zoom / old_zoom)
	queue_redraw()


func _unit_at(tile: Vector2i) -> String:
	for unit in units:
		if int(unit.get("x", -100)) == tile.x and int(unit.get("y", -100)) == tile.y:
			return str(unit.get("id", ""))
	return ""


func _enemy_at(tile: Vector2i) -> String:
	for unit in raiders:
		if int(unit.get("x", -100)) == tile.x and int(unit.get("y", -100)) == tile.y:
			return str(unit.get("id", ""))
	return ""


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#213730"))
	var w := int(map_data.get("width", 50))
	var h := int(map_data.get("height", 50))
	var scale := TILE_SIZE * zoom
	if _grass_texture != null:
		draw_texture_rect(_grass_texture, Rect2(camera_offset, Vector2(w, h) * scale), false)
	var min_x := maxi(0, int(floor(-camera_offset.x / scale)))
	var min_y := maxi(0, int(floor(-camera_offset.y / scale)))
	var max_x := mini(w - 1, int(ceil((size.x - camera_offset.x) / scale)))
	var max_y := mini(h - 1, int(ceil((size.y - camera_offset.y) / scale)))
	var terrain: Array = map_data.get("terrain", [])
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var p := _pos_for(x, y)
			var tile_type := "grass"
			var index := y * w + x
			if index < terrain.size():
				tile_type = str(terrain[index])
			var color: Color = _grass_colors[absi(x * 31 + y * 17 + x * y * 3) % _grass_colors.size()]
			if tile_type == "water":
				color = Color("#537d85")
			elif tile_type == "dirt":
				color = Color("#ac9c71", 0.58)
			elif tile_type == "stone" or tile_type == "rock" or tile_type == "rock_ground":
				color = Color("#82908a")
			elif _grass_texture != null:
				color.a = 0.14
			draw_rect(Rect2(p, Vector2.ONE * (scale + 0.5)), color)
			if scale > 16.0 and (x * 13 + y * 7) % 9 == 0 and tile_type == "grass":
				draw_circle(p + Vector2(0.72, 0.65) * scale, scale * 0.035, Color("#d6d7a0", 0.55))
	if scale > 17.0:
		for y in range(min_y, max_y + 2):
			var yy := camera_offset.y + float(y) * scale
			draw_line(Vector2(0, yy), Vector2(size.x, yy), Color("#263e32", 0.12), 1.0)
		for x in range(min_x, max_x + 2):
			var xx := camera_offset.x + float(x) * scale
			draw_line(Vector2(xx, 0), Vector2(xx, size.y), Color("#263e32", 0.12), 1.0)
	for resource in map_data.get("resources", []):
		var x := int(resource.get("x", -1))
		var y := int(resource.get("y", -1))
		if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
			_draw_resource(resource, _pos_for(x, y), scale)
	for structure in map_data.get("structures", []):
		var x := int(structure.get("x", -1))
		var y := int(structure.get("y", -1))
		if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
			_draw_structure(structure, _pos_for(x, y), scale)
	for drop in map_data.get("drops", []):
		var x := int(drop.get("x", -1))
		var y := int(drop.get("y", -1))
		if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
			var p := _pos_for(x, y)
			draw_rect(Rect2(p + Vector2.ONE * scale * 0.28, Vector2.ONE * scale * 0.44), Color("#d1ae75"))
	for order in orders:
		if str(order.get("status", "")) in ["done", "cancelled"]:
			continue
		var x := int(order.get("x", -1))
		var y := int(order.get("y", -1))
		if x >= min_x and x <= max_x and y >= min_y and y <= max_y:
			var p := _pos_for(x, y)
			var priority := int(order.get("priority", 5))
			draw_rect(Rect2(p + Vector2.ONE * 2, Vector2.ONE * (scale - 4)), Color("#f1d58e", 0.17), false, 2.0)
			draw_circle(p + Vector2(scale * 0.19, scale * 0.2), scale * 0.13, Color("#e8c279") if priority <= 3 else Color("#b1d1ab") if priority <= 6 else Color("#a0aab1"))
	for caravan in caravans:
		if str(caravan.get("kind", "")) == "npc" and caravan.has("x"):
			var p := _pos_for(int(caravan.get("x", 0)), int(caravan.get("y", 0)))
			draw_circle(p + Vector2.ONE * scale * 0.5, scale * 0.34, Color("#e8c279"))
			draw_circle(p + Vector2.ONE * scale * 0.5, scale * 0.19, Color("#546e5e"))
	for unit in raiders:
		_draw_person(unit, scale, true)
	for unit in units:
		_draw_person(unit, scale, false)
	if _tile_hover.x >= 0 and _tile_hover.y >= 0 and _tile_hover.x < w and _tile_hover.y < h:
		draw_rect(Rect2(_pos_for(_tile_hover.x, _tile_hover.y), Vector2.ONE * scale), Color("#e8e6b9", 0.65), false, 1.6)


func _draw_resource(resource: Dictionary, p: Vector2, scale: float) -> void:
	var center := p + Vector2.ONE * scale * 0.5
	var kind := str(resource.get("kind", "tree"))
	if kind == "tree" or kind == "wood":
		if _tree_texture != null:
			var chosen: Texture2D = _pine_texture if (int(resource.get("x", 0)) * 7 + int(resource.get("y", 0)) * 11) % 4 == 0 and _pine_texture != null else _tree_texture
			draw_texture_rect(chosen, Rect2(p + Vector2(-0.12, -0.66) * scale, Vector2(1.24, 1.66) * scale), false)
			return
		draw_rect(Rect2(center + Vector2(-0.08, 0.08) * scale, Vector2(0.16, 0.37) * scale), Color("#785641"))
		draw_circle(center + Vector2(0, -0.11) * scale, scale * 0.34, Color("#315c45"))
		draw_circle(center + Vector2(-0.11, -0.18) * scale, scale * 0.23, Color("#426c48"))
		draw_circle(center + Vector2(0.12, -0.22) * scale, scale * 0.20, Color("#548154"))
	else:
		if kind == "stone" and _stone_texture != null:
			draw_texture_rect(_stone_texture, Rect2(p + Vector2(-0.1, -0.12) * scale, Vector2.ONE * scale * 1.2), false)
			return
		if kind == "berry":
			draw_circle(center, scale * 0.28, Color("#497650"))
			for offset in [Vector2(-0.14, -0.06), Vector2(0.10, -0.09), Vector2(0.04, 0.11)]:
				draw_circle(center + offset * scale, scale * 0.07, Color("#a55762"))
			return
		var points := PackedVector2Array([p + Vector2(0.15, 0.78) * scale, p + Vector2(0.23, 0.33) * scale, p + Vector2(0.56, 0.17) * scale, p + Vector2(0.85, 0.42) * scale, p + Vector2(0.76, 0.80) * scale])
		draw_colored_polygon(points, Color("#687979"))
		draw_polyline(points, Color("#bdc6b4"), 1.5, true)


func _draw_structure(structure: Dictionary, p: Vector2, scale: float) -> void:
	var kind := str(structure.get("kind", "wall"))
	if kind.contains("wall"):
		draw_rect(Rect2(p + Vector2.ONE * scale * 0.08, Vector2.ONE * scale * 0.84), Color("#aa9c78"))
		draw_rect(Rect2(p + Vector2.ONE * scale * 0.16, Vector2.ONE * scale * 0.69), Color("#d5be91"), false, 2.0)
	elif kind.contains("bed"):
		draw_rect(Rect2(p + Vector2(0.14, 0.2) * scale, Vector2(0.72, 0.62) * scale), Color("#73543e"))
		draw_rect(Rect2(p + Vector2(0.23, 0.28) * scale, Vector2(0.54, 0.46) * scale), Color("#d8be98"))
	else:
		draw_rect(Rect2(p + Vector2.ONE * scale * 0.17, Vector2.ONE * scale * 0.66), Color("#745e49"))
		draw_rect(Rect2(p + Vector2(0.25, 0.26) * scale, Vector2(0.5, 0.24) * scale), Color("#c9b18a"))


func _draw_person(unit: Dictionary, scale: float, enemy: bool) -> void:
	var x := int(unit.get("x", -100))
	var y := int(unit.get("y", -100))
	if x < 0 or y < 0:
		return
	var p := _pos_for(x, y)
	if p.x < -scale or p.y < -scale or p.x > size.x + scale or p.y > size.y + scale:
		return
	var center := p + Vector2.ONE * scale * 0.5
	var id := str(unit.get("id", ""))
	PawnVisual.draw_pawn(self, center, scale * 0.88, unit.get("appearance", {}), selected_ids.has(id), enemy, bool(unit.get("drafted", false)))
