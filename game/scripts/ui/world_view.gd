extends Control

signal site_selected(site_id: String)

const WATER := Color("#3b7385")
const FOREST := Color("#527f59")
const PLAIN := Color("#93ad75")
const ROCK := Color("#9a9788")
const ARID := Color("#b7a272")
const TUNDRA := Color("#a9b4a7")

var preview: Dictionary = {}
var selected_site_id := ""
var zoom := 1.0
var globe_rotation := 0.0
var globe_tilt := 0.0
var _site_at_tile: Dictionary = {}
var _hover_tile := Vector2i(-1, -1)
var _rotating := false
var _drag_distance := 0.0
var _surface_texture: ImageTexture
var _surface_mesh: ArrayMesh
var _mesh_rotation := INF
var _mesh_tilt := INF
var _mesh_zoom := INF
var _mesh_size := Vector2.ZERO


func _ready() -> void:
	custom_minimum_size = Vector2(580, 430)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR


func set_preview(data: Dictionary, selected_id: String = "") -> void:
	var new_world: bool = preview.is_empty() or str(preview.get("seed", "")) != str(data.get("seed", "")) or preview.get("tiles", []) != data.get("tiles", [])
	preview = data
	selected_site_id = selected_id
	if new_world or _surface_texture == null:
		_build_surface_texture()
		_surface_mesh = null
	_site_at_tile.clear()
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		_site_at_tile["%d:%d" % [int(site.get("x", -1)), int(site.get("y", -1))]] = site
	if new_world:
		var tile := _selected_tile()
		if tile.x >= 0:
			var site_longitude := ((float(tile.x) + 0.5) / float(maxi(1, int(preview.get("width", 96)))) - 0.5) * TAU
			globe_rotation = 0.0
			globe_tilt = 0.0
			if absf(site_longitude) > PI * 0.42:
				globe_rotation = site_longitude - signf(site_longitude) * PI * 0.42
	queue_redraw()


func rotate_by(angle_radians: float, tilt_radians: float = 0.0) -> void:
	globe_rotation = wrapf(globe_rotation + angle_radians, -PI, PI)
	globe_tilt = clampf(globe_tilt + tilt_radians, -1.1, 1.1)
	_hover_tile = Vector2i(-1, -1)
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
	if columns <= 0 or rows <= 0:
		return
	_draw_surface_mesh(columns, rows)
	_draw_grid(columns, rows)
	_draw_sites()
	var selected_tile := _selected_tile()
	if selected_tile.x >= 0 and _front(float(selected_tile.x) + 0.5, float(selected_tile.y) + 0.5):
		_draw_tile_marker(selected_tile, Color("#f3dc9b"), 10.0)
	if _hover_tile.x >= 0 and _hover_tile != selected_tile and _is_selectable(_hover_tile):
		_draw_tile_marker(_hover_tile, Color("#e8e1bb", 0.8), 6.0)
	draw_arc(center, radius, 0.0, TAU, 128, Color("#a0bec1", 0.43), 2.0)


func _draw_surface_mesh(columns: int, rows: int) -> void:
	if _surface_texture == null:
		return
	if _surface_mesh != null and is_equal_approx(_mesh_rotation, globe_rotation) and is_equal_approx(_mesh_tilt, globe_tilt) and is_equal_approx(_mesh_zoom, zoom) and _mesh_size == size:
		draw_mesh(_surface_mesh, _surface_texture)
		return
	# Draw all visible terrain cells in one textured mesh. The old path sent
	# thousands of separate polygons and recomputed sin/cos for every corner.
	# Pole rows still use the ocean disc because their quads collapse to points.
	var sin_longitude := PackedFloat32Array()
	var cos_longitude := PackedFloat32Array()
	for x in range(columns + 1):
		var longitude := (float(x) / float(columns) - 0.5) * TAU - globe_rotation
		sin_longitude.append(sin(longitude))
		cos_longitude.append(cos(longitude))
	var tilt_sin := sin(globe_tilt)
	var tilt_cos := cos(globe_tilt)
	var center := size * 0.5
	var radius := _radius()
	var vertex_columns := columns + 1
	var vertices := PackedVector3Array()
	var points := PackedVector2Array()
	var depths := PackedFloat32Array()
	var colors := PackedColorArray()
	var uvs := PackedVector2Array()
	for y in range(1, rows):
		var latitude := (float(y) / float(rows) - 0.5) * PI
		var latitude_sin := sin(latitude)
		var latitude_cos := cos(latitude)
		for x in range(vertex_columns):
			var px := latitude_cos * sin_longitude[x]
			var py := latitude_sin * tilt_cos - latitude_cos * cos_longitude[x] * tilt_sin
			var depth := latitude_sin * tilt_sin + latitude_cos * tilt_cos * cos_longitude[x]
			var point := center + Vector2(px, py) * radius
			points.append(point)
			vertices.append(Vector3(point.x, point.y, 0.0))
			depths.append(depth)
			var shade := (1.0 - maxf(0.0, depth)) * 0.35
			colors.append(Color(1.0 - shade, 1.0 - shade, 1.0 - shade))
			uvs.append(Vector2(float(x) / float(columns), float(y) / float(rows)))
	var indices := PackedInt32Array()
	for row in range(rows - 2):
		for x in columns:
			var a := row * vertex_columns + x
			var b := a + 1
			var d := a + vertex_columns
			var c := d + 1
			if depths[a] + depths[b] + depths[c] + depths[d] <= 0.0:
				continue
			# At the limb, back-facing or collapsed cells can fold over. Skip
			# these instead of sending invalid polygons to the renderer.
			if (points[b] - points[a]).cross(points[c] - points[a]) <= 0.02 or (points[c] - points[a]).cross(points[d] - points[a]) <= 0.02:
				continue
			indices.append(a)
			indices.append(b)
			indices.append(c)
			indices.append(a)
			indices.append(c)
			indices.append(d)
	if indices.is_empty():
		return
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	_surface_mesh = ArrayMesh.new()
	_surface_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_mesh_rotation = globe_rotation
	_mesh_tilt = globe_tilt
	_mesh_zoom = zoom
	_mesh_size = size
	draw_mesh(_surface_mesh, _surface_texture)


