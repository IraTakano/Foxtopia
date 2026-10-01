extends RefCounted

## Foxtopia's original armless, legless colonist artwork. Curved paths are
## rendered once at 256 px, mipmapped, then drawn with linear filtering.
const SOURCE_SIZE := 256
static var _pawns: Dictionary = {}
static var _garments: Dictionary = {}
static var _pawn_order: Array[String] = []
static var _garment_order: Array[String] = []


static func draw_pawn(canvas: CanvasItem, center: Vector2, diameter: float, appearance: Dictionary, selected: bool, enemy: bool, drafted: bool) -> void:
	var key := str([appearance.get("sex", "male"), appearance.get("body_type", 0), appearance.get("head_type", 0), appearance.get("skin", "#d9ad81"), appearance.get("hair", "short"), appearance.get("hair_color", "#4d3c32"), appearance.get("shirt", "tshirt"), appearance.get("shirt_color", appearance.get("outfit", "#527a81")), appearance.get("pants", "pants"), appearance.get("pants_color", "#343e48"), appearance.get("apparel", "none"), appearance.get("apparel_color", "#735f50"), appearance.get("hat", "none"), appearance.get("hat_color", "#766b55"), enemy])
	if not _pawns.has(key):
		_pawns[key] = _texture(_pawn_svg(appearance, enemy))
		_pawn_order.append(key)
		if _pawn_order.size() > 192:
			_pawns.erase(_pawn_order.pop_front())
	var texture: Texture2D = _pawns[key]
	if texture == null:
		return
	var r := diameter * 0.5
	if selected:
		_ring(canvas, center + Vector2(0, r * 0.72), r * 0.79, r * 0.29, Color("#ead282"), maxf(1.4, r * 0.07))
	if drafted:
		_ring(canvas, center + Vector2(0, r * 0.72), r * 0.89, r * 0.36, Color("#dc8e78"), maxf(1.3, r * 0.05))
	canvas.draw_texture_rect(texture, Rect2(center - Vector2.ONE * r, Vector2.ONE * diameter), false)


static func draw_apparel_icon(canvas: CanvasItem, center: Vector2, size: float, item_id: String, tint: Color) -> void:
	var key := item_id + tint.to_html(false)
	if not _garments.has(key):
		_garments[key] = _texture(_apparel_svg(item_id, tint))
		_garment_order.append(key)
		if _garment_order.size() > 96:
			_garments.erase(_garment_order.pop_front())
	var texture: Texture2D = _garments[key]
	if texture != null:
		canvas.draw_texture_rect(texture, Rect2(center - Vector2.ONE * size * 0.5, Vector2.ONE * size), false)


static func _texture(svg: String) -> Texture2D:
	var image := Image.new()
	var err := image.load_svg_from_string(svg)
	if err != OK:
		push_error("Pawn SVG render failed: %d" % err)
		return null
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


