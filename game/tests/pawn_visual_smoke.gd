extends SceneTree

const SmoothPawn = preload("res://scripts/ui/smooth_pawn.gd")


func _initialize() -> void:
	var variants := [
		{"sex": "male", "body_type": 0, "head_type": 0, "hair": "short", "shirt": "tshirt", "pants": "pants"},
		{"sex": "male", "body_type": 1, "head_type": 1, "hair": "sidepart", "shirt": "tshirt", "pants": "pants"},
		{"sex": "male", "body_type": 0, "head_type": 1, "hair": "curly", "shirt": "none", "pants": "none"},
		{"sex": "female", "body_type": 0, "head_type": 0, "hair": "bob", "shirt": "tshirt", "pants": "pants"},
		{"sex": "female", "body_type": 1, "head_type": 1, "hair": "wavy", "shirt": "tshirt", "pants": "pants"},
		{"sex": "female", "body_type": 0, "head_type": 1, "hair": "long", "shirt": "none", "pants": "none"},
		{"sex": "female", "body_type": 1, "head_type": 0, "hair": "braid", "shirt": "tshirt", "pants": "pants", "apparel": "jacket"},
	]
	for appearance in variants:
		var image := Image.new()
		assert(image.load_svg_from_string(SmoothPawn._pawn_svg(appearance, false)) == OK, "A colonist appearance could not render.")
		assert(image.get_size() == Vector2i(256, 256))
		assert(image.get_pixel(128, 118).a > 0.95, "Face is missing.")
		assert(image.get_pixel(128, 181).a > 0.95, "Body is missing.")
	var base: Dictionary = variants[0].duplicate(true)
	var bare: Dictionary = base.duplicate(true)
	bare["shirt"] = "none"
	bare["pants"] = "none"
	var dressed_image := _render(base)
	var bare_image := _render(bare)
	assert(_color_distance(dressed_image.get_pixel(128, 180), bare_image.get_pixel(128, 180)) > 0.1, "Shirt does not change the body.")
	assert(_color_distance(dressed_image.get_pixel(128, 205), bare_image.get_pixel(128, 205)) > 0.1, "Pants do not change the body.")
	var jacket: Dictionary = base.duplicate(true)
	jacket["apparel"] = "jacket"
	assert(_color_distance(_render(jacket).get_pixel(112, 180), dressed_image.get_pixel(112, 180)) > 0.05, "Jacket layer is missing.")
	var soft_edge_found := false
	for y in range(45, 232):
		for x in range(73, 183):
			var alpha := dressed_image.get_pixel(x, y).a
			if alpha > 0.05 and alpha < 0.95:
				soft_edge_found = true
				break
		if soft_edge_found:
			break
	assert(soft_edge_found, "Curved silhouette has no antialiasing.")
	for garment in ["tshirt", "pants", "jacket"]:
		assert(_render_icon(garment).get_pixel(128, 100).a > 0.8, "A garment icon failed to render.")
	print("PAWN_VISUAL_SMOKE_OK")
	quit()


func _render(appearance: Dictionary) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(SmoothPawn._pawn_svg(appearance, false)) == OK)
	return image


func _render_icon(item_id: String) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(SmoothPawn._apparel_svg(item_id, Color("#66818c"))) == OK)
	return image


func _color_distance(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