func _build_surface_texture() -> void:
	_surface_texture = null
	var columns := int(preview.get("width", 0))
	var rows := int(preview.get("height", 0))
	var tiles: Array = preview.get("tiles", [])
	if columns <= 0 or rows <= 0 or tiles.size() < columns * rows:
		return
	const DETAIL := 4
	var image := Image.create_empty(columns * DETAIL, rows * DETAIL, false, Image.FORMAT_RGBA8)
	var land_flags := PackedFloat32Array()
	var land_colors := PackedColorArray()
	for kind in tiles:
		var biome := str(kind)
		land_flags.append(0.0 if biome == "water" else 1.0)
		land_colors.append(_biome_color(biome))
	var coast_noise := FastNoiseLite.new()
	coast_noise.seed = str(preview.get("seed", "")).hash()
	coast_noise.frequency = 0.032
	coast_noise.fractal_octaves = 3
	var grain_noise := FastNoiseLite.new()
	grain_noise.seed = coast_noise.seed + 97
	grain_noise.frequency = 0.22
	grain_noise.fractal_octaves = 2
	for py in range(rows * DETAIL):
		var source_y := (float(py) + 0.5) / float(DETAIL) - 0.5
		var y0 := clampi(floori(source_y), 0, rows - 1)
		var y1 := mini(y0 + 1, rows - 1)
		var blend_y := smoothstep(0.0, 1.0, source_y - floorf(source_y))
		for px in range(columns * DETAIL):
			var source_x := (float(px) + 0.5) / float(DETAIL) - 0.5
			var x0 := posmod(floori(source_x), columns)
			var x1 := posmod(x0 + 1, columns)
			var blend_x := smoothstep(0.0, 1.0, source_x - floorf(source_x))
			var w00 := (1.0 - blend_x) * (1.0 - blend_y)
			var w10 := blend_x * (1.0 - blend_y)
			var w01 := (1.0 - blend_x) * blend_y
			var w11 := blend_x * blend_y
			var i00 := y0 * columns + x0
			var i10 := y0 * columns + x1
			var i01 := y1 * columns + x0
			var i11 := y1 * columns + x1
			var landness := land_flags[i00] * w00 + land_flags[i10] * w10 + land_flags[i01] * w01 + land_flags[i11] * w11
			var coast_shape := coast_noise.get_noise_2d(float(px), float(py))
			var grain := grain_noise.get_noise_2d(float(px), float(py))
			var cutoff := 0.49 + coast_shape * 0.085
			var color: Color
			if landness >= cutoff:
				color = (land_colors[i00] * (land_flags[i00] * w00)
					+ land_colors[i10] * (land_flags[i10] * w10)
					+ land_colors[i01] * (land_flags[i01] * w01)
					+ land_colors[i11] * (land_flags[i11] * w11)) / maxf(landness, 0.01)
				if landness < 0.72:
					color = color.lerp(Color("#b9ad8b"), (0.72 - landness) * 0.55)
				color = color.lightened(coast_shape * 0.055 + grain * 0.035)
			else:
				color = Color("#315b6c").lerp(Color("#668b8b"), clampf(landness * 0.94, 0.0, 0.72))
				color = color.lightened(coast_shape * 0.055 + grain * 0.025)
			image.set_pixel(px, py, color)
	_surface_texture = ImageTexture.create_from_image(image)


