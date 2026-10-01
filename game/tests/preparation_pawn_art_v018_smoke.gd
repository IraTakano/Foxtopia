extends SceneTree

const PawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")


func _initialize() -> void:
	var base := {"sex": "female", "body_type": 0, "head_type": 0, "hair": "long", "skin": "#9c604b", "hair_color": "#663a39", "shirt": "tshirt", "shirt_color": "#c7ad72", "pants": "pants", "pants_color": "#5a686e", "apparel": "none", "apparel_color": "#78614e", "hat": "none", "hat_color": "#bd8a11"}
	var variants: Array[Dictionary] = []
	for hairstyle in ["long", "wavy", "bob", "medium", "braid"]:
		var variant: Dictionary = base.duplicate(true)
		variant["hair"] = hairstyle
		variants.append(variant)
	for hairstyle in ["long", "wavy", "bob", "medium", "braid"]:
		var variant: Dictionary = base.duplicate(true)
		variant["hair"] = hairstyle
		variant["hat"] = "brim_hat"
		variants.append(variant)
	var coat: Dictionary = base.duplicate(true)
	coat["apparel"] = "jacket"
	variants.append(coat)
	var broad: Dictionary = coat.duplicate(true)
	broad["sex"] = "male"
	broad["body_type"] = 1
	broad["hat"] = "cap"
	variants.append(broad)
	var sheet := Image.create_empty(194 * 5, 194 * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#202a30"))
	var backdrop := PawnArt._portrait_background_image()
	assert(_color_delta(backdrop.get_pixel(55, 55), backdrop.get_pixel(56, 55)) > 0.002, "Portrait backdrop has no grain")
	for index in variants.size():
		var render := _render(variants[index])
		sheet.blit_rect(backdrop, Rect2i(0, 0, 194, 194), Vector2i((index % 5) * 194, (index / 5) * 194))
		sheet.blend_rect(render, Rect2i(0, 0, 194, 194), Vector2i((index % 5) * 194, (index / 5) * 194))
		# Neither dark nor light skin should contain a left/right face seam.
		assert(_color_delta(render.get_pixel(93, 90), render.get_pixel(101, 90)) < 0.04, "Face is split into two tones")
		assert(render.get_pixel(97, 128).a > 0.95, "Torso has a hole at the trouser seam")
		assert(render.get_pixel(97, 140).a > 0.95, "Trousers have a hole below the shirt")
	var bald_hat: Dictionary = base.duplicate(true)
	bald_hat["hair"] = "bald"
	bald_hat["hat"] = "brim_hat"
	var long_hat: Dictionary = base.duplicate(true)
	long_hat["hat"] = "brim_hat"
	assert(_color_delta(_render(bald_hat).get_pixel(97, 80), _render(long_hat).get_pixel(97, 80)) < 0.04, "Bowler hat leaves front hair across the face")
	assert(_color_delta(_render(bald_hat).get_pixel(78, 104), _render(long_hat).get_pixel(78, 104)) > 0.15, "Bowler hat hides long side hair")
	var without_coat: Dictionary = coat.duplicate(true)
	without_coat["apparel"] = "none"
	assert(_color_delta(_render(coat).get_pixel(97, 150), _render(without_coat).get_pixel(97, 150)) > 0.2, "Coat ends at shirt hem")
	assert(sheet.save_png("user://preparation-pawn-art-v018-sheet.png") == OK)
	assert(backdrop.save_png("user://preparation-pawn-art-v018-background.png") == OK)
	print("PREPARATION_PAWN_ART_V018_SMOKE_OK")
	quit()


func _render(appearance: Dictionary) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(PawnArt._pawn_svg(appearance)) == OK, "Pawn SVG did not render")
	return image


func _color_delta(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
