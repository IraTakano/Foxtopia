extends RefCounted

## A small, layered colonist silhouette for the preparation portrait.
const SOURCE_SIZE := 194
static var _background: Texture2D
static var _pawns: Dictionary = {}


static func draw_background(canvas: CanvasItem, rect: Rect2) -> void:
	if _background == null:
		var backdrop := _portrait_background_image()
		backdrop.generate_mipmaps()
		_background = ImageTexture.create_from_image(backdrop)
	if _background != null:
		canvas.draw_texture_rect(_background, rect, false)
	else:
		canvas.draw_rect(rect, Color("#202a30"))


static func _portrait_background_image() -> Image:
	# The grain lives only in the portrait backdrop, beneath the clean pawn
	# silhouette. A coordinate hash gives the same quiet texture every frame.
	var image := Image.create_empty(SOURCE_SIZE, SOURCE_SIZE, false, Image.FORMAT_RGBA8)
	var center := Color("#303b42")
	var edge := Color("#12171c")
	for y in SOURCE_SIZE:
		for x in SOURCE_SIZE:
			var radius := Vector2(float(x) - 97.0, float(y) - 99.0).length() / 135.0
			var shade := center.lerp(edge, clampf(pow(radius, 1.25), 0.0, 1.0))
			var fleck := ((x * 73856093) ^ (y * 19349663)) & 255
			var grain := (float(fleck) / 255.0 - 0.5) * 0.022
			image.set_pixel(x, y, Color(clampf(shade.r + grain, 0.0, 1.0), clampf(shade.g + grain, 0.0, 1.0), clampf(shade.b + grain, 0.0, 1.0)))
	return image


static func draw_pawn(canvas: CanvasItem, rect: Rect2, appearance: Dictionary) -> void:
	var key := str([
		appearance.get("sex", "female"), appearance.get("skin", "#d9ad81"),
		appearance.get("body_type", 0), appearance.get("head_type", 0),
		appearance.get("hair", "short"), appearance.get("hair_color", "#392d26"),
		appearance.get("shirt", "tshirt"), appearance.get("shirt_color", appearance.get("outfit", "#b7a07d")),
		appearance.get("pants", "pants"), appearance.get("pants_color", "#5f6768"),
		appearance.get("apparel", "none"), appearance.get("apparel_color", "#b7a07d"),
		appearance.get("hat", "none"), appearance.get("hat_color", "#bd8a11")
	])
	if not _pawns.has(key):
		_pawns[key] = _texture(_pawn_svg(appearance))
		# Canvas commands still refer to prior colors during a live wheel drag.
		# Evicting those textures here made roster portraits turn white.
	var pawn: Texture2D = _pawns[key]
	if pawn != null:
		canvas.draw_texture_rect(pawn, rect, false)


static func _texture(svg: String) -> Texture2D:
	var source := Image.new()
	var error := source.load_svg_from_string(svg)
	if error != OK:
		push_error("Preparation pawn SVG render failed: %d" % error)
		return null
	source.generate_mipmaps()
	return ImageTexture.create_from_image(source)


