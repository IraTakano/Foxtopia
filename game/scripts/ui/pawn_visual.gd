extends RefCounted

## Original layered top-down pawn shared by the map, portraits and editor.
## Detail is added at larger sizes so the same silhouette reads on a map tile.

static func draw_pawn(canvas: CanvasItem, center: Vector2, diameter: float, appearance: Dictionary, selected: bool = false, enemy: bool = false, drafted: bool = false) -> void:
	var r := diameter * 0.5
	var skin := _color(str(appearance.get("skin", "#d9ad81")), Color("#d9ad81"))
	var outfit := _color(str(appearance.get("outfit", "#527a81")), Color("#527a81"))
	var hair := _color(str(appearance.get("hair_color", "#4d3c32")), Color("#4d3c32"))
	var hairstyle := str(appearance.get("hair", "short")).to_lower()
	if enemy:
		outfit = Color("#a65b51")

	_ellipse(canvas, center + Vector2(0, r * 0.78), r * 0.55, r * 0.16, Color("#101919", 0.28))
	if selected:
		_ellipse_outline(canvas, center + Vector2(0, r * 0.58), r * 0.76, r * 0.42, Color("#ead282"), maxf(1.5, diameter * 0.035))
	if drafted:
		_ellipse_outline(canvas, center + Vector2(0, r * 0.58), r * 0.85, r * 0.49, Color("#dc8e78"), maxf(1.3, diameter * 0.025))

	var head := center + Vector2(0, -r * 0.17)
	if hairstyle == "long":
		_poly(canvas, head, r, [
			Vector2(-0.34, -0.37), Vector2(-0.46, -0.29), Vector2(-0.52, -0.08),
			Vector2(-0.50, 0.29), Vector2(-0.45, 0.59), Vector2(-0.34, 0.72),
			Vector2(-0.22, 0.67), Vector2(-0.15, 0.32), Vector2(0.15, 0.32),
			Vector2(0.22, 0.67), Vector2(0.34, 0.72), Vector2(0.45, 0.59),
			Vector2(0.50, 0.29), Vector2(0.52, -0.08), Vector2(0.46, -0.29),
			Vector2(0.34, -0.37)
		], hair.darkened(0.20))

	var silhouette := [
		Vector2(-0.28, 0.05), Vector2(-0.40, 0.08), Vector2(-0.49, 0.17),
		Vector2(-0.55, 0.33), Vector2(-0.55, 0.60), Vector2(-0.52, 0.73),
		Vector2(-0.44, 0.84), Vector2(-0.27, 0.91), Vector2(0.27, 0.91),
		Vector2(0.44, 0.84), Vector2(0.52, 0.73), Vector2(0.55, 0.60),
		Vector2(0.55, 0.33), Vector2(0.49, 0.17), Vector2(0.40, 0.08),
		Vector2(0.28, 0.05)
	]
	_poly(canvas, center, r, silhouette, Color("#263432"))
	_poly(canvas, center, r * 0.94, silhouette, outfit.darkened(0.12))
	_poly(canvas, center, r, [
		Vector2(-0.29, 0.11), Vector2(-0.40, 0.15), Vector2(-0.47, 0.31),
		Vector2(-0.47, 0.68), Vector2(-0.40, 0.79), Vector2(-0.23, 0.84),
		Vector2(0.13, 0.84), Vector2(0.18, 0.23), Vector2(0.04, 0.11)
	], outfit.lightened(0.075))
	_poly(canvas, center, r, [
		Vector2(0.19, 0.15), Vector2(0.38, 0.18), Vector2(0.48, 0.33),
		Vector2(0.47, 0.68), Vector2(0.39, 0.79), Vector2(0.27, 0.84),
		Vector2(0.14, 0.84)
	], outfit.darkened(0.20))
	_poly(canvas, center, r, [
		Vector2(-0.21, 0.08), Vector2(0, 0.28), Vector2(0.21, 0.08),
		Vector2(0.15, 0.04), Vector2(0, 0.17), Vector2(-0.15, 0.04)
	], outfit.darkened(0.27))
	# A broad collar, inset chest and a utility pocket make this a garment.
	_poly(canvas, center, r, [
		Vector2(-0.24, 0.10), Vector2(-0.12, 0.08), Vector2(0, 0.23),
		Vector2(0.12, 0.08), Vector2(0.24, 0.10), Vector2(0.16, 0.30),
		Vector2(0, 0.37), Vector2(-0.16, 0.30)
	], outfit.lightened(0.22))
	if diameter >= 34.0:
		canvas.draw_line(center + Vector2(-r * 0.36, r * 0.34), center + Vector2(-r * 0.36, r * 0.68), outfit.darkened(0.35), maxf(0.8, r * 0.012), true)
		canvas.draw_line(center + Vector2(r * 0.36, r * 0.34), center + Vector2(r * 0.36, r * 0.68), outfit.darkened(0.35), maxf(0.8, r * 0.012), true)
		_poly(canvas, center, r, [
			Vector2(0.16, 0.48), Vector2(0.37, 0.47), Vector2(0.36, 0.66),
			Vector2(0.26, 0.71), Vector2(0.16, 0.66)
		], outfit.darkened(0.33))
		_poly(canvas, center, r, [
			Vector2(0.19, 0.51), Vector2(0.34, 0.50), Vector2(0.33, 0.64),
			Vector2(0.26, 0.67), Vector2(0.19, 0.63)
		], outfit.lightened(0.14))
		canvas.draw_line(center + Vector2(-r * 0.22, r * 0.79), center + Vector2(r * 0.15, r * 0.79), outfit.darkened(0.31), maxf(0.8, r * 0.013), true)
	if diameter >= 70.0:
		canvas.draw_line(center + Vector2(-r * 0.08, r * 0.39), center + Vector2(-r * 0.08, r * 0.72), outfit.darkened(0.25), maxf(1.0, r * 0.014), true)
		_ellipse(canvas, center + Vector2(-r * 0.08, r * 0.53), r * 0.018, r * 0.018, outfit.lightened(0.40))
		_ellipse(canvas, center + Vector2(-r * 0.08, r * 0.67), r * 0.018, r * 0.018, outfit.lightened(0.40))

	# Neck and ears establish the direction of the face on a top-down tile.
	_poly(canvas, center, r, [Vector2(-0.14, 0.05), Vector2(0.14, 0.05), Vector2(0.14, 0.28), Vector2(0.0, 0.34), Vector2(-0.14, 0.28)], skin.darkened(0.17))
	_poly(canvas, center, r, [Vector2(-0.10, 0.06), Vector2(0.10, 0.06), Vector2(0.10, 0.24), Vector2(0.0, 0.29), Vector2(-0.10, 0.24)], skin)
	_ellipse(canvas, head + Vector2(-r * 0.39, r * 0.04), r * 0.09, r * 0.13, Color("#27312e"))
	_ellipse(canvas, head + Vector2(r * 0.39, r * 0.04), r * 0.09, r * 0.13, Color("#27312e"))
	_ellipse(canvas, head + Vector2(-r * 0.39, r * 0.04), r * 0.055, r * 0.09, skin.darkened(0.08))
	_ellipse(canvas, head + Vector2(r * 0.39, r * 0.04), r * 0.055, r * 0.09, skin.darkened(0.08))
	_draw_face(canvas, head, r, diameter, skin, hair)
	_draw_hair(canvas, head, r, skin, hair, hairstyle)