func _biome_color(kind: String) -> Color:
	match kind:
		"forest": return Color("#526f53")
		"plains": return Color("#899d72")
		"rocky": return Color("#8c8c80")
		"arid": return Color("#b6a375")
		"tundra": return Color("#a6b3a6")
	return Color("#527c89")


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
			if _front(float(x), float(step)):
				points.append(_project(float(x), float(step)))
			elif points.size() > 1:
				draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)
				points = PackedVector2Array()
		if points.size() > 1:
			draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)
	for y in range(0, rows + 1, 6):
		var points := PackedVector2Array()
		for step in range(0, columns + 2, 2):
			if step <= columns and _front(float(step), float(y)):
				points.append(_project(float(step), float(y)))
			elif points.size() > 1:
				draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)
				points = PackedVector2Array()
		if points.size() > 1:
			draw_polyline(points, Color("#d5e0cf", 0.08), 1.0, true)


func _draw_sites() -> void:
	for raw_site in preview.get("sites", []):
		var site: Dictionary = raw_site
		var kind := str(site.get("kind", "vacant"))
		if kind == "vacant":
			continue
		if not _front(float(site.get("x", 0)) + 0.5, float(site.get("y", 0)) + 0.5):
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
	var longitude := _longitude(tile_x)
	var latitude := _latitude(tile_y)
	var point := Vector2(cos(latitude) * sin(longitude),
		sin(latitude) * cos(globe_tilt) - cos(latitude) * cos(longitude) * sin(globe_tilt))
	return size * 0.5 + point * _radius()


func _longitude(tile_x: float) -> float:
	var columns := maxf(1.0, float(preview.get("width", 96)))
	return wrapf((tile_x / columns - 0.5) * TAU - globe_rotation, -PI, PI)


func _latitude(tile_y: float) -> float:
	return (tile_y / maxf(1.0, float(preview.get("height", 60))) - 0.5) * PI


func _view_z(tile_x: float, tile_y: float) -> float:
	var longitude := _longitude(tile_x)
	var latitude := _latitude(tile_y)
	return sin(latitude) * sin(globe_tilt) + cos(latitude) * cos(globe_tilt) * cos(longitude)


func _front(tile_x: float, tile_y: float) -> bool:
	return _view_z(tile_x, tile_y) > 0.0


func _tile_from_point(point: Vector2) -> Vector2i:
	var normalized := (point - size * 0.5) / _radius()
	if normalized.length_squared() >= 0.985:
		return Vector2i(-1, -1)
	var depth := sqrt(maxf(0.0, 1.0 - normalized.length_squared()))
	var latitude := asin(clampf(normalized.y * cos(globe_tilt) + depth * sin(globe_tilt), -1.0, 1.0))
	var longitude := atan2(normalized.x, depth * cos(globe_tilt) - normalized.y * sin(globe_tilt))
	var columns := int(preview.get("width", 64))
	var rows := int(preview.get("height", 40))
	return Vector2i(posmod(int(floor(((longitude + globe_rotation) / TAU + 0.5) * columns)), columns), clampi(int(floor((latitude / PI + 0.5) * rows)), 0, rows - 1))


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
		"arid": base = ARID
		"tundra": base = TUNDRA
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
		if _rotating:
			_drag_distance += absf(event.relative.x) + absf(event.relative.y)
			if _drag_distance > 4.0:
				rotate_by(-event.relative.x / maxf(1.0, _radius()), -event.relative.y / maxf(1.0, _radius()))
				accept_event()
				return
		var tile := _tile_from_point(event.position)
		if tile != _hover_tile:
			_hover_tile = tile
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.pressed and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			zoom = clampf(zoom * (1.12 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12), 0.75, 1.65)
			queue_redraw()
			accept_event()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			_rotating = true
			_drag_distance = 0.0
			accept_event()
			return
		_rotating = false
		if _drag_distance > 4.0:
			accept_event()
			return
		var tile := _tile_from_point(event.position)
		if not _is_selectable(tile):
			return
		var existing: Dictionary = _site_at_tile.get("%d:%d" % [tile.x, tile.y], {})
		selected_site_id = str(existing.get("id", "tile_%d_%d" % [tile.x, tile.y]))
		queue_redraw()
		site_selected.emit(selected_site_id)
		accept_event()