static func _pawn_svg(appearance: Dictionary, enemy: bool) -> String:
	var sex := "female" if str(appearance.get("sex", "male")) == "female" else "male"
	var body_type := clampi(int(appearance.get("body_type", 0)), 0, 1)
	var head_type := clampi(int(appearance.get("head_type", 0)), 0, 1)
	var skin := _color(str(appearance.get("skin", "#d9ad81")), Color("#d9ad81"))
	var hair := _color(str(appearance.get("hair_color", "#4d3c32")), Color("#4d3c32"))
	var shirt := _color(str(appearance.get("shirt_color", appearance.get("outfit", "#527a81"))), Color("#527a81"))
	var pants := _color(str(appearance.get("pants_color", "#343e48")), Color("#343e48"))
	var coat := _color(str(appearance.get("apparel_color", "#735f50")), Color("#735f50"))
	if enemy:
		shirt = Color("#a65b51")
	var style := str(appearance.get("hair", "bob" if sex == "female" else "short")).to_lower()
	if not ["bald", "shaved", "short", "sidepart", "curly", "bob", "medium", "wavy", "braid", "long"].has(style):
		style = "bob" if sex == "female" else "short"
	var shoulder := (44 if body_type == 0 else 51) if sex == "female" else (56 if body_type == 0 else 62)
	var hip := (52 if body_type == 0 else 57) if sex == "female" else (45 if body_type == 0 else 50)
	var out := '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">'
	out += '<ellipse cx="128" cy="237" rx="47" ry="8" fill="#101b1b" opacity=".25"/>'
	out += _back_hair(style, hair, sex)
	out += _path(_torso_path(shoulder, hip), skin.darkened(0.10), 3.7)
	out += _path("M 102 150 Q 116 143 127 151 L 127 234 Q 105 236 95 226 C 85 201 86 167 102 150 Z", skin.lightened(0.08))
	out += _path("M 128 151 Q 145 143 155 152 C 173 171 169 208 158 231 Q 148 239 128 234 Z", skin.darkened(0.14))
	var wearing_pants := _wears(appearance.get("pants", "pants"))
	if wearing_pants:
		out += _pants(pants)
	var wearing_coat := str(appearance.get("apparel", "none")) == "jacket"
	if _wears(appearance.get("shirt", "tshirt")) and not wearing_coat:
		out += _shirt(shirt, shoulder, hip)
	if wearing_coat:
		out += _jacket(coat, shoulder, hip)
	out += _path("M 116 134 Q 128 139 140 134 L 140 153 Q 128 160 116 153 Z", skin.darkened(0.17), 2.3)
	out += _path("M 119 136 Q 128 139 137 136 L 137 151 Q 128 155 119 151 Z", skin.lightened(0.05))
	out += _face(sex, head_type, skin, hair)
	out += _front_hair(style, hair, sex)
	out += _hat(str(appearance.get("hat", "none")), _color(str(appearance.get("hat_color", "#766b55")), Color("#766b55")))
	out += '</svg>'
	return out


static func _hat(hat_id: String, cloth: Color) -> String:
	if hat_id == "cap":
		var cap := _path("M 83 83 C 83 48 99 34 127 33 C 157 34 174 52 173 82 Q 128 91 83 83 Z", cloth.darkened(0.10), 3.8)
		cap += _path("M 89 72 Q 100 43 127 42 Q 148 41 161 58 Q 127 53 101 77 Z", cloth.lightened(0.17))
		cap += _path("M 78 80 Q 129 89 186 75 Q 193 77 191 83 Q 146 102 79 87 Z", cloth.darkened(0.28), 2.6)
		return cap
	if hat_id == "brim_hat":
		var brim := _path("M 97 41 Q 128 31 159 41 L 165 76 Q 129 88 91 75 Z", cloth.darkened(0.13), 3.5)
		brim += _path("M 100 46 Q 124 36 154 46 L 158 64 Q 127 72 97 63 Z", cloth.lightened(0.15))
		brim += _path("M 61 78 Q 122 95 194 76 Q 207 86 187 94 Q 128 109 68 94 Q 54 88 61 78 Z", cloth.darkened(0.27), 3.5)
		return brim
	return ""


static func _torso_path(shoulder: int, hip: int) -> String:
	return "M 110 138 C {sl1} 136 {sl} 143 {sl} 155 C {sl2} 174 {hl} 199 {hl} 215 Q {hl1} 235 104 238 Q 128 246 152 238 Q {hr1} 235 {hr} 215 C {hr} 199 {sr2} 174 {sr} 155 C {sr} 143 {sr1} 136 146 138 Q 128 145 110 138 Z".format({"sl1": str(130 - shoulder), "sl": str(128 - shoulder), "sl2": str(124 - shoulder), "hl": str(128 - hip), "hl1": str(131 - hip), "hr1": str(125 + hip), "hr": str(128 + hip), "sr2": str(132 + shoulder), "sr": str(128 + shoulder), "sr1": str(126 + shoulder)})


static func _pants(color: Color) -> String:
	var out := _path("M 92 196 Q 128 207 164 196 C 177 207 170 230 155 236 Q 128 244 101 236 C 86 230 79 207 92 196 Z", color.darkened(0.13), 3.6)
	out += _path("M 92 200 Q 110 205 127 206 L 127 237 Q 111 239 101 234 Q 88 215 92 200 Z", color.lightened(0.12))
	out += _path("M 129 206 Q 149 205 164 200 Q 169 216 155 234 Q 145 239 129 237 Z", color.darkened(0.15))
	out += _stroke("M 96 203 Q 128 212 160 203 M 128 213 Q 124 224 128 236", color.darkened(0.30), 2.2)
	out += _stroke("M 104 214 Q 108 222 106 232 M 150 215 Q 145 224 149 231", color.darkened(0.21), 1.6)
	return out


