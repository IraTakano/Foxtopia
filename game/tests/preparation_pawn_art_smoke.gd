extends SceneTree

const PawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")


func _initialize() -> void:
	var base := {"sex": "female", "body_type": 0, "head_type": 0, "hair": "bob", "skin": "#d9ad81", "hair_color": "#493329", "shirt": "tshirt", "shirt_color": "#9e7d56", "pants": "pants", "pants_color": "#4b5964", "apparel": "none"}
	var variants: Array[Dictionary] = []
	for style in ["bald", "bob", "wavy", "long", "braid", "short", "medium", "sidepart"]:
		var spec: Dictionary = base.duplicate(true)
		if style == "sidepart":
			spec["sex"] = "male"
		spec["hair"] = style
		variants.append(spec)
	var signatures: Dictionary = {}
	var sheet := Image.create_empty(194 * 4, 194 * 2, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#202a30"))
	for i in variants.size():
		var image := _render(variants[i])
		var signature := hash(image.get_data())
		assert(not signatures.has(signature), "Hair style is visually identical: %s" % variants[i]["hair"])
		signatures[signature] = true
		sheet.blit_rect(image, Rect2i(Vector2i.ZERO, Vector2i(194, 194)), Vector2i((i % 4) * 194, (i / 4) * 194))
	var bare: Dictionary = base.duplicate(true)
	bare["shirt"] = "none"
	bare["pants"] = "none"
	var bare_image := _render(bare)
	var dressed_image := _render(base)
	assert(_difference(bare_image.get_pixel(97, 120), dressed_image.get_pixel(97, 120)) > 0.1, "Torso clothing does not disappear")
	assert(_difference(bare_image.get_pixel(97, 145), dressed_image.get_pixel(97, 145)) > 0.1, "Leg clothing does not disappear")
	var recolored: Dictionary = bare.duplicate(true)
	recolored["skin"] = "#855b44"
	var dark_image := _render(recolored)
	assert(_difference(bare_image.get_pixel(97, 94), dark_image.get_pixel(97, 94)) > 0.1, "Skin color did not change")
	assert(_difference(bare_image.get_pixel(89, 81), dark_image.get_pixel(89, 81)) < 0.1, "Eye details changed with the skin color")
	var broad: Dictionary = base.duplicate(true)
	broad["body_type"] = 1
	assert(_render(broad).get_pixel(70, 116).a > dressed_image.get_pixel(70, 116).a, "Broad body does not widen")
	assert(sheet.save_png("user://preparation-pawn-art-sheet.png") == OK)
	print("PREPARATION_PAWN_ART_SMOKE_OK")
	quit()


func _render(appearance: Dictionary) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(PawnArt._pawn_svg(appearance)) == OK, "Portrait SVG did not render")
	return image


func _difference(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