static func _draw_face(canvas: CanvasItem, head: Vector2, r: float, diameter: float, skin: Color, hair: Color) -> void:
	# A faceted jaw, lit forehead and cheek plane add expression without
	# turning the figure into a front-facing full-body character.
	var shape := [
		Vector2(-0.19, -0.43), Vector2(-0.34, -0.35), Vector2(-0.42, -0.19),
		Vector2(-0.43, 0.03), Vector2(-0.37, 0.21), Vector2(-0.25, 0.36),
		Vector2(-0.10, 0.43), Vector2(0.10, 0.43), Vector2(0.25, 0.36),
		Vector2(0.38, 0.20), Vector2(0.43, 0.02), Vector2(0.41, -0.20),
		Vector2(0.30, -0.38), Vector2(0.14, -0.44)
	]
	_poly(canvas, head, r, shape, Color("#27312e"))
	_poly(canvas, head, r * 0.92, shape, skin.darkened(0.13))
	_poly(canvas, head + Vector2(-r * 0.025, -r * 0.025), r * 0.86, shape, skin)
	_poly(canvas, head, r, [
		Vector2(-0.27, -0.24), Vector2(-0.14, -0.34), Vector2(0.13, -0.34),
		Vector2(0.28, -0.22), Vector2(0.18, -0.13), Vector2(-0.19, -0.13)
	], skin.lightened(0.07))
	_poly(canvas, head, r, [
		Vector2(0.26, 0.00), Vector2(0.35, 0.03), Vector2(0.31, 0.19),
		Vector2(0.17, 0.30), Vector2(0.22, 0.13)
	], skin.darkened(0.08))
	if diameter < 23.0:
		return
	var ink := hair.darkened(0.45).lerp(Color("#202522"), 0.42)
	_ellipse(canvas, head + Vector2(-r * 0.155, r * 0.06), maxf(0.8, r * 0.042), maxf(0.8, r * 0.034), ink)
	_ellipse(canvas, head + Vector2(r * 0.155, r * 0.06), maxf(0.8, r * 0.042), maxf(0.8, r * 0.034), ink)
	if diameter < 45.0:
		return
	canvas.draw_line(head + Vector2(-r * 0.24, -r * 0.04), head + Vector2(-r * 0.09, -r * 0.06), ink, maxf(1.0, r * 0.022), true)
	canvas.draw_line(head + Vector2(r * 0.09, -r * 0.06), head + Vector2(r * 0.24, -r * 0.04), ink, maxf(1.0, r * 0.022), true)
	_poly(canvas, head, r, [Vector2(-0.025, 0.10), Vector2(0.055, 0.10), Vector2(0.085, 0.20), Vector2(-0.015, 0.21)], skin.darkened(0.16))
	canvas.draw_line(head + Vector2(-r * 0.09, r * 0.28), head + Vector2(r * 0.09, r * 0.28), skin.darkened(0.34), maxf(1.0, r * 0.018), true)
	if diameter < 80.0:
		return
	_ellipse(canvas, head + Vector2(-r * 0.16, r * 0.052), r * 0.016, r * 0.012, Color("#f0e5cf"))
	_ellipse(canvas, head + Vector2(r * 0.15, r * 0.052), r * 0.016, r * 0.012, Color("#f0e5cf"))
	canvas.draw_line(head + Vector2(-r * 0.24, r * 0.18), head + Vector2(-r * 0.17, r * 0.20), skin.lightened(0.14), maxf(1.0, r * 0.018), true)