static func _shirt(color: Color, shoulder: int, hip: int) -> String:
	var sl := str(128 - shoulder)
	var sr := str(128 + shoulder)
	var hl := str(128 - hip)
	var hr := str(128 + hip)
	var shirt_base := "M 110 139 Q 128 148 146 139 C {sri} 138 {sr} 144 {sr} 155 C {sr2} 174 {hr} 198 {hr} 213 Q 128 229 {hl} 213 C {hl} 198 {sl2} 174 {sl} 155 C {sl} 144 {sli} 138 110 139 Z".format({"sr": sr, "sl": sl, "sri": str(114 + shoulder), "sli": str(142 - shoulder), "sr2": str(132 + shoulder), "sl2": str(124 - shoulder), "hl": hl, "hr": hr})
	var out := _path(shirt_base, color.darkened(0.10), 3.4)
	var left_panel := "M 109 143 Q 118 147 126 151 Q 105 178 102 214 Q 91 216 85 212 C 83 180 91 154 109 143 Z"
	var right_panel := "M 146 143 C 166 150 174 179 171 212 Q 151 220 128 221 L 128 151 Q 137 148 146 143 Z"
	out += _path(left_panel, color.lightened(0.15))
	out += _path(right_panel, color.darkened(0.16))
	out += _path("M 109 139 Q 128 151 147 139 L 141 147 Q 128 156 115 147 Z", color.darkened(0.30), 1.2)
	out += _stroke("M 82 212 Q 128 231 174 212", color.darkened(0.29), 2.2)
	out += _stroke("M 87 162 Q 96 168 101 171 M 169 162 Q 160 168 155 171", color.darkened(0.29), 2.2)
	out += _stroke("M 100 165 Q 110 181 106 196 M 155 171 Q 148 185 153 198 M 118 206 Q 128 209 137 205", color.darkened(0.19), 1.6)
	return out


static func _jacket(color: Color, shoulder: int, hip: int) -> String:
	# The outer layer follows the same outline as the body, so neither shirt
	# nor skin can leak through its sides as broad body types change width.
	var out := _path(_torso_path(shoulder, hip), color.darkened(0.09), 3.7)
	out += _path("M 109 140 L 126 159 L 119 173 L 104 151 Z", color.lightened(0.12), 1.7)
	out += _path("M 147 140 L 130 159 L 137 173 L 152 151 Z", color.lightened(0.08), 1.7)
	out += _stroke("M 128 169 Q 130 200 128 233", color.darkened(0.29), 2.4)
	out += '<circle cx="132" cy="186" r="2" fill="#%s"/><circle cx="132" cy="210" r="2" fill="#%s"/>' % [color.darkened(0.38).to_html(false), color.darkened(0.38).to_html(false)]
	return out


static func _face(sex: String, head_type: int, skin: Color, hair: Color) -> String:
	var width := 46 if head_type == 0 else 38
	var left := 128 - width
	var right := 128 + width
	var jaw := 39 if sex == "male" and head_type == 0 else 34 if sex == "male" else 32 if head_type == 0 else 30
	var face_path := "M 128 48 C {l1} 47 {l} 66 {l} 87 C {l} 113 {jl} 140 128 154 C {jr} 140 {r} 113 {r} 87 C {r} 66 {r1} 47 128 48 Z".format({"l1": str(left + 19), "l": str(left), "jl": str(128 - jaw), "jr": str(128 + jaw), "r": str(right), "r1": str(right - 19)})
	var out := _path("M %d 92 Q %d 89 %d 101 L %d 105 Z" % [left + 3, left - 11, left - 3, left + 8], skin.darkened(0.16), 2.1)
	out += _path("M %d 92 Q %d 89 %d 101 L %d 105 Z" % [right - 3, right + 11, right + 3, right - 8], skin.darkened(0.16), 2.1)
	out += _path(face_path, skin.darkened(0.12), 3.6)
	out += _path("M 128 52 C 100 52 89 71 89 94 C 89 116 101 141 128 150 Q 144 138 148 128 C 132 108 135 77 128 52 Z", skin.lightened(0.07))
	out += _path("M 128 52 C 153 52 168 70 168 94 C 168 116 154 139 128 150 Q 150 113 128 52 Z", skin.darkened(0.045))
	out += _path("M 96 76 Q 109 55 128 58 Q 112 68 102 87 Z", skin.lightened(0.14))
	out += _path("M 154 83 Q 165 100 154 129 Q 148 134 145 137 Z", skin.darkened(0.10))
	var ink := hair.darkened(0.48).lerp(Color("#1e2625"), 0.55)
	out += _stroke("M 103 98 Q 110 95 117 98 M 139 98 Q 146 95 153 98", hair.darkened(0.31), 1.8)
	out += '<ellipse cx="111" cy="107" rx="3.0" ry="3.8" fill="#%s"/><ellipse cx="145" cy="107" rx="3.0" ry="3.8" fill="#%s"/>' % [ink.to_html(false), ink.to_html(false)]
	out += _path("M 128 107 Q 125 116 132 119 L 128 120 Z", skin.darkened(0.19))
	out += _stroke("M 119 130 Q 128 133 137 129", skin.darkened(0.32), 2.0)
	return out