static func _pawn_svg(a: Dictionary) -> String:
	var skin := Color.from_string(str(a.get("skin", "#d9ad81")), Color("#d9ad81"))
	var hair := Color.from_string(str(a.get("hair_color", "#392d26")), Color("#392d26"))
	var shirt := Color.from_string(str(a.get("shirt_color", a.get("outfit", "#b7a07d"))), Color("#b7a07d"))
	var pants := Color.from_string(str(a.get("pants_color", "#5f6768")), Color("#5f6768"))
	var coat := Color.from_string(str(a.get("apparel_color", "#b7a07d")), Color("#b7a07d"))
	var hat_color := Color.from_string(str(a.get("hat_color", "#bd8a11")), Color("#bd8a11"))
	var style := str(a.get("hair", "short"))
	var sex := str(a.get("sex", "female"))
	var broad := int(a.get("body_type", 0)) == 1
	var round_head := int(a.get("head_type", 0)) == 1
	var shoulder := (26.0 if broad else 21.0) if sex == "female" else (31.0 if broad else 27.0)
	var waist := (25.0 if broad else 20.0) if sex == "female" else (28.0 if broad else 24.0)
	var hip := (27.0 if broad else 23.0) if sex == "female" else (23.0 if broad else 19.0)
	var sl := 97.0 - shoulder
	var sr := 97.0 + shoulder
	var wl := 97.0 - waist
	var wr := 97.0 + waist
	var hl := 97.0 - hip
	var hr := 97.0 + hip
	var out := '<svg xmlns="http://www.w3.org/2000/svg" width="194" height="194" viewBox="0 0 194 194">'
	out += '<ellipse cx="97" cy="158" rx="26" ry="5" fill="#090c0e" opacity=".32"/>'
	# One outline defines the shoulder, waist and hem for every clothing layer.
	out += _path(_body_path(shoulder, waist, hip), skin, 3.0)
	var wearing_pants := _wears(a.get("pants", "pants"))
	if wearing_pants:
		out += _path('M %.1f 130 Q 97 133 %.1f 130 C %.1f 137 %.1f 142 %.1f 149 Q 97 157 %.1f 149 C %.1f 142 %.1f 137 %.1f 130 Z' % [wl, wr, wr, hr, hr, hl, hl, wl, wl], pants, 2.7)
	var wearing_coat := str(a.get("apparel", "none")) == "jacket"
	if _wears(a.get("shirt", "tshirt")) and not wearing_coat:
		var shirt_path := 'M %.1f 102 C %.1f 98 87 95 91 94 Q 97 101 103 94 C 107 95 %.1f 98 %.1f 102 C %.1f 113 %.1f 123 %.1f 131 Q 97 135 %.1f 131 C %.1f 123 %.1f 113 %.1f 102 Z' % [sl - 0.5, sl + 2.0, sr - 2.0, sr + 0.5, sr + 1.5, wr, wr, wl, wl, sl - 1.5, sl - 0.5]
		out += _path(shirt_path, shirt, 2.7)
		out += _stroke('M 89 97 Q 97 105 105 97', shirt.darkened(0.25), 1.3)
	if wearing_coat:
		out += _path(_body_path(shoulder + 1.5, waist + 1.5, hip + 2.0), coat.darkened(0.07), 2.8)
		out += _path('M 89 95 L 96 102 L 92 111 L 85 103 Z', coat.lightened(0.13), 1.1)
		out += _path('M 105 95 L 98 102 L 102 111 L 109 103 Z', coat.lightened(0.10), 1.1)
		out += _stroke('M 102 120 Q 105 134 104 149', coat.darkened(0.31), 1.35)
		out += _stroke('M 76 125 Q 80 127 84 125 M 110 125 Q 114 127 118 125', coat.darkened(0.20), 1.05)
		out += _stroke('M 80 137 L 87 139 M 107 139 L 114 137', coat.darkened(0.29), 1.35)
		for y in [123, 134, 145]:
			out += '<circle cx="94" cy="%d" r="1.25" fill="#%s"/><circle cx="103" cy="%d" r="1.25" fill="#%s"/>' % [y, coat.darkened(0.48).to_html(false), y, coat.darkened(0.48).to_html(false)]
	# Neck and face come after the clothing; eye ink cannot vanish with skin recoloring.
	out += _path('M 89 91 Q 97 97 105 91 L 104 101 Q 97 106 90 101 Z', skin.darkened(0.10), 2.0)
	out += _head(skin, hair, round_head)
	var hat_id := str(a.get("hat", "none"))
	out += _front_hair(style, hair, round_head, sex) if hat_id == "none" else _hat_side_hair(style, hair, sex)
	out += _hat(hat_id, hat_color)
	return out + '</svg>'


static func _body_path(shoulder: float, waist: float, hip: float) -> String:
	var sl := 97.0 - shoulder
	var sr := 97.0 + shoulder
	var wl := 97.0 - waist
	var wr := 97.0 + waist
	var hl := 97.0 - hip
	var hr := 97.0 + hip
	return 'M %.1f 102 C %.1f 97 87 95 91 94 Q 97 98 103 94 C 107 95 %.1f 97 %.1f 102 C %.1f 111 %.1f 118 %.1f 126 C %.1f 136 %.1f 142 %.1f 149 Q 97 157 %.1f 149 C %.1f 142 %.1f 136 %.1f 126 C %.1f 118 %.1f 111 %.1f 102 Z' % [sl, sl + 2.0, sr - 2.0, sr, sr + 1.0, wr, wr, wr, hr, hr, hl, hl, wl, wl, wl, sl - 1.0, sl]


static func _head(skin: Color, hair: Color, round_head: bool) -> String:
	var contour := 'M 97 55 C 85 55 80 63 80 76 C 80 90 87 101 97 103 C 107 101 114 90 114 76 C 114 63 109 55 97 55 Z'
	if round_head:
		contour = 'M 97 59 C 84 59 78 68 78 80 C 78 92 85 101 97 101 C 109 101 116 92 116 80 C 116 68 110 59 97 59 Z'
	# A single face fill keeps skin color continuous across the nose line.
	var out := _path(contour, skin, 2.9)
	var ink := hair.darkened(0.72).lerp(Color("#171717"), 0.75)
	var eye_y := 82.0 if round_head else 81.0
	var eye_dx := 8.5 if round_head else 7.5
	out += '<ellipse cx="%.1f" cy="%.1f" rx="1.9" ry="2.3" fill="#%s"/><ellipse cx="%.1f" cy="%.1f" rx="1.9" ry="2.3" fill="#%s"/>' % [97.0 - eye_dx, eye_y, ink.to_html(false), 97.0 + eye_dx, eye_y, ink.to_html(false)]
	return out


