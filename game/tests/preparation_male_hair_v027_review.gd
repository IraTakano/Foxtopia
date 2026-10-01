extends SceneTree

const PrepArt = preload("res://scripts/ui/preparation_pawn_art.gd")
const GameArt = preload("res://scripts/ui/smooth_pawn.gd")


func _initialize() -> void:
	var base := {"sex": "male", "body_type": 0, "head_type": 0,
		"skin": "#b78261", "hair_color": "#53382e", "shirt": "tshirt",
		"shirt_color": "#bda66c", "pants": "pants", "pants_color": "#5f6768",
		"apparel": "none", "hat_color": "#bd8a11"}
	var prep_sheet := Image.create_empty(194 * 3, 194 * 2, false, Image.FORMAT_RGBA8)
	var game_sheet := Image.create_empty(256 * 3, 256 * 2, false, Image.FORMAT_RGBA8)
	prep_sheet.fill(Color("#202a30"))
	game_sheet.fill(Color("#202a30"))
	var prep_uncovered: Array[Image] = []
	var game_uncovered: Array[Image] = []
	for row in 2:
		for column in 3:
			var appearance: Dictionary = base.duplicate(true)
			appearance["hair"] = "medium" if row == 0 else "long"
			appearance["hat"] = ["none", "cap", "brim_hat"][column]
			var prep := _render(PrepArt._pawn_svg(appearance))
			var game := _render(GameArt._pawn_svg(appearance, false))
			prep_sheet.blend_rect(prep, Rect2i(0, 0, 194, 194), Vector2i(column * 194, row * 194))
			game_sheet.blend_rect(game, Rect2i(0, 0, 256, 256), Vector2i(column * 256, row * 256))
			if column == 0:
				prep_uncovered.append(prep)
				game_uncovered.append(game)
	assert(_changed_pixels(prep_uncovered[0], prep_uncovered[1], Rect2i(74, 43, 48, 74)) > 70)
	assert(_changed_pixels(game_uncovered[0], game_uncovered[1], Rect2i(76, 40, 105, 110)) > 180)
	assert(prep_sheet.save_png("user://male-hair-v027-prep.png") == OK)
	assert(game_sheet.save_png("user://male-hair-v027-game.png") == OK)
	print("PREPARATION_MALE_HAIR_V027_REVIEW_OK")
	quit()


func _render(svg: String) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(svg) == OK)
	return image


func _changed_pixels(first: Image, second: Image, area: Rect2i) -> int:
	var count := 0
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var a := first.get_pixel(x, y)
			var b := second.get_pixel(x, y)
			if absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a) > 0.12:
				count += 1
	return count