static func _draw_hair(canvas: CanvasItem, head: Vector2, r: float, skin: Color, hair: Color, style: String) -> void:
	match style:
		"shaved":
			var stubble := skin.darkened(0.10).lerp(hair, 0.28)
			_poly(canvas, head, r, [
				Vector2(-0.37, -0.11), Vector2(-0.35, -0.28), Vector2(-0.24, -0.40),
				Vector2(-0.06, -0.44), Vector2(0.18, -0.41), Vector2(0.33, -0.29),
				Vector2(0.38, -0.09), Vector2(0.28, -0.21), Vector2(0.02, -0.26),
				Vector2(-0.25, -0.20)
			], stubble)
			_poly(canvas, head, r, [Vector2(-0.19, -0.38), Vector2(-0.04, -0.41), Vector2(0.20, -0.35), Vector2(0.11, -0.32), Vector2(-0.12, -0.34)], stubble.lightened(0.08))
		"curly":
			_hair_cap(canvas, head, r, hair.darkened(0.14), false)
			for offset in [Vector2(-0.32, -0.30), Vector2(-0.16, -0.43), Vector2(0.04, -0.45), Vector2(0.24, -0.38), Vector2(0.34, -0.23), Vector2(-0.34, -0.12)]:
				_ellipse(canvas, head + offset * r, r * 0.13, r * 0.12, hair)
			for offset in [Vector2(-0.19, -0.45), Vector2(0.02, -0.46), Vector2(0.28, -0.34)]:
				_ellipse(canvas, head + offset * r, r * 0.045, r * 0.035, hair.lightened(0.18))
		"wavy":
			_hair_cap(canvas, head, r, hair, true)
			_poly(canvas, head, r, [
				Vector2(-0.41, -0.25), Vector2(-0.29, -0.37), Vector2(-0.13, -0.40),
				Vector2(0.03, -0.34), Vector2(0.16, -0.40), Vector2(0.35, -0.27),
				Vector2(0.32, -0.12), Vector2(0.15, -0.17), Vector2(0.03, -0.11),
				Vector2(-0.11, -0.15), Vector2(-0.23, -0.07), Vector2(-0.38, -0.10)
			], hair.lightened(0.09))
			_poly(canvas, head, r, [
				Vector2(-0.39, -0.17), Vector2(-0.46, -0.01), Vector2(-0.43, 0.17),
				Vector2(-0.36, 0.27), Vector2(-0.29, 0.18), Vector2(-0.32, -0.09)
			], hair.darkened(0.08))
			_poly(canvas, head, r, [
				Vector2(0.39, -0.17), Vector2(0.46, -0.01), Vector2(0.43, 0.17),
				Vector2(0.36, 0.27), Vector2(0.29, 0.18), Vector2(0.32, -0.09)
			], hair.darkened(0.15))
		"long":
			_hair_cap(canvas, head, r, hair, true)
			_poly(canvas, head, r, [
				Vector2(-0.40, -0.20), Vector2(-0.42, 0.20), Vector2(-0.37, 0.49),
				Vector2(-0.27, 0.55), Vector2(-0.26, 0.17), Vector2(-0.29, -0.12)
			], hair.darkened(0.035))
			_poly(canvas, head, r, [
				Vector2(0.40, -0.20), Vector2(0.42, 0.20), Vector2(0.37, 0.49),
				Vector2(0.27, 0.55), Vector2(0.26, 0.17), Vector2(0.29, -0.12)
			], hair.darkened(0.12))
			canvas.draw_line(head + Vector2(-r * 0.35, r * 0.08), head + Vector2(-r * 0.33, r * 0.43), hair.lightened(0.16), maxf(0.8, r * 0.018), true)
		_:
			_hair_cap(canvas, head, r, hair, false)
			_poly(canvas, head, r, [
				Vector2(-0.37, -0.14), Vector2(-0.25, -0.27), Vector2(-0.04, -0.19),
				Vector2(0.12, -0.25), Vector2(0.30, -0.17), Vector2(0.23, -0.10),
				Vector2(0.03, -0.14), Vector2(-0.16, -0.08)
			], hair.darkened(0.06))


