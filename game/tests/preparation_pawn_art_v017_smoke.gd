extends SceneTree

const PawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")


func _initialize() -> void:
	var base := {"sex": "female", "body_type": 0, "head_type": 0, "hair": "bald", "skin": "#d9ad81", "hair_color": "#493329", "shirt": "tshirt", "shirt_color": "#b16f59", "pants": "pants", "pants_color": "#4b5964", "apparel": "none", "hat": "none"}
	var variants: Array[Dictionary] = []
	for sex in ["female", "male"]:
		var styles := ["bald", "short", "bob", "medium", "wavy", "braid", "long"] if sex == "female" else ["bald", "shaved", "short", "sidepart", "curly", "medium", "long"]
		for style in styles:
			var appearance: Dictionary = base.duplicate(true)
			appearance["sex"] = sex
			appearance["hair"] = style
			variants.append(appearance)
	var signatures: Dictionary = {}
	var sheet := Image.create_empty(194 * 10, 194 * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#202a30"))
	for index in variants.size():
		var render := _render(variants[index])
		var key := str(variants[index]["sex"]) + ":" + str(variants[index]["hair"])
		var signature := hash(render.get_data())
		assert(not signatures.has(signature), "Hair drawing duplicates %s" % key)
		signatures[signature] = true
		sheet.blend_rect(render, Rect2i(0, 0, 194, 194), Vector2i(index % 10 * 194, index / 10 * 194))
	var bald := _render(base)
	assert(bald.get_pixel(97, 45).a < 0.1, "Bald hairstyle still paints hair at crown")
	var coat: Dictionary = base.duplicate(true)
	coat["sex"] = "male"
	coat["hair"] = "long"
	coat["apparel"] = "jacket"
	coat["apparel_color"] = "#735f50"
	coat["hat"] = "cap"
	var coat_render := _render(coat)
	assert(coat_render.get_pixel(77, 119).a > 0.5, "Jacket misses left side of torso")
	assert(coat_render.get_pixel(117, 119).a > 0.5, "Jacket misses right side of torso")
	var bald_coat: Dictionary = coat.duplicate(true)
	bald_coat["hair"] = "bald"
	assert(hash(coat_render.get_data()) != hash(_render(bald_coat).get_data()), "Long hair vanishes under cap")
	for sex in ["female", "male"]:
		for style in ["bald", "short", "sidepart", "curly", "shaved", "bob", "wavy", "medium", "long", "braid"]:
			for hat in ["none", "cap", "brim_hat"]:
				var combination: Dictionary = coat.duplicate(true)
				combination["sex"] = sex
				combination["hair"] = style
				combination["hat"] = hat
				assert(_render(combination).get_pixel(97, 120).a > 0.9, "Missing torso in %s/%s/%s" % [sex, style, hat])
	sheet.blend_rect(coat_render, Rect2i(0, 0, 194, 194), Vector2i(0, 388))
	var bare: Dictionary = base.duplicate(true)
	bare["shirt"] = "none"
	bare["pants"] = "none"
	var nude := _render(bare)
	for symmetric_image in [nude, _render(base)]:
		for y in [110, 123, 145]:
			var left_edge := 97
			var right_edge := 97
			for x in range(60, 97):
				if symmetric_image.get_pixel(x, y).a > 0.5:
					left_edge = mini(left_edge, x)
			for x in range(98, 135):
				if symmetric_image.get_pixel(x, y).a > 0.5:
					right_edge = maxi(right_edge, x)
			assert(absi((97 - left_edge) - (right_edge - 97)) <= 2, "Body edge is asymmetric at y=%d" % y)
	var no_coat: Dictionary = coat.duplicate(true)
	no_coat["apparel"] = "none"
	assert(_distance(coat_render.get_pixel(97, 126), _render(no_coat).get_pixel(97, 126)) > 0.12, "Closed coat does not cover the shirt")
	sheet.blend_rect(nude, Rect2i(0, 0, 194, 194), Vector2i(194, 388))
	assert(sheet.save_png("user://preparation-pawn-art-v017-sheet.png") == OK)
	print("PREPARATION_PAWN_ART_V017_SMOKE_OK")
	quit()


func _render(appearance: Dictionary) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(PawnArt._pawn_svg(appearance)) == OK)
	return image


func _distance(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
