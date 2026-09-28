extends Control

signal site_selected(site_id: String)

var preview: Dictionary = {}
var selected_site_id := ""
var _site_positions: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(580, 430)
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_preview(data: Dictionary, selected_id: String = "") -> void:
	preview = data
	selected_site_id = selected_id
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	draw_rect(rect, Color("#213638"))
	var inset := Rect2(Vector2(18, 18), size - Vector2(36, 36))
	draw_rect(inset, Color("#416b68"))
	var columns := int(preview.get("width", 64))
	var rows := int(preview.get("height", 40))
	var cw := inset.size.x / columns
	var ch := inset.size.y / rows
	var tiles: Array = preview.get("tiles", [])
	for y in rows:
		for x in columns:
			var color := Color("#79916c")
			if tiles.size() > y * columns + x:
				match str(tiles[y * columns + x]):
					"water": color = Color("#50747e")
					"forest": color = Color("#597c62")
					"rocky": color = Color("#858b82")
					_: color = Color("#849874")
			else:
				var v := _noise_value(x, y)
				if v < 0.22: color = Color("#50747e")
				elif v > 0.75: color = Color("#858b82")
			draw_rect(Rect2(inset.position + Vector2(x * cw, y * ch), Vector2(cw + 0.5, ch + 0.5)), color)
	for y in range(0, rows, 5):
		var py := inset.position.y + float(y) * ch
		draw_line(Vector2(inset.position.x, py), Vector2(inset.end.x, py), Color("#e1e4ca", 0.09), 1.0)
	for x in range(0, columns, 5):
		var px := inset.position.x + float(x) * cw
		draw_line(Vector2(px, inset.position.y), Vector2(px, inset.end.y), Color("#e1e4ca", 0.09), 1.0)
	_site_positions.clear()
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		var sx := float(site.get("x", 0))
		var sy := float(site.get("y", 0))
		var width := maxf(1.0, float(preview.get("width", 34)))
		var height := maxf(1.0, float(preview.get("height", 22)))
		var p := inset.position + Vector2((sx + 0.5) / width, (sy + 0.5) / height) * inset.size
		var id := str(site.get("id", ""))
		_site_positions[id] = p
		var kind := str(site.get("kind", "neutral"))
		var fill := Color("#e9c475")
		if kind == "friendly":
			fill = Color("#75c5a9")
		elif kind == "hostile" or kind == "enemy":
			fill = Color("#d8806d")
		elif kind == "player":
			fill = Color("#f1d58e")
		var radius := 6.0 if kind != "player" else 9.0
		draw_circle(p, radius + 2, Color("#223539"))
		draw_circle(p, radius, fill)
		if id == selected_site_id:
			draw_arc(p, 15, 0, TAU, 28, Color("#f6e3a0"), 2.5)
		if kind == "friendly" or kind == "hostile" or kind == "enemy":
			draw_line(p + Vector2(0, -7), p + Vector2(0, -20), Color("#263b37"), 2.0)
			draw_colored_polygon(PackedVector2Array([p + Vector2(1, -20), p + Vector2(13, -16), p + Vector2(1, -12)]), fill)
	draw_rect(inset, Color("#c5d0b8", 0.38), false, 1.0)


func _noise_value(x: int, y: int) -> float:
	var seed_text := str(preview.get("seed", "fox"))
	var seed_hash: int = absi(seed_text.hash())
	var a := sin(float(x) * 0.41 + float(seed_hash % 333) * 0.01)
	var b := cos(float(y) * 0.54 + float(seed_hash % 421) * 0.01)
	var c := sin(float(x + y) * 0.16 + float(seed_hash % 577) * 0.01)
	return clampf((a * 0.33 + b * 0.34 + c * 0.33 + 1.0) * 0.5, 0.0, 1.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var best_id := ""
		var best_dist := 22.0
		for id in _site_positions:
			var dist: float = (event.position as Vector2).distance_to(_site_positions[id])
			if dist < best_dist:
				best_dist = dist
				best_id = str(id)
		if not best_id.is_empty():
			selected_site_id = best_id
			queue_redraw()
			site_selected.emit(best_id)
			accept_event()