static func _back_hair(style: String, hair: Color, sex: String = "female") -> String:
	if style in ["long", "braid"]:
		if style == "long" and sex == "male":
			return ""
		var out := _path("M 94 60 C 74 74 74 94 76 119 L 79 161 Q 88 176 101 165 L 104 125 L 152 125 L 155 165 Q 168 176 177 161 L 180 117 C 182 76 165 50 128 50 Q 107 50 94 60 Z", hair.darkened(0.20), 3.6)
		if style == "braid":
			out += _path("M 171 117 C 186 124 189 140 179 150 C 191 161 187 173 176 178 C 185 190 180 199 169 198 Q 158 182 164 155 Z", hair.darkened(0.09), 2.7)
			out += _stroke("M 165 144 Q 184 151 170 161 M 165 166 Q 183 174 169 184", hair.lightened(0.18), 2.7)
		return out
	if style in ["bob", "wavy"]:
		return _path("M 94 58 C 75 72 75 92 77 114 L 79 146 Q 86 163 101 156 L 105 129 L 151 129 L 155 156 Q 170 163 177 146 L 179 111 C 181 76 164 51 128 50 Q 108 50 94 58 Z", hair.darkened(0.17), 3.4)
	if style == "medium":
		if sex == "male":
			return ""
		return _path("M 96 61 C 80 74 79 96 81 117 L 83 139 Q 89 151 102 144 L 104 121 L 152 121 L 154 144 Q 168 151 173 139 L 175 116 C 177 79 161 52 128 51 Q 109 51 96 61 Z", hair.darkened(0.18), 3.4)
	return ""