static func _hair_cap(canvas: CanvasItem, head: Vector2, r: float, hair: Color, broad: bool) -> void:
	var side := 0.43 if broad else 0.39
	_poly(canvas, head, r, [
		Vector2(-side, -0.11), Vector2(-0.38, -0.31), Vector2(-0.28, -0.42),
		Vector2(-0.12, -0.47), Vector2(0.11, -0.47), Vector2(0.29, -0.39),
		Vector2(0.39, -0.28), Vector2(side, -0.08), Vector2(0.29, -0.17),
		Vector2(0.13, -0.18), Vector2(-0.04, -0.15), Vector2(-0.22, -0.19)
	], hair)
	_poly(canvas, head, r, [
		Vector2(-0.29, -0.36), Vector2(-0.15, -0.43), Vector2(0.10, -0.43),
		Vector2(0.28, -0.35), Vector2(0.10, -0.38), Vector2(-0.11, -0.37)
	], hair.lightened(0.17))


static func _poly(canvas: CanvasItem, origin: Vector2, r: float, points: Array, color: Color) -> void:
	var scaled := PackedVector2Array()
	for point in points:
		scaled.append(origin + point * r)
	canvas.draw_colored_polygon(scaled, color)


static func _ellipse(canvas: CanvasItem, origin: Vector2, rx: float, ry: float, color: Color) -> void:
	var points := PackedVector2Array()
	for step in range(28):
		var angle := float(step) * TAU / 28.0
		points.append(origin + Vector2(cos(angle) * rx, sin(angle) * ry))
	canvas.draw_colored_polygon(points, color)


static func _ellipse_outline(canvas: CanvasItem, origin: Vector2, rx: float, ry: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for step in range(33):
		var angle := float(step) * TAU / 32.0
		points.append(origin + Vector2(cos(angle) * rx, sin(angle) * ry))
	canvas.draw_polyline(points, color, width, true)


static func _color(value: String, fallback: Color) -> Color:
	if value.begins_with("#"):
		return Color(value)
	match value:
		"light": return Color("#f0c9a5")
		"medium": return Color("#d0a178")
		"dark": return Color("#865842")
		"blue": return Color("#527a81")
		"red": return Color("#ae735b")
		"green": return Color("#788965")
	return fallback