static func _hat_side_hair(style: String, hair: Color, sex: String = "female") -> String:
	# Only side locks should show below a hat. Repainting a full fringe under
	# the brim made the bowler hat intersect the hairstyle and darken the face.
	var end_y := 0
	match style:
		"bob": end_y = 102
		"wavy": end_y = 112
		"medium":
			if sex == "male":
				return ''
			end_y = 112
		"long":
			if sex == "male":
				return _path('M 80 77 Q 77 85 80 92 L 85 85 L 84 77 Z', hair.darkened(0.07), 1.8) + _path('M 113 77 Q 118 85 114 93 L 109 86 L 109 77 Z', hair.darkened(0.07), 1.8)
			return _path('M 80 73 C 74 85 73 116 74 137 Q 78 146 86 139 L 87 75 Z', hair.darkened(0.06), 2.2) + _path('M 114 73 C 120 85 121 116 120 137 Q 116 146 108 139 L 107 75 Z', hair.darkened(0.06), 2.2)
		"braid":
			return _path('M 80 73 Q 77 83 79 92 Q 82 97 86 91 L 86 75 Z', hair.darkened(0.06), 2.2) + _path('M 110 73 Q 118 82 116 93 Q 122 102 118 110 Q 121 122 116 135 L 112 142 Q 106 141 109 134 Q 107 123 111 113 Q 108 103 110 92 Z', hair.darkened(0.06), 2.2)
	if end_y == 0:
		return ''
	var left := _path('M 80 73 C 76 82 76 %d 78 %d Q 82 %d 86 %d L 87 75 Z' % [end_y - 12, end_y, end_y + 6, end_y], hair.darkened(0.06), 2.2)
	var right := _path('M 114 73 C 118 82 118 %d 116 %d Q 112 %d 108 %d L 107 75 Z' % [end_y - 12, end_y, end_y + 6, end_y], hair.darkened(0.06), 2.2)
	return left + right


