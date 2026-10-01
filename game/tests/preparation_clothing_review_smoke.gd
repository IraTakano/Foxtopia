extends SceneTree

const PrepArt = preload("res://scripts/ui/preparation_pawn_art.gd")
const GameArt = preload("res://scripts/ui/smooth_pawn.gd")

func _initialize() -> void:
	var prep_sheet := Image.create_empty(194 * 5, 194 * 4, false, Image.FORMAT_RGBA8)
	var game_sheet := Image.create_empty(256 * 5, 256 * 4, false, Image.FORMAT_RGBA8)
	prep_sheet.fill(Color("#202a30"))
	game_sheet.fill(Color("#202a30"))
	var prep_widths: Array[int] = []
	var game_widths: Array[int] = []
	for row in 4:
		var sex := "female" if row < 2 else "male"
		var body_type := row % 2
		for column in 5:
			var appearance := {"sex": sex, "body_type": body_type, "head_type": 0, "skin": "#c48c68", "hair": "bob" if sex == "female" else "short", "hair_color": "#553a2d", "shirt": "none", "shirt_color": "#b1c97c", "pants": "none", "pants_color": "#546780", "apparel": "none", "apparel_color": "#93745a", "hat": "none"}
			match column:
				1: appearance["shirt"] = "tshirt"
				2:
					appearance["shirt"] = "tshirt"
					appearance["pants"] = "pants"
				3:
					appearance["shirt"] = "tshirt"
					appearance["pants"] = "pants"
					appearance["apparel"] = "jacket"
				4:
					appearance["pants"] = "pants"
					appearance["apparel"] = "jacket"
			var prep_image := _render(PrepArt._pawn_svg(appearance))
			prep_sheet.blend_rect(prep_image, Rect2i(0, 0, 194, 194), Vector2i(column * 194, row * 194))
			var game_image := _render(GameArt._pawn_svg(appearance, false))
			game_sheet.blend_rect(game_image, Rect2i(0, 0, 256, 256), Vector2i(column * 256, row * 256))
			if column == 0:
				prep_widths.append(_alpha_span(prep_image, 115))
				game_widths.append(_alpha_span(game_image, 175))
			if column == 3:
				var recolored: Dictionary = appearance.duplicate(true)
				recolored["shirt_color"] = "#f045ad"
				assert(prep_image.get_data() == _render(PrepArt._pawn_svg(recolored)).get_data(), "Coat exposes the shirt in preparation")
				assert(game_image.get_data() == _render(GameArt._pawn_svg(recolored, false)).get_data(), "Coat exposes the shirt in game")
			if column == 1:
				var bare: Dictionary = appearance.duplicate(true)
				bare["shirt"] = "none"
				var prep_bare := _render(PrepArt._pawn_svg(bare))
				var game_bare := _render(GameArt._pawn_svg(bare, false))
				assert(_color_distance(prep_image.get_pixel(97, 145), prep_bare.get_pixel(97, 145)) < 0.01, "Preparation shirt hides the bare lower body")
				assert(_color_distance(game_image.get_pixel(128, 225), game_bare.get_pixel(128, 225)) < 0.01, "Game shirt hides the bare lower body")
				assert(_color_distance(prep_image.get_pixel(97, 115), prep_bare.get_pixel(97, 115)) > 0.1, "Preparation shirt vanished from the upper body")
				assert(_color_distance(game_image.get_pixel(128, 180), game_bare.get_pixel(128, 180)) > 0.1, "Game shirt vanished from the upper body")
	assert(prep_widths[0] < prep_widths[2] and prep_widths[1] < prep_widths[3], "Preparation sex silhouettes are indistinct")
	assert(prep_widths[0] < prep_widths[1] and prep_widths[2] < prep_widths[3], "Preparation broad body does not widen")
	assert(game_widths[0] < game_widths[2] and game_widths[1] < game_widths[3], "Game sex silhouettes are indistinct")
	assert(game_widths[0] < game_widths[1] and game_widths[2] < game_widths[3], "Game broad body does not widen")
	assert(prep_sheet.save_png("user://preparation-clothing-review.png") == OK)
	assert(game_sheet.save_png("user://game-clothing-review.png") == OK)
	print("PREPARATION_CLOTHING_REVIEW_OK")
	quit()


func _render(svg: String) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(svg) == OK)
	return image


func _alpha_span(image: Image, y: int) -> int:
	var left := image.get_width()
	var right := -1
	for x in image.get_width():
		if image.get_pixel(x, y).a >= 0.5:
			left = mini(left, x)
			right = maxi(right, x)
	return right - left + 1


func _color_distance(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b)