static func _front_hair(style: String, hair: Color, sex: String = "female") -> String:
	var out := ""
	match style:
		"bald":
			return ""
		"shaved":
			out = _path("M 85 84 C 84 63 103 49 128 49 C 154 49 172 65 171 84 Q 149 73 129 74 Q 104 73 85 84 Z", hair.darkened(0.15), 2.6)
		"short":
			if sex == "female":
				out = _path("M 82 99 C 79 72 97 49 128 48 C 157 47 175 69 174 91 C 174 102 169 111 164 116 Q 158 112 159 100 L 158 88 C 146 93 135 92 125 89 C 111 95 97 100 82 99 Z", hair.darkened(0.08), 3.0)
				out += _stroke("M 92 76 Q 103 56 129 56 Q 145 56 157 69", hair.lightened(0.12), 2.0)
				return out
			out = _path("M 84 91 C 82 68 97 52 123 49 C 142 47 156 54 165 64 Q 174 76 170 88 C 151 80 131 81 118 83 Q 101 82 84 91 Z", hair.darkened(0.09), 3.0)
			out += _stroke("M 95 68 Q 110 53 134 54 Q 151 56 162 69", hair.lightened(0.15), 2.0)
		"sidepart":
			out = _path("M 83 91 C 80 62 99 47 129 47 C 159 47 176 65 171 89 Q 159 81 147 70 Q 116 92 84 91 Z", hair.darkened(0.10), 3.0)
			out += _path("M 87 83 Q 94 52 130 53 Q 146 53 158 65 Q 120 83 87 83 Z", hair.lightened(0.13))
			out += _stroke("M 148 60 Q 151 68 148 74", hair.darkened(0.32), 2.0)
		"curly":
			out = _path("M 83 93 C 75 73 91 57 104 58 C 108 42 126 42 136 53 C 151 43 167 58 167 66 C 181 73 176 89 168 96 Q 153 79 139 81 Q 116 79 101 89 Z", hair.darkened(0.11), 3.0)
			out += _stroke("M 90 76 Q 89 63 101 62 Q 108 63 111 71 M 112 58 Q 125 48 134 64 M 142 60 Q 160 57 163 76", hair.lightened(0.16), 2.1)
		"bob":
			out = _path("M 83 101 C 78 66 97 47 128 46 C 160 46 179 68 173 105 L 168 128 Q 163 115 164 91 Q 153 91 145 77 Q 124 89 103 82 Q 101 105 88 125 Z", hair.darkened(0.06), 3.0)
			out += _path("M 89 80 Q 97 54 125 52 Q 147 48 162 68 Q 138 59 122 70 Q 106 76 89 80 Z", hair.lightened(0.17))
		"wavy":
			out = _path("M 82 104 C 77 67 98 47 129 46 C 162 45 179 69 173 107 L 168 129 Q 159 114 164 91 Q 152 85 143 75 Q 132 86 118 79 Q 104 91 91 85 Q 100 111 87 126 Z", hair.darkened(0.07), 3.0)
			out += _stroke("M 89 75 Q 101 60 114 67 Q 127 53 141 65 Q 157 58 166 79", hair.lightened(0.22), 3.4)
		"medium":
			if sex == "male":
				out = _path("M 84 90 C 80 70 94 55 112 50 C 137 44 161 54 169 71 Q 173 82 167 94 Q 159 89 156 79 Q 149 88 139 84 Q 129 93 120 84 Q 103 96 92 89 L 85 98 Z", hair.darkened(0.09), 3.0)
				out += _stroke("M 95 68 Q 108 52 130 53 Q 148 55 159 65", hair.lightened(0.14), 1.8)
			else:
				out = _path("M 83 102 C 79 66 99 48 128 47 C 160 47 177 68 173 103 L 167 130 Q 159 121 163 87 Q 144 91 136 75 Q 117 87 98 80 Q 95 115 87 131 Z", hair.darkened(0.07), 3.0)
		"long":
			if sex == "male":
				out = _path("M 81 92 Q 75 73 88 58 L 88 52 L 98 54 Q 113 44 126 47 L 135 44 Q 158 48 169 63 L 176 66 L 173 78 Q 179 93 172 107 L 166 100 L 162 93 Q 156 105 149 99 L 145 88 Q 137 105 124 101 L 127 88 Q 115 104 105 100 L 105 91 Q 95 103 85 99 L 83 112 Q 77 103 81 92 Z", hair.darkened(0.08), 3.0)
				out += _stroke("M 89 71 Q 106 51 128 53 Q 153 55 165 69 M 138 60 Q 128 78 113 84", hair.lightened(0.13), 1.8)
				return out
			out = _path("M 81 101 C 78 64 97 46 128 46 C 161 46 180 65 174 101 Q 170 119 170 145 Q 159 134 163 91 Q 149 83 141 73 Q 119 87 99 82 Q 93 113 85 144 Z", hair.darkened(0.08), 3.0)
			out += _path("M 91 72 Q 108 49 135 51 Q 155 53 166 75 Q 138 58 119 70 Q 105 76 91 72 Z", hair.lightened(0.16))
		"braid":
			out = _path("M 83 101 C 77 66 99 46 128 46 C 159 46 178 66 174 99 Q 165 94 163 86 Q 140 76 128 80 Q 103 84 92 105 Z", hair.darkened(0.08), 3.0)
			out += _path("M 89 72 Q 103 51 130 51 Q 155 52 168 77 Q 145 61 127 69 Q 106 79 89 72 Z", hair.lightened(0.16))
	return out


