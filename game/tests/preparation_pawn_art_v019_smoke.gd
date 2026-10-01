extends SceneTree

const PreparationArt = preload("res://scripts/ui/preparation_pawn_art.gd")
const InGameArt = preload("res://scripts/ui/smooth_pawn.gd")


func _initialize() -> void:
	var base := {"sex": "female", "body_type": 0, "head_type": 0, "hair": "short", "skin": "#af795b", "hair_color": "#5a342c", "shirt": "tshirt", "shirt_color": "#c5ad69", "pants": "pants", "pants_color": "#667078", "apparel": "none", "apparel_color": "#6d795b", "hat": "none"}
	var sheet := Image.create_empty(194 * 7, 194 * 3, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#202a30"))
	var game_sheet := Image.create_empty(256 * 7, 256 * 2, false, Image.FORMAT_RGBA8)
	game_sheet.fill(Color("#202a30"))
	for sex_index in 2:
		var sex := "female" if sex_index == 0 else "male"
		var styles: Array = ["bald", "short", "bob", "medium", "wavy", "braid", "long"] if sex == "female" else ["bald", "shaved", "short", "sidepart", "curly", "medium", "long"]
		for style_index in styles.size():
			var appearance: Dictionary = base.duplicate(true)
			appearance["sex"] = sex
			appearance["hair"] = styles[style_index]
			var preparation := _render(PreparationArt._pawn_svg(appearance))
			sheet.blend_rect(preparation, Rect2i(0, 0, 194, 194), Vector2i(style_index * 194, sex_index * 194))
			var in_game := _render(InGameArt._pawn_svg(appearance, false))
			game_sheet.blend_rect(in_game, Rect2i(0, 0, 256, 256), Vector2i(style_index * 256, sex_index * 256))
			assert(in_game.get_pixel(128, 77).a > 0.9, "In-game renderer lost face for %s/%s" % [sex, styles[style_index]])
	var female_short := PreparationArt._front_hair("short", Color("#5a342c"), false, "female")
	var male_short := PreparationArt._front_hair("short", Color("#5a342c"), false, "male")
	assert(female_short != male_short, "Short hairstyle does not distinguish the two cuts")
	assert(PreparationArt._front_hair("medium", Color("#5a342c"), false, "female") != PreparationArt._front_hair("medium", Color("#5a342c"), false, "male"))
	assert(PreparationArt._front_hair("long", Color("#5a342c"), false, "female") != PreparationArt._front_hair("long", Color("#5a342c"), false, "male"))
	var coat: Dictionary = base.duplicate(true)
	coat["hair"] = "bald"
	coat["apparel"] = "jacket"
	var coat_image := _render(PreparationArt._pawn_svg(coat))
	sheet.blend_rect(coat_image, Rect2i(0, 0, 194, 194), Vector2i(0, 388))
	for index in 6:
		var coat_variant: Dictionary = coat.duplicate(true)
		coat_variant["sex"] = "female" if index % 2 == 0 else "male"
		coat_variant["hair"] = "long" if index / 2 == 0 else "medium" if index / 2 == 1 else "bald"
		coat_variant["apparel_color"] = ["#76654b", "#697b8a", "#8a624d"][index / 2]
		sheet.blend_rect(_render(PreparationArt._pawn_svg(coat_variant)), Rect2i(0, 0, 194, 194), Vector2i((index + 1) * 194, 388))
	var changed_shirt: Dictionary = coat.duplicate(true)
	changed_shirt["shirt_color"] = "#e32555"
	var changed_shirt_image := _render(PreparationArt._pawn_svg(changed_shirt))
	assert(_delta(coat_image.get_pixel(97, 124), changed_shirt_image.get_pixel(97, 124)) < 0.01, "Shirt appears through the closed coat")
	assert(_delta(coat_image.get_pixel(81, 125), changed_shirt_image.get_pixel(81, 125)) < 0.01, "Shirt appears beside the closed coat")
	assert(coat_image.get_pixel(97, 145).a > 0.98, "Coat does not cover the trouser waist")
	var in_game_coat := _render(InGameArt._pawn_svg(coat, false))
	var in_game_changed := _render(InGameArt._pawn_svg(changed_shirt, false))
	assert(_delta(in_game_coat.get_pixel(128, 190), in_game_changed.get_pixel(128, 190)) < 0.01, "In-game coat leaves a shirt panel")
	assert(sheet.save_png("user://preparation-pawn-art-v019-sheet.png") == OK)
	assert(game_sheet.save_png("user://preparation-pawn-art-v019-game-sheet.png") == OK)
	print("PREPARATION_PAWN_ART_V019_SMOKE_OK")
	quit()


func _render(svg: String) -> Image:
	var image := Image.new()
	assert(image.load_svg_from_string(svg) == OK, "Pawn art SVG did not render")
	return image


func _delta(a: Color, b: Color) -> float:
	return absf(a.r - b.r) + absf(a.g - b.g) + absf(a.b - b.b) + absf(a.a - b.a)
