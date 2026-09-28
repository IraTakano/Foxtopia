extends RefCounted

## A compact, original top-down pawn assembled from editable layers.
## Used by both the preparation preview and the map, so appearance never diverges.

static func draw_pawn(canvas: CanvasItem, center: Vector2, diameter: float, appearance: Dictionary, selected: bool = false, enemy: bool = false, drafted: bool = false) -> void:
	var r := diameter * 0.5
	var skin := _color(str(appearance.get("skin", "#d9ad81")), Color("#d9ad81"))
	var outfit := _color(str(appearance.get("outfit", "#527a81")), Color("#527a81"))
	var hair := _color(str(appearance.get("hair_color", "#4d3c32")), Color("#4d3c32"))
	var hair_style := str(appearance.get("hair", "short"))
	if enemy:
		outfit = Color("#a65b51")
	# All pieces use the same proportions in the lobby preview and on the map.
	canvas.draw_circle(center + Vector2(0, r * 0.70), r * 0.62, Color("#12211f", 0.35))
	if selected:
		canvas.draw_arc(center + Vector2(0, r * 0.43), r * 0.88, 0, TAU, 32, Color("#f2d180"), maxf(2.0, diameter * 0.06))
	if drafted:
		canvas.draw_arc(center + Vector2(0, r * 0.43), r * 0.98, 0, TAU, 32, Color("#e19479"), maxf(1.5, diameter * 0.04))
	var body_points := PackedVector2Array([
		center + Vector2(-r * 0.40, r * 0.06),
		center + Vector2(-r * 0.56, r * 0.42),
		center + Vector2(-r * 0.46, r * 0.82),
		center + Vector2(-r * 0.25, r * 0.95),
		center + Vector2(r * 0.25, r * 0.95),
		center + Vector2(r * 0.46, r * 0.82),
		center + Vector2(r * 0.56, r * 0.42),
		center + Vector2(r * 0.40, r * 0.06),
	])
	canvas.draw_colored_polygon(body_points, Color("#293532"))
	canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(-r * 0.35, r * 0.11),
		center + Vector2(-r * 0.48, r * 0.43),
		center + Vector2(-r * 0.39, r * 0.78),
		center + Vector2(-r * 0.20, r * 0.88),
		center + Vector2(r * 0.20, r * 0.88),
		center + Vector2(r * 0.39, r * 0.78),
		center + Vector2(r * 0.48, r * 0.43),
		center + Vector2(r * 0.35, r * 0.11),
	]), outfit)
	canvas.draw_colored_polygon(PackedVector2Array([
		center + Vector2(-r * 0.35, r * 0.18),
		center + Vector2(-r * 0.24, r * 0.75),
		center + Vector2(r * 0.19, r * 0.76),
		center + Vector2(r * 0.34, r * 0.18),
	]), outfit.lightened(0.08))
	var head_center := center + Vector2(0, -r * 0.23)
	if hair_style == "long":
		canvas.draw_rect(Rect2(head_center + Vector2(-r * 0.52, -r * 0.03), Vector2(r * 0.24, r * 0.82)), hair.darkened(0.10))
		canvas.draw_rect(Rect2(head_center + Vector2(r * 0.28, -r * 0.03), Vector2(r * 0.24, r * 0.82)), hair.darkened(0.10))
	canvas.draw_circle(head_center, r * 0.49, Color("#293532"))
	canvas.draw_circle(head_center, r * 0.45, skin)
	canvas.draw_arc(head_center + Vector2(-r * 0.04, -r * 0.04), r * 0.36, PI * 1.02, PI * 1.82, 12, skin.lightened(0.12), maxf(1.0, r * 0.07))
	match hair_style:
		"shaved":
			canvas.draw_arc(head_center, r * 0.43, PI * 1.08, PI * 1.92, 14, hair, maxf(1.0, r * 0.11))
		"curly":
			for offset in [Vector2(-0.35, -0.22), Vector2(-0.25, -0.40), Vector2(-0.05, -0.48), Vector2(0.16, -0.46), Vector2(0.35, -0.32)]:
				canvas.draw_circle(head_center + offset * r, r * 0.17, hair)
		"wavy":
			canvas.draw_colored_polygon(PackedVector2Array([
				head_center + Vector2(-0.45, -0.08) * r,
				head_center + Vector2(-0.40, -0.37) * r,
				head_center + Vector2(-0.18, -0.51) * r,
				head_center + Vector2(0.04, -0.42) * r,
				head_center + Vector2(0.22, -0.53) * r,
				head_center + Vector2(0.41, -0.30) * r,
				head_center + Vector2(0.43, -0.02) * r,
				head_center + Vector2(0.11, -0.23) * r,
				head_center + Vector2(-0.17, -0.17) * r
			]), hair)
		"long":
			canvas.draw_arc(head_center, r * 0.43, PI * 1.06, PI * 1.94, 17, hair, maxf(2.0, r * 0.20))
		_:
			canvas.draw_arc(head_center, r * 0.42, PI * 1.08, PI * 1.92, 15, hair, maxf(2.0, r * 0.21))
			canvas.draw_colored_polygon(PackedVector2Array([
				head_center + Vector2(-0.39, -0.22) * r,
				head_center + Vector2(0.03, -0.48) * r,
				head_center + Vector2(0.36, -0.26) * r,
				head_center + Vector2(0.16, -0.12) * r
			]), hair)
	if diameter >= 55.0:
		canvas.draw_circle(head_center + Vector2(-r * 0.14, r * 0.11), r * 0.027, Color("#3c322c"))
		canvas.draw_circle(head_center + Vector2(r * 0.14, r * 0.11), r * 0.027, Color("#3c322c"))


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