static func _apparel_svg(item_id: String, tint: Color) -> String:
	var out := '<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256"><ellipse cx="128" cy="222" rx="73" ry="9" fill="#111719" opacity=".25"/>'
	if item_id == "cap" or item_id == "brim_hat":
		out += _path("M 66 114 Q 76 47 128 44 Q 183 46 191 114 L 183 155 Q 128 177 73 155 Z", tint.darkened(0.13), 6.0)
		out += _path("M 77 111 Q 86 58 127 53 Q 155 52 174 80 Q 128 74 93 119 Z", tint.lightened(0.17))
		out += _path("M 44 143 Q 128 177 212 137 Q 227 147 212 163 Q 128 199 44 165 Q 31 155 44 143 Z", tint.darkened(0.26), 5.0)
	elif item_id == "pants":
		out += _path("M 68 52 Q 128 61 188 52 L 179 194 Q 177 208 164 209 L 145 209 L 128 133 L 111 209 L 92 209 Q 79 208 77 194 Z", tint.darkened(0.08), 6.0)
		out += _path("M 76 63 Q 100 68 127 68 L 123 133 L 105 199 L 86 198 Z", tint.lightened(0.14))
		out += _path("M 129 69 Q 157 68 180 63 L 171 197 L 150 200 L 132 132 Z", tint.darkened(0.16))
		out += _stroke("M 70 70 Q 128 80 186 70 M 128 80 L 128 128", tint.darkened(0.31), 4.0)
	elif item_id == "jacket":
		out += _path("M 93 48 L 113 51 L 128 82 L 143 51 L 163 48 L 204 71 L 219 117 L 188 129 L 178 105 L 184 211 Q 128 224 72 211 L 78 105 L 68 129 L 37 117 L 52 71 Z", tint.darkened(0.17), 6.0)
		out += _path("M 94 55 L 119 104 L 112 208 Q 94 212 79 207 L 84 91 Q 88 66 94 55 Z", tint.lightened(0.15))
		out += _path("M 162 55 Q 174 70 176 93 L 177 206 Q 158 215 143 211 L 137 103 Z", tint.darkened(0.10))
		out += _path("M 111 53 L 128 82 L 116 119 L 94 65 Z", tint.lightened(0.23), 2.5)
		out += _path("M 145 53 L 128 82 L 140 119 L 162 65 Z", tint.lightened(0.05), 2.5)
		out += _stroke("M 79 202 Q 128 218 177 202 M 52 104 L 78 114 M 204 104 L 178 114 M 128 101 L 128 209", tint.darkened(0.34), 3.2)
	else:
		out += _path("M 93 51 L 111 49 Q 128 73 145 49 L 163 51 L 203 73 L 217 111 L 184 127 L 175 106 L 179 206 Q 128 218 77 206 L 81 106 L 72 127 L 39 111 L 53 73 Z", tint.darkened(0.08), 6.0)
		out += _path("M 91 60 L 101 72 L 94 198 Q 110 207 127 208 L 127 76 Q 108 73 91 60 Z", tint.lightened(0.15))
		out += _path("M 146 75 Q 168 68 178 91 L 174 200 Q 153 208 129 208 L 129 76 Z", tint.darkened(0.16))
		out += _path("M 105 52 Q 128 80 151 52 L 143 68 Q 128 82 113 68 Z", tint.darkened(0.30), 2.0)
		out += _stroke("M 76 198 Q 128 210 180 198 M 55 106 L 79 116 M 201 106 L 177 116", tint.darkened(0.31), 3.0)
	return out + '</svg>'


static func _path(d: String, fill: Color, outline: float = 0.0) -> String:
	var border := ''
	if outline > 0.0:
		border = ' stroke="#202b2c" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"' % str(outline)
	return '<path d="%s" fill="#%s"%s/>' % [d, fill.to_html(false), border]


static func _stroke(d: String, color: Color, width: float) -> String:
	return '<path d="%s" fill="none" stroke="#%s" stroke-width="%s" stroke-linecap="round" stroke-linejoin="round"/>' % [d, color.to_html(false), str(width)]


static func _wears(value: Variant) -> bool:
	if value is bool:
		return value
	return str(value).to_lower() not in ["", "none", "naked", "false", "0"]


static func _ring(canvas: CanvasItem, origin: Vector2, rx: float, ry: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for i in range(49):
		var angle := float(i) * TAU / 48.0
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