static func _front_hair(style: String, hair: Color, round_head: bool, sex: String = "female") -> String:
	var top := 53 if round_head else 50
	match style:
		"bald":
			return ''
		"shaved":
			return _path('M 80 69 Q 82 %d 97 %d Q 112 %d 114 69 Q 97 63 80 69 Z' % [top + 9, top + 6, top + 9], hair.darkened(0.10), 1.4)
		"short":
			if sex == "female":
				var pixie := _path('M 79 80 C 77 65 84 %d 96 %d C 108 %d 116 59 116 73 C 116 81 114 86 112 88 C 108 86 109 80 107 76 C 98 80 88 81 79 80 Z' % [top + 4, top + 2, top], hair.darkened(0.07), 2.2)
				return pixie + _stroke('M 84 68 Q 91 56 103 57', hair.lightened(0.10), 1.2)
			return _path('M 81 74 C 80 63 87 %d 96 %d C 103 %d 111 55 114 63 Q 117 69 114 74 C 104 70 94 71 81 74 Z' % [top + 5, top + 4, top + 2], hair.darkened(0.07), 2.2)
		"sidepart":
			var out := _path('M 79 74 Q 79 %d 96 %d Q 115 %d 115 74 Q 105 69 100 64 Q 90 76 79 74 Z' % [top + 8, top, top + 5], hair.darkened(0.09), 2.2)
			out += _path('M 82 68 Q 88 54 101 54 Q 110 54 113 64 Q 99 59 92 66 Z', hair.lightened(0.15))
			return out
		"curly":
			var out := _path('M 78 74 Q 75 60 84 57 Q 88 49 97 53 Q 104 48 110 56 Q 119 58 116 74 Q 108 69 103 73 Q 98 67 93 72 Q 85 69 78 74 Z', hair.darkened(0.11), 2.2)
			for x in [83, 91, 100, 109]:
				out += '<circle cx="%d" cy="61" r="4" fill="#%s"/>' % [x, hair.to_html(false)]
			return out
		"bob":
			return _path('M 78 77 Q 76 57 91 52 Q 108 47 117 63 L 116 100 Q 111 105 108 100 L 109 68 Q 99 78 86 70 L 86 100 Q 81 105 78 100 Z', hair.darkened(0.06), 2.3)
		"wavy":
			var out := _path('M 78 78 Q 75 57 92 51 Q 111 47 117 63 L 117 105 Q 121 114 114 119 Q 106 117 109 105 L 110 68 Q 103 75 97 69 Q 90 78 84 72 L 85 106 Q 88 115 80 119 Q 73 114 77 105 Z', hair.darkened(0.05), 2.3)
			out += _stroke('M 82 65 Q 89 60 95 64 Q 104 59 113 65', hair.lightened(0.09), 1.4)
			return out
		"medium":
			if sex == "male":
				return _path('M 80 78 C 78 64 86 54 96 51 C 107 49 116 57 116 69 Q 117 77 112 81 Q 108 79 105 73 Q 101 80 96 77 Q 90 85 85 80 L 80 83 Z', hair.darkened(0.08), 2.3) + _stroke('M 85 66 Q 92 55 103 56 Q 109 58 111 63', hair.lightened(0.12), 1.15)
			return _path('M 78 78 Q 76 56 91 52 Q 110 48 117 64 L 116 107 Q 113 114 107 110 L 109 70 Q 99 76 87 68 L 86 110 Q 80 114 77 107 Z', hair.darkened(0.06), 2.3)
		"long":
			if sex == "male":
				var anime := _path('M 78 80 C 75 67 82 55 91 52 L 90 49 Q 98 47 104 50 L 110 49 Q 119 57 117 69 L 121 74 L 117 78 Q 119 87 114 92 L 110 82 L 109 74 Q 105 79 102 77 L 100 70 Q 96 77 92 75 L 91 70 Q 86 78 82 78 L 79 91 Q 75 85 78 80 Z', hair.darkened(0.08), 2.3)
				anime += _stroke('M 83 67 Q 92 53 106 55 Q 113 58 115 65 M 100 59 Q 96 69 91 74', hair.lightened(0.13), 1.15)
				return anime
			return _path('M 78 78 Q 76 56 91 51 Q 112 47 117 65 L 120 135 Q 117 146 107 140 Q 109 116 110 68 Q 98 77 85 70 Q 85 116 87 140 Q 77 146 74 135 Z', hair.darkened(0.07), 2.3)
		"braid":
			var out := _path('M 79 78 Q 76 55 93 51 Q 112 47 117 67 L 114 91 Q 108 84 110 70 Q 95 72 85 80 L 83 96 Q 78 97 79 78 Z', hair.darkened(0.06), 2.3)
			out += _path('M 112 86 Q 120 93 117 102 Q 122 110 118 118 Q 122 128 116 137 L 112 144 Q 107 142 109 136 Q 107 126 111 118 Q 108 109 111 102 Z', hair.darkened(0.04), 2.2)
			out += _stroke('M 111 104 Q 116 107 118 110 M 111 117 Q 116 120 119 123 M 110 130 Q 114 133 117 135', hair.lightened(0.11), 1.2)
			return out
		_:
			return ''


static func _hat(hat_id: String, cloth: Color) -> String:
	if hat_id == "brim_hat":
		var out := _path('M 83 62 L 86 46 Q 97 37 108 46 L 111 62 Q 97 68 83 62 Z', cloth.darkened(0.10), 2.8)
		out += _path('M 84 57 Q 97 61 110 57 L 111 63 Q 97 67 83 63 Z', cloth.darkened(0.28))
		out += _path('M 73 65 Q 97 72 121 65 Q 126 69 120 73 Q 97 80 74 73 Q 68 69 73 65 Z', cloth.darkened(0.13), 2.6)
		return out
	if hat_id == "cap":
		var out := _path('M 80 64 Q 80 43 97 42 Q 114 43 115 64 Q 97 70 80 64 Z', cloth.darkened(0.10), 2.7)
		out += _path('M 83 60 Q 86 47 96 47 Q 103 47 107 52 Q 93 53 83 60 Z', cloth.lightened(0.17))
		out += _path('M 78 65 Q 100 72 122 65 Q 124 69 117 72 Q 97 76 78 70 Z', cloth.darkened(0.23), 2.4)
		return out
	return ''


static func _path(d: String, fill: Color, border: float = 0.0) -> String:
	var stroke := ''
	if border > 0.0:
		stroke = ' stroke="#171717" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"' % str(border)
	return '<path d="%s" fill="#%s"%s/>' % [d, fill.to_html(false), stroke]


static func _stroke(d: String, color: Color, width: float) -> String:
	return '<path d="%s" fill="none" stroke="#%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % [d, color.to_html(false), str(width)]


static func _wears(value: Variant) -> bool:
	return str(value).to_lower() not in ["", "none", "naked", "false", "0"]
