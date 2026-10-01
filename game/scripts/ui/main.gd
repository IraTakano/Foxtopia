extends Control

const MapViewScript = preload("res://scripts/ui/map_view.gd")
const WorldViewScript = preload("res://scripts/ui/world_view.gd")
const TerrainPreviewScript = preload("res://scripts/ui/terrain_preview.gd")
const PawnPreviewScript = preload("res://scripts/ui/pawn_preview.gd")
const PawnVisualScript = preload("res://scripts/ui/pawn_visual.gd")
const ApparelIconScript = preload("res://scripts/ui/apparel_icon.gd")
const SettingsScript = preload("res://scripts/ui/settings.gd")
const I18n = preload("res://scripts/ui/i18n.gd")
const SetupCatalog = preload("res://scripts/model/setup_catalog.gd")
const PreparationPresetStore = preload("res://scripts/ui/preparation_preset_store.gd")
const PreparationNamePool = preload("res://scripts/ui/preparation_name_pool.gd")
const PreparationRules = preload("res://scripts/model/preparation_rules.gd")

const BG := Color("#1b1d1e")
const PANEL := Color("#282b2c")
const PANEL_ALT := Color("#35393a")
const CREAM := Color("#e5e1d6")
const MUTED := Color("#aaa9a0")
const GOLD := Color("#c8af79")
const TEAL := Color("#a2b8a4")
const RED := Color("#d18a7e")
const HUD_BG := Color("#172027ed")
const HUD_PANEL := Color("#1c252ce8")
const HUD_BORDER := Color("#54616a")
const HUD_TAB := Color("#27343c")
const HUD_ACTIVE := Color("#4c6068")

const JOBS := ["chop", "mine", "harvest", "haul", "build", "treat", "research"]
const JOB_LABELS := ["Chop", "Mine", "Harvest", "Haul", "Build", "Care", "Research"]
const TRAIT_IDS := ["", "hardworking", "calm", "quick", "curious", "kind", "night_owl", "timid", "abrasive", "lazy", "pyromaniac", "fast_walker", "ugly"]
const TRAIT_NAMES := ["None", "Hardworking", "Calm", "Quick", "Curious", "Kind", "Night owl", "Timid", "Abrasive", "Lazy", "Pyromaniac", "Fast walker", "Ugly"]
const CONDITION_IDS := ["", "asthma", "bad_back", "scar", "cut_light", "cut_deep", "bruise", "burn", "scratch"]
const CONDITION_NAMES := ["None", "Asthma", "Bad back", "Scar", "Light cut", "Deep cut", "Bruise", "Burn", "Scratch"]
const CHRONIC_CONDITION_IDS := ["", "asthma", "bad_back"]
const INJURY_KIND_IDS := ["scar", "cut_light", "cut_deep", "bruise", "burn", "scratch"]
const INJURY_BODY_PART_IDS := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]
const CHILDHOOD_IDS := ["rural_child", "town_child", "apprentice", "vatgrown_soldier", "unknown"]
const ADULTHOOD_IDS := ["farmer", "builder", "medic", "scholar", "unknown"]
const SKILL_IDS := ["chop", "mine", "harvest", "haul", "build", "research", "treat", "combat"]
const CLASSIC_SKILL_IDS := ["shooting", "melee", "social", "animals", "medical", "cooking", "construction", "plants", "mining", "artistic", "crafting", "intellectual"]
const HAIR_OPTIONS := ["Short", "Wavy", "Long", "Curly", "Shaved"]
const SKIN_OPTIONS := ["#f8dcc3", "#efc69f", "#e7ad82", "#d99568", "#cb875d", "#b97952", "#a86b48", "#925b3d", "#7d4e36", "#6a422f", "#573729", "#442c23"]
const OUTFIT_OPTIONS := ["#527a81", "#b16f59", "#7b8664", "#92759a", "#b89c65"]
const HAIR_COLOR_OPTIONS := ["#282421", "#4d3c32", "#704934", "#8b6449", "#ad7850", "#bb9b69", "#d1b880", "#8c5f56", "#754d48", "#a2a2a0", "#e5dfd2", "#343a3a"]
const LEGACY_MALE_HAIR_IDS := ["short", "sidepart", "curly", "shaved", "bald", "bob", "wavy", "long", "braid", "medium"]
const LEGACY_FEMALE_HAIR_IDS := ["bob", "wavy", "long", "braid", "bald", "short", "sidepart", "curly", "shaved", "medium"]
const MALE_HAIR_IDS := ["bald", "shaved", "short", "sidepart", "curly", "medium", "long"]
const FEMALE_HAIR_IDS := ["bald", "short", "bob", "medium", "wavy", "braid", "long"]
const PREPARATION_FEMALE_NAMES := "Ada,Aisha,Alara,Alba,Alea,Alexandra,Alina,Amara,Amelia,Anika,Aria,Asena,Aslı,Ayla,Bahar,Bella,Beren,Bianca,Carla,Celia,Clara,Dalia,Defne,Deniz,Derya,Dila,Ece,Elena,Elif,Elina,Elisa,Elvan,Emilia,Esma,Estelle,Eva,Fatma,Freya,Gabriela,Gizem,Hana,Hazel,Helena,Ilgın,Ines,Iris,Jade,Jana,Jasmine,Juno,Kara,Lara,Lea,Lena,Leyla,Lila,Lina,Livia,Luna,Mara,Marina,Maya,Melis,Mina,Mira,Nadia,Nara,Neva,Nika,Nila,Nilay,Nora,Olivia,Öykü,Petra,Reya,Rina,Rosa,Sara,Selin,Sena,Seren,Sofia,Suna,Talia,Tara,Uma,Vera,Yasemin,Zara,Zehra,Zeynep"
const PREPARATION_MALE_NAMES := "Adem,Adrian,Ahmet,Akın,Ali,Alp,Aras,Arda,Arden,Aslan,Atlas,Baran,Barış,Batu,Ben,Bora,Can,Cem,Deniz,Doruk,Efe,Ege,Emir,Emre,Enes,Eray,Eren,Erik,Faris,Felix,Galip,Hakan,Harun,Hugo,Ivan,Jack,Jonas,Kaan,Kai,Kerem,Kuzey,Leon,Liam,Lucas,Marco,Mateo,Max,Mert,Mika,Milo,Miran,Nadir,Nazım,Noah,Okan,Omar,Onur,Orhan,Ozan,Patrick,Rafael,Rami,Ravi,Robin,Roman,Roni,Samir,Sarp,Selim,Serhat,Silas,Sinan,Soren,Tamer,Theo,Tomas,Tuna,Utku,Vedat,Viktor,Yağız,Yaman,Yusuf,Zeki"
const PREPARATION_SURNAMES := "Acar,Aksoy,Alkan,Altın,Arden,Arslan,Aslan,Aydın,Başar,Bennett,Bergen,Blake,Bozkurt,Brown,Carter,Çelik,Demir,Deniz,Doyle,Durmaz,Erdoğan,Eren,Ergin,Eroğlu,Everett,Fen,Fischer,Foster,Gale,Garcia,Giray,Güneş,Hale,Han,Harris,Hart,Hayes,Holm,Işık,Kara,Kaya,Keskin,Khan,King,Klein,Korkmaz,Kurt,Lane,Larsen,Lee,Marin,Marsh,Martin,Mercer,Miller,Moore,Moran,Moreau,Narin,Nolan,Özdemir,Özen,Park,Petrov,Reed,Rivera,Rowan,Santos,Scott,Sever,Shaw,Silva,Stone,Şahin,Tan,Taylor,Thorne,Toprak,Torres,Turner,Uzun,Vale,Vega,Walker,Ward,West,Wright,Yalçın,Yılmaz,Yıldız,Zane"
const PREPARATION_TURKISH_FEMALE_NAMES := "Ada,Alara,Asena,Aslı,Ayla,Bahar,Beren,Defne,Deniz,Derya,Dila,Ece,Elif,Elvan,Esma,Fatma,Gizem,Ilgın,Leyla,Melis,Mina,Mira,Neva,Nilay,Öykü,Selin,Sena,Seren,Suna,Yasemin,Zehra,Zeynep"
const PREPARATION_TURKISH_MALE_NAMES := "Adem,Ahmet,Akın,Ali,Alp,Aras,Arda,Aslan,Baran,Barış,Batu,Bora,Can,Cem,Deniz,Doruk,Efe,Ege,Emir,Emre,Enes,Eray,Eren,Galip,Hakan,Harun,Kaan,Kerem,Kuzey,Mert,Miran,Nazım,Okan,Onur,Orhan,Ozan,Sarp,Selim,Serhat,Sinan,Tamer,Tuna,Utku,Vedat,Yağız,Yaman,Yusuf,Zeki"
const PREPARATION_TURKISH_SURNAMES := "Acar,Aksoy,Alkan,Altın,Arslan,Aslan,Aydın,Başar,Bozkurt,Çelik,Demir,Deniz,Durmaz,Erdoğan,Eren,Ergin,Eroğlu,Giray,Güneş,Işık,Kara,Kaya,Keskin,Korkmaz,Kurt,Narin,Özdemir,Özen,Sever,Şahin,Tan,Toprak,Uzun,Yalçın,Yılmaz,Yıldız"
const PREPARATION_INTERNATIONAL_SURNAMES := "Arden,Bennett,Bergen,Blake,Brown,Carter,Doyle,Everett,Fen,Fischer,Foster,Gale,Garcia,Hale,Han,Harris,Hart,Hayes,Holm,Khan,King,Klein,Lane,Larsen,Lee,Marin,Marsh,Martin,Mercer,Miller,Moore,Moran,Moreau,Nolan,Park,Petrov,Reed,Rivera,Rowan,Santos,Scott,Shaw,Silva,Stone,Taylor,Thorne,Torres,Turner,Vale,Vega,Walker,Ward,West,Wright,Zane"
const PREPARATION_TURKISH_NICKNAMES := "Kıvılcım,Gölge,Boz,Kaya,Mavi,Fırtına,Yıldırım,Çınar,Kuzgun,Şahin,Çakıl,Kum,Ayaz,Poyraz,Yel,Gece,Gündüz,Işık,Çakır,Kurt,Asi,Sarp,Duman,Kırağı,Dalgıç,Çelik,Çevik,Minik,Yaman,Çakmak,Sessiz,Parlak,Derin,İzci,Usta,Tilki,Bulut,Şafak,Kıvırcık,Boncuk,Çiçek,Ateş,Akarsu,Yosun,Kartal,Kırlangıç,Rüzgar,Serçe,Denizci,Kaptan,Yıldız,Arı,Çita,Fındık,Kömür,Kırmızı,İnci,Şimşek,Gümüş,Kelebek,Şeker,Kara,Akça,Tunaç,Bilge,Çoban,Ozan,Ardıç,Çam,Tekir,Pars,Meraklı,Şanslı"
const PREPARATION_INTERNATIONAL_NICKNAMES := "Sparrow,Scout,Rook,Wren,Raven,Fox,Ghost,Ash,Ember,Flint,Stone,Slate,River,Storm,Blaze,Frost,Dusk,Dawn,Shade,Sunny,Patch,Doc,Sparks,Red,Blue,Gold,Silver,Bee,Kit,Mouse,Bear,Hawk,Finch,Swift,Dash,Skip,Whisper,Whistle,Arrow,Comet,Star,Orbit,Nova,Tinker,Forge,Anchor,Compass,North,South,Drift,Rusty,Pepper,Sage,Maple,Willow,Moss,Thorn,Clover,Pine,Bramble,Acorn,Brook,Lark,Moth,Cricket,Otter,Junebug,Lucky,Smudge,Cinder,Harbor,Skipper,Quest,Shiver,Bolt,Pixie,Smokey,Sunny,Midnight,Chime,Glimmer,Teacup,Marbles,Crimson,Indigo,Glint"
const PREPARATION_TURKISH_NICKNAME_PREFIXES := "Sessiz,Yaban,Gece,Şafak,Kuzey,Güney,Gümüş,Altın,Kızıl,Mavi,Kara,Ak,Saklı,Serin,Derin,Uçan,Keskin,Küçük,Büyük,Hızlı,Eski,Yeni,Uzak,Yakın,Parlak,Sakin,Yalnız,Cesur,Kırık,İnce,Yüksek,Alçak,Genç,Bilge,Çevik,Neşeli,Soğuk,Sıcak,Sisli,Ayazlı"
const PREPARATION_INTERNATIONAL_NICKNAME_PREFIXES := "Quiet,Wild,Night,Dawn,North,South,Silver,Golden,Red,Blue,Black,White,Hidden,Cool,Deep,Swift,Little,Grand,Fast,Old,New,Far,Near,Bright,Calm,Lone,Brave,Broken,Thin,High,Low,Young,Wise,Amber,Pale,Stormy,Cloudy,Misty,Winter,Summer"
const PREPARATION_EXTRA_TURKISH_NICKNAMES := "Akbaba,Alaca,Aslan,Avcı,Badem,Bal,Balta,Baykuş,Bıçak,Boğa,Bozkır,Böcek,Buz,Ceylan,Çapa,Çayır,Çaylak,Çerağ,Çiğdem,Çiftçi,Çizgi,Demir,Diken,Dolunay,Dönence,Doruk,Ekin,Engerek,Eşkin,Fener,Fok,Geyik,Gölcük,Güneş,Güvercin,Hançer,Hazine,Horoz,Ilgaz,İğne,İncir,İpek,İpekçi,Karaca,Karga,Kasırga,Kaval,Kılıç,Kirpi,Kök,Kumru,Kumul,Kuyu,Leylek,Lodos,Martı,Mercan,Mızrak,Nar,Nehir,Nöbetçi,Ocak,Orman,Oymak,Palamut,Pamuk,Panter,Papatya,Pınar,Pus,Pusula,Rota,Sabır,Saksağan,Salkım,Sansar,Sarmaşık,Saz,Sedef,Sel,Seren,Ses,Sığırcık,Siper,Sis,Söğüt,Şövalye,Taş,Tavşan,Tayfun,Telaş,Tılsım,Tohum,Toprak,Uçurtma,Ufuk,Uysal,Vadi,Yağmur,Yakut,Yaprak,Yelken,Yengeç,Yılan,Yolcu,Yonca,Zeytin,Zırh,Zümrüt"
const PREPARATION_EXTRA_INTERNATIONAL_NICKNAMES := "Badger,Bison,Lynx,Heron,Osprey,Kestrel,Robin,Crow,Magpie,Mantis,Gecko,Mink,Stoat,Weasel,Ferret,Mole,Boar,Stag,Elk,Fawn,Doe,Puma,Cougar,Jaguar,Panther,Falcon,Eagle,Owl,Nightowl,Firefly,Firebug,Glowworm,Beetle,Hopper,Salmon,Pike,Minnow,Marlin,Shell,Pebble,Boulder,Granite,Marble,Quartz,Copper,Bronze,Iron,Onyx,Opal,Jade,Pearl,Ruby,Topaz,Jasper,Garnet,Cobalt,Azure,Umber,Saffron,Sable,Scarlet,Violet,Lilac,Teal,Olive,Hazel,Coral,Briar,Rowan,Cedar,Aspen,Birch,Elm,Fir,Spruce,Ashen,Thistle,Fern,Nettle,Huckle,Juniper,Bracken,Fennel,Thyme,Basil,Pollen,Honeybee,Bumble,Quiver,Archer,Ranger,Wanderer,Nomad,Rover,Drifter,Rambler,Wayfarer,Keeper,Watcher,Seeker,Builder,Crafter,Stitch,Needle,Thread,Button,Tumbler,Knuckle,Rocket,Snap,Flicker,Lantern,Beacon,Jester,Joker,Grin,Smirk,Gleam,Shimmer,Twinkle,Ripple,Rumble,Thunder,Hail,Snow,Rain,Gust,Gale,Zephyr,Eclipse,Solstice,Meteor,Nebula,Cosmos,Zodiac,Saturn,Mars,Pluto,Mercury,Venus,Galaxy,Horizon"
const ITEM_PRICES := GameModel.ITEM_PRICES
# The model uses 600 simulation steps per day. An MVP step includes full pawn
# decisions and movement, so matching RimWorld's real-time day length made even
# the fastest setting feel inert. Keep the in-game calendar unchanged while
# making normal play 1.5 steps/s and the fastest setting 9 steps/s.
const NORMAL_STEPS_PER_REAL_SECOND := 1.5
const RESEARCH_PROJECTS := [
	{"id": "farming", "name": ["Farming", "Tarım", "Rolnictwo"], "detail": ["Grow crops for a steady food supply.", "Düzenli yiyecek için ekim alanları kur.", "Uprawiaj rośliny, by stale zdobywać żywność."]},
	{"id": "first_aid", "name": ["First Aid", "İlk Yardım", "Pierwsza pomoc"], "detail": ["Improve treatment and recovery.", "Bakımı ve iyileşmeyi geliştir.", "Usprawnij leczenie i powrót do zdrowia."]},
	{"id": "stonework", "name": ["Stonework", "Taş İşçiliği", "Obróbka kamienia"], "detail": ["Build durable stone walls.", "Dayanıklı taş duvarlar inşa et.", "Buduj trwałe kamienne ściany."]},
	{"id": "barriers", "name": ["Barriers", "Barikat", "Barykady"], "detail": ["Strengthen the settlement against raids.", "Yerleşkeyi baskınlara karşı güçlendir.", "Wzmocnij osadę przed najazdami."]}
]

class PawnPortrait extends Control:
	const PawnDrawer = preload("res://scripts/ui/pawn_visual.gd")
	const PreparationPawnArt = preload("res://scripts/ui/preparation_pawn_art.gd")
	var appearance: Dictionary = {}
	var classic_preparation := false
	var is_selected := false
	var is_drafted := false

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	func set_appearance(next_appearance: Dictionary) -> void:
		appearance = next_appearance
		queue_redraw()

	func _draw() -> void:
		if classic_preparation:
			var drawing_size := 100.0 if size.y >= 70.0 else 80.0
			var drawing_top := -7.0 if size.y >= 70.0 else -10.0
			PreparationPawnArt.draw_pawn(self, Rect2((size.x - drawing_size) * 0.5, drawing_top, drawing_size, drawing_size), appearance)
			return
		PawnDrawer.draw_pawn(self, Vector2(size.x * 0.5, size.y * 0.45), minf(size.x, size.y) * 0.78, appearance, is_selected, false, is_drafted)


class FamilyGraph extends Control:
	var clusters: Array = []
	var edges: Array = []
	var families: Array = []
	const LINK_COLOR := Color("#8e9796")
	const LINK_WIDTH := 8.0

	func _draw() -> void:
		for cluster in clusters:
			var rect: Rect2 = cluster
			draw_rect(rect, Color("#292b2d"))
		for family in families:
			var parents: Array = family["parents"]
			var children: Array = family["children"]
			if parents.is_empty() or children.is_empty():
				continue
			var color := LINK_COLOR
			var rail_y := (float(parents[0].y) + float(children[0].y)) * 0.5
			var left_x := INF
			var right_x := -INF
			for parent in parents:
				var center: Vector2 = parent
				left_x = minf(left_x, center.x)
				right_x = maxf(right_x, center.x)
				_draw_segment(center, Vector2(center.x, rail_y), color)
			for child in children:
				var center: Vector2 = child
				left_x = minf(left_x, center.x)
				right_x = maxf(right_x, center.x)
			_draw_segment(Vector2(left_x, rail_y), Vector2(right_x, rail_y), color)
			for child in children:
				var center: Vector2 = child
				_draw_segment(Vector2(center.x, rail_y), Vector2(center.x, center.y - 6.0), color)
				_draw_arrow_head(Vector2(center.x, center.y - 4.0), Vector2.DOWN, color)
		for edge in edges:
			var start: Vector2 = edge["start"]
			var finish: Vector2 = edge["finish"]
			var active: bool = edge["active"]
			var color := LINK_COLOR if active else Color("#67716f")
			if str(edge.get("kind", "parent")) == "sibling":
				_draw_segment(start, finish, color)
			else:
				var arrow_direction := 1.0 if finish.y >= start.y else -1.0
				var arrow_base_y := finish.y - arrow_direction * 6.0
				var middle_y := (start.y + arrow_base_y) * 0.5
				_draw_segment(start, Vector2(start.x, middle_y), color)
				_draw_segment(Vector2(start.x, middle_y), Vector2(finish.x, middle_y), color)
				_draw_segment(Vector2(finish.x, middle_y), Vector2(finish.x, arrow_base_y), color)
				_draw_arrow_head(Vector2(finish.x, finish.y - arrow_direction * 4.0), Vector2(0, arrow_direction), color)

	func _draw_segment(start: Vector2, finish: Vector2, color: Color) -> void:
		if start.distance_squared_to(finish) < 0.25:
			return
		# Draw one solid rail with integer-aligned edges. At reduced window sizes
		# a thin outlined stroke breaks into visibly jagged pixels.
		if absf(start.x - finish.x) < 0.25:
			var top := minf(start.y, finish.y)
			draw_rect(Rect2(roundf(start.x - LINK_WIDTH * 0.5), floorf(top), LINK_WIDTH, ceilf(absf(finish.y - start.y))), color)
		elif absf(start.y - finish.y) < 0.25:
			var left := minf(start.x, finish.x)
			draw_rect(Rect2(floorf(left), roundf(start.y - LINK_WIDTH * 0.5), ceilf(absf(finish.x - start.x)), LINK_WIDTH), color)
		else:
			draw_line(start, finish, color, LINK_WIDTH, true)

	func _draw_arrow_head(tip: Vector2, direction: Vector2, color: Color) -> void:
		var back := tip - direction * 16.0
		var side := Vector2(-direction.y, direction.x) * 12.0
		var shape := PackedVector2Array([tip, back + side, back - side])
		draw_colored_polygon(shape, color)
		draw_polyline(PackedVector2Array([tip, back + side, back - side, tip]), color, 2.0, true)


class RelationshipArrow extends Control:
	var forward := true
	var _arrow_texture: Texture2D

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		var points := "2,2 136,2 158,16 136,30 2,30" if forward else "22,2 158,2 158,30 22,30 0,16"
		var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="160" height="32" viewBox="0 0 160 32"><polygon points="%s" fill="#626c6d"/><polyline points="%s" fill="none" stroke="#9ba5a5" stroke-width="2" stroke-linejoin="round"/></svg>' % [points, points]
		var arrow_image := Image.new()
		if arrow_image.load_svg_from_buffer(svg.to_utf8_buffer(), 4.0) == OK:
			_arrow_texture = ImageTexture.create_from_image(arrow_image)

	func _draw() -> void:
		if _arrow_texture != null:
			draw_texture_rect(_arrow_texture, Rect2(Vector2.ZERO, size), false)


class PrepDiceButton extends Button:
	func _ready() -> void:
		flat = true
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var side := minf(15.0, minf(size.x, size.y) - 4.0)
		var origin := (size - Vector2.ONE * side) * 0.5
		var ink := Color("#d1d0c9")
		draw_rect(Rect2(origin, Vector2.ONE * side), ink, false, 1.2)
		for mark in [Vector2(3.5, 3.5), Vector2(11.5, 3.5), Vector2(7.5, 7.5), Vector2(3.5, 11.5), Vector2(11.5, 11.5)]:
			draw_circle(origin + mark * side / 15.0, 1.05, ink)


class PrepInfoButton extends Button:
	func _ready() -> void:
		flat = true
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var center := size * 0.5
		var ink := Color("#d1d0c9")
		draw_arc(center, 7.5, 0.0, TAU, 24, ink, 1.2, true)
		draw_circle(center + Vector2(0, -3.8), 1.1, ink)
		draw_line(center + Vector2(0, -0.5), center + Vector2(0, 4.6), ink, 1.6, true)


class PrepResetButton extends Button:
	func _ready() -> void:
		flat = true
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var center := size * 0.5
		var ink := Color("#d1d0c9")
		draw_arc(center, 7.5, -2.5, 3.45, 28, ink, 1.7, true)
		draw_colored_polygon(PackedVector2Array([center + Vector2(-8.1, -1.5), center + Vector2(-8.0, -7.4), center + Vector2(-2.6, -3.3)]), ink)


class PrepPointLimitButton extends Button:
	var enabled := false

	func _ready() -> void:
		flat = true
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var ink := Color("#4fb963") if enabled else Color("#d22329")
		var left := 4.0
		var right := size.x - 4.0
		var top := 4.0
		var bottom := size.y - 4.0
		if enabled:
			draw_line(Vector2(left, size.y * 0.53), Vector2(size.x * 0.42, bottom), ink, 3.5)
			draw_line(Vector2(size.x * 0.42, bottom), Vector2(right, top), ink, 3.5)
		else:
			draw_line(Vector2(left, top), Vector2(right, bottom), ink, 3.5)
			draw_line(Vector2(right, top), Vector2(left, bottom), ink, 3.5)


class PrepColorButton extends Button:
	signal color_changed(next_color: Color)
	var color := Color.WHITE

	func _ready() -> void:
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var inside := Rect2(Vector2(2, 2), size - Vector2(4, 4))
		draw_rect(inside, color)
		draw_rect(inside, Color("#6b6a65"), false, 1.0)

	func set_picked_color(next_color: Color) -> void:
		color = next_color
		queue_redraw()
		color_changed.emit(next_color)


class PrepColorActionButton extends Button:
	var action := "copy"

	func _ready() -> void:
		flat = true
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var ink := Color("#e5e2d9")
		var shadow := Color("#111417")
		var accent := Color("#c9a46d")
		if is_hovered():
			draw_rect(Rect2(Vector2.ZERO, size), Color("#414344"))
		if action == "eyedropper":
			draw_colored_polygon(PackedVector2Array([Vector2(3, 21), Vector2(4, 16), Vector2(7, 19)]), ink)
			draw_colored_polygon(PackedVector2Array([Vector2(4, 16), Vector2(14, 6), Vector2(19, 11), Vector2(9, 21)]), shadow)
			draw_colored_polygon(PackedVector2Array([Vector2(7, 16), Vector2(14, 9), Vector2(16, 11), Vector2(9, 18)]), ink)
			draw_colored_polygon(PackedVector2Array([Vector2(13, 6), Vector2(17, 2), Vector2(21, 2), Vector2(24, 5), Vector2(24, 8), Vector2(19, 13)]), shadow)
			draw_colored_polygon(PackedVector2Array([Vector2(15, 6), Vector2(18, 3), Vector2(21, 3), Vector2(23, 5), Vector2(23, 8), Vector2(19, 11)]), ink)
			draw_circle(Vector2(20, 6), 1.2, shadow)
			return
		# Two paper outlines with a clear direction mark, on the color-name row.
		draw_rect(Rect2(3, 7, 11, 13), shadow)
		draw_rect(Rect2(3, 7, 11, 13), ink, false, 1.5)
		draw_rect(Rect2(7, 3, 11, 13), shadow)
		draw_rect(Rect2(7, 3, 11, 13), ink, false, 1.5)
		if action == "copy":
			draw_line(Vector2(17, 10), Vector2(22, 5), shadow, 3.5, true)
			draw_line(Vector2(17, 10), Vector2(22, 5), accent, 2.0, true)
			draw_line(Vector2(17, 5), Vector2(22, 5), accent, 2.0, true)
			draw_line(Vector2(22, 5), Vector2(22, 10), accent, 2.0, true)
		else:
			draw_line(Vector2(10, 16), Vector2(5, 21), shadow, 3.5, true)
			draw_line(Vector2(10, 16), Vector2(5, 21), accent, 2.0, true)
			draw_line(Vector2(5, 16), Vector2(5, 21), accent, 2.0, true)
			draw_line(Vector2(5, 21), Vector2(10, 21), accent, 2.0, true)


class PrepColorWheel extends Control:
	signal color_changed(next_color: Color)
	const DIAMETER := 176
	var color := Color.WHITE
	var _wheel_texture: ImageTexture
	var _drag_part := ""

	func _ready() -> void:
		custom_minimum_size = Vector2(208, 184)
		mouse_filter = Control.MOUSE_FILTER_STOP
		var image := Image.create(DIAMETER, DIAMETER, false, Image.FORMAT_RGBA8)
		var radius := float(DIAMETER) * 0.5
		for y in range(DIAMETER):
			for x in range(DIAMETER):
				var offset := Vector2(float(x) + 0.5 - radius, float(y) + 0.5 - radius)
				var saturation := offset.length() / radius
				if saturation > 1.0:
					image.set_pixel(x, y, Color.TRANSPARENT)
				else:
					var hue := fposmod(atan2(offset.y, offset.x) / TAU, 1.0)
					image.set_pixel(x, y, Color.from_hsv(hue, saturation, 1.0))
		_wheel_texture = ImageTexture.create_from_image(image)
		queue_redraw()

	func _draw() -> void:
		draw_texture(_wheel_texture, Vector2(2, 2))
		var center := Vector2(90, 90)
		var angle := color.h * TAU
		var marker := center + Vector2(cos(angle), sin(angle)) * color.s * 87.0
		draw_circle(marker, 7.0, Color.BLACK)
		draw_circle(marker, 5.0, color)
		draw_arc(marker, 6.0, 0.0, TAU, 24, Color.WHITE, 1.5, true)
		for y in range(176):
			var value := 1.0 - float(y) / 175.0
			draw_rect(Rect2(189, 2 + y, 15, 1), Color.from_hsv(color.h, color.s, value))
		draw_rect(Rect2(188, 1, 17, 178), Color("#696a68"), false, 1)
		var marker_y := 2.0 + (1.0 - color.v) * 175.0
		draw_line(Vector2(186, marker_y), Vector2(207, marker_y), Color.WHITE, 2.0)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_drag_part = "value" if event.position.x >= 185.0 else "wheel"
				_pick(event.position)
			else:
				_drag_part = ""
		elif event is InputEventMouseMotion and not _drag_part.is_empty():
			_pick(event.position)

	func _pick(point: Vector2) -> void:
		if _drag_part == "value":
			color = Color.from_hsv(color.h, color.s, clampf(1.0 - (point.y - 2.0) / 175.0, 0.0, 1.0))
		else:
			var offset := point - Vector2(90, 90)
			color = Color.from_hsv(fposmod(atan2(offset.y, offset.x) / TAU, 1.0), clampf(offset.length() / 87.5, 0.0, 1.0), color.v)
		queue_redraw()
		color_changed.emit(color)


class PrepGenderButton extends Button:
	var is_male := false
	var selected := false

	func _ready() -> void:
		flat = true
		custom_minimum_size = Vector2(20, 21)
		for state in ["normal", "hover", "pressed", "focus"]:
			add_theme_stylebox_override(state, StyleBoxEmpty.new())

	func _draw() -> void:
		var ink := Color("#ef9cb9") if not is_male else Color("#80b9e5")
		if not selected:
			ink.a = 0.64
		var center := Vector2(8.5, 9.0)
		draw_arc(center, 4.4, 0.0, TAU, 24, ink, 1.8, true)
		if is_male:
			draw_line(center + Vector2(3.1, -3.1), center + Vector2(7.5, -7.5), ink, 1.8, true)
			draw_line(center + Vector2(4.1, -7.5), center + Vector2(7.5, -7.5), ink, 1.8, true)
			draw_line(center + Vector2(7.5, -7.5), center + Vector2(7.5, -4.1), ink, 1.8, true)
		else:
			draw_line(center + Vector2(0, 4.4), center + Vector2(0, 9.2), ink, 1.8, true)
			draw_line(center + Vector2(-2.6, 7.0), center + Vector2(2.6, 7.0), ink, 1.8, true)

class PassionFlame extends Button:
	signal level_changed(next_level: int)
	var level := 0
	static var _icons: Dictionary = {}

	func _ready() -> void:
		flat = true
		custom_minimum_size = Vector2(22, 21)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pressed.connect(_cycle)

	func _cycle() -> void:
		level = (level + 1) % 3
		level_changed.emit(level)
		queue_redraw()

	func _draw() -> void:
		if not _icons.has(level):
			var flame_path := 'M12 2 C13 7 17 8 17 13 C17 18 14.6 21 11.7 21 C8.4 21 6 18.2 6 14.8 C6 11.7 7.9 9.5 9.3 7.3 C9.2 10 10.5 10.9 11.4 11.3 C12.9 8.9 12.2 5.5 12 2 Z'
			var core_path := 'M11.8 12.7 C13.3 14.3 14.1 15.4 14.1 17 C14.1 19.2 12.8 20.4 11.5 20.4 C10 20.4 8.9 19.1 8.9 17.4 C8.9 15.7 10.2 14.4 11.8 12.7 Z'
			var svg := '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24">'
			if level == 0:
				svg += '<path d="%s" fill="none" stroke="#55595a" stroke-width="1.6" stroke-linejoin="round"/>' % flame_path
			elif level == 1:
				svg += '<path d="%s" fill="#ec8139" stroke="#97471f" stroke-width=".8" stroke-linejoin="round"/><path d="%s" fill="#ffd57a"/>' % [flame_path, core_path]
			else:
				svg += '<g transform="translate(-4 7) scale(.65)"><path d="%s" fill="#e77932"/><path d="%s" fill="#ffd176"/></g>' % [flame_path, core_path]
				svg += '<path d="%s" fill="#f2973e" stroke="#97471f" stroke-width=".7"/><path d="%s" fill="#ffdc86"/>' % [flame_path, core_path]
				svg += '<g transform="translate(11 7) scale(.65)"><path d="%s" fill="#e77932"/><path d="%s" fill="#ffd176"/></g>' % [flame_path, core_path]
			svg += '</svg>'
			var source := Image.new()
			if source.load_svg_from_string(svg) == OK:
				_icons[level] = ImageTexture.create_from_image(source)
		if _icons.has(level):
			var bounds := Rect2(Vector2(5, 4), Vector2(12, 13)) if level == 0 else Rect2(Vector2(6, 4), Vector2(11, 14)) if level == 1 else Rect2(Vector2(1, 1), Vector2(20, 19))
			draw_texture_rect(_icons[level], bounds, false)


class PrepStepper extends HBoxContainer:
	signal changed(next_value: int)
	var value := 0
	var minimum := 0
	var maximum := 100
	var display_mode := "standard"
	var field: LineEdit
	var track: Control
	var skill_display: Button

	func _init(initial_value: int = 0, lower: int = 0, upper: int = 100, mode: String = "standard") -> void:
		minimum = lower
		maximum = upper
		value = clampi(initial_value, minimum, maximum)
		display_mode = mode

	func _ready() -> void:
		add_theme_constant_override("separation", 0 if display_mode != "standard" else 2)
		var previous := Button.new()
		previous.text = "<"
		previous.custom_minimum_size = Vector2(14, 21) if display_mode == "skill" else (Vector2(17, 25) if display_mode == "age" else (Vector2(18, 25) if display_mode != "standard" else Vector2(23, 25)))
		previous.pressed.connect(func(): set_value(value - 1))
		field = LineEdit.new()
		field.text = str(value)
		field.alignment = HORIZONTAL_ALIGNMENT_CENTER
		field.custom_minimum_size = Vector2(20, 21) if display_mode == "skill" else (Vector2(48, 25) if display_mode == "age" else (Vector2(36, 25) if display_mode != "standard" else Vector2(42, 25)))
		field.add_theme_font_size_override("font_size", 12)
		field.text_submitted.connect(func(_text: String): _commit())
		field.focus_exited.connect(_commit)
		var next := Button.new()
		next.text = ">"
		next.custom_minimum_size = Vector2(14, 21) if display_mode == "skill" else (Vector2(17, 25) if display_mode == "age" else (Vector2(18, 25) if display_mode != "standard" else Vector2(23, 25)))
		next.pressed.connect(func(): set_value(value + 1))
		if display_mode != "standard":
			previous.flat = true
			next.flat = true
			previous.add_theme_font_size_override("font_size", 12)
			next.add_theme_font_size_override("font_size", 12)
		if display_mode == "inline":
			field.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
			field.add_theme_stylebox_override("read_only", StyleBoxEmpty.new())
		if display_mode in ["skill", "age"]:
			for state_name in ["normal", "focus", "read_only"]:
				var field_style := StyleBoxFlat.new()
				field_style.bg_color = Color("#494b4d") if display_mode == "skill" else Color("#17191a")
				field_style.set_content_margin_all(0)
				field.add_theme_stylebox_override(state_name, field_style)
		if display_mode == "skill":
			skill_display = Button.new()
			skill_display.text = str(value)
			skill_display.custom_minimum_size = Vector2(20, 21)
			skill_display.alignment = HORIZONTAL_ALIGNMENT_CENTER
			skill_display.add_theme_font_size_override("font_size", 12)
			for state_name in ["normal", "hover", "pressed"]:
				var cell := StyleBoxFlat.new()
				cell.bg_color = Color("#494b4d") if state_name == "normal" else Color("#555759")
				cell.set_content_margin_all(0)
				skill_display.add_theme_stylebox_override(state_name, cell)
			skill_display.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
			skill_display.pressed.connect(func():
				skill_display.visible = false
				field.visible = true
				field.grab_focus()
				field.select_all())
			add_child(skill_display)
			add_child(field)
			field.visible = false
			field.focus_exited.connect(_finish_skill_edit)
			field.text_submitted.connect(func(_text: String): _finish_skill_edit())
			track = PrepSkillTrack.new()
			track.custom_minimum_size = Vector2(74, 21)
			track.level = value
			track.level_picked.connect(func(next_level: int): set_value(next_level))
			add_child(track)
			add_child(previous)
			add_child(next)
		else:
			add_child(previous)
			add_child(field)
			add_child(next)

	func set_value(next_value: int, emit_change := true) -> void:
		value = clampi(next_value, minimum, maximum)
		field.text = str(value)
		if is_instance_valid(skill_display):
			skill_display.text = str(value)
		if is_instance_valid(track):
			track.level = value
			track.queue_redraw()
		if emit_change:
			changed.emit(value)

	func _commit() -> void:
		set_value(int(field.text) if field.text.is_valid_int() else value)

	func _finish_skill_edit() -> void:
		if display_mode == "skill" and is_instance_valid(skill_display):
			field.visible = false
			skill_display.visible = true


class PrepSkillTrack extends Control:
	signal level_picked(next_level: int)
	var level := 0
	var dragging := false

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 21)), Color("#292b2d"))
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 21)), Color("#545658"), false, 1.0)
		if level > 0:
			draw_rect(Rect2(Vector2(1, 1), Vector2((size.x - 2) * float(level) / 20.0, 19)), Color("#58615b"))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				level_picked.emit(clampi(roundi(event.position.x / maxf(1.0, size.x) * 20.0), 0, 20))
		elif event is InputEventMouseMotion and dragging:
			level_picked.emit(clampi(roundi(event.position.x / maxf(1.0, size.x) * 20.0), 0, 20))


class PrepCargoIcon extends Control:
	var item_id := ""

	func _ready() -> void:
		custom_minimum_size = Vector2(36, 36)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(size.x / 36.0, size.y / 36.0))
		match item_id:
			"packaged_survival_meal":
				draw_rect(Rect2(4, 10, 28, 20), Color("#443820"))
				draw_rect(Rect2(5, 8, 26, 20), Color("#b58929"))
				draw_rect(Rect2(5, 8, 26, 5), Color("#d6ac37"))
				draw_line(Vector2(8, 19), Vector2(28, 19), Color("#916b22"), 2)
			"medicine":
				draw_rect(Rect2(3, 8, 30, 22), Color("#263c40"))
				draw_rect(Rect2(5, 9, 26, 19), Color("#568e91"))
				draw_rect(Rect2(15, 11, 6, 16), Color("#afd1ce"))
				draw_rect(Rect2(10, 16, 16, 6), Color("#afd1ce"))
			"component":
				var metal := Color("#9a9a8d")
				var edge := Color("#555953")
				draw_colored_polygon(PackedVector2Array([Vector2(3, 11), Vector2(9, 5), Vector2(17, 13), Vector2(27, 3), Vector2(33, 9), Vector2(23, 18), Vector2(33, 27), Vector2(27, 33), Vector2(18, 23), Vector2(9, 32), Vector2(3, 27), Vector2(13, 18)]), edge)
				draw_circle(Vector2(18, 18), 10, metal)
				draw_circle(Vector2(18, 18), 4, Color("#5e615d"))
			"pistol":
				draw_rect(Rect2(5, 13, 24, 5), Color("#242629"))
				draw_rect(Rect2(6, 12, 20, 3), Color("#595e5f"))
				draw_colored_polygon(PackedVector2Array([Vector2(12, 17), Vector2(21, 17), Vector2(18, 28), Vector2(13, 27)]), Color("#4f3b31"))
				draw_rect(Rect2(25, 14, 7, 2), Color("#9a8571"))
			"assault_rifle", "sniper_rifle":
				draw_rect(Rect2(2, 16, 32, 4), Color("#25292a"))
				draw_rect(Rect2(10, 14, 15, 4), Color("#4b5152"))
				draw_line(Vector2(13, 19), Vector2(16, 29), Color("#323637"), 4)
				draw_line(Vector2(8, 20), Vector2(4, 25), Color("#323637"), 3)
				if item_id == "sniper_rifle":
					draw_rect(Rect2(15, 10, 11, 3), Color("#242829"))
					draw_rect(Rect2(31, 17, 5, 2), Color("#202526"))
			"chemfuel":
				draw_rect(Rect2(8, 8, 23, 25), Color("#571d21"))
				draw_rect(Rect2(10, 10, 19, 21), Color("#a52e34"))
				draw_rect(Rect2(12, 6, 11, 5), Color("#481d20"))
				draw_line(Vector2(16, 16), Vector2(24, 25), Color("#622225"), 2)
				draw_line(Vector2(24, 16), Vector2(16, 25), Color("#622225"), 2)
			"female_elephant":
				draw_colored_polygon(PackedVector2Array([Vector2(4, 17), Vector2(8, 11), Vector2(24, 10), Vector2(30, 16), Vector2(29, 25), Vector2(26, 25), Vector2(25, 31), Vector2(20, 31), Vector2(20, 25), Vector2(12, 25), Vector2(10, 31), Vector2(6, 31)]), Color("#818281"))
				draw_circle(Vector2(27, 16), 7, Color("#9d9e9b"))
				draw_rect(Rect2(30, 17, 4, 12), Color("#8e908e"))
				draw_circle(Vector2(29, 14), 1.2, Color("#333435"))
			"spear":
				draw_line(Vector2(5, 30), Vector2(29, 7), Color("#825d37"), 4)
				draw_colored_polygon(PackedVector2Array([Vector2(24, 9), Vector2(33, 2), Vector2(30, 15)]), Color("#a2aaa6"))
			_:
				draw_rect(Rect2(5, 8, 26, 22), Color("#6f7372"))
				draw_rect(Rect2(7, 10, 22, 5), Color("#a1a5a2"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class PrepGrain extends Control:
	var grain: Texture2D

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

	func _draw() -> void:
		if grain != null:
			draw_texture_rect(grain, Rect2(Vector2.ZERO, size), true)

var screen := "menu"
var session_kind := "solo"
var setup_mode := "solo"
var setup_seed := ""
var scenario_id := "landfall"
var storyteller_id := "steady"
var difficulty_id := "frontier"
var world_options := {"coverage": 0.50, "rainfall": 0.50, "temperature": 0.50, "population": 0.50}
var starting_cargo: Dictionary = {}
var _cargo_search_text := ""
var _preparation_grain: Texture2D
var _preparation_copied_color := ""
var _preparation_sample_target: PrepColorButton
var _preparation_sample_overlay: ColorRect
var _selected_equipment_catalog_id := "wood"
var _equipment_category_filter := 0
var _equipment_material_filter := 0
var colonist_count := 3
var faction_count := 2
var host_port := 24567
var selected_site_id := ""
var world_preview: Dictionary = {}
var faction_name := "Unnamed colony"
var settlement_name := "Unnamed settlement"
var character_specs: Array = []
var world_character_specs: Array = []
var external_relationships: Array = []
var _colony_relation_first_index := 0
var _colony_relation_second_index := 1
var _external_source_index := 0
var _external_target_key := "c:0"
var _world_roster_expanded := false
var _preparation_appearance_category := 0
var _used_prepared_full_names: Dictionary = {}
var _used_prepared_first_names: Dictionary = {}
var _used_prepared_nicknames: Dictionary = {}
var point_limit_enabled := true
var current_tab := ""
var pawn_tab := ""
var order_category := "Designate"
var schedule_brush := "work"
var selected_ids: Array[String] = []
var selected_order_id := ""
var default_order_priority := 5
var current_tool := ""
var game_paused := false
var speed := 1.0
var _tick_accumulator := 0.0
var _last_hud_render_ms := 0
var _status_text := ""
var _status_timer := 0.0
var _game_root: Control
var _map_view: Control
var _sidebar: VBoxContainer
var _tool_panel: PanelContainer
var _pawn_panel: PanelContainer
var _pawn_detail_panel: PanelContainer
var _pawn_summary: VBoxContainer
var _pawn_detail_content: VBoxContainer
var _command_strip: HBoxContainer
var _resource_stack: VBoxContainer
var _alert_stack: VBoxContainer
var _notice_label: Label
var _time_label: Label
var _portrait_strip: HBoxContainer
var _tab_buttons: Dictionary = {}
var _speed_buttons: Dictionary = {}
var _portrait_signature := ""
var _context_menu: PopupMenu
var _context_tile := Vector2i.ZERO
var _context_unit_id := ""
var _context_enemy_id := ""
var _context_order_id := ""
var _context_caravan_id := ""
var _context_structure_id := ""
var _trade_caravan_pending_id := ""
var _style_colonist_pending_id := ""
var _world_view: Control
var _world_settings_preview: Control
var _site_info: VBoxContainer
var _terrain_preview: Control
var _seed_edit: LineEdit
var _mode_option: OptionButton
var _host_port_input: SpinBox
var _character_inputs: Array = []
var _roster_buttons: Array[Button] = []
var _character_points: Label
var _editing_character_index := 0
var preparation_tab := "characters"
var preferences = SettingsScript.load_settings()
var _menu_overlay: Control
var _settings_overlay: Control
var _settings_return_paused := false
var _exit_return_paused := false
var _exit_warning_open := false
var _pause_menu_open := false
var _save_picker_open := false
var _naming_prompt_open := false
var _naming_overlay: Control
var _active_alerts: Array[String] = []
var _settings_draft: Dictionary = {}
var _settings_page: VBoxContainer
var _capture_keybind_action := ""


func _ready() -> void:
	get_tree().auto_accept_quit = false
	preferences.apply_settings()
	Game.state_changed.connect(_on_state_changed)
	Game.event_emitted.connect(_on_event_emitted)
	Net.connection_changed.connect(_on_connection_changed)
	Net.lobby_changed.connect(_on_lobby_changed)
	Net.snapshot_received.connect(_on_network_snapshot)
	_show_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if screen == "game":
			if _naming_prompt_open:
				return
			if is_instance_valid(_settings_overlay):
				_close_settings()
			_request_exit(false)
		else:
			get_tree().quit()


func _process(delta: float) -> void:
	if _status_timer > 0.0:
		_status_timer -= delta
		if _status_timer <= 0.0 and is_instance_valid(_notice_label):
			_notice_label.visible = false
	if screen != "game":
		return
	if game_paused:
		return
	_pan_camera_from_keys(delta)
	if session_kind != "join" and Game.advance_autosave(delta, preferences.autosave_interval_minutes, preferences.autosave_count):
		_notice(_prep_local("Autosaved.", "Otomatik kaydedildi.", "Zapisano automatycznie."))
	_tick_accumulator += delta * speed * NORMAL_STEPS_PER_REAL_SECOND
	while _tick_accumulator >= 1.0 and not game_paused:
		_tick_accumulator -= 1.0
		if session_kind != "join":
			Game.tick(1.0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if _naming_prompt_open:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE and is_instance_valid(_settings_overlay):
		_close_settings()
		get_viewport().set_input_as_handled()
		return
	if event.keycode == KEY_ESCAPE and is_instance_valid(_menu_overlay):
		_close_menu_overlay()
		get_viewport().set_input_as_handled()
		return
	if is_instance_valid(_settings_overlay) or is_instance_valid(_menu_overlay):
		return
	if screen == "game" and not _pause_menu_open and not _exit_warning_open and not _save_picker_open:
		var focused := get_viewport().gui_get_focus_owner()
		if focused is LineEdit or focused is TextEdit or focused is SpinBox:
			return
		var keybinds: Dictionary = preferences.keybinds
		for action in keybinds:
			if event.keycode != int(keybinds[action]):
				continue
			if _handle_game_shortcut(str(action)):
				get_viewport().set_input_as_handled()
			return
	if event.keycode == KEY_F11:
		if DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]:
			preferences.window_mode = "windowed"
		else:
			preferences.window_mode = "fullscreen"
		preferences.apply_settings()
		preferences.save_settings()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and screen == "game":
		_show_pause_menu()
		get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void:
	if is_instance_valid(_preparation_sample_target):
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_end_preparation_color_sampling()
			get_viewport().set_input_as_handled()
			return
	if screen == "characters" and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var name_focus := get_viewport().gui_get_focus_owner()
		if name_focus is LineEdit and name_focus.get_parent() != null and name_focus.get_parent().name == "PreparationNames":
			if not name_focus.get_global_rect().has_point(event.position):
				name_focus.release_focus()
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if _naming_prompt_open:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
		return
	if not _capture_keybind_action.is_empty() and is_instance_valid(_settings_overlay):
		get_viewport().set_input_as_handled()
		var action := _capture_keybind_action
		_capture_keybind_action = ""
		if event.keycode in [KEY_ESCAPE, KEY_F11, 0]:
			_build_settings_page(_settings_page, "controls", _settings_draft)
			return
		var binds: Dictionary = _settings_draft["keybinds"].duplicate()
		var previous := int(binds[action])
		for other in binds:
			if other != action and int(binds[other]) == event.keycode:
				binds[other] = previous
				break
		binds[action] = event.keycode
		_settings_draft["keybinds"] = binds
		_build_settings_page(_settings_page, "controls", _settings_draft)
		return
	if event.keycode == KEY_ESCAPE and screen == "game" and not _pause_menu_open and not _exit_warning_open and not _save_picker_open and not _naming_prompt_open and not is_instance_valid(_settings_overlay) and not is_instance_valid(_menu_overlay):
		_show_pause_menu()
		get_viewport().set_input_as_handled()
		return
	if screen != "game" or _pause_menu_open or _exit_warning_open or _save_picker_open or _naming_prompt_open or is_instance_valid(_settings_overlay) or is_instance_valid(_menu_overlay):
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit or focused is SpinBox:
		return
	# Handle pause before GUI buttons see Space as ui_accept. Otherwise a
	# focused HUD button can activate its tab on the same keypress.
	if event.keycode == int(preferences.keybinds.get("pause", KEY_SPACE)):
		_handle_game_shortcut("pause")
		get_viewport().set_input_as_handled()
		return
	for action in ["tab_orders", "tab_work", "tab_schedule", "tab_health", "tab_research", "tab_world"]:
		if event.keycode == int(preferences.keybinds.get(action, 0)):
			if _handle_game_shortcut(action):
				get_viewport().set_input_as_handled()
			return


func _handle_game_shortcut(action: String) -> bool:
	match action:
		"pause": _set_speed(speed if game_paused else 0.0)
		"speed_1": _set_speed(1.0)
		"speed_2": _set_speed(3.0)
		"speed_3": _set_speed(6.0)
		"draft": _toggle_draft_shortcut()
		"clear_order": _clear_order_shortcut()
		"zoom_in":
			if is_instance_valid(_map_view): _map_view.zoom_step(1.12)
		"zoom_out":
			if is_instance_valid(_map_view): _map_view.zoom_step(1.0 / 1.12)
		"tab_orders": _set_tab("Emirler")
		"tab_work": _set_tab("İşler")
		"tab_schedule": _set_tab("Günlük plan")
		"tab_health": _set_tab("Sağlık")
		"tab_research": _set_tab("Araştırma")
		"tab_world": _set_tab("Dünya")
		"previous_colonist": _select_next_colonist(-1)
		"next_colonist": _select_next_colonist(1)
		"focus_colonist": _focus_selected_colonist()
		"pan_up", "pan_down", "pan_left", "pan_right": pass
		_: return false
	return true


func _pan_camera_from_keys(delta: float) -> void:
	if not is_instance_valid(_map_view) or is_instance_valid(_settings_overlay) or is_instance_valid(_menu_overlay):
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit or focused is SpinBox:
		return
	var binds: Dictionary = preferences.keybinds
	var direction := Vector2.ZERO
	if Input.is_key_pressed(int(binds["pan_up"])) or Input.is_key_pressed(KEY_UP): direction.y += 1.0
	if Input.is_key_pressed(int(binds["pan_down"])) or Input.is_key_pressed(KEY_DOWN): direction.y -= 1.0
	if Input.is_key_pressed(int(binds["pan_left"])) or Input.is_key_pressed(KEY_LEFT): direction.x += 1.0
	if Input.is_key_pressed(int(binds["pan_right"])) or Input.is_key_pressed(KEY_RIGHT): direction.x -= 1.0
	if direction != Vector2.ZERO:
		var fast := 2.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0
		_map_view.pan_pixels(direction.normalized() * delta * 480.0 * fast)


func _select_next_colonist(direction: int) -> void:
	var people := _local_colonists(_snapshot())
	if people.is_empty(): return
	var current_index := -1
	for index in people.size():
		if selected_ids.has(str(people[index].get("id", ""))):
			current_index = index
			break
	var next_index := (0 if direction > 0 else people.size() - 1) if current_index < 0 else posmod(current_index + direction, people.size())
	_select_colonist(str(people[next_index].get("id", "")))
	_focus_selected_colonist()


func _focus_selected_colonist() -> void:
	if not is_instance_valid(_map_view): return
	var person := _selected_person(_snapshot())
	if person.is_empty(): return
	_map_view.focus_tile(Vector2i(int(person.get("x", 0)), int(person.get("y", 0))))


func _toggle_draft_shortcut() -> void:
	var people := _local_colonists(_snapshot())
	var targets: Array = []
	for person in people:
		if selected_ids.is_empty() or selected_ids.has(str(person.get("id", ""))):
			targets.append(person)
	if targets.is_empty(): return
	var should_draft := false
	for person in targets:
		if not bool(person.get("drafted", false)):
			should_draft = true
			break
	for person in targets:
		_send_command({"type": "set_draft", "colonist_id": str(person.get("id", "")), "drafted": should_draft})


func _clear_order_shortcut() -> void:
	for person_id in selected_ids:
		_send_command({"type": "direct", "colonist_id": person_id, "action": "clear"})


func _style(color: Color, border: Color = Color.TRANSPARENT, radius: int = 2) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.border_width_left = 1 if border.a > 0.0 else 0
	box.border_width_top = 1 if border.a > 0.0 else 0
	box.border_width_right = 1 if border.a > 0.0 else 0
	box.border_width_bottom = 1 if border.a > 0.0 else 0
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 9
	box.content_margin_top = 6
	box.content_margin_right = 9
	box.content_margin_bottom = 6
	return box


func _button(label_text: String, action: Callable, accent := false, minimum := Vector2.ZERO) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = minimum if minimum != Vector2.ZERO else Vector2(0, 32)
	button.add_theme_color_override("font_color", BG if accent else CREAM)
	button.add_theme_color_override("font_hover_color", BG if accent else CREAM)
	button.add_theme_color_override("font_pressed_color", BG if accent else CREAM)
	button.add_theme_stylebox_override("normal", _style(GOLD if accent else PANEL_ALT, Color("#555957", 0.8)))
	button.add_theme_stylebox_override("hover", _style(Color("#dec895") if accent else Color("#4a4e4d"), GOLD))
	button.add_theme_stylebox_override("pressed", _style(Color("#aa915f") if accent else Color("#202323"), GOLD))
	button.pressed.connect(action)
	return button


func _label(value: String, font_size := 16, color: Color = CREAM) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	return label


func _panel(minimum := Vector2.ZERO) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = minimum
	panel.add_theme_stylebox_override("panel", _style(PANEL, Color("#4a4d4a", 0.75)))
	return panel


func _compact_option(option: OptionButton) -> void:
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := _style(PANEL_ALT, Color("#555957", 0.8))
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		option.add_theme_stylebox_override(state, style)


func _vbox(separation := 10) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	return box


func _hbox(separation := 10) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", separation)
	return box


func _clear_screen() -> VBoxContainer:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var background := ColorRect.new()
	background.color = BG
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var margin := MarginContainer.new()
	var edge := 0 if screen == "game" else 20
	margin.add_theme_constant_override("margin_left", edge)
	margin.add_theme_constant_override("margin_top", edge)
	margin.add_theme_constant_override("margin_right", edge)
	margin.add_theme_constant_override("margin_bottom", edge)
	add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := _vbox(0 if screen in ["game", "characters"] else 12)
	margin.add_child(content)
	return content


func _screen_header(parent: VBoxContainer, title: String, subtitle: String) -> void:
	var row := _hbox(16)
	parent.add_child(row)
	var mark := _label("◆", 28, GOLD)
	row.add_child(mark)
	var headings := _vbox(1)
	headings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(headings)
	var title_label := _label(title, 27)
	title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	headings.add_child(title_label)
	var subtitle_label := _label(subtitle, 14, MUTED)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	headings.add_child(subtitle_label)
	var line := HSeparator.new()
	parent.add_child(line)


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return spacer


func _show_menu() -> void:
	screen = "menu"
	var root := _clear_screen()
	_menu_overlay = null
	_settings_overlay = null
	_add_menu_backdrop()
	var stage := _hbox(0)
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(stage)
	var illustration_space := Control.new()
	illustration_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage.add_child(illustration_space)
	var choices := _vbox(13)
	choices.custom_minimum_size = Vector2(340, 0)
	choices.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stage.add_child(choices)
	var logo := _hbox(6)
	logo.alignment = BoxContainer.ALIGNMENT_CENTER
	choices.add_child(logo)
	var mark := TextureRect.new()
	mark.texture = load("res://assets/foxtopia_mark.svg")
	mark.custom_minimum_size = Vector2(64, 64)
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.add_child(mark)
	var wordmark := _label("FOXTOPIA", 38, Color("#f5e9c9"))
	wordmark.add_theme_constant_override("outline_size", 5)
	wordmark.add_theme_color_override("font_outline_color", Color("#17232a"))
	wordmark.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	wordmark.add_theme_constant_override("shadow_offset_y", 4)
	logo.add_child(wordmark)
	var gap := Control.new()
	gap.custom_minimum_size.y = 4
	choices.add_child(gap)
	for entry in [
		[_tr("menu.new_game"), Callable(self, "_show_new_game_menu")],
		[_tr("menu.join_game"), Callable(self, "_show_join")],
		[_tr("menu.load_game"), Callable(self, "_load_saved_game")],
		[_tr("menu.settings"), Callable(self, "_show_settings")],
		[_tr("menu.quit"), func(): get_tree().quit()],
	]:
		var centered := CenterContainer.new()
		choices.add_child(centered)
		centered.add_child(_menu_button(str(entry[0]), entry[1]))
	var right_margin := Control.new()
	right_margin.custom_minimum_size.x = maxf(28.0, get_viewport_rect().size.x * 0.07)
	stage.add_child(right_margin)


func _menu_button(label_text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(232, 39)
	button.add_theme_font_size_override("font_size", 16)
	for state in ["normal", "hover", "pressed"]:
		var fill := Color("#705537")
		if state == "hover":
			fill = Color("#8b6d45")
		elif state == "pressed":
			fill = Color("#51402c")
		var box := _style(fill, Color("#bb9966"), 1)
		box.border_width_left = 2
		box.border_width_top = 2
		box.border_width_right = 2
		box.border_width_bottom = 3
		box.shadow_color = Color(0.0, 0.0, 0.0, 0.65)
		box.shadow_size = 4
		box.shadow_offset = Vector2(0, 3)
		button.add_theme_stylebox_override(state, box)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color("#f0eadc"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#f0eadc"))
	button.pressed.connect(action)
	return button


func _setup_card(minimum := Vector2.ZERO, emphasis := false) -> PanelContainer:
	var card := _panel(minimum)
	var border := Color("#a99065") if emphasis else Color("#646668")
	var fill := Color("#262829f7") if emphasis else Color("#282a2bfa")
	var style := _style(fill, border, 2)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	style.shadow_color = Color(0, 0, 0, 0.38)
	style.shadow_size = 5
	card.add_theme_stylebox_override("panel", style)
	return card


func _preparation_panel(minimum := Vector2.ZERO, outer := false) -> PanelContainer:
	var card := _panel(minimum)
	var style := _style(Color("#202223") if outer else Color("#232526"), Color("#a99065") if outer else Color("#3b3d3f"), 0)
	style.content_margin_left = 0 if outer else 9
	style.content_margin_top = 0 if outer else 9
	style.content_margin_right = 0 if outer else 9
	style.content_margin_bottom = 0 if outer else 9
	if outer:
		style.shadow_color = Color(0, 0, 0, 0.38)
		style.shadow_size = 5
	card.add_theme_stylebox_override("panel", style)
	if _preparation_grain == null:
		var noise := Image.create_empty(48, 48, false, Image.FORMAT_RGBA8)
		var noise_rng := RandomNumberGenerator.new()
		noise_rng.seed = 50502026
		for y in range(48):
			for x in range(48):
				var grain_alpha := noise_rng.randi_range(8, 18)
				noise.set_pixel(x, y, Color8(210, 207, 196, grain_alpha))
		_preparation_grain = ImageTexture.create_from_image(noise)
	var grain_layer := PrepGrain.new()
	grain_layer.grain = _preparation_grain
	grain_layer.modulate.a = 0.8 if outer else 0.25
	grain_layer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grain_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.add_child(grain_layer)
	return card


func _preparation_dice_button(action: Callable, hint: String, minimum := Vector2(27, 27), transparent := false) -> PrepDiceButton:
	var button := PrepDiceButton.new()
	button.custom_minimum_size = minimum
	button.tooltip_text = hint
	button.pressed.connect(action)
	if transparent:
		button.flat = true
		for state in ["normal", "hover", "pressed", "focus"]:
			button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	else:
		for state in ["normal", "hover", "pressed"]:
			button.add_theme_stylebox_override(state, _style(Color("#36383a") if state == "normal" else Color("#4b4d4f"), Color("#6a6c6d"), 0))
	return button

func _preparation_name_input_style(field: LineEdit) -> void:
	for state in ["normal", "focus", "read_only"]:
		var style := _style(Color("#191b1d"), Color("#555759") if state != "focus" else GOLD, 0)
		style.content_margin_left = 7
		style.content_margin_right = 7
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		field.add_theme_stylebox_override(state, style)


func _square_preparation_controls(parent: Control) -> void:
	for item in parent.find_children("*", "Control", true, false):
		var control: Control = item
		if control.has_meta("prep_curved_tab"):
			continue
		if control is Button and (control as Button).flat:
			continue
		if not (control is Button or control is LineEdit or control is PanelContainer):
			continue
		for state in ["normal", "hover", "pressed", "focus", "read_only", "panel"]:
			var inherited_style: bool = (control is Button and state in ["normal", "hover", "pressed", "focus"]) or (control is LineEdit and state in ["normal", "focus", "read_only"]) or (control is PanelContainer and state == "panel")
			if not control.has_theme_stylebox_override(state) and not inherited_style:
				continue
			var current := control.get_theme_stylebox(state)
			if current is StyleBoxFlat:
				var square := (current as StyleBoxFlat).duplicate() as StyleBoxFlat
				square.set_corner_radius_all(0)
				control.add_theme_stylebox_override(state, square)
	for popup_item in parent.find_children("*", "PopupPanel", true, false):
		var popup := popup_item as PopupPanel
		popup.add_theme_stylebox_override("panel", _style(Color("#262729"), Color("#555759"), 0))
	for menu_item in parent.find_children("*", "MenuButton", true, false):
		var menu := (menu_item as MenuButton).get_popup()
		menu.add_theme_stylebox_override("panel", _style(Color("#262729"), Color("#555759"), 0))


func _preparation_tab_button(label_text: String, action: Callable, selected: bool) -> Button:
	var button := _setup_button(label_text, action, false, Vector2(155, 30))
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 13)
	for state in ["normal", "hover", "pressed"]:
		var fill := Color("#353638") if selected else Color("#2c2e30")
		if state == "hover":
			fill = Color("#424345")
		elif state == "pressed":
			fill = Color("#242527")
		var style := _style(fill, Color("#777779") if selected else Color("#555658"), 0)
		style.content_margin_left = 8
		style.content_margin_right = 8
		button.add_theme_stylebox_override(state, style)
	return button


func _setup_button(label_text: String, action: Callable, selected := false, minimum := Vector2.ZERO) -> Button:
	var button := _menu_button(label_text, action)
	button.custom_minimum_size = minimum if minimum != Vector2.ZERO else Vector2(0, 40)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal", "hover", "pressed"]:
		var fill := Color("#765b37") if selected else Color("#37393a")
		if state == "hover": fill = Color("#947347") if selected else Color("#4b4d4f")
		if state == "pressed": fill = Color("#624b30") if selected else Color("#292b2c")
		var style := _style(fill, GOLD if selected or state == "hover" else Color("#66686a"), 2)
		style.border_width_left = 3 if selected else 1
		style.content_margin_left = 3 if minimum.x > 0.0 and minimum.x < 50.0 else 12
		style.content_margin_right = 3 if minimum.x > 0.0 and minimum.x < 50.0 else 12
		style.shadow_color = Color(0, 0, 0, 0.35)
		style.shadow_size = 3
		button.add_theme_stylebox_override(state, style)
	return button


func _setup_section(parent: VBoxContainer, title: String) -> void:
	var heading := _label(title.to_upper(), 13, GOLD)
	heading.add_theme_constant_override("outline_size", 2)
	heading.add_theme_color_override("font_outline_color", Color("#0c1519"))
	parent.add_child(heading)


func _setup_copy(value: String, size := 15, color := CREAM) -> Label:
	var copy := _label(value, size, color)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return copy


func _show_new_game_menu() -> void:
	if is_instance_valid(_menu_overlay):
		return
	_menu_overlay = ColorRect.new()
	_menu_overlay.color = Color(0.015, 0.025, 0.035, 0.7)
	_menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_menu_overlay)
	_menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_menu_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := _panel(Vector2(510, 0))
	panel.add_theme_stylebox_override("panel", _style(Color("#171c20"), Color("#a18a62"), 1))
	center.add_child(panel)
	var content := _vbox(15)
	panel.add_child(content)
	content.add_child(_label(_tr("menu.new_game"), 24, CREAM))
	content.add_child(_label(_tr("menu.choose_mode"), 13, MUTED))
	for entry in [
		[_tr("menu.single_player"), _tr("menu.single_description"), "solo"],
		[_tr("menu.host_game"), _tr("menu.host_description"), "host"],
	]:
		var row := _hbox(12)
		content.add_child(row)
		row.add_child(_menu_button(str(entry[0]), Callable(self, "_begin_new_game").bind(str(entry[2]))))
		var description := _label(str(entry[1]), 13, MUTED)
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)
	content.add_child(_menu_button(_tr("common.cancel"), _close_menu_overlay))


func _close_menu_overlay() -> void:
	if is_instance_valid(_menu_overlay):
		_menu_overlay.queue_free()
	_menu_overlay = null


func _begin_new_game(kind: String) -> void:
	_close_menu_overlay()
	_begin_session(kind)


func _add_menu_backdrop() -> void:
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://assets/menu_world_v2.png") if ResourceLoader.exists("res://assets/menu_world_v2.png") else load("res://assets/menu_world_illustrated.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	move_child(backdrop, 1)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.04, 0.25)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	move_child(shade, 2)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _begin_session(kind: String) -> void:
	session_kind = kind
	setup_mode = "solo" if kind == "solo" else "coop"
	setup_seed = str(randi())
	selected_site_id = ""
	faction_name = "Unnamed colony"
	settlement_name = "Unnamed settlement"
	character_specs.clear()
	world_character_specs = _default_world_prepared_specs()
	external_relationships = []
	_external_source_index = 0
	_external_target_key = "c:0"
	_world_roster_expanded = false
	starting_cargo.clear()
	_cargo_search_text = ""
	_equipment_category_filter = 0
	_equipment_material_filter = 0
	_selected_equipment_catalog_id = "wood"
	_preparation_appearance_category = 0
	colonist_count = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("colonist_count", 3))
	point_limit_enabled = true
	_editing_character_index = 0
	preparation_tab = "characters"
	if kind == "solo":
		Net.start_solo()
		_show_scenario_selection()
	else:
		_show_setup()


func _show_join() -> void:
	screen = "join"
	var root := _clear_screen()
	_screen_header(root, _prep_local("Join game", "Odaya katıl", "Dołącz do gry"), _prep_local("Enter the host's address.", "Ev sahibinin adresini gir.", "Wpisz adres gospodarza."))
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel := _panel(Vector2(600, 0))
	center.add_child(panel)
	var inner := _vbox(16)
	panel.add_child(inner)
	inner.add_child(_label(_prep_local("Server address", "Sunucu adresi", "Adres serwera"), 18))
	var address := LineEdit.new()
	address.text = "127.0.0.1"
	address.placeholder_text = _prep_local("IP address or domain", "IP veya alan adı", "Adres IP lub domena")
	inner.add_child(address)
	inner.add_child(_label("Port", 18))
	var port := SpinBox.new()
	port.min_value = 1024
	port.max_value = 65535
	port.value = 24567
	inner.add_child(port)
	var row := _hbox()
	inner.add_child(row)
	row.add_child(_button(_tr("common.back"), _show_menu))
	row.add_child(_button(_prep_local("Connect", "Bağlan", "Połącz"), func(): _connect_to_host(address.text, int(port.value)), true))


func _connect_to_host(address: String, port: int) -> void:
	var result = Net.join(address.strip_edges(), port)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", _prep_local("Could not connect.", "Bağlanılamadı.", "Nie można połączyć się."))))
		return
	session_kind = "join"
	_show_waiting_room(_prep_local("Waiting for the host to start the game. The world opens when the connection is ready.", "Ev sahibinin oyunu başlatması bekleniyor. Bağlantı kurulduğunda dünya açılır.", "Oczekiwanie na rozpoczęcie gry przez gospodarza. Świat otworzy się po połączeniu."))


func _show_setup() -> void:
	screen = "setup"
	var inner := _setup_stage(_prep_local("New game", "Yeni oyun", "Nowa gra"),
		_prep_local("Choose how you will play. You can prepare one to three colonists.", "Nasıl oynayacağını seç. Bir ile üç kolonist hazırlayabilirsin.", "Wybierz tryb gry. Możesz przygotować od jednej do trzech postaci."))
	var body := _hbox(24)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var mode_panel := _setup_card(Vector2(420, 0))
	body.add_child(mode_panel)
	var choices := _vbox(17)
	mode_panel.add_child(choices)
	_setup_section(choices, _prep_local("01 / Session", "01 / Oturum", "01 / Sesja"))
	choices.add_child(_label(_prep_local("Choose a play mode", "Oyun modunu seç", "Wybierz tryb gry"), 22, CREAM))
	choices.add_child(_setup_copy(_prep_local("Decide who shares this planet before choosing the expedition.", "Keşif ekibini seçmeden önce bu gezegeni kimin paylaşacağına karar ver.", "Zdecyduj, kto podzieli tę planetę, zanim wybierzesz wyprawę."), 14, MUTED))
	_mode_option = OptionButton.new()
	_mode_option.add_item(_tr("setup.mode_solo"), 0)
	_mode_option.add_item(_tr("setup.mode_coop"), 1)
	_mode_option.add_item(_tr("setup.mode_competitive"), 2)
	_mode_option.select(0 if setup_mode == "solo" else 1 if setup_mode == "coop" else 2)
	_mode_option.disabled = session_kind == "solo"
	_mode_option.custom_minimum_size.y = 42
	_compact_option(_mode_option)
	choices.add_child(_mode_option)
	if session_kind == "host":
		_setup_section(choices, _prep_local("Host port", "Oda portu", "Port gospodarza"))
		_host_port_input = SpinBox.new()
		_host_port_input.min_value = 1024
		_host_port_input.max_value = 65535
		_host_port_input.value = host_port
		choices.add_child(_host_port_input)
	choices.add_child(HSeparator.new())
	_setup_section(choices, _prep_local("Play together", "Birlikte oyna", "Gra razem"))
	for guide in [
		[_prep_local("Single player", "Tek oyunculu", "Jeden gracz"), _prep_local("Build and manage one colony on your own.", "Tek bir koloniyi tek başına kur ve yönet.", "Buduj i prowadź jedną kolonię samodzielnie.")],
		[_prep_local("Co-op colony", "Ortak koloni", "Kolonia wspólna"), _prep_local("Share the same people and settlement with friends.", "Aynı insanları ve yerleşkeyi arkadaşlarınla paylaş.", "Dzielcie ludzi i osadę ze znajomymi.")],
		[_prep_local("Separate colonies", "Ayrı koloniler", "Osobne kolonie"), _prep_local("Each player chooses a site on the same planet.", "Her oyuncu aynı gezegende ayrı bir yer seçer.", "Każdy gracz wybiera miejsce na tej samej planecie.")],
	]:
		var guide_row := _vbox(2)
		choices.add_child(guide_row)
		guide_row.add_child(_label(str(guide[0]), 14, CREAM))
		guide_row.add_child(_setup_copy(str(guide[1]), 12, MUTED))
	choices.add_child(_spacer())
	choices.add_child(_setup_copy(_prep_local("Your next choices set the crew, event pacing and world.", "Sonraki seçimlerin ekibi, olay temposunu ve dünyayı belirler.", "Kolejne wybory określą załogę, tempo wydarzeń i świat."), 13, MUTED))
	var explanation := _setup_card(Vector2.ZERO, true)
	explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(explanation)
	var copy := _vbox(18)
	explanation.add_child(copy)
	_setup_section(copy, _prep_local("The journey", "Yolculuk", "Podróż"))
	copy.add_child(_label(_prep_local("One planet. Your way to settle it.", "Bir gezegen. Onu kurmanın yolu senin.", "Jedna planeta. Wasz sposób na osiedlenie."), 24, CREAM))
	var text_body := _prep_local("Single player controls one colony. In co-op, everyone controls the same people. Separate colonies begin in different places of the same generated world. Each player can choose a different settlement map.", "Tek oyunculu tek koloniyi yönetir. Ortak oyunda herkes aynı insanları yönetir. Ayrı koloniler aynı oluşturulan dünyanın farklı yerlerinde başlar; her oyuncu farklı bir yerleşke haritası seçebilir.", "W grze jednoosobowej zarządzasz jedną kolonią. W kooperacji wszyscy kontrolują tych samych ludzi. Osobne kolonie zaczynają w różnych miejscach tego samego świata; każdy wybiera własną mapę osady.")
	copy.add_child(_setup_copy(text_body, 16))
	copy.add_child(HSeparator.new())
	_setup_section(copy, _prep_local("Coming next", "Sonraki adımlar", "Następne kroki"))
	copy.add_child(_setup_copy(_prep_local("Select a starting scenario, shape the story's pace, generate the planet, choose a landing site and prepare your colonists.", "Başlangıç senaryosunu seç, hikâyenin temposunu belirle, gezegeni oluştur, iniş yerini seç ve kolonistlerini hazırla.", "Wybierz scenariusz, ustal tempo opowieści, wygeneruj planetę, wskaż miejsce lądowania i przygotuj kolonistów."), 14, MUTED))
	var art_frame := PanelContainer.new()
	art_frame.custom_minimum_size.y = 220
	art_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var art_border := _style(Color("#111a21"), Color("#8e7651"), 2)
	art_border.content_margin_left = 1
	art_border.content_margin_top = 1
	art_border.content_margin_right = 1
	art_border.content_margin_bottom = 1
	art_frame.add_theme_stylebox_override("panel", art_border)
	copy.add_child(art_frame)
	var art := TextureRect.new()
	art.texture = load("res://assets/menu_world_v2.png") if ResourceLoader.exists("res://assets/menu_world_v2.png") else load("res://assets/menu_world_illustrated.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_frame.add_child(art)
	_setup_footer(inner, _show_menu, _advance_to_scenario)


func _setup_stage(title: String, subtitle: String) -> VBoxContainer:
	var root := _clear_screen()
	_add_menu_backdrop()
	var frame := _setup_card(Vector2.ZERO, true)
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(frame)
	var inner := _vbox(11)
	frame.add_child(inner)
	var brand := _hbox(10)
	inner.add_child(brand)
	var mark := TextureRect.new()
	mark.texture = load("res://assets/foxtopia_mark.svg")
	mark.custom_minimum_size = Vector2(44, 44)
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	brand.add_child(mark)
	var brand_name := _label("FOXTOPIA", 21, Color("#f5e9c9"))
	brand_name.add_theme_constant_override("outline_size", 3)
	brand_name.add_theme_color_override("font_outline_color", Color("#17232a"))
	brand.add_child(brand_name)
	var brand_gap := Control.new()
	brand_gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brand.add_child(brand_gap)
	brand.add_child(_label(_prep_local("NEW COLONY", "YENİ KOLONİ", "NOWA KOLONIA"), 12, GOLD))
	inner.add_child(HSeparator.new())
	var title_row := _hbox(16)
	inner.add_child(title_row)
	var headings := _vbox(3)
	headings.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(headings)
	headings.add_child(_label(title, 27, CREAM))
	headings.add_child(_setup_copy(subtitle, 13, MUTED))
	var step_names := [
		_prep_local("MODE", "MOD", "TRYB"),
		_prep_local("SCENARIO", "SENARYO", "SCENARIUSZ"),
		_prep_local("STORY", "HİKÂYE", "OPOWIEŚĆ"),
		_prep_local("PLANET", "GEZEGEN", "PLANETA"),
		_prep_local("LANDING", "İNİŞ", "LĄDOWANIE"),
		_prep_local("CREW", "EKİP", "ZAŁOGA"),
	]
	var step_ids := ["setup", "scenario", "storyteller", "world_settings", "world_select", "characters"]
	if session_kind == "solo":
		step_names.remove_at(0)
		step_ids.remove_at(0)
	var current_step := maxi(0, step_ids.find(screen))
	var progress := _hbox(5)
	inner.add_child(progress)
	for index in step_names.size():
		var step := PanelContainer.new()
		step.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		step.add_theme_stylebox_override("panel", _style(Color("#705537") if index == current_step else Color("#26353d9c"), GOLD if index == current_step else Color("#57666a"), 2))
		progress.add_child(step)
		var text_label := _label("%02d  %s" % [index + 1, step_names[index]], 11, Color("#fff0cd") if index == current_step else MUTED)
		text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		step.add_child(text_label)
	return inner


func _setup_footer(parent: VBoxContainer, back_action: Callable, next_action: Callable) -> void:
	parent.add_child(HSeparator.new())
	var row := _hbox(12)
	parent.add_child(row)
	row.add_child(_setup_button("←  " + _tr("common.back"), back_action, false, Vector2(150, 40)))
	var filler := Control.new()
	filler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(filler)
	row.add_child(_setup_button(_prep_local("Continue", "Devam et", "Kontynuuj") + "  →", next_action, true, Vector2(164, 40)))


func _advance_to_scenario() -> void:
	setup_mode = ["solo", "coop", "competitive"][_mode_option.selected]
	if session_kind == "host" and is_instance_valid(_host_port_input):
		host_port = int(_host_port_input.value)
	_show_scenario_selection()


func _show_scenario_selection() -> void:
	screen = "scenario"
	if starting_cargo.is_empty():
		starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	var inner := _setup_stage(_prep_local("Choose a scenario", "Senaryo seç", "Wybierz scenariusz"),
		_prep_local("The starting cargo changes with your choice.", "Seçimin başlangıç yükünü değiştirir.", "Wybór zmienia ładunek początkowy."))
	var body := _hbox(18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var list_panel := _setup_card(Vector2(330, 0))
	body.add_child(list_panel)
	var list := _vbox(11)
	list_panel.add_child(list)
	_setup_section(list, _prep_local("Choose your beginning", "Başlangıcını seç", "Wybierz początek"))
	for entry in SetupCatalog.SCENARIOS:
		var chosen_id := str(entry["id"])
		var entry_card := _setup_card(Vector2.ZERO, chosen_id == scenario_id)
		list.add_child(entry_card)
		var entry_copy := _vbox(5)
		entry_card.add_child(entry_copy)
		var button_text := "%02d   %s" % [SetupCatalog.SCENARIOS.find(entry) + 1, SetupCatalog.localized(entry["name"], preferences.language)]
		entry_copy.add_child(_setup_button(button_text, func(): _select_scenario(chosen_id), chosen_id == scenario_id, Vector2(0, 38)))
		entry_copy.add_child(_setup_copy(SetupCatalog.localized(entry["summary"], preferences.language), 12, MUTED))
	var selected: Dictionary = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id)
	var detail := _setup_card(Vector2.ZERO, true)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail.add_child(scroll)
	var description := _vbox(10)
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(description)
	_setup_section(description, _prep_local("Scenario dossier", "Senaryo dosyası", "Opis scenariusza"))
	description.add_child(_label(SetupCatalog.localized(selected["name"], preferences.language), 27, CREAM))
	description.add_child(_setup_copy(SetupCatalog.localized(selected["summary"], preferences.language), 15, GOLD))
	description.add_child(HSeparator.new())
	_setup_section(description, _prep_local("The story", "Hikâye", "Opowieść"))
	description.add_child(_setup_copy(SetupCatalog.localized(selected["story"], preferences.language), 15))
	_setup_section(description, _prep_local("The first days", "İlk günler", "Pierwsze dni"))
	description.add_child(_setup_copy(SetupCatalog.localized(selected["first_days"], preferences.language), 14, MUTED))
	description.add_child(HSeparator.new())
	_setup_section(description, _prep_local("Starting conditions", "Başlangıç koşulları", "Warunki początkowe"))
	description.add_child(_setup_copy(SetupCatalog.localized(selected["conditions"], preferences.language), 14))
	description.add_child(_label(_prep_local("%d colonists" % colonist_count, "%d kolonist" % colonist_count, "%d kolonistów" % colonist_count), 17, GOLD))
	_setup_section(description, _prep_local("Starting supplies", "Başlangıç malzemeleri", "Zapasy początkowe"))
	var supplies := GridContainer.new()
	supplies.columns = 2
	supplies.add_theme_constant_override("h_separation", 10)
	supplies.add_theme_constant_override("v_separation", 5)
	description.add_child(supplies)
	for kind in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
		var supply := _hbox(8)
		supply.custom_minimum_size.x = 210
		supplies.add_child(supply)
		var supply_name := _label(_cargo_label(kind), 14, CREAM)
		supply_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		supply.add_child(supply_name)
		supply.add_child(_label("× %d" % int(selected["inventory"].get(kind, 0)), 14, GOLD))
	description.add_child(_setup_copy(_prep_local("You can adjust the cargo and each colonist's gear during crew preparation.", "Ekip hazırlığında yükü ve her kolonistin ekipmanını değiştirebilirsin.", "Ładunek i wyposażenie każdego kolonisty można zmienić podczas przygotowywania załogi."), 12, MUTED))
	_setup_footer(inner, _show_menu if session_kind == "solo" else _show_setup, _show_storyteller_selection)


func _select_scenario(id: String) -> void:
	scenario_id = id
	colonist_count = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("colonist_count", 3))
	character_specs.clear()
	world_character_specs = _default_world_prepared_specs()
	external_relationships = []
	_external_source_index = 0
	_external_target_key = "c:0"
	_world_roster_expanded = false
	starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	_show_scenario_selection()


func _show_storyteller_selection() -> void:
	screen = "storyteller"
	var inner := _setup_stage(_prep_local("Story and difficulty", "Hikâye ve zorluk", "Opowieść i trudność"),
		_prep_local("Choose the pace of events and the danger level.", "Olay temposunu ve tehlike düzeyini seç.", "Wybierz tempo zdarzeń i poziom zagrożenia."))
	var body := _hbox(18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var teller_panel := _setup_card(Vector2(310, 0))
	body.add_child(teller_panel)
	var storytellers := _vbox(10)
	teller_panel.add_child(storytellers)
	_setup_section(storytellers, _prep_local("Event rhythm", "Olay temposu", "Rytm wydarzeń"))
	storytellers.add_child(_label(_prep_local("Narrator", "Anlatıcı", "Narrator"), 22, CREAM))
	for entry in SetupCatalog.STORYTELLERS:
		var chosen_id := str(entry["id"])
		var choice := _setup_card(Vector2.ZERO, chosen_id == storyteller_id)
		storytellers.add_child(choice)
		var choice_copy := _vbox(4)
		choice.add_child(choice_copy)
		choice_copy.add_child(_setup_button(SetupCatalog.localized(entry["name"], preferences.language), func(): _select_storyteller(chosen_id), chosen_id == storyteller_id, Vector2(0, 34)))
		choice_copy.add_child(_setup_copy(SetupCatalog.localized(entry["summary"], preferences.language), 12, MUTED))
	var portrait_panel := _setup_card(Vector2(370, 0), true)
	portrait_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(portrait_panel)
	var portrait_content := _vbox(7)
	portrait_panel.add_child(portrait_content)
	var selected_storyteller: Dictionary = SetupCatalog.find_by_id(SetupCatalog.STORYTELLERS, storyteller_id)
	_setup_section(portrait_content, _prep_local("Your narrator", "Anlatıcın", "Twój narrator"))
	portrait_content.add_child(_label(SetupCatalog.localized(selected_storyteller["name"], preferences.language), 23, CREAM))
	var portrait := TextureRect.new()
	portrait.texture = load("res://assets/storyteller_%s.png" % {"steady": "mira", "gentle": "elian", "erratic": "rook"}.get(storyteller_id, "mira"))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size.y = 230
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait_content.add_child(portrait)
	portrait_content.add_child(HSeparator.new())
	portrait_content.add_child(_setup_copy(SetupCatalog.localized(selected_storyteller["summary"], preferences.language), 14, CREAM))
	var difficulty_panel := _setup_card(Vector2(280, 0))
	body.add_child(difficulty_panel)
	var difficulty := _vbox(8)
	difficulty_panel.add_child(difficulty)
	_setup_section(difficulty, _prep_local("Threat level", "Tehdit düzeyi", "Poziom zagrożenia"))
	difficulty.add_child(_label(_prep_local("Difficulty", "Zorluk", "Trudność"), 22, CREAM))
	for entry in SetupCatalog.DIFFICULTIES:
		var chosen_id := str(entry["id"])
		var choice := _setup_card(Vector2.ZERO, chosen_id == difficulty_id)
		difficulty.add_child(choice)
		var choice_copy := _vbox(3)
		choice.add_child(choice_copy)
		choice_copy.add_child(_setup_button(SetupCatalog.localized(entry["name"], preferences.language), func(): _select_difficulty(chosen_id), chosen_id == difficulty_id, Vector2(0, 31)))
		choice_copy.add_child(_setup_copy(SetupCatalog.localized(entry["summary"], preferences.language), 11, MUTED))
	_setup_footer(inner, _show_scenario_selection, _show_world_settings)


func _select_storyteller(id: String) -> void:
	storyteller_id = id
	_show_storyteller_selection()


func _select_difficulty(id: String) -> void:
	difficulty_id = id
	_show_storyteller_selection()


func _show_world_settings() -> void:
	screen = "world_settings"
	var inner := _setup_stage(_prep_local("Create world", "Dünya oluştur", "Stwórz świat"),
		_prep_local("The same seed and settings always produce the same planet.", "Aynı tohum ve ayarlar her zaman aynı gezegeni oluşturur.", "Ten sam klucz i ustawienia zawsze tworzą tę samą planetę."))
	var body := _hbox(20)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var controls_panel := _setup_card(Vector2(440, 0))
	body.add_child(controls_panel)
	var controls := _vbox(12)
	controls_panel.add_child(controls)
	_setup_section(controls, _prep_local("Planet parameters", "Gezegen ayarları", "Parametry planety"))
	controls.add_child(_label(_tr("setup.seed"), 19, CREAM))
	_seed_edit = LineEdit.new()
	_seed_edit.text = setup_seed
	_seed_edit.custom_minimum_size.y = 37
	controls.add_child(_seed_edit)
	controls.add_child(_setup_button(_prep_local("Randomize seed", "Yeni tohum üret", "Losuj klucz"), func():
		_seed_edit.text = str(randi())
		_refresh_world_settings_preview(), false, Vector2(190, 36)))
	_seed_edit.text_submitted.connect(func(_submitted: String): _refresh_world_settings_preview())
	controls.add_child(HSeparator.new())
	_world_setting_row(controls, "coverage", _prep_local("Land coverage", "Kara oranı", "Udział lądu"), 0.25, 0.75)
	_world_setting_row(controls, "rainfall", _prep_local("Rainfall", "Yağış", "Opady"), 0.0, 1.0)
	_world_setting_row(controls, "temperature", _prep_local("Temperature", "Sıcaklık", "Temperatura"), 0.0, 1.0)
	_world_setting_row(controls, "population", _prep_local("Other settlements", "Diğer yerleşkeler", "Inne osady"), 0.0, 1.0)
	controls.add_child(_spacer())
	controls.add_child(_setup_copy(_prep_local("A seed keeps the layout reproducible. Change any setting, then generate to see the full planet.", "Tohum, yerleşimi tekrar oluşturulabilir kılar. Ayarları değiştirip tüm gezegeni görmek için oluştur.", "Klucz pozwala odtworzyć układ. Zmień ustawienia i wygeneruj całą planetę."), 12, MUTED))
	var detail := _setup_card(Vector2.ZERO, true)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail)
	var detail_content := _vbox(8)
	detail.add_child(detail_content)
	_setup_section(detail_content, _prep_local("Live preview", "Canlı önizleme", "Podgląd na żywo"))
	detail_content.add_child(_label(_prep_local("Your planet", "Gezegenin", "Twoja planeta"), 22, CREAM))
	detail_content.add_child(_setup_copy(_prep_local("Land coverage shapes continents; rainfall and temperature influence local biomes. Other settlements affect the number of friendly and hostile neighbors.", "Kara oranı kıtaları biçimlendirir; yağış ve sıcaklık yerel biyomları etkiler. Diğer yerleşkeler dost ve düşman komşuların sayısını değiştirir.", "Udział lądu kształtuje kontynenty; opady i temperatura wpływają na lokalne biomy. Liczba osad zmienia liczbę przyjaznych i wrogich sąsiadów."), 13, MUTED))
	_world_settings_preview = WorldViewScript.new()
	_world_settings_preview.custom_minimum_size = Vector2(420, 300)
	_world_settings_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_settings_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_content.add_child(_world_settings_preview)
	_refresh_world_settings_preview()
	var preview_hint := _setup_copy(_prep_local("Drag to rotate the preview. After generation, select any unoccupied land tile for your settlement.", "Önizlemeyi döndürmek için sürükle. Oluşturduktan sonra yerleşken için boş bir kara parçası seç.", "Przeciągnij, aby obrócić podgląd. Po wygenerowaniu wybierz wolny obszar lądu na osadę."), 12, MUTED)
	detail_content.add_child(preview_hint)
	_setup_footer(inner, _show_storyteller_selection, _advance_to_world)


func _refresh_world_settings_preview() -> void:
	if not is_instance_valid(_world_settings_preview): return
	var seed_value := _seed_edit.text.strip_edges() if is_instance_valid(_seed_edit) else setup_seed
	_world_settings_preview.set_preview(Game.preview_world(seed_value if not seed_value.is_empty() else "Foxtopia", world_options))


func _world_setting_row(parent: VBoxContainer, key: String, title: String, minimum: float, maximum: float) -> void:
	var row := _hbox(12)
	parent.add_child(row)
	var title_label := _label(title, 15)
	title_label.custom_minimum_size.x = 160
	row.add_child(title_label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = 0.05
	slider.value = float(world_options.get(key, 0.5))
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)
	var value_label := _label("%d%%" % roundi(slider.value * 100.0), 14, GOLD)
	value_label.custom_minimum_size.x = 45
	row.add_child(value_label)
	slider.value_changed.connect(func(value: float):
		world_options[key] = value
		value_label.text = "%d%%" % roundi(value * 100.0))
	slider.drag_ended.connect(func(_changed: bool): _refresh_world_settings_preview())


func _advance_to_world() -> void:
	if is_instance_valid(_mode_option) and _mode_option.is_inside_tree():
		setup_mode = ["solo", "coop", "competitive"][_mode_option.selected]
	if is_instance_valid(_seed_edit) and _seed_edit.is_inside_tree():
		setup_seed = _seed_edit.text.strip_edges()
	if setup_seed.is_empty():
		setup_seed = str(randi())
	if session_kind == "host":
		var host_result = Net.host(host_port)
		if host_result is Dictionary and not bool(host_result.get("ok", true)):
			_notice(str(host_result.get("error", _prep_local("Could not open the game room.", "Oda açılamadı.", "Nie można otworzyć pokoju gry."))))
			return
		Net.configure_lobby({"mode": setup_mode, "seed": setup_seed, "colonists_per_faction": colonist_count,
			"world_options": world_options, "scenario_id": scenario_id,
			"storyteller_id": storyteller_id, "difficulty_id": difficulty_id})
	world_preview = Game.preview_world(setup_seed, world_options)
	var sites: Array = world_preview.get("sites", [])
	selected_site_id = ""
	for site in sites:
		if str(site.get("kind", "")) == "vacant" or str(site.get("kind", "")) == "player":
			selected_site_id = str(site.get("id", ""))
			break
	if selected_site_id.is_empty() and not sites.is_empty():
		selected_site_id = str(sites[0].get("id", ""))
	_show_world_selection()


func _show_world_selection() -> void:
	screen = "world_select"
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world_view = WorldViewScript.new()
	_world_view.set_preview(world_preview, selected_site_id)
	_world_view.site_selected.connect(_select_site)
	root.add_child(_world_view)
	_world_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var overlay := Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var arrival_panel := _setup_card(Vector2.ZERO, true)
	overlay.add_child(arrival_panel)
	_place(arrival_panel, 0.0, 0.0, 0.0, 0.0, 16, 18, 520, 126)
	var arrival := _vbox(4)
	arrival_panel.add_child(arrival)
	_setup_section(arrival, _prep_local("05 / Landing site", "05 / İniş yeri", "05 / Miejsce lądowania"))
	arrival.add_child(_label(_prep_local("Choose where to begin", "Başlangıç yerini seç", "Wybierz miejsce startu"), 21, CREAM))
	arrival.add_child(_setup_copy(_prep_local("Select an unoccupied land tile on the planet.", "Gezegende işgal edilmemiş bir kara parçası seç.", "Wybierz wolny obszar lądu na planecie."), 12, MUTED))
	var info_panel := _setup_card()
	overlay.add_child(info_panel)
	_place(info_panel, 0.0, 0.31, 0.0, 1.0, 16, 0, 350, -57)
	var info_content := _vbox(6)
	info_panel.add_child(info_content)
	_setup_section(info_content, _prep_local("Selected region", "Seçilen bölge", "Wybrany region"))
	_site_info = _vbox(4)
	_site_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_content.add_child(_site_info)
	var terrain_panel := _setup_card()
	overlay.add_child(terrain_panel)
	_place(terrain_panel, 1.0, 0.0, 1.0, 0.0, -355, 18, -16, 376)
	var terrain_content := _vbox(5)
	terrain_panel.add_child(terrain_content)
	_setup_section(terrain_content, _prep_local("Landing area preview", "İniş bölgesi önizlemesi", "Podgląd miejsca lądowania"))
	_terrain_preview = TerrainPreviewScript.new()
	_terrain_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_terrain_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	terrain_content.add_child(_terrain_preview)
	_update_site_info()
	var back := _setup_button("←  " + _tr("common.back"), _show_world_settings)
	overlay.add_child(back)
	_place(back, 0.0, 1.0, 0.0, 1.0, 16, -47, 100, -10)
	var random_button := _setup_button(_prep_local("Random site", "Rastgele yer", "Losowe miejsce"), _select_random_site)
	overlay.add_child(random_button)
	_place(random_button, 0.0, 1.0, 0.0, 1.0, 110, -47, 272, -10)
	var next := _setup_button(_tr("world.continue") + "  →", _show_characters, true)
	overlay.add_child(next)
	_place(next, 1.0, 1.0, 1.0, 1.0, -220, -47, -16, -10)
	var rotate_hint := _label(_prep_local("Drag to rotate  ·  Scroll to zoom", "Döndürmek için sürükle  ·  Yakınlaştırmak için kaydır", "Przeciągnij, aby obrócić  ·  Przewiń, aby przybliżyć"), 13, MUTED)
	rotate_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotate_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(rotate_hint)
	_place(rotate_hint, 0.5, 1.0, 0.5, 1.0, -290, -41, 290, -12)


func _select_site(site_id: String) -> void:
	for site in world_preview.get("sites", []):
		if str(site.get("id", "")) == site_id and str(site.get("kind", "")) not in ["vacant", "player"]:
			_notice(_tr("world.occupied"))
			_world_view.set_preview(world_preview, selected_site_id)
			return
	if site_id.begins_with("tile_"):
		var parts := site_id.split("_")
		if parts.size() != 3:
			return
		var x := int(parts[1])
		var y := int(parts[2])
		var width := int(world_preview.get("width", 0))
		var height := int(world_preview.get("height", 0))
		if x < 0 or y < 0 or x >= width or y >= height:
			return
		if str((world_preview.get("tiles", []) as Array)[y * width + x]) == "water":
			_notice(_tr("world.water"))
			return
	selected_site_id = site_id
	_update_site_info()


func _update_site_info() -> void:
	if not is_instance_valid(_site_info):
		return
	for child in _site_info.get_children():
		_site_info.remove_child(child)
		child.queue_free()
	var chosen: Dictionary = Game.describe_site(world_preview, selected_site_id)
	if chosen.is_empty():
		_site_info.add_child(_setup_copy(_tr("world.choose_tile"), 13, CREAM))
		if is_instance_valid(_terrain_preview): _terrain_preview.set_map({})
		return
	var nearby_friendly := 0
	var nearby_hostile := 0
	for other in world_preview.get("sites", []):
		if str(other.get("id", "")) == selected_site_id: continue
		var separation: int = abs(int(other.get("x", 0)) - int(chosen.get("x", 0))) + abs(int(other.get("y", 0)) - int(chosen.get("y", 0)))
		if separation > 20: continue
		if str(other.get("kind", "")) == "friendly": nearby_friendly += 1
		if str(other.get("kind", "")) == "hostile": nearby_hostile += 1
	var site_name := str(chosen.get("name", "Unsettled land"))
	_site_info.add_child(_label(_prep_local("Unsettled land", "Yerleşilmemiş arazi", "Niezasiedlony teren") if site_name == "Unsettled land" else I18n.localize_site_name(site_name, preferences.language), 18, GOLD))
	_site_info.add_child(_setup_copy("%s  ·  %s" % [_localized_site_feature(str(chosen.get("biome", "plains"))), _localized_site_feature(str(chosen.get("terrain", "Flat")))], 13, CREAM))
	_site_info.add_child(_setup_copy("%.1f° %s  ·  %.1f° %s" % [absf(float(chosen.get("latitude", 0.0))), "N" if float(chosen.get("latitude", 0.0)) >= 0.0 else "S", absf(float(chosen.get("longitude", 0.0))), "E" if float(chosen.get("longitude", 0.0)) >= 0.0 else "W"], 12, MUTED))
	_site_info.add_child(HSeparator.new())
	var annual_range := "%.1f–%.1f °C" % [float(chosen.get("temperature_min", chosen.get("temperature", 0.0))), float(chosen.get("temperature_max", chosen.get("temperature", 0.0)))]
	for entry in [
		[_prep_local("Elevation", "Rakım", "Wysokość"), "%d m  ·  %s" % [int(chosen.get("elevation", 0)), _shore_type_name(str(chosen.get("shore_type", "coast" if bool(chosen.get("coastal", false)) else "none")))]],
		[_prep_local("Yearly range", "Yıllık aralık", "Zakres roczny"), annual_range],
		[_prep_local("Annual mean", "Yıllık ortalama", "Średnia roczna"), "%.1f °C" % float(chosen.get("temperature", 0.0))],
		[_prep_local("Growing days", "Ekim günleri", "Dni uprawy"), _prep_local("%d / 60 days", "%d / 60 gün", "%d / 60 dni") % int(chosen.get("growing_days", 0))],
		[_prep_local("Local seasons", "Yerel mevsimler", "Lokalne pory roku"), _climate_pattern_name(str(chosen.get("season_pattern", "four_seasons")))],
		[_prep_local("Rainfall", "Yağış", "Opady"), _prep_local("%d mm/year", "%d mm/yıl", "%d mm/rok") % int(chosen.get("rainfall", 0))],
		[_prep_local("Stone", "Taş", "Kamień"), ", ".join((chosen.get("stone_types", []) as Array).map(func(stone): return _localized_site_feature(str(stone))))],
		[_prep_local("Nearby", "Yakında", "W pobliżu"), _prep_local("%d friendly · %d hostile", "%d dost · %d düşman", "%d przyjaciół · %d wrogów") % [nearby_friendly, nearby_hostile]],
	]:
		var row := _hbox(5)
		_site_info.add_child(row)
		var key := _label(str(entry[0]), 12, MUTED)
		key.custom_minimum_size.x = 124
		row.add_child(key)
		var value := _setup_copy(str(entry[1]), 12, CREAM)
		value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(value)
	var climate_row := _hbox(0)
	_site_info.add_child(climate_row)
	var climate_fill := Control.new()
	climate_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	climate_row.add_child(climate_fill)
	climate_row.add_child(_setup_button(_prep_local("Period climate  →", "Dönem iklimi  →", "Klimat okresów  →"), func(): _show_site_climate_details(chosen), false, Vector2(172, 27)))
	if is_instance_valid(_terrain_preview):
		_terrain_preview.set_map(Game.preview_local_map(world_preview, selected_site_id))


func _shore_type_name(shore_type: String) -> String:
	match shore_type:
		"coast": return _prep_local("Sea coast", "Deniz kıyısı", "Wybrzeże morskie")
		"lakeshore": return _prep_local("Lake shore", "Göl kıyısı", "Brzeg jeziora")
		_: return _prep_local("Inland", "İç bölge", "W głębi lądu")


func _climate_pattern_name(pattern: String) -> String:
	match pattern:
		"permanent_winter": return _prep_local("Permanent winter", "Sürekli kış", "Wieczna zima")
		"permanent_summer": return _prep_local("Permanent summer", "Sürekli yaz", "Wieczne lato")
		"two_seasons": return _prep_local("Two seasons", "İki mevsim", "Dwie pory roku")
		_: return _prep_local("Four seasons", "Dört mevsim", "Cztery pory roku")


func _climate_period_name(index: int) -> String:
	match posmod(index, 4):
		0: return _prep_local("January", "Ocak", "Styczeń")
		1: return _prep_local("April", "Nisan", "Kwiecień")
		2: return _prep_local("July", "Temmuz", "Lipiec")
		_: return _prep_local("October", "Ekim", "Październik")


func _local_season_name(season: String) -> String:
	match season:
		"spring": return _prep_local("Spring", "İlkbahar", "Wiosna")
		"summer": return _prep_local("Summer", "Yaz", "Lato")
		"autumn": return _prep_local("Autumn", "Sonbahar", "Jesień")
		"winter": return _prep_local("Winter", "Kış", "Zima")
		"warm": return _prep_local("Warm", "Sıcak", "Ciepła")
		_: return _prep_local("Cool", "Serin", "Chłodna")


func _climate_year_day_label(year_day: int) -> String:
	var normalized := clampi(year_day, 1, ClimateCalendar.DAYS_PER_YEAR)
	return "%d %s" % [(normalized - 1) % ClimateCalendar.DAYS_PER_PERIOD + 1, _climate_period_name((normalized - 1) / ClimateCalendar.DAYS_PER_PERIOD)]


func _show_site_climate_details(chosen: Dictionary) -> void:
	var popup := Control.new()
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(popup)
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.58)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	popup.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed: popup.queue_free())
	var card := _setup_card(Vector2.ZERO, true)
	popup.add_child(card)
	_place(card, 0.5, 0.5, 0.5, 0.5, -260, -185, 260, 185)
	var content := _vbox(8)
	card.add_child(content)
	content.add_child(_label(_prep_local("Regional climate", "Bölgesel iklim", "Klimat regionu"), 20, GOLD))
	content.add_child(_setup_copy(_prep_local("4 periods × 15 days = 60 days per year", "4 dönem × 15 gün = yılda 60 gün", "4 okresy × 15 dni = 60 dni w roku"), 13, CREAM))
	content.add_child(_setup_copy(_climate_pattern_name(str(chosen.get("season_pattern", "four_seasons"))) + "  ·  " + _prep_local("yearly %.1f–%.1f °C", "yıllık %.1f–%.1f °C", "rocznie %.1f–%.1f °C") % [float(chosen.get("temperature_min", 0.0)), float(chosen.get("temperature_max", 0.0))], 12, MUTED))
	content.add_child(HSeparator.new())
	for period in chosen.get("monthly_temperatures", []):
		if not period is Dictionary: continue
		var period_index := int(period.get("period_index", 0))
		var row := _hbox(8)
		content.add_child(row)
		var name := _label(_climate_period_name(period_index), 13, GOLD)
		name.custom_minimum_size.x = 105
		row.add_child(name)
		var season := _label(_local_season_name(str(period.get("season", "spring"))), 12, CREAM)
		season.custom_minimum_size.x = 65
		row.add_child(season)
		row.add_child(_label("%.1f–%.1f °C" % [float(period.get("min", 0.0)), float(period.get("max", 0.0))], 12, CREAM))
		var fill := Control.new()
		fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(fill)
		row.add_child(_label(_prep_local("%d/15 grow", "%d/15 ekim", "%d/15 uprawy") % int(period.get("growing_days", 0)), 12, MUTED))
	content.add_child(HSeparator.new())
	var windows: Array = chosen.get("growing_periods", [])
	var window_text := _prep_local("No outdoor growing days", "Açık havada ekim günü yok", "Brak dni uprawy na zewnątrz") if windows.is_empty() else _prep_local("All year", "Bütün yıl", "Cały rok") if int(chosen.get("growing_days", 0)) == ClimateCalendar.DAYS_PER_YEAR else ", ".join(windows.map(func(window): return "%s – %s" % [_climate_year_day_label(int(window.get("start_day", 1))), _climate_year_day_label(int(window.get("end_day", 1)))]))
	content.add_child(_setup_copy(_prep_local("Outdoor growing: ", "Açık hava ekimi: ", "Uprawa na zewnątrz: ") + window_text, 12, CREAM))
	content.add_child(_setup_copy(_prep_local("Seasonal averages; weather events may differ.", "Mevsimsel ortalama; hava olayları farklılık gösterebilir.", "Średnie sezonowe; pogoda może się różnić."), 11, MUTED))
	content.add_child(_setup_button(_tr("common.close"), func(): popup.queue_free(), false, Vector2(0, 30)))


func _localized_site_feature(value: String) -> String:
	match value.to_lower():
		"plains": return _prep_local("Plains", "Ova", "Równina")
		"forest": return _prep_local("Forest", "Orman", "Las")
		"rocky": return _prep_local("Rocky terrain", "Kayalık arazi", "Teren skalisty")
		"tundra": return _prep_local("Tundra", "Tundra", "Tundra")
		"arid": return _prep_local("Arid", "Kurak", "Suchy")
		"flat": return _prep_local("Flat", "Düz", "Płaski")
		"hilly": return _prep_local("Hilly", "Tepelik", "Pagórkowaty")
		"mountainous": return _prep_local("Mountainous", "Dağlık", "Górzysty")
		"granite": return _prep_local("Granite", "Granit", "Granit")
		"slate": return _prep_local("Slate", "Arduvaz", "Łupek")
		"limestone": return _prep_local("Limestone", "Kireçtaşı", "Wapień")
		"sandstone": return _prep_local("Sandstone", "Kumtaşı", "Piaskowiec")
		_: return value


func _select_random_site() -> void:
	var free_sites: Array = []
	for site in world_preview.get("sites", []):
		if str(site.get("kind", "")) == "vacant": free_sites.append(str(site.get("id", "")))
	if free_sites.is_empty(): return
	selected_site_id = str(free_sites[randi_range(0, free_sites.size() - 1)])
	_world_view.set_preview(world_preview, selected_site_id)
	_update_site_info()


func _show_characters() -> void:
	var color_dialog := get_node_or_null("PreparationColorDialog")
	if color_dialog != null:
		color_dialog.queue_free()
	_end_preparation_color_sampling()
	screen = "characters"
	if character_specs.size() > colonist_count:
		character_specs.resize(colonist_count)
	while character_specs.size() < colonist_count:
		var i := character_specs.size()
		character_specs.append(_default_prepared_spec(i))
	_editing_character_index = clampi(_editing_character_index, 0, colonist_count - 1)
	var root := _clear_screen()
	_add_menu_backdrop()
	var frame_row := _hbox(0)
	frame_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(frame_row)
	var left_margin := Control.new()
	left_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_row.add_child(left_margin)
	# EdB's three columns are laid out for this fixed logical canvas. Keep the
	# whole canvas centered instead of leaving an unused area inside a wide frame.
	var frame_width := 1020.0
	var frame_height := 764.0
	var available_width := size.x - (40.0 if size.x < 1020.0 else 0.0)
	var available_height := size.y - (40.0 if size.y < 764.0 else 0.0)
	var preparation_scale := minf(1.0, minf(available_width / 1020.0, available_height / 764.0))
	var frame_holder := Control.new()
	frame_holder.custom_minimum_size = Vector2(frame_width, frame_height) * preparation_scale
	frame_holder.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame_row.add_child(frame_holder)
	var frame := _preparation_panel(Vector2(frame_width, frame_height), true)
	frame.name = "PreparationFrame"
	frame.position = Vector2.ZERO
	frame.size = Vector2(frame_width, frame_height)
	frame.scale = Vector2.ONE * preparation_scale
	frame_holder.add_child(frame)
	var right_margin := Control.new()
	right_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_row.add_child(right_margin)
	var inner := _vbox(0)
	frame.add_child(inner)
	var heading := Control.new()
	heading.custom_minimum_size.y = 50.0
	inner.add_child(heading)
	var points_column := _vbox(0)
	points_column.position = Vector2(frame_width - 244.0, 1)
	points_column.size = Vector2(226, 42)
	heading.add_child(points_column)
	_character_points = _label("", 13, MUTED)
	_character_points.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	points_column.add_child(_character_points)
	var point_toggle_row := _hbox(4)
	point_toggle_row.alignment = BoxContainer.ALIGNMENT_END
	points_column.add_child(point_toggle_row)
	var point_limit_label := _label(_prep_local("Use Point Limits", "Puan Sınırını Kullan", "Użyj limitu punktów"), 13, MUTED)
	point_limit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	point_toggle_row.add_child(point_limit_label)
	var limit_toggle := PrepPointLimitButton.new()
	limit_toggle.enabled = point_limit_enabled
	limit_toggle.custom_minimum_size = Vector2(23, 23)
	limit_toggle.pressed.connect(func(): point_limit_enabled = not point_limit_enabled; _show_characters())
	limit_toggle.name = "PreparationPointLimitToggle"
	point_toggle_row.add_child(limit_toggle)
	var tabs := Control.new()
	tabs.name = "PreparationTabs"
	tabs.custom_minimum_size.y = 32.0
	inner.add_child(tabs)
	for tab_index in range(3):
		var tab_id: String = ["characters", "relationships", "equipment"][tab_index]
		var chosen_tab: String = tab_id
		var tab_name := _prep_local("Characters", "Karakterler", "Postacie") if tab_id == "characters" else _prep_local("Relationships", "İlişkiler", "Relacje") if tab_id == "relationships" else _prep_local("Equipment", "Ekipman", "Wyposażenie")
		var tab_button := _preparation_tab_button(tab_name, func(): _switch_preparation_tab(chosen_tab), tab_id == preparation_tab)
		tab_button.custom_minimum_size = Vector2(200, 32)
		tab_button.size = Vector2(200, 32)
		tab_button.position = Vector2(tab_index * 190.0, 0)
		tab_button.set_meta("prep_curved_tab", true)
		for tab_state in ["normal", "hover", "pressed"]:
			var tab_style := (tab_button.get_theme_stylebox(tab_state) as StyleBoxFlat).duplicate() as StyleBoxFlat
			tab_style.corner_radius_top_left = 22
			tab_style.corner_radius_top_right = 22
			tab_style.corner_radius_bottom_left = 0
			tab_style.corner_radius_bottom_right = 0
			tab_style.border_width_bottom = 0 if tab_id == preparation_tab else 1
			tab_button.add_theme_stylebox_override(tab_state, tab_style)
		tabs.add_child(tab_button)
	var body_panel := PanelContainer.new()
	var body_style := _style(Color("#303234"), Color("#707173"), 0)
	body_style.content_margin_left = 15
	body_style.content_margin_top = 15
	body_style.content_margin_right = 13
	body_style.content_margin_bottom = 15
	body_panel.add_theme_stylebox_override("panel", body_style)
	body_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body_panel)
	var body_grain := PrepGrain.new()
	body_grain.grain = _preparation_grain
	body_grain.modulate = Color(1.0, 1.0, 1.0, 0.5)
	body_panel.add_child(body_grain)
	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_panel.add_child(body_scroll)
	var body := _hbox(12)
	body.custom_minimum_size = Vector2(frame_width - 46.0, maxf(290.0, frame_height - 190.0))
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.add_child(body)
	_character_inputs.clear()
	_roster_buttons.clear()
	if preparation_tab == "relationships":
		_build_preparation_relationships(body)
	elif preparation_tab == "equipment":
		_build_preparation_equipment(body)
	else:
		_build_preparation_character(body)
	_refresh_character_points()
	var footer_gap := Control.new()
	footer_gap.custom_minimum_size.y = 18.0
	inner.add_child(footer_gap)
	var footer := Control.new()
	footer.custom_minimum_size.y = 37.0
	inner.add_child(footer)
	var footer_buttons := [
		_setup_button(_tr("common.back"), _return_to_world_from_characters, true, Vector2(149, 37)),
		_setup_button(_prep_local("Load preset", "Hazır ayar yükle", "Wczytaj zestaw"), _load_preparation_preset, true, Vector2(149, 37)),
		_setup_button(_prep_local("Save preset", "Hazır ayar kaydet", "Zapisz zestaw"), _save_preparation_preset, true, Vector2(149, 37)),
		_setup_button(_prep_local("Start", "Başlat", "Rozpocznij"), _advance_to_lobby, true, Vector2(149, 37))
	]
	for footer_index in range(footer_buttons.size()):
		var footer_button: Button = footer_buttons[footer_index]
		footer.add_child(footer_button)
		footer_button.size = Vector2(149, 37)
		match footer_index:
			0: footer_button.position = Vector2.ZERO
			1: footer_button.position = Vector2(frame_width * 0.5 - 163, 0)
			2: footer_button.position = Vector2(frame_width * 0.5 + 12, 0)
			3: footer_button.position = Vector2(frame_width - 149, 0)
	_square_preparation_controls(frame)
	if preparation_scale < 1.0:
		_fit_preparation_frame_after_layout(frame, preparation_scale)


func _fit_preparation_frame_after_layout(frame: Control, factor: float) -> void:
	await get_tree().process_frame
	if is_instance_valid(frame):
		frame.pivot_offset = Vector2.ZERO
		frame.scale = Vector2.ONE * factor


func _prep_local(en: String, tr: String, pl: String) -> String:
	return tr if preferences.language == "tr" else pl if preferences.language == "pl" else en


func _switch_preparation_tab(tab_id: String) -> void:
	_save_character_inputs()
	preparation_tab = tab_id
	_show_characters()


func _on_preparation_sex_changed() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	spec["hair_style"] = "short"
	spec["hair_index"] = (MALE_HAIR_IDS if str(spec.get("sex", "female")) == "male" else FEMALE_HAIR_IDS).find("short")
	_show_characters()


func _hair_options_for_sex(sex: String) -> Array:
	if sex == "male":
		return [_prep_local("Bald", "Kel", "Łysy"), _prep_local("Buzz cut", "Kazınmış", "Ogolony"), _prep_local("Short crop", "Kısa kesim", "Krótkie cięcie"), _prep_local("Side part", "Yandan ayrık", "Z przedziałkiem"), _prep_local("Curly", "Kıvırcık", "Kręcone"), _prep_local("Medium", "Orta", "Średnie"), _prep_local("Long", "Uzun", "Długie")]
	return [_prep_local("Bald", "Kel", "Łysa"), _prep_local("Pixie", "Pixie", "Pixie"), _prep_local("Bob", "Küt", "Bob"), _prep_local("Medium", "Orta", "Średnie"), _prep_local("Wavy", "Dalgalı", "Falowane"), _prep_local("Braid", "Örgü", "Warkocz"), _prep_local("Long", "Uzun", "Długie")]


func _preparation_hair_style(spec: Dictionary) -> String:
	var male := str(spec.get("sex", "female")) == "male"
	var current_ids := MALE_HAIR_IDS if male else FEMALE_HAIR_IDS
	var saved_id := str(spec.get("hair_style", ""))
	if current_ids.has(saved_id):
		return saved_id
	var legacy_ids := LEGACY_MALE_HAIR_IDS if male else LEGACY_FEMALE_HAIR_IDS
	var legacy_id := str(legacy_ids[clampi(int(spec.get("hair_index", 0)), 0, legacy_ids.size() - 1)])
	if current_ids.has(legacy_id):
		return legacy_id
	return "medium" if legacy_id in ["bob", "wavy", "sidepart", "curly"] else "long" if legacy_id == "braid" else "short"


func _preparation_color_field(parent: VBoxContainer, title: String, initial_color: String, presets: Array, changed: Callable) -> PrepColorButton:
	var row := _hbox(5)
	parent.add_child(row)
	var caption := _label(title, 11, MUTED)
	caption.custom_minimum_size.x = 75
	row.add_child(caption)
	var picker := PrepColorButton.new()
	picker.custom_minimum_size = Vector2(132, 25)
	picker.color = Color(initial_color)
	picker.tooltip_text = _prep_local("Choose any color", "İstediğin rengi seç", "Wybierz dowolny kolor")
	picker.color_changed.connect(func(_color: Color): changed.call())
	picker.pressed.connect(func(): _open_preparation_color_dialog(picker))
	row.add_child(picker)
	return picker


func _end_preparation_color_sampling() -> void:
	_preparation_sample_target = null
	if is_instance_valid(_preparation_sample_overlay):
		_preparation_sample_overlay.queue_free()
	_preparation_sample_overlay = null


func _begin_preparation_color_sampling(target: PrepColorButton) -> void:
	_end_preparation_color_sampling()
	if not is_instance_valid(target):
		return
	_preparation_sample_target = target
	var overlay := ColorRect.new()
	overlay.name = "PreparationColorSamplingOverlay"
	overlay.color = Color.TRANSPARENT
	overlay.z_index = 40
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.mouse_default_cursor_shape = Control.CURSOR_CROSS
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_preparation_sample_overlay = overlay
	var hint := PanelContainer.new()
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_theme_stylebox_override("panel", _style(Color("#191c1e"), GOLD, 0))
	_preparation_place(overlay, hint, maxf(10.0, (size.x - 420.0) * 0.5), 17, 420, 31)
	var hint_label := _label(_prep_local("Eyedropper active  ·  Click a color  ·  Esc cancels", "Damlalık etkin  ·  Bir renge tıkla  ·  Esc iptal", "Pipeta aktywna  ·  Kliknij kolor  ·  Esc anuluje"), 12, CREAM)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.add_child(hint_label)
	var sampled := {"done": false}
	overlay.gui_input.connect(func(event: InputEvent):
		if not event is InputEventMouseButton:
			return
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_end_preparation_color_sampling()
			overlay.accept_event()
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var chosen := DisplayServer.screen_get_pixel(DisplayServer.mouse_get_position())
				if is_instance_valid(_preparation_sample_target):
					_preparation_sample_target.set_picked_color(chosen)
				sampled["done"] = true
			elif bool(sampled["done"]):
				_end_preparation_color_sampling()
			overlay.accept_event())


func _open_preparation_color_dialog(target: PrepColorButton) -> void:
	var existing := get_node_or_null("PreparationColorDialog")
	if existing != null:
		existing.queue_free()
	var dialog := PanelContainer.new()
	dialog.name = "PreparationColorDialog"
	dialog.z_index = 30
	dialog.position = Vector2(maxf(10.0, size.x - 280.0), 105.0)
	dialog.custom_minimum_size = Vector2(230, 252)
	dialog.add_theme_stylebox_override("panel", _style(Color("#27292a"), GOLD, 0))
	add_child(dialog)
	var content := _vbox(5)
	dialog.add_child(content)
	var header := _hbox(5)
	header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	content.add_child(header)
	var header_label := _label(_prep_local("Color", "Renk", "Kolor") + "  ⠿", 14, CREAM)
	header_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(header_label)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_child(gap)
	var sample_button := PrepColorActionButton.new()
	sample_button.action = "eyedropper"
	sample_button.custom_minimum_size = Vector2(26, 24)
	sample_button.pressed.connect(func(): _begin_preparation_color_sampling(target))
	sample_button.tooltip_text = _prep_local("Pick a color from the screen, then click a pixel", "Ekrandan renk almak için bir piksele tıkla", "Pobierz kolor z ekranu")
	header.add_child(sample_button)
	header.add_child(_preparation_classic_bare_button("×", dialog.queue_free, 22, 22, 18))
	var drag_state := {"active": false, "origin": Vector2.ZERO}
	header.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			drag_state["active"] = event.pressed
			drag_state["origin"] = event.global_position - dialog.position
		elif event is InputEventMouseMotion and bool(drag_state["active"]):
			dialog.position = (event.global_position - drag_state["origin"]).clamp(Vector2.ZERO, size - dialog.size))
	var wheel := PrepColorWheel.new()
	wheel.name = "PreparationColorWheel"
	wheel.color = target.color
	wheel.color_changed.connect(func(next_color: Color): target.set_picked_color(next_color))
	content.add_child(wheel)
	var selected_row := _hbox(6)
	content.add_child(selected_row)
	var selected_label := _label(_prep_local("Selected", "Seçilen", "Wybrany") + "  #" + target.color.to_html(false).to_upper(), 12, CREAM)
	selected_label.name = "PreparationSelectedColorLabel"
	selected_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected_row.add_child(selected_label)
	var selected_patch := Panel.new()
	selected_patch.name = "PreparationSelectedColorPreview"
	selected_patch.custom_minimum_size = Vector2(30, 21)
	selected_patch.add_theme_stylebox_override("panel", _style(target.color, Color("#ded7c9"), 0))
	selected_row.add_child(selected_patch)
	target.color_changed.connect(func(next_color: Color):
		if not is_instance_valid(dialog):
			return
		wheel.color = next_color
		wheel.queue_redraw()
		selected_label.text = _prep_local("Selected", "Seçilen", "Wybrany") + "  #" + next_color.to_html(false).to_upper()
		selected_patch.add_theme_stylebox_override("panel", _style(next_color, Color("#ded7c9"), 0)))


func _preparation_roster(body: HBoxContainer) -> void:
	var panel := PanelContainer.new()
	panel.name = "PreparationRoster"
	panel.custom_minimum_size.x = 110
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := _style(Color("#202123"), Color.TRANSPARENT, 0)
	panel_style.content_margin_left = 6
	panel_style.content_margin_top = 6
	panel_style.content_margin_right = 5
	panel_style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", panel_style)
	body.add_child(panel)
	var roster := _vbox(6)
	panel.add_child(roster)
	var actions := _hbox(4)
	roster.add_child(actions)
	var add_button := _setup_button(_prep_local("Add", "Ekle", "Dodaj"), _add_prepared_colonist, true, Vector2(69, 22))
	add_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_button.add_theme_font_size_override("font_size", 11)
	add_button.tooltip_text = _prep_local("Add colonist (maximum eight)", "Kolonist ekle (en fazla sekiz)", "Dodaj kolonistę (maksymalnie ośmiu)")
	actions.add_child(add_button)
	var options := MenuButton.new()
	options.flat = false
	options.text = "..."
	options.custom_minimum_size = Vector2(25, 22)
	options.add_theme_font_size_override("font_size", 11)
	for state in ["normal", "hover", "pressed"]:
		var option_style := _style(Color("#755a39") if state == "normal" else Color("#8c6b45"), GOLD if state == "hover" else Color("#a78a59"), 0)
		option_style.border_width_left = 2
		option_style.border_width_top = 2
		option_style.border_width_right = 2
		option_style.border_width_bottom = 2
		options.add_theme_stylebox_override(state, option_style)
	actions.add_child(options)
	var choices := options.get_popup()
	choices.add_item(_prep_local("Add random colonist", "Rastgele kolonist ekle", "Dodaj losowego kolonistę"), 0)
	choices.add_separator(_prep_local("World", "Dünya", "Świat"))
	for world_index in world_character_specs.size():
		choices.add_item(str(world_character_specs[world_index].get("name", "Colonist")), 100 + world_index)
	choices.id_pressed.connect(func(id: int):
		if id == 0:
			_add_prepared_colonist()
		else:
			_restore_world_colonist(id - 100))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	roster.add_child(scroll)
	var cards := _vbox(0)
	cards.custom_minimum_size.x = 83
	scroll.add_child(cards)
	for i in colonist_count:
		var spec: Dictionary = character_specs[i]
		var index_copy := i
		var card := Button.new()
		card.custom_minimum_size = Vector2(83, 116)
		card.tooltip_text = _prepared_display_name(spec)
		card.pressed.connect(func(): _select_character_editor(index_copy))
		for state in ["normal", "hover", "pressed"]:
			var card_fill := Color("#38393a") if i == _editing_character_index else Color("#202123")
			if state == "hover": card_fill = Color("#444547")
			if state == "pressed": card_fill = Color("#2e3032")
			var card_style := _style(card_fill, Color("#55575a") if i == _editing_character_index else Color.TRANSPARENT, 0)
			card_style.content_margin_left = 0
			card_style.content_margin_right = 0
			card_style.content_margin_top = 0
			card_style.content_margin_bottom = 0
			card.add_theme_stylebox_override(state, card_style)
		card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		cards.add_child(card)
		var portrait := PawnPortrait.new()
		portrait.classic_preparation = true
		portrait.name = "RosterPortrait"
		portrait.custom_minimum_size = Vector2(70, 78)
		portrait.position = Vector2(6, 1)
		portrait.size = Vector2(70, 78)
		portrait.appearance = _spec_appearance(spec)
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(portrait)
		var name_label := _label(_prepared_display_name(spec), 12, CREAM)
		name_label.name = "RosterName"
		name_label.position = Vector2(1, 79)
		name_label.size = Vector2(81, 16)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.clip_text = true
		name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		name_label.tooltip_text = _prepared_display_name(spec)
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(name_label)
		var role_label := _label(_preparation_roster_role(spec), 11, MUTED)
		role_label.name = "RosterRole"
		role_label.position = Vector2(1, 95)
		role_label.size = Vector2(81, 16)
		role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role_label.clip_text = true
		role_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		role_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(role_label)
		if i == _editing_character_index and colonist_count > 1:
			var remove := Button.new()
			remove.text = "×"
			remove.flat = true
			remove.position = Vector2(68, 1)
			remove.size = Vector2(14, 16)
			remove.add_theme_font_size_override("font_size", 15)
			remove.tooltip_text = _prep_local("Move to World pool", "Dünya havuzuna taşı", "Przenieś do puli świata")
			remove.pressed.connect(func(): _remove_prepared_colonist(index_copy))
			card.add_child(remove)
		_roster_buttons.append(card)
	var world_header := Button.new()
	world_header.name = "PreparationWorldHeader"
	world_header.text = "%s (%d) %s" % [_prep_local("World", "Dünya", "Świat"), world_character_specs.size(), "▾" if _world_roster_expanded else "▸"]
	world_header.custom_minimum_size = Vector2(83, 25)
	world_header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	world_header.add_theme_font_size_override("font_size", 11)
	for state in ["normal", "hover", "pressed"]:
		world_header.add_theme_stylebox_override(state, _style(Color("#292b2c") if state == "normal" else Color("#353738"), Color.TRANSPARENT, 0))
	cards.add_child(world_header)
	var world_section := _vbox(0)
	world_section.name = "PreparationWorldSection"
	cards.add_child(world_section)
	world_section.visible = _world_roster_expanded
	world_header.pressed.connect(func():
		_world_roster_expanded = not _world_roster_expanded
		world_section.visible = _world_roster_expanded
		world_header.text = "%s (%d) %s" % [_prep_local("World", "Dünya", "Świat"), world_character_specs.size(), "▾" if _world_roster_expanded else "▸"])
	for world_index in world_character_specs.size():
		var world_spec: Dictionary = world_character_specs[world_index]
		var world_index_copy := world_index
		var world_card := Button.new()
		world_card.custom_minimum_size = Vector2(83, 116)
		world_card.tooltip_text = "%s\n%s" % [_prepared_display_name(world_spec),
			_prep_local("Add this person from World", "Bu kişiyi Dünya'dan ekle", "Dodaj tę osobę ze świata")]
		world_card.disabled = colonist_count >= 8
		world_card.pressed.connect(func(): _restore_world_colonist(world_index_copy))
		for state in ["normal", "hover", "pressed"]:
			var world_style := _style(Color("#222325") if state == "normal" else Color("#383a3b"), Color.TRANSPARENT, 0)
			world_style.content_margin_left = 0
			world_style.content_margin_right = 0
			world_style.content_margin_top = 0
			world_style.content_margin_bottom = 0
			world_card.add_theme_stylebox_override(state, world_style)
		world_card.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		world_section.add_child(world_card)
		var world_portrait := PawnPortrait.new()
		world_portrait.classic_preparation = true
		world_portrait.appearance = _spec_appearance(world_spec)
		world_portrait.position = Vector2(6, 1)
		world_portrait.size = Vector2(70, 78)
		world_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world_card.add_child(world_portrait)
		var world_name := _label(_prepared_display_name(world_spec), 12, CREAM)
		world_name.position = Vector2(1, 79)
		world_name.size = Vector2(81, 16)
		world_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		world_name.clip_text = true
		world_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		world_name.tooltip_text = _prepared_display_name(world_spec)
		world_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world_card.add_child(world_name)
		var world_role := _label(_preparation_roster_role(world_spec), 11, MUTED)
		world_role.position = Vector2(1, 95)
		world_role.size = Vector2(81, 16)
		world_role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		world_role.clip_text = true
		world_role.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		world_role.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world_card.add_child(world_role)


func _preparation_roster_role(spec: Dictionary) -> String:
	if str(spec.get("adulthood", "farmer")) == "unknown":
		return _prep_local("Unknown", "Bilinmiyor", "Nieznane")
	if str(spec.get("childhood", "")) == "vatgrown_soldier":
		return _prep_local("Vatgrown", "Tankta yetişmiş", "Z kadzi")
	match str(spec.get("adulthood", "farmer")):
		"builder": return _prep_local("Builder", "İnşaatçı", "Budowniczy")
		"medic": return _prep_local("Medic", "Sağlıkçı", "Medyk")
		"scholar": return _prep_local("Scholar", "Araştırmacı", "Badacz")
		_: return _prep_local("Farmer", "Çiftçi", "Rolnik")


func _default_prepared_spec(index: int) -> Dictionary:
	var i := clampi(index, 0, 2)
	var nickname := str(["Wren", "Boz", "Mavi"][i])
	var default_passions := [
		{"plants": 2, "animals": 1},
		{"construction": 2, "mining": 1},
		{"medical": 2, "intellectual": 1}
	]
	return {
		"name": nickname, "first_name": ["Adeline", "Baran", "Deniz"][i],
		"nickname": nickname, "last_name": ["Fox", "Kaya", "Aksoy"][i],
		"hair_index": i % 4, "hair_color": HAIR_COLOR_OPTIONS[i + 1],
		"skin_color": SKIN_OPTIONS[i * 3], "body_type": i % 2, "head_type": i % 2,
		"trait_ids": ["hardworking"] if i == 0 else ["calm"] if i == 1 else ["quick"],
		"condition_ids": [], "sex": "female" if i != 1 else "male", "age": 25 + i * 4,
		"childhood": "rural_child", "adulthood": ["farmer", "builder", "medic"][i],
		"starting_gear": {"weapon": "fists", "shirt": "tshirt", "pants": "pants", "shirt_color": OUTFIT_OPTIONS[i % OUTFIT_OPTIONS.size()], "pants_color": "#5f6768"},
		"starting_relationships": {}, "skills": _derive_work_skills(_default_classic_skill_profile(i)),
		"passions": default_passions[i]
	}

func _default_world_prepared_specs() -> Array:
	var candidates: Array = []
	var names := ["Mara", "Robin", "Iris", "Tomas", "Elin"]
	var nicknames := ["Scout", "Rook", "Sage", "Tinker", "Fable"]
	var surnames := ["Keene", "Ortiz", "Marsh", "Voss", "Hale"]
	for i in names.size():
		var spec := _default_prepared_spec(i % 3)
		spec["name"] = nicknames[i]
		spec["nickname"] = nicknames[i]
		spec["first_name"] = names[i]
		spec["last_name"] = surnames[i]
		spec["sex"] = "male" if i in [1, 3] else "female"
		spec["hair_index"] = i % 4
		spec["skin_color"] = SKIN_OPTIONS[(i * 2 + 1) % SKIN_OPTIONS.size()]
		spec["starting_relationships"] = {}
		candidates.append(spec)
	return candidates


func _default_classic_skill_profile(index: int) -> Dictionary:
	var profiles := [
		{"shooting": 1, "melee": 1, "construction": 2, "mining": 0, "cooking": 2, "plants": 3, "animals": 2, "crafting": 1, "artistic": 0, "medical": 1, "social": 2, "intellectual": 1},
		{"shooting": 2, "melee": 2, "construction": 3, "mining": 3, "cooking": 1, "plants": 1, "animals": 0, "crafting": 2, "artistic": 1, "medical": 0, "social": 1, "intellectual": 1},
		{"shooting": 1, "melee": 0, "construction": 1, "mining": 0, "cooking": 1, "plants": 1, "animals": 1, "crafting": 1, "artistic": 2, "medical": 3, "social": 3, "intellectual": 2}
	]
	return (profiles[clampi(index, 0, profiles.size() - 1)] as Dictionary).duplicate(true)


func _add_prepared_colonist() -> void:
	if colonist_count >= 8:
		_notice(_prep_local("A colony can start with at most eight people.", "Bir koloni en fazla sekiz kişiyle başlayabilir.", "Kolonia może zacząć z najwyżej ośmioma osobami."))
		return
	_save_character_inputs()
	var new_spec := _default_prepared_spec(colonist_count)
	var identity := _pick_prepared_name(str(new_spec.get("sex", "female")))
	new_spec["first_name"] = identity["first"]
	new_spec["nickname"] = identity["nick"]
	new_spec["name"] = identity["nick"]
	new_spec["last_name"] = identity["last"]
	character_specs.append(new_spec)
	colonist_count += 1
	_editing_character_index = colonist_count - 1
	_show_characters()


func _remove_prepared_colonist(index: int) -> void:
	if colonist_count <= 1 or index < 0 or index >= colonist_count:
		return
	_save_character_inputs()
	var previous_links: Array = []
	for other_index in range(colonist_count):
		if other_index == index:
			continue
		var relation_id := _preparation_family_relation(index, other_index)
		if relation_id != "none":
			previous_links.append({"other": other_index, "relation": relation_id})
	var new_world_index := world_character_specs.size()
	var removed: Dictionary = character_specs[index].duplicate(true)
	removed["starting_relationships"] = {}
	world_character_specs.append(removed)
	character_specs.remove_at(index)
	_remap_external_relationships_after_transfer("c", index, "w", new_world_index)
	for previous_link in previous_links:
		var old_other := int(previous_link["other"])
		var new_other := old_other - 1 if old_other > index else old_other
		external_relationships.append({"from": "w:%d" % new_world_index, "to": "c:%d" % new_other, "relation": str(previous_link["relation"])})
	for new_index in character_specs.size():
		var spec: Dictionary = character_specs[new_index]
		var old_links: Dictionary = spec.get("starting_relationships", {})
		var new_links := {}
		for old_target in old_links:
			var target := int(old_target)
			if target == index:
				continue
			new_links[str(target - 1 if target > index else target)] = old_links[old_target]
		spec["starting_relationships"] = new_links
	colonist_count = character_specs.size()
	_external_source_index = new_world_index
	_external_target_key = "c:0"
	_editing_character_index = mini(_editing_character_index, colonist_count - 1)
	_show_characters()


func _restore_world_colonist(index: int) -> void:
	if colonist_count >= 8 or index < 0 or index >= world_character_specs.size():
		return
	_save_character_inputs()
	var new_colonist_index := colonist_count
	var restored: Dictionary = world_character_specs[index].duplicate(true)
	restored["starting_relationships"] = {}
	world_character_specs.remove_at(index)
	character_specs.append(restored)
	colonist_count = character_specs.size()
	_remap_external_relationships_after_transfer("w", index, "c", new_colonist_index)
	for bond_index in range(external_relationships.size() - 1, -1, -1):
		var bond: Dictionary = external_relationships[bond_index]
		var first_key := str(bond.get("from", ""))
		var second_key := str(bond.get("to", ""))
		if first_key.begins_with("c:") and second_key.begins_with("c:"):
			if _set_starting_relation(int(first_key.substr(2)), int(second_key.substr(2)), str(bond.get("relation", "none"))):
				external_relationships.remove_at(bond_index)
	_external_source_index = 0
	_external_target_key = "c:0"
	_editing_character_index = colonist_count - 1
	_show_characters()


func _remap_external_relationships_after_transfer(from_kind: String, moved_index: int, to_kind: String, new_index: int) -> void:
	for raw_bond in external_relationships:
		if not raw_bond is Dictionary:
			continue
		var bond: Dictionary = raw_bond
		for side in ["from", "to"]:
			var key := str(bond.get(side, ""))
			if not key.begins_with(from_kind + ":"):
				continue
			var old_index := int(key.substr(2))
			if old_index == moved_index:
				bond[side] = "%s:%d" % [to_kind, new_index]
			elif old_index > moved_index:
				bond[side] = "%s:%d" % [from_kind, old_index - 1]


func _build_preparation_character(body: HBoxContainer) -> void:
	_build_preparation_character_classic(body)


func _preparation_classic_panel(width: float, height: float, fill := Color("#232526")) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(width, height)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(fill, Color("#3b3d3f"), 0))
	if _preparation_grain != null:
		var grain_layer := PrepGrain.new()
		grain_layer.grain = _preparation_grain
		grain_layer.modulate = Color(1.0, 1.0, 1.0, 0.23)
		grain_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(grain_layer)
	return panel


func _preparation_place(parent: Control, child: Control, x: float, y: float, width: float, height: float) -> void:
	parent.add_child(child)
	child.set_anchors_preset(Control.PRESET_TOP_LEFT)
	child.position = Vector2(x, y)
	child.size = Vector2(width, height)
	child.custom_minimum_size = Vector2(width, height)


func _preparation_classic_caption(parent: Control, caption: String, x: float, y: float, width: float, height: float, font_size := 12, color := MUTED) -> Label:
	var label := _label(caption, font_size, color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_preparation_place(parent, label, x, y, width, height)
	return label


func _preparation_classic_gold_button(caption: String, action: Callable, width: float, height: float) -> Button:
	var button := _setup_button(caption, action, true, Vector2(width, height))
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button


func _preparation_classic_bare_button(caption: String, action: Callable, width: float, height: float, font_size := 16) -> Button:
	var button := Button.new()
	button.text = caption
	button.flat = true
	button.custom_minimum_size = Vector2(width, height)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#babbb9"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	for state_name in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	button.pressed.connect(action)
	return button


func _preparation_classic_gold_menu(caption: String, width: float, height: float) -> MenuButton:
	var menu := MenuButton.new()
	menu.flat = false
	menu.text = caption
	menu.alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu.custom_minimum_size = Vector2(width, height)
	menu.add_theme_font_size_override("font_size", 13)
	for state_name in ["normal", "hover", "pressed"]:
		var fill := Color("#705633") if state_name == "normal" else Color("#82643b") if state_name == "hover" else Color("#594326")
		var style := _style(fill, Color("#30251a"), 0)
		style.border_width_left = 3
		style.border_width_top = 2
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.content_margin_top = 1
		style.content_margin_bottom = 1
		menu.add_theme_stylebox_override(state_name, style)
	menu.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return menu


func _preparation_classic_rgb_handle(color: Color) -> Texture2D:
	var image_data := Image.create_empty(11, 10, false, Image.FORMAT_RGBA8)
	image_data.fill(Color("#111112"))
	for yy in range(1, 9):
		for xx in range(1, 10):
			image_data.set_pixel(xx, yy, color)
	return ImageTexture.create_from_image(image_data)


func _preparation_classic_rgb_slider(parent: Control, y: float, channel: int, initial_color: Color, update: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 255
	slider.step = 1
	slider.value = [initial_color.r8, initial_color.g8, initial_color.b8][channel]
	slider.custom_minimum_size = Vector2(135, 18)
	var channel_dim: Color = [Color("#532727"), Color("#225330"), Color("#293c68")][channel]
	var channel_bright: Color = [Color("#b8433c"), Color("#37a853"), Color("#456fc1")][channel]
	var track_style := _style(channel_dim, Color("#0d0e0f"), 0)
	track_style.content_margin_top = 2
	track_style.content_margin_bottom = 2
	slider.add_theme_stylebox_override("slider", track_style)
	slider.add_theme_stylebox_override("grabber_area", _style(channel_bright, Color.TRANSPARENT, 0))
	slider.add_theme_stylebox_override("grabber_area_highlight", _style(channel_bright.lightened(0.15), Color.TRANSPARENT, 0))
	var handle_color: Color = [Color("#aa2527"), Color("#087e22"), Color("#152e8b")][channel]
	var handle := _preparation_classic_rgb_handle(handle_color)
	slider.add_theme_icon_override("grabber", handle)
	slider.add_theme_icon_override("grabber_highlight", handle)
	slider.value_changed.connect(func(_value: float): update.call())
	_preparation_place(parent, slider, 75, y, 135, 18)
	return slider


func _build_preparation_character_classic(body: HBoxContainer) -> void:
	_preparation_roster(body)
	_preparation_migrate_legacy_injuries(_editing_character_index)
	var old: Dictionary = character_specs[_editing_character_index]
	var editor := _vbox(10)
	editor.custom_minimum_size.x = 832
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(editor)

	# The screenshot has a continuous, 65-pixel-high name strip above three inset columns.
	var name_panel := _preparation_classic_panel(832, 65, Color("#252729"))
	name_panel.name = "PreparationNames"
	name_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	editor.add_child(name_panel)
	_preparation_place(name_panel, _preparation_dice_button(_randomize_prepared_colonist, _prep_local("Randomize this colonist", "Bu kolonisti rastgele oluştur", "Wylosuj tę postać"), Vector2(26, 27), true), 16, 17, 26, 27)
	var info_button := PrepInfoButton.new()
	info_button.custom_minimum_size = Vector2(26, 27)
	info_button.pressed.connect(_show_prepared_character_info)
	info_button.tooltip_text = _prep_local("Character overview", "Karakter özeti", "Opis postaci")
	_preparation_place(name_panel, info_button, 46, 17, 26, 27)
	var first_name_edit := LineEdit.new()
	first_name_edit.text = str(old.get("first_name", old.get("name", "Colonist")))
	first_name_edit.placeholder_text = _prep_local("First Name", "İlk ad", "Imię")
	first_name_edit.tooltip_text = _prep_local("First name", "İlk ad", "Imię")
	_preparation_name_input_style(first_name_edit)
	_preparation_place(name_panel, first_name_edit, 76, 18, 118, 28)
	var name_edit := LineEdit.new()
	name_edit.text = _normalize_prepared_nickname(str(old.get("nickname", old.get("name", "Colonist"))))
	name_edit.placeholder_text = _prep_local("Nickname", "Takma ad", "Pseudonim")
	name_edit.tooltip_text = _prep_local("Nickname shown above the colonist", "Kolonistin üzerinde görünen takma ad", "Pseudonim nad postacią")
	_preparation_name_input_style(name_edit)
	name_edit.add_theme_font_size_override("font_size", 11 if name_edit.text.length() > 9 else 12)
	name_edit.text_changed.connect(func(value: String):
		name_edit.add_theme_font_size_override("font_size", 11 if value.length() > 9 else 12))
	_preparation_place(name_panel, name_edit, 198, 18, 118, 28)
	var last_name_edit := LineEdit.new()
	last_name_edit.text = str(old.get("last_name", ""))
	last_name_edit.placeholder_text = _prep_local("Last Name", "Soyad", "Nazwisko")
	last_name_edit.tooltip_text = _prep_local("Last name", "Soyad", "Nazwisko")
	_preparation_name_input_style(last_name_edit)
	_preparation_place(name_panel, last_name_edit, 320, 18, 138, 28)
	_preparation_place(name_panel, _preparation_dice_button(_randomize_prepared_name, _prep_local("Randomize names", "Adları rastgele seç", "Wylosuj imiona"), Vector2(26, 27), true), 463, 17, 26, 27)
	_preparation_place(name_panel, _preparation_classic_gold_button(_prep_local("Load Character", "Karakter Yükle", "Wczytaj postać"), _load_character_preset, 125, 37), 561, 13, 125, 37)
	_preparation_place(name_panel, _preparation_classic_gold_button(_prep_local("Save Character", "Karakter Kaydet", "Zapisz postać"), _save_character_preset, 125, 37), 694, 13, 125, 37)

	var columns := _hbox(11)
	columns.custom_minimum_size = Vector2(832, 483)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.add_child(columns)
	var appearance_panel := _preparation_classic_panel(226, 483)
	appearance_panel.name = "PreparationAppearance"
	columns.add_child(appearance_panel)
	_preparation_classic_caption(appearance_panel, _prep_local("Biological Age", "Biyolojik Yaş", "Wiek biologiczny"), 16, 10, 96, 18, 11, Color("#cacac8"))
	_preparation_classic_caption(appearance_panel, _prep_local("Chronological Age", "Kronolojik Yaş", "Wiek chronologiczny"), 112, 10, 110, 18, 11, Color("#cacac8"))
	var age := PrepStepper.new(int(old.get("age", 25)), 18, 80, "age")
	age.changed.connect(func(_value: int): _refresh_character_editor())
	_preparation_place(appearance_panel, age, 16, 30, 82, 25)
	var chronological_age := PrepStepper.new(int(old.get("chronological_age", old.get("age", 25))), 18, 1200, "age")
	chronological_age.changed.connect(func(_value: int): _refresh_character_editor())
	_preparation_place(appearance_panel, chronological_age, 112, 30, 82, 25)
	var equipped_gear: Dictionary = old.get("starting_gear", {})
	var appearance_categories := [_prep_local("Hat", "Şapka", "Kapelusz"), _prep_local("Hairstyle", "Saç modeli", "Fryzura"),
		_prep_local("Body type", "Vücut tipi", "Typ sylwetki"), _prep_local("Head type", "Kafa tipi", "Typ głowy"),
		_prep_local("Torso", "Gövde", "Tułów"), _prep_local("Legs", "Bacaklar", "Nogi"),
		_prep_local("Apparel", "Dış giysi", "Odzież wierzchnia")]
	var appearance_menu := _preparation_classic_gold_menu(appearance_categories[_preparation_appearance_category], 192, 27)
	for category_index in appearance_categories.size():
		appearance_menu.get_popup().add_item(appearance_categories[category_index], category_index)
	appearance_menu.get_popup().id_pressed.connect(func(category_index: int):
		_save_character_inputs()
		_preparation_appearance_category = category_index
		_show_characters())
	_preparation_place(appearance_panel, appearance_menu, 17, 90, 192, 27)
	_preparation_classic_caption(appearance_menu, "▾", 172, 1, 15, 23, 12, CREAM).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var portrait_box := Panel.new()
	portrait_box.name = "PreparationPortrait"
	portrait_box.add_theme_stylebox_override("panel", _style(Color("#16191b"), Color("#696c6e"), 0))
	_preparation_place(appearance_panel, portrait_box, 16, 125, 194, 195)
	var preview := PawnPreviewScript.new()
	preview.classic_preparation_background = true
	_preparation_place(portrait_box, preview, 1, 1, 192, 193)
	var sex := {"index": 0 if str(old.get("sex", "female")) == "female" else 1, "row": portrait_box}
	var female_button := PrepGenderButton.new()
	female_button.selected = int(sex["index"]) == 0
	female_button.pressed.connect(func(): sex["index"] = 0; _on_preparation_sex_changed())
	female_button.tooltip_text = _prep_local("Female", "Kadın", "Kobieta")
	_preparation_place(portrait_box, female_button, 7, 7, 20, 21)
	var male_button := PrepGenderButton.new()
	male_button.is_male = true
	male_button.selected = int(sex["index"]) == 1
	male_button.pressed.connect(func(): sex["index"] = 1; _on_preparation_sex_changed())
	male_button.tooltip_text = _prep_local("Male", "Erkek", "Mężczyzna")
	_preparation_place(portrait_box, male_button, 27, 7, 20, 21)
	_preparation_place(portrait_box, _preparation_dice_button(_randomize_prepared_appearance, _prep_local("Randomize appearance", "Görünüşü rastgele seç", "Wylosuj wygląd"), Vector2(21, 21), true), 160, 6, 22, 22)
	var hair_ids := MALE_HAIR_IDS if str(old.get("sex", "female")) == "male" else FEMALE_HAIR_IDS
	var hair := {"index": hair_ids.find(_preparation_hair_style(old))}
	var body_type := {"index": clampi(int(old.get("body_type", 0)), 0, 1)}
	var head_type := {"index": clampi(int(old.get("head_type", 0)), 0, 1)}
	var hair_color: PrepColorButton = null
	var skin: PrepColorButton = null
	var first_choice: Dictionary = {}
	var second_choice: Dictionary = {}
	match _preparation_appearance_category:
		0:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("No hat", "Şapka yok", "Bez kapelusza"), _prep_local("Bowler hat", "Melon şapka", "Melonik"), _cargo_label("cap")], 1 if str(equipped_gear.get("hat", "none")) == "brim_hat" else 2 if str(equipped_gear.get("hat", "none")) == "cap" else 0, func(value: int): _set_starting_gear("hat", ["none", "brim_hat", "cap"][value]), 0, 194)
			if str(equipped_gear.get("hat", "none")) != "none":
				second_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Cloth", "Kumaş", "Tkanina")], 0, func(_value: int): pass, 0, 194)
		1:
			first_choice = _arrow_choice_field(appearance_panel, "", _hair_options_for_sex(str(old.get("sex", "female"))), int(hair["index"]), func(value: int): hair["index"] = value; _refresh_character_editor(), 0, 194)
			var hair_color_names := [_prep_local("Custom color", "Özel renk", "Własny kolor"), _prep_local("Black", "Siyah", "Czarny"), _prep_local("Dark brown", "Koyu kahve", "Ciemny brąz"), _prep_local("Brown", "Kahve", "Brąz"), _prep_local("Chestnut", "Kestane", "Kasztan"), _prep_local("Auburn", "Kızıl kahve", "Kasztanowy"), _prep_local("Copper", "Bakır", "Miedziany"), _prep_local("Blonde", "Sarı", "Blond"), _prep_local("Ash", "Kül", "Popielaty"), _prep_local("Mahogany", "Maun", "Mahoń"), _prep_local("Gray", "Gri", "Szary"), _prep_local("White", "Beyaz", "Biały"), _prep_local("Charcoal", "Kömür", "Grafit")]
			var hair_preset := HAIR_COLOR_OPTIONS.find(str(old.get("hair_color", HAIR_COLOR_OPTIONS[1])))
			second_choice = _arrow_choice_field(appearance_panel, "", hair_color_names, 0 if bool(old.get("hair_color_custom", false)) or hair_preset < 0 else hair_preset + 1, func(value: int):
				if value > 0:
					_set_prepared_color("hair_color", Color(str(HAIR_COLOR_OPTIONS[value - 1])), true, false), 0, 194, "", true)
		2:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Normal", "Normal", "Normalna"), _prep_local("Broad", "Geniş", "Szeroka")], int(body_type["index"]), func(value: int): body_type["index"] = value; _refresh_character_editor(), 0, 194)
			second_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Custom color", "Özel renk", "Własny kolor"), _prep_local("Light skin", "Açık ten", "Jasna skóra"), _prep_local("Medium skin", "Orta ten", "Średnia skóra"), _prep_local("Dark skin", "Koyu ten", "Ciemna skóra")], 0 if bool(old.get("skin_color_custom", false)) else _preparation_skin_group(str(old.get("skin_color", SKIN_OPTIONS[0]))) + 1, func(value: int):
				if value > 0:
					_set_prepared_color("skin_color", Color(str(SKIN_OPTIONS[(value - 1) * 4])), true, false), 0, 194, "", true)
		3:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Oval", "Oval", "Owalna"), _prep_local("Round", "Yuvarlak", "Okrągła")], int(head_type["index"]), func(value: int): head_type["index"] = value; _refresh_character_editor(), 0, 194)
		4:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("T-shirt", "Tişört", "Koszulka"), _prep_local("No torso clothing", "Gövde kıyafeti yok", "Bez ubrania na tułowiu")], 1 if str(equipped_gear.get("shirt", "tshirt")) == "none" else 0, func(value: int): _set_preparation_torso(value), 0, 194)
			if str(equipped_gear.get("shirt", "tshirt")) != "none":
				second_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Cloth", "Kumaş", "Tkanina")], 0, func(_value: int): pass, 0, 194)
		5:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Pants", "Pantolon", "Spodnie"), _prep_local("No leg clothing", "Bacak kıyafeti yok", "Bez ubrania na nogach")], 1 if str(equipped_gear.get("pants", "pants")) == "none" else 0, func(value: int): _set_preparation_legs(value), 0, 194)
			if str(equipped_gear.get("pants", "pants")) != "none":
				second_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Cloth", "Kumaş", "Tkanina")], 0, func(_value: int): pass, 0, 194)
		6:
			first_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("No outer clothing", "Dış giysi yok", "Bez odzieży wierzchniej"), _prep_local("Coat", "Kaban", "Płaszcz")], 1 if str(equipped_gear.get("apparel", "none")) == "jacket" else 0, func(value: int): _set_preparation_apparel(value), 0, 194)
			if str(equipped_gear.get("apparel", "none")) == "jacket":
				second_choice = _arrow_choice_field(appearance_panel, "", [_prep_local("Cloth", "Kumaş", "Tkanina")], 0, func(_value: int): pass, 0, 194)
	if _preparation_appearance_category == 1:
		hair["row"] = first_choice["row"]
	elif _preparation_appearance_category == 2:
		body_type["row"] = first_choice["row"]
	elif _preparation_appearance_category == 3:
		head_type["row"] = first_choice["row"]
	(first_choice["row"] as Control).position = Vector2(0, 326)
	if not second_choice.is_empty():
		(second_choice["row"] as Control).position = Vector2(0, 358)
		# Leave room beside the color/material name for the copy and paste tools.
		var color_value_menu := second_choice["value_menu"] as Button
		color_value_menu.custom_minimum_size.x = 140
		(color_value_menu.get_parent() as Control).custom_minimum_size.x = 140
		(second_choice["row"] as Control).custom_minimum_size.x = 168
	var color_key := _preparation_active_color_key(old)
	if not color_key.is_empty():
		var appearance_colors := _spec_appearance(old)
		var appearance_key := "skin" if color_key == "skin_color" else color_key
		var clothing_color := Color(str(appearance_colors.get(appearance_key, "#f1b92d")))
		var swatch := PrepColorButton.new()
		swatch.color = clothing_color
		swatch.tooltip_text = _prep_local("Edit selected color", "Seçili rengi düzenle", "Edytuj wybrany kolor")
		swatch.pressed.connect(func(): _open_preparation_color_dialog(swatch))
		_preparation_place(appearance_panel, swatch, 18, 398, 50, 50)
		var copy_color := PrepColorActionButton.new()
		copy_color.action = "copy"
		copy_color.pressed.connect(func():
			_preparation_copied_color = "#" + swatch.color.to_html(false)
			DisplayServer.clipboard_set(_preparation_copied_color))
		copy_color.tooltip_text = _prep_local("Copy this color", "Bu rengi kopyala", "Kopiuj kolor")
		_preparation_place(appearance_panel, copy_color, 169, 360, 25, 25)
		var paste_color := PrepColorActionButton.new()
		paste_color.action = "paste"
		paste_color.pressed.connect(func():
			if not _preparation_copied_color.is_empty():
				swatch.set_picked_color(Color(_preparation_copied_color)))
		paste_color.tooltip_text = _prep_local("Paste copied color onto this colonist", "Kopyalanan rengi bu koloniste uygula", "Wklej kolor")
		_preparation_place(appearance_panel, paste_color, 197, 360, 25, 25)
		var rgb_sliders: Array[HSlider] = []
		for channel in range(3):
			rgb_sliders.append(_preparation_classic_rgb_slider(appearance_panel, 392.0 + float(channel) * 20.0, channel, clothing_color, func():
				var new_color := Color(float(rgb_sliders[0].value) / 255.0, float(rgb_sliders[1].value) / 255.0, float(rgb_sliders[2].value) / 255.0)
				swatch.set_picked_color(new_color)))
		swatch.color_changed.connect(func(next_color: Color):
			for channel_index in range(3):
				rgb_sliders[channel_index].set_value_no_signal(roundi(next_color[channel_index] * 255.0))
			_set_prepared_color(color_key, next_color, false)
			if color_key in ["hair_color", "skin_color"] and not second_choice.is_empty():
				second_choice["index"] = 0
				(second_choice["value_menu"] as Button).text = _prep_local("Custom color", "Özel renk", "Własny kolor")
			preview.set_appearance(_spec_appearance(character_specs[_editing_character_index]))
			if _editing_character_index < _roster_buttons.size():
				var roster_portrait := _roster_buttons[_editing_character_index].get_node_or_null("RosterPortrait") as PawnPortrait
				if roster_portrait != null:
					roster_portrait.set_appearance(_spec_appearance(character_specs[_editing_character_index]))
			_refresh_character_points())

	var biography := _vbox(12)
	biography.custom_minimum_size.x = 321
	columns.add_child(biography)
	var history_panel := _preparation_classic_panel(321, 121)
	history_panel.name = "PreparationBackstory"
	history_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	biography.add_child(history_panel)
	_preparation_classic_caption(history_panel, _prep_local("Backstory", "Geçmiş", "Przeszłość"), 15, 6, 250, 31, 19, CREAM)
	_preparation_place(history_panel, _preparation_dice_button(func(): _randomize_preparation_choices("backstory"), _prep_local("Randomize backstory", "Geçmişi rastgele seç", "Wylosuj przeszłość"), Vector2(22, 22), true), 286, 10, 22, 22)
	var childhood := _arrow_choice_field(history_panel, _prep_local("Childhood", "Çocukluk", "Dzieciństwo"), [_prep_local("Rural child", "Köy çocuğu", "Dziecko ze wsi"), _prep_local("Town child", "Kasaba çocuğu", "Dziecko z miasta"), _prep_local("Apprentice", "Çırak", "Uczeń"), _prep_local("Vatgrown soldier", "Tankta yetişmiş asker", "Żołnierz z kadzi"), _prep_local("Unknown", "Bilinmiyor", "Nieznane")], maxi(0, CHILDHOOD_IDS.find(str(old.get("childhood", "rural_child")))), func(_value: int): _refresh_character_editor(), 74, 193, "childhood")
	(childhood["row"] as Control).position = Vector2(15, 44)
	var adulthood := _arrow_choice_field(history_panel, _prep_local("Adulthood", "Yetişkinlik", "Dorosłość"), [_prep_local("Farmer", "Çiftçi", "Rolnik"), _prep_local("Builder", "İnşaatçı", "Budowniczy"), _prep_local("Medic", "Sağlıkçı", "Medyk"), _prep_local("Scholar", "Araştırmacı", "Badacz"), _prep_local("Unknown", "Bilinmiyor", "Nieznane")], maxi(0, ADULTHOOD_IDS.find(str(old.get("adulthood", "farmer")))), func(_value: int): _refresh_character_editor(), 74, 193, "adulthood")
	(adulthood["row"] as Control).position = Vector2(15, 78)
	var childhood_note := _label("", 11, MUTED)
	childhood_note.visible = false
	history_panel.add_child(childhood_note)
	var adulthood_note := _label("", 11, MUTED)
	adulthood_note.visible = false
	history_panel.add_child(adulthood_note)
	var traits_panel := _preparation_classic_panel(321, 157)
	traits_panel.name = "PreparationTraitsHealth"
	traits_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	biography.add_child(traits_panel)
	var trait_header := _hbox(3)
	_preparation_place(traits_panel, trait_header, 15, 5, 295, 29)
	trait_header.add_child(_label(_prep_local("Traits", "Özellikler", "Cechy"), 19, CREAM))
	var trait_header_gap := Control.new()
	trait_header_gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trait_header.add_child(trait_header_gap)
	var old_traits: Array = old.get("trait_ids", [TRAIT_IDS[clampi(int(old.get("trait_index", 0)) + 1, 1, TRAIT_IDS.size() - 1)]])
	var trait_fields := _preparation_choice_chips(traits_panel, TRAIT_IDS, _preparation_trait_names(), old_traits, _prep_local("Add trait", "Özellik ekle", "Dodaj cechę"), trait_header, 38.0, true)
	trait_header.add_child(_preparation_dice_button(func(): _randomize_preparation_choices("traits"), _prep_local("Randomize traits", "Özellikleri rastgele seç", "Wylosuj cechy"), Vector2(22, 22), true))
	var health_panel := _preparation_classic_panel(321, 181)
	health_panel.name = "PreparationHealth"
	biography.add_child(health_panel)
	var health_header := _hbox(3)
	_preparation_place(health_panel, health_header, 15, 5, 295, 30)
	health_header.add_child(_label(_prep_local("Health", "Sağlık", "Zdrowie"), 19, CREAM))
	var health_header_gap := Control.new()
	health_header_gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_header.add_child(health_header_gap)
	var old_conditions: Array = old.get("condition_ids", [])
	var condition_fields := _build_preparation_health_editor(health_panel, health_header, old_conditions, old.get("health_injuries", []))
	var skill_stack := _vbox(8)
	skill_stack.custom_minimum_size.x = 261
	columns.add_child(skill_stack)
	var skill_panel := _preparation_classic_panel(261, 367)
	skill_panel.name = "PreparationSkills"
	skill_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	skill_stack.add_child(skill_panel)
	_preparation_classic_caption(skill_panel, _prep_local("Skills", "Beceriler", "Umiejętności"), 14, 5, 140, 31, 19, CREAM)
	var skill_clear := PrepResetButton.new()
	skill_clear.custom_minimum_size = Vector2(25, 25)
	skill_clear.pressed.connect(_reset_preparation_skills)
	skill_clear.tooltip_text = _prep_local("Clear skills", "Becerileri temizle", "Wyczyść umiejętności")
	_preparation_place(skill_panel, skill_clear, 190, 5, 25, 25)
	var skill_random := _preparation_dice_button(_randomize_preparation_skills,
		_prep_local("Randomize skills", "Becerileri rastgele dağıt", "Wylosuj umiejętności"), Vector2(25, 25), true)
	_preparation_place(skill_panel, skill_random, 220, 5, 25, 25)
	var skill_fields: Dictionary = {}
	var old_skills: Dictionary = old.get("skills", {})
	var old_passions: Dictionary = old.get("passions", {})
	var old_modifiers: Dictionary = PreparationRules.skill_modifiers(str(old.get("childhood", "rural_child")), str(old.get("adulthood", "farmer")), old_traits, old_conditions)
	var old_incapable: Array = PreparationRules.incapable_of(str(old.get("childhood", "rural_child")), str(old.get("adulthood", "farmer")), old_traits, old_conditions)
	for skill_index in range(CLASSIC_SKILL_IDS.size()):
		var skill := str(CLASSIC_SKILL_IDS[skill_index])
		var saved_level := clampi(int(old_skills.get(skill, _legacy_preparation_skill(old_skills, skill))) + int(old_modifiers.get(skill, 0)), 0, 20)
		skill_fields[skill] = _preparation_skill_field(skill_panel, _localized_skill(skill), saved_level, _refresh_character_editor, int(old_passions.get(skill, 0)), 41.0 + float(skill_index) * 26.0)
		_set_preparation_skill_disabled(skill_fields[skill], old_incapable.has(skill))
	var incapable_panel := _preparation_classic_panel(261, 108)
	incapable_panel.name = "PreparationIncapable"
	skill_stack.add_child(incapable_panel)
	_preparation_classic_caption(incapable_panel, _prep_local("Incapable of", "Yapamadığı işler", "Niezdolność"), 14, 4, 225, 32, 19, CREAM)
	var incapable_text := _preparation_classic_caption(incapable_panel, "", 14, 33, 233, 64, 12, MUTED)
	incapable_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_character_inputs.append({"index": _editing_character_index, "name": name_edit, "first_name": first_name_edit, "last_name": last_name_edit, "age": age, "chronological_age": chronological_age, "childhood": childhood, "adulthood": adulthood, "childhood_note": childhood_note, "adulthood_note": adulthood_note, "sex": sex, "body_type": body_type, "head_type": head_type, "hair": hair, "hair_color": hair_color, "skin": skin, "traits": trait_fields, "conditions": condition_fields, "skills": skill_fields, "modifiers": old_modifiers, "incapable_text": incapable_text, "preview": preview})
	name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	first_name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	last_name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	_refresh_character_editor()


func _localized_skill(skill: String) -> String:
	match skill:
		"shooting": return _prep_local("Shooting", "Atıcılık", "Strzelanie")
		"melee": return _prep_local("Melee", "Yakın Dövüş", "Walka wręcz")
		"construction": return _prep_local("Construction", "İnşaat", "Budownictwo")
		"mining": return _prep_local("Mining", "Madencilik", "Górnictwo")
		"cooking": return _prep_local("Cooking", "Aşçılık", "Gotowanie")
		"plants": return _prep_local("Growing", "Yetiştirme", "Uprawa")
		"animals": return _prep_local("Animals", "Hayvanlar", "Zwierzęta")
		"crafting": return _prep_local("Crafting", "Üretim", "Rzemiosło")
		"artistic": return _prep_local("Artistic", "Sanat", "Sztuka")
		"medical": return _prep_local("Medicine", "Tıp", "Medycyna")
		"social": return _prep_local("Social", "Sosyal", "Relacje")
		"intellectual": return _prep_local("Intellectual", "Entelektüel", "Intelekt")
		"chop": return _prep_local("Chop", "Odunculuk", "Wycinka")
		"mine": return _prep_local("Mine", "Madencilik", "Górnictwo")
		"harvest": return _prep_local("Harvest", "Hasat", "Zbiory")
		"haul": return _prep_local("Haul", "Taşıma", "Transport")
		"build": return _prep_local("Build", "İnşa", "Budowa")
		"research": return _prep_local("Research", "Araştırma", "Badania")
		"treat": return _prep_local("Treat", "Tedavi", "Leczenie")
		"combat": return _prep_local("Combat", "Savaş", "Walka")
		_: return skill.capitalize()


func _preparation_incapable_name(work: String) -> String:
	match work:
		"medical": return _prep_local("Caring", "Bakım", "Opieka")
		"firefighting": return _prep_local("Firefighting", "Yangın söndürme", "Gaszenie pożarów")
		"haul": return _prep_local("Hauling", "Taşıma", "Transport")
		_: return _localized_skill(work)


func _legacy_preparation_skill(old_skills: Dictionary, skill: String) -> int:
	match skill:
		"shooting", "melee": return int(old_skills.get("combat", 0))
		"construction": return int(old_skills.get("build", 0))
		"mining": return int(old_skills.get("mine", 0))
		"plants": return int(old_skills.get("harvest", old_skills.get("chop", 0)))
		"medical": return int(old_skills.get("treat", 0))
		"intellectual": return int(old_skills.get("research", 0))
		_: return 0


func _derive_work_skills(classic: Dictionary) -> Dictionary:
	var skills := classic.duplicate(true)
	skills["chop"] = int(classic.get("plants", 0))
	skills["harvest"] = int(classic.get("plants", 0))
	skills["mine"] = int(classic.get("mining", 0))
	skills["haul"] = 0
	skills["build"] = int(classic.get("construction", 0))
	skills["research"] = int(classic.get("intellectual", 0))
	skills["treat"] = int(classic.get("medical", 0))
	skills["combat"] = maxi(int(classic.get("shooting", 0)), int(classic.get("melee", 0)))
	return skills


func _spec_appearance(spec: Dictionary) -> Dictionary:
	var sex := str(spec.get("sex", "female"))
	var gear: Dictionary = spec.get("starting_gear", {})
	return {"sex": sex, "body_type": clampi(int(spec.get("body_type", 0)), 0, 1),
		"head_type": clampi(int(spec.get("head_type", 0)), 0, 1),
		"hair": _preparation_hair_style(spec),
		"hair_color": str(spec.get("hair_color", HAIR_COLOR_OPTIONS[clampi(int(spec.get("hair_color_index", 1)), 0, HAIR_COLOR_OPTIONS.size() - 1)])),
		"skin": str(spec.get("skin_color", SKIN_OPTIONS[clampi(int(spec.get("skin_index", 0)), 0, SKIN_OPTIONS.size() - 1)])),
		"apparel": str(gear.get("apparel", "none")),
		"hat": str(gear.get("hat", "none")),
		"hat_color": str(gear.get("hat_color", "#bd8a11")),
		"apparel_color": str(gear.get("apparel_color", "#735f50")),
		"shirt": str(gear.get("shirt", "tshirt")),
		"pants": str(gear.get("pants", "pants")),
		"shirt_color": str(gear.get("shirt_color", OUTFIT_OPTIONS[clampi(int(spec.get("outfit_index", 0)), 0, OUTFIT_OPTIONS.size() - 1)])),
		"pants_color": str(gear.get("pants_color", "#5f6768"))}


func _preparation_active_color_key(spec: Dictionary) -> String:
	var gear: Dictionary = spec.get("starting_gear", {})
	match _preparation_appearance_category:
		0: return "hat_color" if str(gear.get("hat", "none")) != "none" else ""
		1: return "hair_color"
		2: return "skin_color"
		4: return "shirt_color" if str(gear.get("shirt", "tshirt")) != "none" else ""
		5: return "pants_color" if str(gear.get("pants", "pants")) != "none" else ""
		6: return "apparel_color" if str(gear.get("apparel", "none")) == "jacket" else ""
	return ""


func _preparation_skin_group(color_code: String) -> int:
	var selected := Color.from_string(color_code, Color(SKIN_OPTIONS[0]))
	var best_index := 0
	var best_distance := INF
	for group in range(3):
		var reference := Color(str(SKIN_OPTIONS[group * 4]))
		var distance := pow(selected.r - reference.r, 2) + pow(selected.g - reference.g, 2) + pow(selected.b - reference.b, 2)
		if distance < best_distance:
			best_distance = distance
			best_index = group
	return best_index


func _set_prepared_color(key: String, next_color: Color, redraw := true, custom := true) -> void:
	if key.is_empty() or _editing_character_index < 0 or _editing_character_index >= character_specs.size():
		return
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var value := "#" + next_color.to_html(false)
	if key in ["skin_color", "hair_color"]:
		spec[key] = value
		spec[key + "_custom"] = custom
	else:
		var gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
		gear[key] = value
		spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	if redraw:
		_show_characters()


func _build_preparation_relationships(body: HBoxContainer) -> void:
	var panel := _preparation_panel(Vector2.ZERO)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var panel_style := _style(Color("#303234"), Color.TRANSPARENT, 0)
	panel_style.set_content_margin_all(0)
	panel.add_theme_stylebox_override("panel", panel_style)
	body.add_child(panel)
	var content := _vbox(7)
	panel.add_child(content)
	var family_section := _preparation_panel(Vector2(0, 355))
	family_section.name = "PreparationColonyRelations"
	family_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	family_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(family_section)
	var family_content := _vbox(5)
	family_section.add_child(family_content)
	family_content.add_child(_label(_prep_local("Colony Relationships", "Koloni ilişkileri", "Relacje kolonii"), 21, CREAM))
	family_content.add_child(_label(_prep_local("Click between two portraits to add or change their bond.", "Bağ eklemek veya değiştirmek için iki portrenin arasına tıkla.", "Kliknij między portretami, aby ustawić więź."), 12, MUTED))
	_preparation_colony_relationship_editor(family_content)
	var other_section := _preparation_panel(Vector2(0, 204))
	other_section.name = "PreparationOtherRelations"
	other_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	other_section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(other_section)
	var other_content := _vbox(5)
	other_section.add_child(other_content)
	other_content.add_child(_label(_prep_local("World Relationships", "Dünya ilişkileri", "Relacje ze światem"), 21, CREAM))
	if world_character_specs.is_empty():
		other_content.add_child(_label(_prep_local("No people outside the colony.", "Koloni dışında kişi yok.", "Brak osób poza kolonią."), 12, MUTED))
	else:
		var world_columns := _hbox(13)
		world_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		world_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
		other_content.add_child(world_columns)
		var world_editor := _vbox(4)
		world_editor.custom_minimum_size.x = 480
		world_columns.add_child(world_editor)
		_preparation_other_relationship_editor(world_editor)
		var world_ledger := _vbox(5)
		world_ledger.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		world_columns.add_child(world_ledger)
		_preparation_relationship_ledger(world_ledger, true)


func _preparation_colony_relationship_editor(parent: VBoxContainer) -> void:
	if colonist_count < 2:
		parent.add_child(_label(_prep_local("Add another colonist to create a relationship.", "İlişki kurmak için bir kolonist daha ekle.", "Dodaj kolejną postać, aby utworzyć relację."), 13, MUTED))
		return
	var scroll := ScrollContainer.new()
	scroll.name = "PreparationColonyPairScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var grid := GridContainer.new()
	grid.name = "PreparationColonyPairGrid"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(grid)
	for first_index in range(colonist_count):
		for second_index in range(first_index + 1, colonist_count):
			var tile := _preparation_focused_relation("c:%d" % first_index, "c:%d" % second_index)
			tile.name = "PreparationColonyPair_%d_%d" % [first_index, second_index]
			tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(tile)
	# A final spacer keeps the last cell at half width when the pair count is odd.
	if int(colonist_count * (colonist_count - 1) / 2) % 2 == 1:
		var spacer := Control.new()
		spacer.custom_minimum_size.x = 1
		grid.add_child(spacer)


func _preparation_other_relationship_editor(parent: VBoxContainer) -> void:
	_external_source_index = clampi(_external_source_index, 0, world_character_specs.size() - 1)
	var source_key := "w:%d" % _external_source_index
	if not _preparation_endpoint_valid(_external_target_key) or _external_target_key == source_key:
		_external_target_key = "c:0"
	var selectors := _hbox(8)
	parent.add_child(selectors)
	var source_button := MenuButton.new()
	source_button.flat = false
	source_button.name = "PreparationWorldSource"
	source_button.text = "%s  ▾" % _prepared_display_name(world_character_specs[_external_source_index])
	source_button.custom_minimum_size = Vector2(190, 27)
	_preparation_equipment_gold_style(source_button)
	selectors.add_child(source_button)
	for world_index in world_character_specs.size():
		source_button.get_popup().add_item(_prepared_display_name(world_character_specs[world_index]), world_index)
	source_button.get_popup().id_pressed.connect(func(world_index: int):
		_external_source_index = world_index
		if _external_target_key == "w:%d" % world_index:
			_external_target_key = "c:0"
		_show_characters())
	var target_button := MenuButton.new()
	target_button.flat = false
	target_button.name = "PreparationWorldTarget"
	target_button.custom_minimum_size = Vector2(190, 27)
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 38
	selectors.add_child(spacer)
	_preparation_equipment_gold_style(target_button)
	selectors.add_child(target_button)
	var targets: Array[String] = []
	for colonist_index in range(colonist_count):
		targets.append("c:%d" % colonist_index)
	for world_index in world_character_specs.size():
		if world_index != _external_source_index:
			targets.append("w:%d" % world_index)
	if not targets.has(_external_target_key):
		_external_target_key = targets[0]
	target_button.text = "%s  ▾" % _preparation_endpoint_name(_external_target_key)
	for target_index in targets.size():
		var target_key := targets[target_index]
		var prefix := _prep_local("Colony", "Koloni", "Kolonia") if target_key.begins_with("c:") else _prep_local("World", "Dünya", "Świat")
		target_button.get_popup().add_item("%s: %s" % [prefix, _preparation_endpoint_name(target_key)], target_index)
	target_button.get_popup().id_pressed.connect(func(target_index: int):
		_external_target_key = targets[target_index]
		_show_characters())
	parent.add_child(_preparation_focused_relation(source_key, _external_target_key))


func _preparation_focused_relation(first_key: String, second_key: String) -> VBoxContainer:
	var panel := _vbox(0)
	panel.name = "PreparationFocusedBond_%s_%s" % [first_key.replace(":", "_"), second_key.replace(":", "_")]
	var tile := PanelContainer.new()
	tile.custom_minimum_size.y = 112
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tile_style := _style(Color("#292b2d"), Color("#414446"), 0)
	tile_style.content_margin_left = 6
	tile_style.content_margin_top = 5
	tile_style.content_margin_right = 6
	tile_style.content_margin_bottom = 5
	tile.add_theme_stylebox_override("panel", tile_style)
	panel.add_child(tile)
	var relation_id := _preparation_relation_between(first_key, second_key)
	var first_role := _preparation_endpoint_relation_label(first_key, relation_id)
	var second_role := _preparation_endpoint_relation_label(second_key, _preparation_reverse_relation(relation_id))
	var row := _hbox(5)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	tile.add_child(row)
	row.add_child(_preparation_other_person_card(_preparation_endpoint_spec(first_key), first_role, first_key.begins_with("w:")))
	var link_column := _vbox(2)
	link_column.alignment = BoxContainer.ALIGNMENT_CENTER
	link_column.custom_minimum_size.x = 166
	row.add_child(link_column)
	if relation_id == "none":
		var picker := MenuButton.new()
		picker.flat = false
		picker.name = "PreparationBondPicker_%s_%s" % [first_key.replace(":", "_"), second_key.replace(":", "_")]
		picker.text = "+"
		picker.tooltip_text = _prep_local("Set bond", "Bağ belirle", "Ustaw więź")
		picker.custom_minimum_size = Vector2(34, 34)
		picker.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		picker.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state in ["normal", "hover", "pressed", "focus"]:
			var color := Color("#303234") if state == "normal" else Color("#424547")
			picker.add_theme_stylebox_override(state, _style(color, Color("#5d6162"), 0))
		picker.add_theme_color_override("font_color", CREAM)
		picker.add_theme_font_size_override("font_size", 20)
		link_column.add_child(picker)
		_preparation_relation_menu(picker, first_key, second_key, true)
	else:
		_preparation_relationship_arrow(link_column, first_role, true, first_key, second_key)
		_preparation_relationship_arrow(link_column, second_role, false, first_key, second_key)
	row.add_child(_preparation_other_person_card(_preparation_endpoint_spec(second_key), second_role, second_key.begins_with("w:")))
	if relation_id != "none":
		var first_copy := first_key
		var second_copy := second_key
		var remove := Button.new()
		remove.name = "PreparationBondRemove_%s_%s" % [first_key.replace(":", "_"), second_key.replace(":", "_")]
		_preparation_style_relation_remove(remove)
		remove.tooltip_text = _prep_local("Remove this bond", "Bu bağı kaldır", "Usuń tę więź")
		remove.pressed.connect(func():
			_set_preparation_relation(first_copy, second_copy, "none")
			_show_characters())
		link_column.add_child(remove)
	return panel


func _preparation_relationship_ledger(parent: VBoxContainer, is_world: bool) -> void:
	parent.add_child(_label(_prep_local("Current relationships", "Mevcut ilişkiler", "Obecne relacje"), 15, CREAM))
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	parent.add_child(scroll)
	var entries := _vbox(3)
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(entries)
	var pairs: Array = []
	if is_world:
		for raw_bond in external_relationships:
			if not raw_bond is Dictionary:
				continue
			var bond: Dictionary = raw_bond
			var first_key := str(bond.get("from", ""))
			var second_key := str(bond.get("to", ""))
			if _preparation_endpoint_valid(first_key) and _preparation_endpoint_valid(second_key) and (first_key.begins_with("w:") or second_key.begins_with("w:")):
				pairs.append({"first": first_key, "second": second_key, "relation": str(bond.get("relation", "none"))})
	else:
		for first_index in range(colonist_count):
			for second_index in range(first_index + 1, colonist_count):
				var relation_id := _preparation_family_relation(first_index, second_index)
				if relation_id != "none":
					pairs.append({"first": "c:%d" % first_index, "second": "c:%d" % second_index, "relation": relation_id})
	for pair_index in pairs.size():
		var pair: Dictionary = pairs[pair_index]
		var first_key := str(pair["first"])
		var second_key := str(pair["second"])
		var relation_id := str(pair["relation"])
		var row := _hbox(3)
		row.name = ("PreparationWorldBond_" if is_world else "PreparationColonyBond_") + str(pair_index + 1)
		entries.add_child(row)
		var select := Button.new()
		select.flat = false
		select.text = _preparation_link_action_label(first_key, second_key, relation_id)
		select.alignment = HORIZONTAL_ALIGNMENT_LEFT
		select.clip_text = true
		select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		select.custom_minimum_size.y = 29
		select.add_theme_font_size_override("font_size", 11)
		for state in ["normal", "hover", "pressed"]:
			select.add_theme_stylebox_override(state, _style(Color("#303234") if state == "normal" else Color("#424547"), Color.TRANSPARENT, 0))
		row.add_child(select)
		select.pressed.connect(func():
			if is_world:
				var world_key := first_key if first_key.begins_with("w:") else second_key
				_external_source_index = int(world_key.substr(2))
				_external_target_key = second_key if world_key == first_key else first_key
			else:
				_colony_relation_first_index = int(first_key.substr(2))
				_colony_relation_second_index = int(second_key.substr(2))
			_show_characters())
		var remove := Button.new()
		remove.name = "PreparationBondRemove_%s_%s" % [first_key.replace(":", "_"), second_key.replace(":", "_")]
		_preparation_style_relation_remove(remove)
		remove.tooltip_text = _prep_local("Remove relationship", "İlişkiyi kaldır", "Usuń relację")
		remove.pressed.connect(func():
			_set_preparation_relation(first_key, second_key, "none")
			_show_characters())
		row.add_child(remove)
	if pairs.is_empty():
		entries.add_child(_label(_prep_local("No relationships yet.", "Henüz ilişki yok.", "Brak relacji."), 12, MUTED))


func _preparation_style_relation_remove(remove: Button) -> void:
	remove.text = "×"
	remove.flat = false
	remove.custom_minimum_size = Vector2(30, 28)
	remove.size_flags_horizontal = Control.SIZE_SHRINK_END
	remove.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	remove.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	remove.add_theme_font_size_override("font_size", 22)
	remove.add_theme_color_override("font_color", CREAM)
	for state in ["normal", "hover", "pressed", "focus"]:
		var remove_style := _style(Color("#353839") if state == "normal" else Color("#4b5051"), Color("#697071"), 0)
		remove_style.set_content_margin_all(0)
		remove.add_theme_stylebox_override(state, remove_style)


func _preparation_other_person_card(spec: Dictionary, role_text: String, is_world: bool) -> Panel:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(110, 100)
	card.add_theme_stylebox_override("panel", _style(Color("#181a1b") if is_world else Color("#3a3c3e"), Color.TRANSPARENT, 0))
	var portrait := PawnPortrait.new()
	portrait.classic_preparation = true
	portrait.position = Vector2(20, 2)
	portrait.size = Vector2(70, 64)
	portrait.appearance = _spec_appearance(spec)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(portrait)
	var person_name := _label(_prepared_display_name(spec), 14, CREAM)
	person_name.position = Vector2(2, 65)
	person_name.size = Vector2(106, 17)
	person_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	person_name.clip_text = true
	card.add_child(person_name)
	var role := _label(role_text, 14, CREAM)
	role.position = Vector2(2, 81)
	role.size = Vector2(106, 18)
	role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role.clip_text = true
	card.add_child(role)
	return card


func _preparation_relationship_arrow(parent: VBoxContainer, title: String, forward: bool, first_key: String, second_key: String) -> void:
	var picker := MenuButton.new()
	picker.name = "PreparationRelationshipPickerForward" if forward else "PreparationRelationshipPickerReverse"
	picker.text = ""
	picker.flat = true
	picker.tooltip_text = _prep_local("Change relationship", "İlişkiyi değiştir", "Zmień relację")
	picker.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	picker.custom_minimum_size = Vector2(160, 30)
	parent.add_child(picker)
	var arrow := RelationshipArrow.new()
	arrow.forward = forward
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picker.add_child(arrow)
	arrow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var caption := _label(title, 14, CREAM)
	arrow.add_child(caption)
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preparation_relation_menu(picker, first_key, second_key, forward)


func _preparation_relation_menu(picker: MenuButton, first_key: String, second_key: String, forward: bool) -> void:
	var relation_ids := ["parent", "child", "grandparent", "grandchild", "partner", "sibling", "friend", "rival"]
	if _preparation_relation_between(first_key, second_key) != "none":
		relation_ids.push_front("none")
	for option_index in relation_ids.size():
		var relation_id := str(relation_ids[option_index])
		var first := first_key if forward else second_key
		var second := second_key if forward else first_key
		var display := _prep_local("Remove relationship", "İlişkiyi kaldır", "Usuń relację") if relation_id == "none" else _preparation_link_action_label(first, second, relation_id)
		picker.get_popup().add_item(display, option_index)
		if not _can_set_preparation_relation(first, second, relation_id):
			picker.get_popup().set_item_disabled(option_index, true)
	picker.get_popup().id_pressed.connect(func(choice_index: int):
		var first := first_key if forward else second_key
		var second := second_key if forward else first_key
		if _set_preparation_relation(first, second, str(relation_ids[choice_index])):
			_show_characters())


func _preparation_picker_relation(relation_id: String, forward: bool, display_swapped: bool) -> String:
	if forward == display_swapped:
		if relation_id == "parent": return "child"
		if relation_id == "child": return "parent"
		if relation_id == "grandparent": return "grandchild"
		if relation_id == "grandchild": return "grandparent"
	return relation_id


func _preparation_plus_placeholder(button: MenuButton, caption: String) -> void:
	if button.tooltip_text.is_empty():
		button.tooltip_text = caption
	var plus := _label("+", 19, CREAM)
	plus.position = Vector2(button.custom_minimum_size.x - 23.0, 2.0)
	plus.size = Vector2(20, 20)
	plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(plus)


func _preparation_relation_label(relation_id: String, forward: bool) -> String:
	match relation_id:
		"friend": return _prep_local("Friend", "Arkadaş", "Przyjaciel")
		"rival": return _prep_local("Rival", "Rakip", "Rywal")
		"partner": return _prep_local("Partner", "Partner", "Partner")
		"parent": return _prep_local("Parent", "Ebeveyn", "Rodzic") if forward else _prep_local("Child", "Çocuk", "Dziecko")
		"child": return _prep_local("Child", "Çocuk", "Dziecko") if forward else _prep_local("Parent", "Ebeveyn", "Rodzic")
		"grandparent": return _prep_local("Grandparent", "Büyük ebeveyn", "Dziadek/babcia") if forward else _prep_local("Grandchild", "Torun", "Wnuk/wnuczka")
		"grandchild": return _prep_local("Grandchild", "Torun", "Wnuk/wnuczka") if forward else _prep_local("Grandparent", "Büyük ebeveyn", "Dziadek/babcia")
		"sibling": return _prep_local("Sibling", "Kardeş", "Rodzeństwo")
		_: return _prep_local("No relation", "İlişki yok", "Brak relacji")


func _preparation_kinship_label(person_index: int, relation_id: String) -> String:
	var female := str(character_specs[person_index].get("sex", "female")) == "female"
	match relation_id:
		"parent": return _prep_local("Mother", "Anne", "Matka") if female else _prep_local("Father", "Baba", "Ojciec")
		"child": return _prep_local("Daughter", "Kız", "Córka") if female else _prep_local("Son", "Oğul", "Syn")
		"grandparent": return _prep_local("Grandmother", "Büyükanne", "Babcia") if female else _prep_local("Grandfather", "Büyükbaba", "Dziadek")
		"grandchild": return _prep_local("Granddaughter", "Kız torun", "Wnuczka") if female else _prep_local("Grandson", "Erkek torun", "Wnuk")
		"sibling": return _prep_local("Sister", "Kız kardeş", "Siostra") if female else _prep_local("Brother", "Erkek kardeş", "Brat")
		_: return _preparation_roster_role(character_specs[person_index])


func _preparation_reverse_relation(relation_id: String) -> String:
	match relation_id:
		"parent": return "child"
		"child": return "parent"
		"grandparent": return "grandchild"
		"grandchild": return "grandparent"
		_: return relation_id


func _preparation_personal_relation_label(person_index: int, relation_id: String) -> String:
	if relation_id in ["parent", "child", "grandparent", "grandchild", "sibling"]:
		return _preparation_kinship_label(person_index, relation_id)
	if relation_id == "partner":
		return _prep_local("Wife", "Eş", "Żona") if str(character_specs[person_index].get("sex", "female")) == "female" else _prep_local("Husband", "Koca", "Mąż")
	return _preparation_relation_label(relation_id, true)


func _preparation_endpoint_valid(key: String) -> bool:
	if key.length() < 3 or key.substr(1, 1) != ":" or not key.substr(2).is_valid_int():
		return false
	var index := int(key.substr(2))
	if key.begins_with("c:"):
		return index >= 0 and index < colonist_count
	if key.begins_with("w:"):
		return index >= 0 and index < world_character_specs.size()
	return false


func _preparation_endpoint_spec(key: String) -> Dictionary:
	if not _preparation_endpoint_valid(key):
		return {}
	return character_specs[int(key.substr(2))] if key.begins_with("c:") else world_character_specs[int(key.substr(2))]


func _preparation_endpoint_name(key: String) -> String:
	return _prepared_display_name(_preparation_endpoint_spec(key))


func _preparation_endpoint_relation_label(key: String, relation_id: String) -> String:
	if relation_id == "none":
		return _prep_local("Colonist", "Kolonist", "Kolonista") if key.begins_with("c:") else _prep_local("World", "Dünya", "Świat")
	var female := str(_preparation_endpoint_spec(key).get("sex", "female")) == "female"
	match relation_id:
		"parent": return _prep_local("Mother", "Anne", "Matka") if female else _prep_local("Father", "Baba", "Ojciec")
		"child": return _prep_local("Daughter", "Kız", "Córka") if female else _prep_local("Son", "Oğul", "Syn")
		"grandparent": return _prep_local("Grandmother", "Büyükanne", "Babcia") if female else _prep_local("Grandfather", "Büyükbaba", "Dziadek")
		"grandchild": return _prep_local("Granddaughter", "Kız torun", "Wnuczka") if female else _prep_local("Grandson", "Erkek torun", "Wnuk")
		"sibling": return _prep_local("Sister", "Kız kardeş", "Siostra") if female else _prep_local("Brother", "Erkek kardeş", "Brat")
		"partner": return _prep_local("Wife", "Eş", "Żona") if female else _prep_local("Husband", "Koca", "Mąż")
		_: return _preparation_relation_label(relation_id, true)


func _preparation_link_action_label(first_key: String, second_key: String, relation_id: String) -> String:
	var first_name := _preparation_endpoint_name(first_key)
	var second_name := _preparation_endpoint_name(second_key)
	var first_role := _preparation_endpoint_relation_label(first_key, relation_id)
	var second_role := _preparation_endpoint_relation_label(second_key, _preparation_reverse_relation(relation_id))
	if relation_id in ["parent", "grandparent"]:
		return "%s: %s  →  %s: %s" % [first_role, first_name, second_role, second_name]
	if relation_id in ["child", "grandchild"]:
		return "%s: %s  →  %s: %s" % [second_role, second_name, first_role, first_name]
	return "%s: %s  ↔  %s: %s" % [first_role, first_name, second_role, second_name]


func _preparation_relation_between(first_key: String, second_key: String) -> String:
	if not _preparation_endpoint_valid(first_key) or not _preparation_endpoint_valid(second_key) or first_key == second_key:
		return "none"
	if first_key.begins_with("c:") and second_key.begins_with("c:"):
		return _preparation_family_relation(int(first_key.substr(2)), int(second_key.substr(2)))
	for raw_bond in external_relationships:
		if not raw_bond is Dictionary:
			continue
		var bond: Dictionary = raw_bond
		if str(bond.get("from", "")) == first_key and str(bond.get("to", "")) == second_key:
			return str(bond.get("relation", "none"))
		if str(bond.get("from", "")) == second_key and str(bond.get("to", "")) == first_key:
			return _preparation_reverse_relation(str(bond.get("relation", "none")))
	return "none"


func _preparation_all_endpoint_keys() -> Array[String]:
	var keys: Array[String] = []
	for index in range(colonist_count):
		keys.append("c:%d" % index)
	for index in world_character_specs.size():
		keys.append("w:%d" % index)
	return keys


func _preparation_is_ancestor_key(older_key: String, younger_key: String, ignore_first := "", ignore_second := "") -> bool:
	var pending: Array[String] = [older_key]
	var seen: Dictionary = {}
	while not pending.is_empty():
		var current: String = pending.pop_back()
		if seen.has(current):
			continue
		seen[current] = true
		for next_key in _preparation_all_endpoint_keys():
			if next_key == current or (current == ignore_first and next_key == ignore_second) or (current == ignore_second and next_key == ignore_first):
				continue
			if _preparation_relation_between(current, next_key) in ["parent", "grandparent"]:
				if next_key == younger_key:
					return true
				pending.append(next_key)
	return false


func _can_set_preparation_relation(first_key: String, second_key: String, relation_id: String) -> bool:
	if not _preparation_endpoint_valid(first_key) or not _preparation_endpoint_valid(second_key) or first_key == second_key:
		return false
	if first_key.begins_with("c:") and second_key.begins_with("c:"):
		return _can_set_starting_relation(int(first_key.substr(2)), int(second_key.substr(2)), relation_id)
	if relation_id == "none":
		return true
	if relation_id not in ["friend", "rival", "partner", "parent", "child", "sibling", "grandparent", "grandchild"]:
		return false
	if relation_id in ["partner", "sibling"]:
		if _preparation_is_ancestor_key(first_key, second_key, first_key, second_key) or _preparation_is_ancestor_key(second_key, first_key, first_key, second_key):
			return false
	if relation_id == "partner":
		for key in [first_key, second_key]:
			for other_key in _preparation_all_endpoint_keys():
				if other_key != first_key and other_key != second_key and _preparation_relation_between(key, other_key) == "partner":
					return false
	if relation_id not in ["parent", "child", "grandparent", "grandchild"]:
		return true
	var older_key := first_key if relation_id in ["parent", "grandparent"] else second_key
	var younger_key := second_key if relation_id in ["parent", "grandparent"] else first_key
	if _preparation_is_ancestor_key(younger_key, older_key, first_key, second_key):
		return false
	var wanted := "parent" if relation_id in ["parent", "child"] else "grandparent"
	var count := 0
	var same_sex := 0
	for other_key in _preparation_all_endpoint_keys():
		if other_key == older_key:
			continue
		if _preparation_relation_between(other_key, younger_key) == wanted:
			count += 1
			if str(_preparation_endpoint_spec(other_key).get("sex", "female")) == str(_preparation_endpoint_spec(older_key).get("sex", "female")):
				same_sex += 1
	if count >= (2 if wanted == "parent" else 4) or same_sex >= (1 if wanted == "parent" else 2):
		return false
	return true


func _set_preparation_relation(first_key: String, second_key: String, relation_id: String) -> bool:
	if not _can_set_preparation_relation(first_key, second_key, relation_id):
		return false
	if first_key.begins_with("c:") and second_key.begins_with("c:"):
		return _set_starting_relation(int(first_key.substr(2)), int(second_key.substr(2)), relation_id)
	return _set_external_relation(first_key, second_key, relation_id)


func _set_external_relation(first_key: String, second_key: String, relation_id: String) -> bool:
	if not _can_set_preparation_relation(first_key, second_key, relation_id):
		return false
	if relation_id in ["parent", "child", "grandparent", "grandchild"]:
		var older_key := first_key if relation_id in ["parent", "grandparent"] else second_key
		var younger_key := second_key if relation_id in ["parent", "grandparent"] else first_key
		var older_spec := _preparation_endpoint_spec(older_key).duplicate(true)
		var younger_spec := _preparation_endpoint_spec(younger_key)
		var gap := 32 if relation_id in ["grandparent", "grandchild"] else 16
		older_spec["chronological_age"] = maxi(int(older_spec.get("chronological_age", older_spec.get("age", 25))), int(younger_spec.get("chronological_age", younger_spec.get("age", 25))) + gap)
		if older_key.begins_with("c:"):
			character_specs[int(older_key.substr(2))] = older_spec
		else:
			world_character_specs[int(older_key.substr(2))] = older_spec
	for bond_index in range(external_relationships.size() - 1, -1, -1):
		var bond: Dictionary = external_relationships[bond_index]
		if (str(bond.get("from", "")) == first_key and str(bond.get("to", "")) == second_key) or (str(bond.get("from", "")) == second_key and str(bond.get("to", "")) == first_key):
			external_relationships.remove_at(bond_index)
	if relation_id != "none":
		external_relationships.append({"from": first_key, "to": second_key, "relation": relation_id})
	return true


func _preparation_pair_action_label(first_index: int, second_index: int, relation_id: String) -> String:
	var first_name := _prepared_display_name(character_specs[first_index])
	var second_name := _prepared_display_name(character_specs[second_index])
	match relation_id:
		"parent": return _prep_local("Parent: %s → Child: %s", "Ebeveyn: %s → Çocuk: %s", "Rodzic: %s → Dziecko: %s") % [first_name, second_name]
		"child": return _prep_local("Parent: %s → Child: %s", "Ebeveyn: %s → Çocuk: %s", "Rodzic: %s → Dziecko: %s") % [second_name, first_name]
		"grandparent": return _prep_local("Grandparent: %s → Grandchild: %s", "Büyük ebeveyn: %s → Torun: %s", "Dziadek/babcia: %s → Wnuk/wnuczka: %s") % [first_name, second_name]
		"grandchild": return _prep_local("Grandparent: %s → Grandchild: %s", "Büyük ebeveyn: %s → Torun: %s", "Dziadek/babcia: %s → Wnuk/wnuczka: %s") % [second_name, first_name]
		"partner": return _prep_local("Spouses: %s ↔ %s", "Eşler: %s ↔ %s", "Małżonkowie: %s ↔ %s") % [first_name, second_name]
		"sibling": return _prep_local("Siblings: %s ↔ %s", "Kardeşler: %s ↔ %s", "Rodzeństwo: %s ↔ %s") % [first_name, second_name]
		"friend": return _prep_local("Friends: %s ↔ %s", "Arkadaşlar: %s ↔ %s", "Przyjaciele: %s ↔ %s") % [first_name, second_name]
		"rival": return _prep_local("Rivals: %s ↔ %s", "Rakipler: %s ↔ %s", "Rywale: %s ↔ %s") % [first_name, second_name]
		_: return ""


func _can_set_starting_relation(first_index: int, second_index: int, relation_id: String) -> bool:
	if first_index < 0 or second_index < 0 or first_index >= colonist_count or second_index >= colonist_count or first_index == second_index:
		return false
	if relation_id == "none":
		return true
	if relation_id not in ["friend", "rival", "partner", "parent", "child", "sibling", "grandparent", "grandchild"]:
		return false
	if relation_id in ["partner", "sibling"]:
		if _preparation_is_ancestor_key("c:%d" % first_index, "c:%d" % second_index, "c:%d" % first_index, "c:%d" % second_index) or _preparation_is_ancestor_key("c:%d" % second_index, "c:%d" % first_index, "c:%d" % second_index, "c:%d" % first_index):
			return false
	if relation_id == "partner":
		for person_index in [first_index, second_index]:
			for other_index in range(colonist_count):
				if other_index != first_index and other_index != second_index and _preparation_family_relation(person_index, other_index) == "partner":
					return false
			for world_index in world_character_specs.size():
				if _preparation_relation_between("c:%d" % person_index, "w:%d" % world_index) == "partner":
					return false
	if relation_id not in ["parent", "child", "grandparent", "grandchild"]:
		return true
	var older_index := first_index if relation_id in ["parent", "grandparent"] else second_index
	var younger_index := second_index if relation_id in ["parent", "grandparent"] else first_index
	if _preparation_is_ancestor_key("c:%d" % younger_index, "c:%d" % older_index, "c:%d" % first_index, "c:%d" % second_index):
		return false
	var parent_count := 0
	var same_sex_count := 0
	for other_index in range(colonist_count):
		if other_index == older_index:
			continue
		var related_as := _preparation_family_relation(other_index, younger_index)
		if related_as == ("parent" if relation_id in ["parent", "child"] else "grandparent"):
			parent_count += 1
			if str(character_specs[other_index].get("sex", "female")) == str(character_specs[older_index].get("sex", "female")):
				same_sex_count += 1
	for world_index in world_character_specs.size():
		if _preparation_relation_between("w:%d" % world_index, "c:%d" % younger_index) == ("parent" if relation_id in ["parent", "child"] else "grandparent"):
			parent_count += 1
			if str(world_character_specs[world_index].get("sex", "female")) == str(character_specs[older_index].get("sex", "female")):
				same_sex_count += 1
	if parent_count >= (2 if relation_id in ["parent", "child"] else 4):
		return false
	if same_sex_count >= (1 if relation_id in ["parent", "child"] else 2):
		return false
	return true


func _preparation_is_ancestor(older_index: int, younger_index: int) -> bool:
	var descendants: Array = [older_index]
	var seen: Dictionary = {}
	while not descendants.is_empty():
		var next_index := int(descendants.pop_back())
		if seen.has(next_index):
			continue
		seen[next_index] = true
		for other_index in range(colonist_count):
			if _preparation_family_relation(next_index, other_index) in ["parent", "grandparent"]:
				if other_index == younger_index:
					return true
				descendants.append(other_index)
	return false


func _set_starting_relation(first_index: int, second_index: int, relation_id: String) -> bool:
	if not _can_set_starting_relation(first_index, second_index, relation_id):
		return false
	if relation_id in ["parent", "child", "grandparent", "grandchild"]:
		var parent_index := first_index if relation_id in ["parent", "grandparent"] else second_index
		var child_index := second_index if relation_id in ["parent", "grandparent"] else first_index
		var parent_spec: Dictionary = character_specs[parent_index].duplicate(true)
		var child_spec: Dictionary = character_specs[child_index]
		var minimum_parent_age := int(child_spec.get("chronological_age", child_spec.get("age", 25))) + (32 if relation_id in ["grandparent", "grandchild"] else 16)
		parent_spec["chronological_age"] = maxi(int(parent_spec.get("chronological_age", parent_spec.get("age", 25))), minimum_parent_age)
		character_specs[parent_index] = parent_spec
	var lower := mini(first_index, second_index)
	var higher := maxi(first_index, second_index)
	var normalized_relation := relation_id
	if first_index > second_index:
		if relation_id == "parent": normalized_relation = "child"
		elif relation_id == "child": normalized_relation = "parent"
		elif relation_id == "grandparent": normalized_relation = "grandchild"
		elif relation_id == "grandchild": normalized_relation = "grandparent"
	for pair_index in [lower, higher]:
		var spec: Dictionary = character_specs[pair_index].duplicate(true)
		var relationships: Dictionary = spec.get("starting_relationships", {}).duplicate(true)
		relationships.erase(str(higher if pair_index == lower else lower))
		if pair_index == lower and normalized_relation != "none":
			relationships[str(higher)] = normalized_relation
		spec["starting_relationships"] = relationships
		character_specs[pair_index] = spec
	_normalize_preparation_relation_ages()
	return true


func _normalize_preparation_relation_ages() -> void:
	# Editing a direct link can raise a child's age. Propagate that change up
	# every existing ancestor chain so the entire crew remains a valid setup.
	for pass_index in range(colonist_count):
		var changed := false
		for older_index in range(colonist_count):
			for younger_index in range(colonist_count):
				var relation := _preparation_family_relation(older_index, younger_index)
				if relation not in ["parent", "grandparent"]:
					continue
				var younger: Dictionary = character_specs[younger_index]
				var older: Dictionary = character_specs[older_index]
				var minimum_age := int(younger.get("chronological_age", younger.get("age", 25))) + (32 if relation == "grandparent" else 16)
				if int(older.get("chronological_age", older.get("age", 25))) < minimum_age:
					var updated: Dictionary = older.duplicate(true)
					updated["chronological_age"] = minimum_age
					character_specs[older_index] = updated
					changed = true
		if not changed:
			break


func _preparation_family_relation(first_index: int, second_index: int) -> String:
	if first_index == second_index:
		return "none"
	var lower := mini(first_index, second_index)
	var higher := maxi(first_index, second_index)
	var known: Dictionary = character_specs[lower].get("starting_relationships", {})
	var relation := str(known.get(str(higher), "none"))
	if relation == "none":
		var reverse_known: Dictionary = character_specs[higher].get("starting_relationships", {})
		relation = str(reverse_known.get(str(lower), "none"))
		if relation == "parent": relation = "child"
		elif relation == "child": relation = "parent"
		elif relation == "grandparent": relation = "grandchild"
		elif relation == "grandchild": relation = "grandparent"
	if first_index > second_index:
		if relation == "parent":
			return "child"
		if relation == "child":
			return "parent"
		if relation == "grandparent":
			return "grandchild"
		if relation == "grandchild":
			return "grandparent"
	return relation


func _preparation_family_person_card(graph: FamilyGraph, position: Vector2, person_index: int, kinship := "") -> void:
	var spec: Dictionary = character_specs[person_index]
	var card := PanelContainer.new()
	card.name = "PreparationRelationshipPerson_%d" % person_index
	card.position = position
	card.custom_minimum_size = Vector2(76, 76)
	card.size = Vector2(76, 76)
	var style := _style(Color("#393b3d") if position.y < 90.0 or kinship.is_empty() else Color("#171819"), Color.TRANSPARENT, 0)
	style.set_content_margin_all(0)
	card.add_theme_stylebox_override("panel", style)
	graph.add_child(card)
	# PanelContainer positions its direct children. This canvas keeps the remove
	# control on the portrait instead of stretching it across the graph.
	var canvas := Control.new()
	canvas.custom_minimum_size = Vector2(76, 76)
	card.add_child(canvas)
	var portrait := PawnPortrait.new()
	portrait.classic_preparation = true
	portrait.position = Vector2(3, 0)
	portrait.size = Vector2(70, 47)
	portrait.appearance = _spec_appearance(spec)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(portrait)
	var name_label := _label(_prepared_display_name(spec), 11, CREAM)
	name_label.position = Vector2(2, 47)
	name_label.size = Vector2(72, 15)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.clip_text = true
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(name_label)
	var role := _preparation_kinship_label(person_index, kinship) if not kinship.is_empty() else _prep_local("Colonist", "Kolonist", "Kolonista")
	var role_label := _label(role, 9, MUTED)
	role_label.position = Vector2(2, 61)
	role_label.size = Vector2(72, 13)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.clip_text = true
	role_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(role_label)
	var remove_actions: Array = []
	for other_index in range(colonist_count):
		if other_index == person_index:
			continue
		var relation_id := _preparation_family_relation(person_index, other_index)
		if relation_id == "none":
			continue
		remove_actions.append(other_index)
	if not remove_actions.is_empty():
		var remove_menu := MenuButton.new()
		remove_menu.name = "PreparationRelationshipRemove_%d" % person_index
		remove_menu.text = "×"
		remove_menu.flat = true
		remove_menu.position = Vector2(58, 1)
		remove_menu.size = Vector2(17, 18)
		remove_menu.tooltip_text = _prep_local("Remove a relationship", "İlişkiyi kaldır", "Usuń relację")
		remove_menu.add_theme_font_size_override("font_size", 16)
		remove_menu.add_theme_color_override("font_color", Color("#dedbd4"))
		for state in ["normal", "hover", "pressed", "focus"]:
			remove_menu.add_theme_stylebox_override(state, StyleBoxEmpty.new())
		canvas.add_child(remove_menu)
		for action_index in remove_actions.size():
			var other_index := int(remove_actions[action_index])
			var other_name := _prepared_display_name(character_specs[other_index])
			var relation_id := _preparation_family_relation(person_index, other_index)
			remove_menu.get_popup().add_item(_prep_local("Remove %s: %s", "%s ilişkisini kaldır: %s", "Usuń %s: %s") % [_preparation_personal_relation_label(person_index, relation_id), other_name], action_index)
		remove_menu.get_popup().id_pressed.connect(func(choice_index: int):
			if _set_starting_relation(person_index, int(remove_actions[choice_index]), "none"):
				_show_characters())


func _preparation_family_add_slot(graph: FamilyGraph, position: Vector2, anchor_index: int, slot_role: String) -> void:
	var add := MenuButton.new()
	add.position = position
	add.custom_minimum_size = Vector2(90, 92)
	add.size = Vector2(90, 92)
	add.flat = false
	add.text = ""
	add.tooltip_text = _prep_local("Add parent", "Ebeveyn ekle", "Dodaj rodzica") if slot_role == "parent" else _prep_local("Add bond", "Bağ ekle", "Dodaj więź")
	add.add_theme_font_size_override("font_size", 12)
	add.add_theme_color_override("font_color", MUTED)
	for state in ["normal", "hover", "pressed"]:
		var style := _style(Color("#303234") if position.y < 100.0 else Color("#202123") if state == "normal" else Color("#3b3d3f"), Color.TRANSPARENT, 0)
		style.set_content_margin_all(2)
		add.add_theme_stylebox_override(state, style)
	graph.add_child(add)
	var add_icon_bg := Panel.new()
	add_icon_bg.position = Vector2(77, 6)
	add_icon_bg.size = Vector2(11, 11)
	add_icon_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_style := _style(Color("#b8bab9"), Color.TRANSPARENT, 0)
	icon_style.set_content_margin_all(0)
	add_icon_bg.add_theme_stylebox_override("panel", icon_style)
	add.add_child(add_icon_bg)
	var add_icon := _label("+", 12, Color("#26282a"))
	add_icon.position = Vector2(0, -4)
	add_icon.size = Vector2(11, 15)
	add_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_icon_bg.add_child(add_icon)
	var actions: Array = []
	var popup := add.get_popup()
	var anchor_name := _prepared_display_name(character_specs[anchor_index])
	for other_index in range(colonist_count):
		if other_index == anchor_index or _preparation_family_relation(anchor_index, other_index) in ["parent", "child", "sibling"]:
			continue
		var other_name := _prepared_display_name(character_specs[other_index])
		var roles := ["parent"] if slot_role == "parent" else ["child", "sibling"] if slot_role == "child" else ["child", "parent", "sibling"]
		for role in roles:
			var relation_from_anchor := "child" if role == "parent" else "parent" if role == "child" else "sibling"
			if not _can_set_starting_relation(anchor_index, other_index, relation_from_anchor):
				continue
			var relation_label := ""
			if role == "sibling":
				relation_label = _prep_local("Siblings: %s  ↔  %s", "Kardeşler: %s  ↔  %s", "Rodzeństwo: %s  ↔  %s") % [anchor_name, other_name]
			else:
				var parent_name := other_name if role == "parent" else anchor_name
				var child_name := anchor_name if role == "parent" else other_name
				relation_label = _prep_local("Parent: %s  →  Child: %s", "Ebeveyn: %s  →  Çocuk: %s", "Rodzic: %s  →  Dziecko: %s") % [parent_name, child_name]
			popup.add_item(relation_label, actions.size())
			actions.append({"other": other_index, "relation": relation_from_anchor})
	if actions.is_empty():
		popup.add_item(_prep_local("No available colonist", "Uygun kolonist yok", "Brak dostępnej postaci"))
		popup.set_item_disabled(0, true)
	else:
		popup.id_pressed.connect(func(id: int):
			var action: Dictionary = actions[id]
			var other := int(action["other"])
			var relation := str(action["relation"])
			_set_starting_relation(anchor_index, other, relation)
			_show_characters())


func _build_preparation_family_graph(graph: FamilyGraph) -> void:
	graph.clusters.clear()
	graph.edges.clear()
	graph.families.clear()
	var layers: Array[int] = []
	for person_index in range(colonist_count):
		layers.append(0)
	# The same colonist must occupy exactly one card, even when they have more
	# than one parent, child, or grandchild connection.
	for pass_index in range(colonist_count):
		var changed := false
		for older_index in range(colonist_count):
			for younger_index in range(colonist_count):
				var relation := _preparation_family_relation(older_index, younger_index)
				var depth := 2 if relation == "grandparent" else 1 if relation == "parent" else 0
				if depth > 0 and layers[younger_index] < layers[older_index] + depth:
					layers[younger_index] = layers[older_index] + depth
					changed = true
		if not changed:
			break
	var max_layer := 0
	for layer in layers:
		max_layer = maxi(max_layer, layer)
	var rows: Array = []
	for layer in range(max_layer + 1):
		rows.append([])
	for person_index in range(colonist_count):
		(rows[layers[person_index]] as Array).append(person_index)
	var widest := 1
	for row in rows:
		widest = maxi(widest, (row as Array).size())
	var positions: Dictionary = {}
	var graph_height := maxf(172.0, float(max_layer * 94 + 84))
	graph.custom_minimum_size = Vector2(maxf(0.0, float(widest * 86 + 12)), graph_height)
	graph.clusters.append(Rect2(0, 0, graph.custom_minimum_size.x, graph_height))
	for layer in rows.size():
		var people: Array = rows[layer]
		for slot in people.size():
			var person_index := int(people[slot])
			var position := Vector2(8.0 + float(widest - people.size()) * 43.0 + float(slot) * 86.0, (float(layer) * 94.0 + 8.0) if max_layer > 0 else 48.0)
			positions[person_index] = position
			var role := ""
			for other_index in range(colonist_count):
				if _preparation_family_relation(person_index, other_index) == "parent":
					role = "parent"
					break
				if _preparation_family_relation(person_index, other_index) == "grandparent":
					role = "grandparent"
				elif _preparation_family_relation(person_index, other_index) == "child" and role.is_empty():
					role = "child"
			_preparation_family_person_card(graph, position, person_index, role)
	var children_by_parents: Dictionary = {}
	for child_index in range(colonist_count):
		var parents: Array = []
		for parent_index in range(colonist_count):
			if _preparation_family_relation(parent_index, child_index) == "parent":
				parents.append(parent_index)
		if parents.is_empty():
			continue
		parents.sort()
		var key := str(parents)
		if not children_by_parents.has(key):
			children_by_parents[key] = {"parents": parents, "children": []}
		(children_by_parents[key]["children"] as Array).append(child_index)
	for group in children_by_parents.values():
		var parent_centers: Array = []
		var child_centers: Array = []
		for person_index in group["parents"]:
			parent_centers.append((positions[person_index] as Vector2) + Vector2(38, 76))
		for person_index in group["children"]:
			child_centers.append((positions[person_index] as Vector2) + Vector2(38, 0))
		graph.families.append({"parents": parent_centers, "children": child_centers})
	for first_index in range(colonist_count):
		for second_index in range(first_index + 1, colonist_count):
			var relation := _preparation_family_relation(first_index, second_index)
			if relation in ["grandparent", "grandchild"]:
				var older_index := first_index if relation == "grandparent" else second_index
				var younger_index := second_index if relation == "grandparent" else first_index
				graph.edges.append({"start": (positions[older_index] as Vector2) + Vector2(38, 76), "finish": (positions[younger_index] as Vector2) + Vector2(38, 0), "active": true, "kind": "grandparent"})
			elif relation == "sibling" and layers[first_index] == layers[second_index]:
				graph.edges.append({"start": (positions[first_index] as Vector2) + Vector2(76, 38), "finish": (positions[second_index] as Vector2) + Vector2(0, 38), "active": true, "kind": "sibling"})
	graph.queue_redraw()


func _build_preparation_equipment(body: HBoxContainer) -> void:
	var gear_columns := _hbox(12)
	gear_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gear_columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(gear_columns)
	if starting_cargo.is_empty():
		starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	var available_panel := _preparation_equipment_panel()
	available_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	available_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gear_columns.add_child(available_panel)
	var available := _vbox(0)
	available_panel.add_child(available)
	var filters := _hbox(10)
	available.add_child(filters)
	var category_labels := [
		_prep_local("All categories", "Tüm kategoriler", "Wszystkie kategorie"),
		_prep_local("Resources", "Kaynaklar", "Surowce"),
		_prep_local("Apparel", "Giysiler", "Odzież"),
		_prep_local("Weapons", "Silahlar", "Broń")
	]
	var category := MenuButton.new()
	category.flat = false
	category.name = "PreparationCategoryFilter"
	category.text = "%s  ▾" % category_labels[clampi(_equipment_category_filter, 0, category_labels.size() - 1)]
	category.custom_minimum_size = Vector2(140, 28)
	_preparation_equipment_gold_style(category)
	for index in category_labels.size():
		category.get_popup().add_item(str(category_labels[index]), index)
	filters.add_child(category)
	var material_labels := [
		_prep_local("All materials", "Tüm malzemeler", "Wszystkie materiały"),
		_prep_local("Wood", "Ahşap", "Drewno"),
		_prep_local("Stone", "Taş", "Kamień"),
		_prep_local("Cloth", "Kumaş", "Tkanina"),
		_prep_local("Metal", "Metal", "Metal"),
		_prep_local("Organic", "Organik", "Organiczne")
	]
	var material := MenuButton.new()
	material.flat = false
	material.name = "PreparationMaterialFilter"
	material.text = "%s  ▾" % material_labels[clampi(_equipment_material_filter, 0, material_labels.size() - 1)]
	material.custom_minimum_size = Vector2(160, 28)
	_preparation_equipment_gold_style(material)
	for index in material_labels.size():
		material.get_popup().add_item(str(material_labels[index]), index)
	filters.add_child(material)
	available.add_child(_preparation_equipment_gap(13))
	var catalog_header := PanelContainer.new()
	catalog_header.custom_minimum_size.y = 19
	var header_style := _style(Color("#1f2022"), Color.TRANSPARENT, 0)
	header_style.content_margin_left = 63
	header_style.content_margin_right = 12
	header_style.content_margin_top = 0
	header_style.content_margin_bottom = 0
	catalog_header.add_theme_stylebox_override("panel", header_style)
	available.add_child(catalog_header)
	var header_contents := _hbox(0)
	catalog_header.add_child(header_contents)
	var item_header := _label(_prep_local("Name⌄", "Ad⌄", "Nazwa⌄"), 11, Color("#b5b5b5"))
	item_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_contents.add_child(item_header)
	var cost_header := _label(_prep_local("Cost", "Maliyet", "Koszt"), 11, Color("#b5b5b5"))
	cost_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cost_header.custom_minimum_size.x = 43
	header_contents.add_child(cost_header)
	var catalog_back := _preparation_equipment_list_back()
	catalog_back.size_flags_vertical = Control.SIZE_EXPAND_FILL
	available.add_child(catalog_back)
	var catalog_scroll := _preparation_equipment_scroll()
	catalog_back.add_child(catalog_scroll)
	var catalog_rows := _vbox(0)
	catalog_rows.custom_minimum_size.x = 446
	catalog_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	catalog_scroll.add_child(catalog_rows)
	# Only offer items that the current simulation can actually use as cargo.
	var catalog_ids: Array = GameModel.PREPARATION_CARGO_IDS
	var visible_catalog: Array[String] = []
	for item_id in catalog_ids:
		if _equipment_item_visible(item_id, _equipment_category_filter, _equipment_material_filter):
			visible_catalog.append(item_id)
	if not visible_catalog.is_empty() and _selected_equipment_catalog_id not in visible_catalog:
		_selected_equipment_catalog_id = visible_catalog[0]
	for item_id in visible_catalog:
		var chosen_id: String = item_id
		catalog_rows.add_child(_preparation_equipment_catalog_row(chosen_id, catalog_rows.get_child_count() % 2, chosen_id == _selected_equipment_catalog_id))
	category.get_popup().id_pressed.connect(func(index: int):
		_equipment_category_filter = index
		_show_characters())
	material.get_popup().id_pressed.connect(func(index: int):
		_equipment_material_filter = index
		_show_characters())
	available.add_child(_preparation_equipment_gap(13))
	var add_equipment := _setup_button(_prep_local("Add Equipment", "Ekipman Ekle", "Dodaj wyposażenie"), func(): _adjust_starting_cargo(_selected_equipment_catalog_id, 1), true, Vector2(160, 35))
	_preparation_equipment_gold_style(add_equipment)
	add_equipment.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	available.add_child(add_equipment)
	var selected_panel := _preparation_equipment_panel()
	selected_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gear_columns.add_child(selected_panel)
	var selected := _vbox(0)
	selected_panel.add_child(selected)
	var selected_back := _preparation_equipment_list_back()
	selected_back.size_flags_vertical = Control.SIZE_EXPAND_FILL
	selected.add_child(selected_back)
	var selected_scroll := _preparation_equipment_scroll()
	selected_back.add_child(selected_scroll)
	var selected_rows := _vbox(0)
	selected_rows.custom_minimum_size.x = 446
	selected_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected_scroll.add_child(selected_rows)
	for cargo_id in starting_cargo.keys():
		var chosen_id := str(cargo_id)
		if not GameModel.PREPARATION_CARGO_IDS.has(chosen_id):
			continue
		var quantity := int(starting_cargo.get(chosen_id, 0))
		if quantity <= 0:
			continue
		selected_rows.add_child(_preparation_equipment_selected_row(chosen_id, quantity, selected_rows.get_child_count() % 2))
	selected.add_child(_preparation_equipment_gap(13))
	var remove_all := _setup_button(_prep_local("Remove All", "Tümünü Kaldır", "Usuń wszystko"), _clear_starting_cargo, true, Vector2(160, 35))
	_preparation_equipment_gold_style(remove_all)
	remove_all.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	selected.add_child(remove_all)


func _preparation_equipment_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 567)
	var style := _style(Color("#232526"), Color("#3b3d3f"), 0)
	style.content_margin_left = 12
	style.content_margin_top = 12
	style.content_margin_right = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	if _preparation_grain != null:
		var grain_layer := PrepGrain.new()
		grain_layer.grain = _preparation_grain
		grain_layer.modulate.a = 0.23
		panel.add_child(grain_layer)
	return panel


func _preparation_equipment_list_back() -> PanelContainer:
	var back := PanelContainer.new()
	var style := _style(Color("#18181c"), Color.TRANSPARENT, 0)
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	back.add_theme_stylebox_override("panel", style)
	return back


func _preparation_equipment_scroll() -> ScrollContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	return scroll


func _preparation_equipment_gap(height: float) -> Control:
	var gap := Control.new()
	gap.custom_minimum_size.y = height
	return gap


func _preparation_equipment_gold_style(button: Button) -> void:
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color("#efe8da"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color("#efe8da"))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	for state in ["normal", "hover", "pressed"]:
		var fill := Color("#6a522f") if state == "normal" else Color("#80633a") if state == "hover" else Color("#574328")
		var style := _style(fill, Color("#392a1b"), 0)
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 2
		style.border_width_bottom = 3
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		button.add_theme_stylebox_override(state, style)


func _preparation_equipment_catalog_row(item_id: String, row_index: int, selected: bool) -> Button:
	var row := Button.new()
	row.name = "PreparationCatalogRow_%s" % item_id
	row.custom_minimum_size.y = 42
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.focus_mode = Control.FOCUS_NONE
	for state in ["normal", "hover", "pressed"]:
		var fill := Color("#0c0c0c") if selected else Color("#313133") if row_index % 2 == 0 else Color("#36383a")
		if state == "hover" and not selected:
			fill = Color("#414345")
		var style := _style(fill, Color.TRANSPARENT, 0)
		style.content_margin_left = 0
		style.content_margin_top = 0
		style.content_margin_right = 0
		style.content_margin_bottom = 0
		row.add_theme_stylebox_override(state, style)
	row.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	row.pressed.connect(func():
		_selected_equipment_catalog_id = item_id
		for sibling in row.get_parent().get_children():
			if sibling is Button and str(sibling.name).begins_with("PreparationCatalogRow_"):
				var row_selected := sibling == row
				for style_name in ["normal", "hover", "pressed"]:
					var fill := Color("#0c0c0c") if row_selected else Color("#313133") if sibling.get_index() % 2 == 0 else Color("#36383a")
					var selection_style := _style(fill, Color.TRANSPARENT, 0)
					selection_style.set_content_margin_all(0)
					sibling.add_theme_stylebox_override(style_name, selection_style))
	row.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			var click := event as InputEventMouseButton
			if click.pressed and click.button_index == MOUSE_BUTTON_LEFT and click.double_click:
				row.accept_event()
				_selected_equipment_catalog_id = item_id
				_adjust_starting_cargo(item_id, 1))
	var contents := _hbox(16)
	contents.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(contents)
	contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	contents.offset_left = 12
	contents.offset_top = 3
	contents.offset_right = -12
	contents.offset_bottom = -3
	contents.add_child(_preparation_equipment_icon(item_id))
	var name_label := _label(_cargo_label(item_id), 14, Color("#c7c7c7"))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	contents.add_child(name_label)
	var cost := _label(_preparation_equipment_display_cost(item_id), 14, Color("#c7c7c7"))
	cost.custom_minimum_size.x = 46
	cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cost.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	contents.add_child(cost)
	return row


func _preparation_equipment_selected_row(item_id: String, quantity: int, row_index: int) -> PanelContainer:
	var row := PanelContainer.new()
	row.name = "PreparationCargoRow_%s" % item_id
	row.custom_minimum_size.y = 42
	var fill := Color("#313133") if row_index % 2 == 0 else Color("#36383a")
	var style := _style(fill, Color.TRANSPARENT, 0)
	style.content_margin_left = 14
	style.content_margin_top = 3
	style.content_margin_right = 28
	style.content_margin_bottom = 3
	row.add_theme_stylebox_override("panel", style)
	var contents := _hbox(12)
	row.add_child(contents)
	contents.add_child(_preparation_equipment_icon(item_id))
	var name_label := _label(_cargo_label(item_id), 14, Color("#c7c7c7"))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	contents.add_child(name_label)
	var stepper := _hbox(0)
	contents.add_child(stepper)
	var previous := Button.new()
	var next := Button.new()
	var field := LineEdit.new()
	stepper.add_child(previous)
	stepper.add_child(field)
	stepper.add_child(next)
	previous.text = "◀"
	next.text = "▶"
	for arrow in [previous, next]:
		arrow.custom_minimum_size = Vector2(10, 28)
		arrow.flat = true
		arrow.add_theme_font_size_override("font_size", 12)
		arrow.add_theme_color_override("font_color", Color("#a3a4a4"))
		arrow.add_theme_color_override("font_hover_color", Color("#e0e0e0"))
		arrow.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	previous.pressed.connect(func(): _adjust_starting_cargo(item_id, -1))
	next.pressed.connect(func(): _adjust_starting_cargo(item_id, 1))
	field.text = str(quantity)
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.custom_minimum_size = Vector2(60, 28)
	field.add_theme_color_override("font_color", Color("#dbdbdb"))
	field.add_theme_font_size_override("font_size", 14)
	field.text_submitted.connect(func(_text: String): _preparation_equipment_commit_quantity(item_id, field))
	field.focus_exited.connect(func(): _preparation_equipment_commit_quantity(item_id, field))
	for field_state in ["normal", "focus", "read_only"]:
		var field_style := _style(Color("#121416"), Color("#202224"), 0)
		field_style.content_margin_left = 0
		field_style.content_margin_right = 0
		field_style.content_margin_top = 2
		field_style.content_margin_bottom = 2
		field.add_theme_stylebox_override(field_state, field_style)
	return row


func _preparation_equipment_commit_quantity(item_id: String, field: LineEdit) -> void:
	if not is_instance_valid(field):
		return
	var previous := int(starting_cargo.get(item_id, 0))
	var quantity := clampi(int(field.text) if field.text.is_valid_int() else previous, 0, 999)
	field.text = str(quantity)
	if quantity == previous:
		return
	starting_cargo[item_id] = quantity
	if quantity == 0:
		call_deferred("_show_characters")
	else:
		_refresh_character_points()


func _preparation_equipment_display_cost(item_id: String) -> String:
	if GameModel.PREPARATION_DISPLAY_COSTS.has(item_id):
		var value := float(GameModel.PREPARATION_DISPLAY_COSTS[item_id])
		return str(int(value)) if is_equal_approx(value, floorf(value)) else str(value)
	return str(ITEM_PRICES.get(item_id, 1))


func _preparation_equipment_icon(item_id: String) -> Control:
	var apparel_id := item_id
	if apparel_id in ["tshirt", "pants", "jacket", "cap", "brim_hat"]:
		var apparel := ApparelIconScript.new()
		apparel.item_id = apparel_id
		apparel.tint = Color("#798c87")
		apparel.custom_minimum_size = Vector2(36, 36)
		return apparel
	var texture_path := ""
	match item_id:
		"wood": texture_path = "res://assets/item_wood.svg"
		"stone", "steel": texture_path = "res://assets/item_stone.svg"
		"silver": texture_path = "res://assets/item_silver.svg"
		"food": texture_path = "res://assets/item_food.svg"
	if texture_path != "":
		var texture_icon := TextureRect.new()
		texture_icon.texture = load(texture_path)
		texture_icon.custom_minimum_size = Vector2(36, 36)
		texture_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if item_id == "steel":
			texture_icon.modulate = Color("#b1a8a0")
		return texture_icon
	var icon := PrepCargoIcon.new()
	icon.item_id = item_id
	return icon


func _equipment_item_visible(item_id: String, category: int, material: int) -> bool:
	var is_apparel := item_id.begins_with("polarbearskin_") or item_id in ["tshirt", "pants", "jacket", "cap", "brim_hat"]
	var is_weapon := item_id in ["spear", "pistol", "assault_rifle", "sniper_rifle"]
	var category_visible := true
	match category:
		1: category_visible = not is_apparel and not is_weapon
		2: category_visible = is_apparel
		3: category_visible = is_weapon
	if not category_visible:
		return false
	var item_material := "polarbearskin" if item_id.begins_with("polarbearskin_") else "wood" if item_id in ["wood", "spear"] else "stone" if item_id == "stone" else "cloth" if is_apparel else "metal" if item_id in ["silver", "steel", "component", "pistol", "assault_rifle", "sniper_rifle"] else "organic"
	var material_ids := ["", "wood", "stone", "cloth", "metal", "organic", "polarbearskin"]
	return material == 0 or item_material == material_ids[clampi(material, 0, material_ids.size() - 1)]


func _clear_starting_cargo() -> void:
	for item_id in starting_cargo.keys():
		starting_cargo[item_id] = 0
	_show_characters()


func _preparation_inline_color(row: HBoxContainer, key: String, initial_color: String, preview: Control) -> void:
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(35, 27)
	picker.color = Color(initial_color)
	picker.edit_alpha = false
	picker.tooltip_text = _prep_local("Choose any color", "İstediğin rengi seç", "Wybierz dowolny kolor")
	picker.color_changed.connect(func(color: Color):
		var spec: Dictionary = character_specs[_editing_character_index]
		var gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
		gear[key] = "#" + color.to_html(false)
		spec["starting_gear"] = gear
		preview.call("set_appearance", _spec_appearance(spec)))
	row.add_child(picker)


func _cargo_label(item_id: String) -> String:
	match item_id:
		"wood": return _prep_local("Wood", "Odun", "Drewno")
		"stone": return _prep_local("Stone", "Taş", "Kamień")
		"food": return _prep_local("Food", "Yiyecek", "Żywność")
		"medicine": return _prep_local("Medicine", "İlaç", "Lekarstwa")
		"silver": return _prep_local("Silver", "Gümüş", "Srebro")
		"spear": return _prep_local("Spear", "Mızrak", "Włócznia")
		"tshirt": return _prep_local("T-shirt", "Tişört", "Koszulka")
		"pants": return _prep_local("Pants", "Pantolon", "Spodnie")
		"jacket": return _prep_local("Coat", "Kaban", "Płaszcz")
		"cap": return _prep_local("Cap", "Kep", "Czapka")
		"brim_hat": return _prep_local("Brimmed hat", "Siperli şapka", "Kapelusz z rondem")
		"packaged_survival_meal": return _prep_local("Packaged survival meal", "Paketlenmiş hayatta kalma yemeği", "Pakowany posiłek przetrwania")
		"component": return _prep_local("Component", "Bileşen", "Komponent")
		"pistol": return _prep_local("Pistol", "Tabanca", "Pistolet")
		"steel": return _prep_local("Steel", "Çelik", "Stal")
		"assault_rifle": return _prep_local("Assault rifle", "Taarruz tüfeği", "Karabin szturmowy")
		"sniper_rifle": return _prep_local("Sniper rifle", "Keskin nişancı tüfeği", "Karabin snajperski")
		"chemfuel": return _prep_local("Chemfuel", "Kimyasal yakıt", "Paliwo chemiczne")
		"female_elephant": return _prep_local("Female elephant", "Dişi fil", "Samica słonia")
		"polarbearskin_bowler_hat": return _prep_local("Polarbearskin bowler hat", "Kutup ayısı derisi melon şapka", "Melonik ze skóry niedźwiedzia polarnego")
		"polarbearskin_button_down_shirt": return _prep_local("Polarbearskin button-down shirt", "Kutup ayısı derisi düğmeli gömlek", "Koszula ze skóry niedźwiedzia polarnego")
		"polarbearskin_cowboy_hat": return _prep_local("Polarbearskin cowboy hat", "Kutup ayısı derisi kovboy şapkası", "Kapelusz kowbojski ze skóry niedźwiedzia polarnego")
		"polarbearskin_duster": return _prep_local("Polarbearskin duster", "Kutup ayısı derisi uzun ceket", "Płaszcz ze skóry niedźwiedzia polarnego")
		"polarbearskin_jacket": return _prep_local("Polarbearskin coat", "Kutup ayısı derisi kaban", "Płaszcz ze skóry niedźwiedzia polarnego")
		"polarbearskin_pants": return _prep_local("Polarbearskin pants", "Kutup ayısı derisi pantolon", "Spodnie ze skóry niedźwiedzia polarnego")
		"polarbearskin_parka": return _prep_local("Polarbearskin parka", "Kutup ayısı derisi parka", "Parka ze skóry niedźwiedzia polarnego")
		"polarbearskin_tribalwear": return _prep_local("Polarbearskin tribalwear", "Kutup ayısı derisi kabile giysisi", "Strój plemienny ze skóry niedźwiedzia polarnego")
		"polarbearskin_tshirt": return _prep_local("Polarbearskin T-shirt", "Kutup ayısı derisi tişört", "T-shirt ze skóry niedźwiedzia polarnego")
	return item_id.capitalize()


func _display_item(item_id: String) -> String:
	match item_id:
		"fists": return _prep_local("Unarmed", "Silahsız", "Bez broni")
		"clothes": return _prep_local("Clothes", "Giysi", "Ubranie")
		"none", "": return _tr("common.none")
		_: return _cargo_label(item_id)


func _display_trait(trait_id: String) -> String:
	match trait_id:
		"hardworking": return _prep_local("Hardworking", "Çalışkan", "Pracowity")
		"calm": return _prep_local("Calm", "Sakin", "Spokojny")
		"quick": return _prep_local("Quick", "Çevik", "Szybki")
		"curious": return _prep_local("Curious", "Meraklı", "Ciekawy")
		"kind": return _prep_local("Kind", "İyi kalpli", "Życzliwy")
		"night_owl": return _prep_local("Night owl", "Gece kuşu", "Nocny marek")
		"timid": return _prep_local("Timid", "Çekingen", "Nieśmiały")
		"abrasive": return _prep_local("Abrasive", "Geçimsiz", "Kłótliwy")
		"lazy": return _prep_local("Lazy", "Tembel", "Leniwy")
		"pyromaniac": return _prep_local("Pyromaniac", "Piroman", "Piroman")
		"fast_walker": return _prep_local("Fast walker", "Hızlı yürür", "Szybki chód")
		"ugly": return _prep_local("Ugly", "Çirkin", "Brzydki")
		_: return trait_id.replace("_", " ").capitalize()


func _display_background(background_id: String) -> String:
	match background_id:
		"unknown": return _prep_local("Unknown", "Bilinmiyor", "Nieznane")
		"rural_child": return _prep_local("Rural child", "Köy çocuğu", "Dziecko ze wsi")
		"town_child": return _prep_local("Town child", "Kasaba çocuğu", "Dziecko z miasta")
		"apprentice": return _prep_local("Apprentice", "Çırak", "Uczeń")
		"vatgrown_soldier": return _prep_local("Vatgrown soldier", "Tankta yetişmiş asker", "Żołnierz z kadzi")
		"farmer": return _prep_local("Farmer", "Çiftçi", "Rolnik")
		"builder": return _prep_local("Builder", "İnşaatçı", "Budowniczy")
		"medic": return _prep_local("Medic", "Sağlıkçı", "Medyk")
		"scholar": return _prep_local("Scholar", "Araştırmacı", "Badacz")
		_: return background_id.replace("_", " ").capitalize()


func _display_work(work_id: String) -> String:
	match work_id:
		"chop": return _prep_local("Chop", "Ağaç kes", "Ścinanie")
		"mine": return _prep_local("Mine", "Maden", "Wydobycie")
		"harvest": return _prep_local("Harvest", "Hasat", "Zbiory")
		"haul": return _prep_local("Haul", "Taşı", "Transport")
		"build": return _prep_local("Build", "İnşa", "Budowa")
		"treat": return _prep_local("Care", "Tedavi", "Opieka")
		"research": return _tr("tabs.research")
		"combat": return _prep_local("Combat", "Savaş", "Walka")
		_: return work_id.capitalize()


func _display_site_kind(kind: String) -> String:
	match kind:
		"friendly": return _tr("world.friendly")
		"hostile": return _tr("world.hostile")
		"player": return _prep_local("Player settlement", "Oyuncu yerleşkesi", "Osada gracza")
		"vacant": return _tr("world.vacant")
		_: return kind.capitalize()


func _adjust_starting_cargo(item_id: String, delta: int) -> void:
	if not GameModel.PREPARATION_CARGO_IDS.has(item_id):
		return
	var previous := int(starting_cargo.get(item_id, 0))
	var quantity := clampi(previous + delta, 0, 999)
	# Dictionary insertion order is the visible right-hand order. Re-added items
	# belong after the existing items instead of jumping to a fixed top slot.
	if previous == 0 and quantity > 0:
		starting_cargo.erase(item_id)
	starting_cargo[item_id] = quantity
	_show_characters()


func _set_starting_gear(slot_id: String, item_id: String) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {"weapon": "fists", "shirt": "tshirt", "pants": "pants"})
	gear[slot_id] = item_id
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _set_preparation_torso(choice: int) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
	gear["shirt"] = "none" if choice == 1 else "tshirt"
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _set_preparation_apparel(choice: int) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
	gear["apparel"] = "jacket" if choice == 1 else "none"
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _set_preparation_legs(choice: int) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
	gear["pants"] = "none" if choice == 1 else "pants"
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _set_preparation_clothing(choice: int) -> void:
	# Support older saved UI actions while the visible editor uses two slots.
	_set_preparation_torso(1 if choice == 2 else 0)
	_set_preparation_apparel(1 if choice == 1 else 0)
	if choice == 2:
		_set_preparation_legs(1)
	else:
		_set_preparation_legs(0)


func _randomize_prepared_colonist() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	spec["sex"] = "female" if randi() % 2 == 0 else "male"
	var identity := _pick_prepared_name(str(spec["sex"]))
	spec["first_name"] = identity["first"]
	spec["nickname"] = identity["nick"]
	spec["name"] = identity["nick"]
	spec["last_name"] = identity["last"]
	spec["body_type"] = randi() % 2
	spec["head_type"] = randi() % 2
	spec["age"] = randi_range(19, 61)
	spec["chronological_age"] = int(spec["age"]) + randi_range(0, 80)
	spec["favorite_color"] = OUTFIT_OPTIONS[randi() % OUTFIT_OPTIONS.size()]
	var random_hair_ids := MALE_HAIR_IDS if str(spec["sex"]) == "male" else FEMALE_HAIR_IDS
	spec["hair_index"] = randi() % random_hair_ids.size()
	spec["hair_style"] = random_hair_ids[int(spec["hair_index"])]
	spec["hair_color"] = HAIR_COLOR_OPTIONS[randi() % HAIR_COLOR_OPTIONS.size()]
	spec["skin_color"] = SKIN_OPTIONS[randi() % SKIN_OPTIONS.size()]
	var randomized_gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
	randomized_gear["shirt_color"] = OUTFIT_OPTIONS[randi() % OUTFIT_OPTIONS.size()]
	spec["starting_gear"] = randomized_gear
	for attempt in range(96):
		var candidate := spec.duplicate(true)
		candidate["childhood"] = CHILDHOOD_IDS[randi() % CHILDHOOD_IDS.size()]
		candidate["adulthood"] = ADULTHOOD_IDS[randi() % ADULTHOOD_IDS.size()]
		var trait_pool := TRAIT_IDS.slice(1)
		trait_pool.shuffle()
		candidate["trait_ids"] = trait_pool.slice(0, randi_range(0, 2))
		candidate["condition_ids"] = []
		candidate["health_injuries"] = []
		var randomized_skills: Dictionary = {}
		var randomized_passions: Dictionary = {}
		for skill in CLASSIC_SKILL_IDS:
			randomized_skills[skill] = randi_range(0, 5)
			randomized_passions[skill] = 2 if randi() % 12 == 0 else 1 if randi() % 4 == 0 else 0
		candidate["skills"] = _derive_work_skills(randomized_skills)
		candidate["passions"] = randomized_passions
		if _preparation_random_candidate_fits(candidate):
			character_specs[_editing_character_index] = candidate
			_show_characters()
			return
	# If the rest of the crew has used nearly every point, choose the least
	# expensive valid character rather than silently generating an over-limit one.
	spec["childhood"] = "unknown"
	spec["adulthood"] = "unknown"
	spec["trait_ids"] = []
	spec["condition_ids"] = []
	spec["health_injuries"] = []
	var empty_skills := {}
	for skill in CLASSIC_SKILL_IDS:
		empty_skills[skill] = 0
	spec["skills"] = _derive_work_skills(empty_skills)
	spec["passions"] = {}
	if _preparation_random_candidate_fits(spec):
		character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_prepared_appearance() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	spec["sex"] = "female" if randi() % 2 == 0 else "male"
	spec["body_type"] = randi() % 2
	spec["head_type"] = randi() % 2
	var random_hair_ids := MALE_HAIR_IDS if str(spec["sex"]) == "male" else FEMALE_HAIR_IDS
	spec["hair_index"] = randi() % random_hair_ids.size()
	spec["hair_style"] = random_hair_ids[int(spec["hair_index"])]
	spec["hair_color"] = HAIR_COLOR_OPTIONS[randi() % HAIR_COLOR_OPTIONS.size()]
	spec["skin_color"] = SKIN_OPTIONS[randi() % SKIN_OPTIONS.size()]
	character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_preparation_choices(kind: String) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	for attempt in range(64):
		var candidate := spec.duplicate(true)
		if kind == "traits":
			var trait_choices := TRAIT_IDS.slice(1)
			trait_choices.shuffle()
			candidate["trait_ids"] = trait_choices.slice(0, randi_range(1, 3))
		elif kind == "backstory":
			candidate["childhood"] = CHILDHOOD_IDS[randi() % CHILDHOOD_IDS.size()]
			candidate["adulthood"] = ADULTHOOD_IDS[randi() % ADULTHOOD_IDS.size()]
		else:
			var condition_choices := CHRONIC_CONDITION_IDS.slice(1)
			condition_choices.shuffle()
			candidate["condition_ids"] = condition_choices.slice(0, randi_range(0, 2))
			candidate["health_injuries"] = []
			if randi() % 2 == 0:
				candidate["health_injuries"] = [{"kind": INJURY_KIND_IDS[randi() % INJURY_KIND_IDS.size()],
					"body_part": INJURY_BODY_PART_IDS[randi() % INJURY_BODY_PART_IDS.size()], "count": 1}]
		if _preparation_random_candidate_fits(candidate):
			character_specs[_editing_character_index] = candidate
			_show_characters()
			return
	if kind == "traits":
		spec["trait_ids"] = []
	elif kind == "backstory":
		spec["childhood"] = "unknown"
		spec["adulthood"] = "unknown"
	else:
		spec["condition_ids"] = []
		spec["health_injuries"] = []
	if _preparation_random_candidate_fits(spec):
		character_specs[_editing_character_index] = spec
	_show_characters()


func _reset_preparation_skills() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var empty_skills := {}
	for skill in CLASSIC_SKILL_IDS:
		empty_skills[skill] = 0
	spec["skills"] = _derive_work_skills(empty_skills)
	spec["passions"] = {}
	character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_preparation_skills() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	for attempt in range(96):
		var candidate := spec.duplicate(true)
		var skills := {}
		var passions := {}
		for skill in CLASSIC_SKILL_IDS:
			skills[skill] = randi_range(0, 8)
			passions[skill] = randi_range(0, 2)
		candidate["skills"] = _derive_work_skills(skills)
		candidate["passions"] = passions
		if _preparation_random_candidate_fits(candidate):
			character_specs[_editing_character_index] = candidate
			_show_characters()
			return
	var empty_skills := {}
	for skill in CLASSIC_SKILL_IDS:
		empty_skills[skill] = 0
	spec["skills"] = _derive_work_skills(empty_skills)
	spec["passions"] = {}
	if _preparation_random_candidate_fits(spec):
		character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_prepared_name() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var identity := _pick_prepared_name(str(spec.get("sex", "female")))
	spec["first_name"] = identity["first"]
	spec["nickname"] = identity["nick"]
	spec["name"] = identity["nick"]
	spec["last_name"] = identity["last"]
	character_specs[_editing_character_index] = spec
	_show_characters()


func _prepared_display_name(spec: Dictionary) -> String:
	var nickname := _normalize_prepared_nickname(str(spec.get("nickname", "")))
	if not nickname.is_empty():
		return nickname
	return str(spec.get("first_name", spec.get("name", ""))).strip_edges()


func _normalize_prepared_nickname(raw_nickname: String) -> String:
	var nickname := raw_nickname.strip_edges()
	# Earlier versions generated PascalCase pairs such as NewBramble.
	# Split only a known generated prefix and a known nickname root.
	for turkish in [false, true]:
		var prefixes := (PREPARATION_TURKISH_NICKNAME_PREFIXES if turkish else PREPARATION_INTERNATIONAL_NICKNAME_PREFIXES).split(",")
		var roots := (PREPARATION_TURKISH_NICKNAMES if turkish else PREPARATION_INTERNATIONAL_NICKNAMES).split(",")
		for prefix in prefixes:
			if not nickname.begins_with(str(prefix)) or nickname.length() <= str(prefix).length():
				continue
			var suffix := nickname.substr(str(prefix).length())
			if roots.has(suffix):
				return "%s %s" % [prefix, suffix]
	return nickname


func _pick_prepared_name(sex: String) -> Dictionary:
	var given_names := PreparationNamePool.MALE_NAMES if sex == "male" else PreparationNamePool.FEMALE_NAMES
	var turkish_names := (PREPARATION_TURKISH_MALE_NAMES if sex == "male" else PREPARATION_TURKISH_FEMALE_NAMES).split(",")
	var international_names := given_names.split(",")
	var turkish_surnames := PREPARATION_TURKISH_SURNAMES.split(",")
	var international_surnames := PREPARATION_INTERNATIONAL_SURNAMES.split(",")
	var occupied := {}
	var occupied_first := {}
	for person in character_specs + world_character_specs:
		if person is Dictionary:
			var current_first := str(person.get("first_name", person.get("name", "")))
			occupied[(current_first + "|" + str(person.get("last_name", ""))).to_lower()] = true
			occupied_first[current_first.to_lower()] = true
	for attempt in range(700):
		var turkish := randi() % 4 == 0
		var first_names := turkish_names if turkish else international_names
		var last_names := turkish_surnames if turkish else international_surnames
		var first := str(first_names[randi() % first_names.size()])
		var last := str(last_names[randi() % last_names.size()])
		var key := (first + "|" + last).to_lower()
		if not occupied.has(key) and not occupied_first.has(first.to_lower()) and not _used_prepared_first_names.has(first.to_lower()) and not _used_prepared_full_names.has(key):
			_used_prepared_full_names[key] = true
			_used_prepared_first_names[first.to_lower()] = true
			return {"first": first, "nick": _pick_prepared_nickname(first, turkish), "last": last, "culture": "tr" if turkish else "international"}
	for first in international_names:
		if occupied_first.has(str(first).to_lower()) or _used_prepared_first_names.has(str(first).to_lower()):
			continue
		for last in international_surnames:
			var key := (str(first) + "|" + str(last)).to_lower()
			if not occupied.has(key) and not _used_prepared_full_names.has(key):
				_used_prepared_full_names[key] = true
				_used_prepared_first_names[str(first).to_lower()] = true
				return {"first": str(first), "nick": _pick_prepared_nickname(str(first), false), "last": str(last), "culture": "international"}
	var serial := _used_prepared_full_names.size() + 1
	var fallback_first := str(international_names[serial % international_names.size()])
	return {"first": fallback_first, "nick": _pick_prepared_nickname(fallback_first, false), "last": "%s %d" % [str(international_surnames[serial % international_surnames.size()]), serial], "culture": "international"}


func _pick_prepared_nickname(first: String, turkish: bool) -> String:
	var nicknames := (PREPARATION_TURKISH_NICKNAMES if turkish else PREPARATION_INTERNATIONAL_NICKNAMES).split(",")
	nicknames.append_array((PREPARATION_EXTRA_TURKISH_NICKNAMES if turkish else PREPARATION_EXTRA_INTERNATIONAL_NICKNAMES).split(","))
	var prefixes := (PREPARATION_TURKISH_NICKNAME_PREFIXES if turkish else PREPARATION_INTERNATIONAL_NICKNAME_PREFIXES).split(",")
	var simple: Array[String] = []
	var spaced: Array[String] = []
	for nickname in nicknames + prefixes:
		if str(nickname).length() <= 9 and not simple.has(str(nickname)):
			simple.append(str(nickname))
	for prefix in prefixes:
		for nickname in nicknames:
			if str(prefix).to_lower() == str(nickname).to_lower():
				continue
			var pair := "%s %s" % [prefix, nickname]
			if pair.length() <= 10:
				spaced.append(pair)
	var occupied := {}
	for person in character_specs + world_character_specs:
		if person is Dictionary:
			occupied[str(person.get("nickname", "")).strip_edges().to_lower()] = true
	for attempt in range(400):
		var roll := randi() % 100
		var pool := simple if roll < 85 else spaced
		if pool.is_empty():
			continue
		var candidate: String = pool[randi() % pool.size()]
		var key := candidate.to_lower()
		if key != first.to_lower() and not occupied.has(key) and not _used_prepared_nicknames.has(key):
			_used_prepared_nicknames[key] = true
			return candidate
	for pool in [simple, spaced]:
		for candidate in pool:
			var key := str(candidate).to_lower()
			if key != first.to_lower() and not occupied.has(key) and not _used_prepared_nicknames.has(key):
				_used_prepared_nicknames[key] = true
				return candidate
	# A compact compound supplies further names after the ordinary pool is used.
	for prefix in prefixes:
		for nickname in nicknames:
			var candidate := "%s %s" % [prefix, nickname]
			if candidate.length() > 12:
				continue
			var key := candidate.to_lower()
			if key != first.to_lower() and not occupied.has(key) and not _used_prepared_nicknames.has(key):
				_used_prepared_nicknames[key] = true
				return candidate
	return first


func _show_prepared_character_info() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	var dialog := AcceptDialog.new()
	dialog.title = "%s %s" % [str(spec.get("first_name", spec.get("name", "Colonist"))), str(spec.get("last_name", ""))]
	var traits: Array = spec.get("trait_ids", [])
	var trait_names: Array[String] = []
	for trait_id in traits:
		trait_names.append(_display_trait(str(trait_id)))
	dialog.dialog_text = "%s: %s\n%s: %s\n%s: %s\n%s: %s" % [
		_prep_local("Nickname", "Takma ad", "Pseudonim"), str(spec.get("name", "")),
		_prep_local("Age", "Yaş", "Wiek"), str(spec.get("age", 25)),
		_prep_local("Backstory", "Geçmiş", "Przeszłość"), _display_background(str(spec.get("adulthood", "farmer"))),
		_prep_local("Traits", "Özellikler", "Cechy"), ", ".join(trait_names) if not trait_names.is_empty() else _prep_local("None", "Yok", "Brak")]
	add_child(dialog)
	dialog.popup_centered(Vector2i(410, 230))
	dialog.confirmed.connect(dialog.queue_free)


func _save_character_preset() -> void:
	_save_character_inputs()
	_open_preparation_library("character", true)


func _load_character_preset() -> void:
	_open_preparation_library("character", false)


func _save_preparation_preset() -> void:
	_save_character_inputs()
	_open_preparation_library("crew", true)


func _load_preparation_preset() -> void:
	_open_preparation_library("crew", false)


func _preparation_library_data(kind: String) -> Dictionary:
	if kind == "character":
		return (character_specs[_editing_character_index] as Dictionary).duplicate(true)
	return {"colonist_count": colonist_count, "point_limit_enabled": point_limit_enabled,
		"characters": character_specs.duplicate(true), "world_characters": world_character_specs.duplicate(true),
		"external_relationships": external_relationships.duplicate(true),
		"starting_cargo": starting_cargo.duplicate(true)}


func _open_preparation_library(kind: String, save_mode: bool) -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD, 0))
	add_child(popup)
	var content := _vbox(8)
	content.custom_minimum_size.x = 470
	popup.add_child(content)
	var title := _prep_local("Saved characters", "Kayıtlı karakterler", "Zapisane postacie") if kind == "character" else _prep_local("Crew presets", "Ekip hazır ayarları", "Zestawy załogi")
	content.add_child(_label(title, 21, GOLD))
	var name_edit: LineEdit = null
	if save_mode:
		name_edit = LineEdit.new()
		name_edit.placeholder_text = _prep_local("Save name", "Kayıt adı", "Nazwa zapisu")
		name_edit.text = str(character_specs[_editing_character_index].get("name", "Character")) if kind == "character" else "Crew %s" % Time.get_date_string_from_system()
		content.add_child(name_edit)
		var save_button := _button(_prep_local("Create new save", "Yeni kayıt oluştur", "Utwórz nowy zapis"), func():
			var id := PreparationPresetStore.safe_id(name_edit.text)
			if id.is_empty():
				_notice(_prep_local("Enter a save name.", "Kayıt adı gir.", "Podaj nazwę zapisu."))
				return
			if not PreparationPresetStore.load_slot(kind, id).is_empty():
				_confirm_preparation_overwrite(kind, name_edit.text, popup)
			else:
				_store_preparation_slot(kind, name_edit.text, popup), true)
		content.add_child(save_button)
	var slots: Array = PreparationPresetStore.list_slots(kind)
	if slots.is_empty():
		content.add_child(_label(_prep_local("No saved entries yet", "Henüz kayıt yok", "Brak zapisów"), 13, MUTED))
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(470, minf(310.0, float(slots.size()) * 43.0))
		content.add_child(scroll)
		var rows := _vbox(4)
		scroll.add_child(rows)
		for slot in slots:
			var slot_id := str(slot["id"])
			var slot_name := str(slot["name"])
			var row := _hbox(5)
			rows.add_child(row)
			row.add_child(_button((_prep_local("Overwrite", "Üzerine yaz", "Nadpisz") if save_mode else _prep_local("Load", "Yükle", "Wczytaj")) + "  " + slot_name,
				func():
					if save_mode:
						_confirm_preparation_overwrite(kind, slot_name, popup)
					else:
						_load_preparation_slot(kind, slot_id, popup), false, Vector2(390, 32)))
			row.add_child(_button(_prep_local("Delete", "Sil", "Usuń"), func(): _confirm_preparation_delete(kind, slot_id, popup, save_mode), false, Vector2(65, 32)))
	content.add_child(_button(_tr("common.close"), popup.hide))
	popup.popup_hide.connect(popup.queue_free)
	popup.popup_centered(Vector2i(510, 480))


func _store_preparation_slot(kind: String, name: String, popup: PopupPanel) -> void:
	var saved: bool = PreparationPresetStore.save_slot(kind, name, _preparation_library_data(kind))
	_notice(_prep_local("Saved.", "Kaydedildi.", "Zapisano.") if saved else _prep_local("Could not save.", "Kaydedilemedi.", "Nie udało się zapisać."))
	if saved and is_instance_valid(popup):
		popup.hide()


func _load_preparation_slot(kind: String, id: String, popup: PopupPanel) -> void:
	var record: Dictionary = PreparationPresetStore.load_slot(kind, id)
	var data: Dictionary = record.get("data", {})
	if kind == "character":
		if not data.has("name"):
			_notice(_prep_local("Invalid character save.", "Karakter kaydı geçersiz.", "Nieprawidłowy zapis postaci."))
			return
		character_specs[_editing_character_index] = data.duplicate(true)
	else:
		if not data.get("characters", null) is Array:
			_notice(_prep_local("Invalid crew save.", "Ekip kaydı geçersiz.", "Nieprawidłowy zapis załogi."))
			return
		colonist_count = clampi(int(data.get("colonist_count", (data["characters"] as Array).size())), 1, 8)
		point_limit_enabled = bool(data.get("point_limit_enabled", true))
		character_specs = (data["characters"] as Array).duplicate(true)
		world_character_specs = (data.get("world_characters", []) as Array).duplicate(true)
		external_relationships = (data.get("external_relationships", []) as Array).duplicate(true)
		_external_source_index = 0
		_external_target_key = "c:0"
		starting_cargo = {}
		if data.get("starting_cargo", null) is Dictionary:
			for item_id in (data["starting_cargo"] as Dictionary):
				if GameModel.PREPARATION_CARGO_IDS.has(str(item_id)):
					starting_cargo[str(item_id)] = clampi(int(data["starting_cargo"][item_id]), 0, 999)
		_editing_character_index = 0
		preparation_tab = "characters"
	if is_instance_valid(popup):
		popup.hide()
	_show_characters()


func _confirm_preparation_overwrite(kind: String, name: String, popup: PopupPanel) -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = _prep_local("Overwrite save", "Kaydın üzerine yaz", "Nadpisz zapis")
	confirmation.dialog_text = _prep_local("Replace '%s'?", "'%s' kaydının üzerine yazılsın mı?", "Zastąpić '%s'?") % name
	add_child(confirmation)
	confirmation.confirmed.connect(func(): _store_preparation_slot(kind, name, popup))
	confirmation.visibility_changed.connect(func(): if not confirmation.visible: confirmation.queue_free())
	confirmation.popup_centered()


func _confirm_preparation_delete(kind: String, id: String, popup: PopupPanel, save_mode: bool) -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = _prep_local("Delete save", "Kaydı sil", "Usuń zapis")
	confirmation.dialog_text = _prep_local("Delete '%s' permanently?", "'%s' kaydı kalıcı silinsin mi?", "Usunąć '%s' na stałe?") % id
	add_child(confirmation)
	confirmation.confirmed.connect(func():
		if PreparationPresetStore.delete_slot(kind, id):
			if is_instance_valid(popup): popup.hide()
			_open_preparation_library(kind, save_mode)
		else:
			_notice(_prep_local("Could not delete save.", "Kayıt silinemedi.", "Nie udało się usunąć zapisu.")))
	confirmation.visibility_changed.connect(func(): if not confirmation.visible: confirmation.queue_free())
	confirmation.popup_centered()


func _cycle_field(parent: Control, title: String, values: Array, initial_index: int, changed: Callable, label_width := 112, value_width := 170) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, values.size() - 1)}
	var row := _hbox(5)
	parent.add_child(row)
	var title_label := _label(title, 12, MUTED)
	title_label.custom_minimum_size = Vector2(label_width, 0)
	row.add_child(title_label)
	var choice := _preparation_option(values, value_width)
	choice.select(int(state["index"]))
	choice.item_selected.connect(func(index: int):
		state["index"] = index
		changed.call())
	row.add_child(_setup_button("◀", func(): _step_preparation_choice(state, choice, -1, changed), false, Vector2(28, 27)))
	row.add_child(choice)
	row.add_child(_setup_button("▶", func(): _step_preparation_choice(state, choice, 1, changed), false, Vector2(28, 27)))
	state["option"] = choice
	state["values"] = values
	state["row"] = row
	return state


func _step_preparation_choice(state: Dictionary, choice: OptionButton, direction: int, changed: Callable) -> void:
	state["index"] = posmod(int(state["index"]) + direction, choice.item_count)
	choice.select(int(state["index"]))
	changed.call()


func _preparation_option(values: Array, minimum_width: float) -> OptionButton:
	var choice := OptionButton.new()
	for value in values:
		choice.add_item(str(value))
	choice.custom_minimum_size = Vector2(minimum_width, 28)
	choice.clip_text = true
	choice.add_theme_font_size_override("font_size", 12)
	for mode in ["normal", "hover", "pressed"]:
		choice.add_theme_stylebox_override(mode, _style(Color("#28333a") if mode == "normal" else Color("#394b51"), Color("#67736f"), 2))
	return choice


func _choice_field(parent: Control, title: String, values: Array, initial_index: int, changed: Callable, label_width := 112, value_width := 170) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, values.size() - 1)}
	var row := _hbox(5)
	parent.add_child(row)
	var caption := _label(title, 12, MUTED)
	caption.custom_minimum_size.x = label_width
	row.add_child(caption)
	var choice := _preparation_option(values, value_width)
	choice.select(int(state["index"]))
	choice.item_selected.connect(func(index: int):
		state["index"] = index
		changed.call())
	row.add_child(choice)
	state["option"] = choice
	state["row"] = row
	return state


func _arrow_choice_field(parent: Control, title: String, values: Array, initial_index: int, changed: Callable, label_width := 112, _value_width := 150, chooser_kind := "", nonselectable_first := false) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, values.size() - 1)}
	var row := _hbox(0)
	row.custom_minimum_size = Vector2(label_width + 14 + _value_width + 14, 29)
	parent.add_child(row)
	var caption := _label(title, 12, MUTED)
	caption.custom_minimum_size.x = label_width
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(caption)
	var value_menu: Button = Button.new() if not chooser_kind.is_empty() else MenuButton.new()
	value_menu.text = str(values[int(state["index"])])
	value_menu.custom_minimum_size = Vector2(_value_width, 29)
	value_menu.alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_menu.add_theme_font_size_override("font_size", 12)
	value_menu.add_theme_color_override("font_color", CREAM)
	for menu_style in ["normal", "hover", "pressed"]:
		value_menu.add_theme_stylebox_override(menu_style, StyleBoxEmpty.new())
	if chooser_kind.is_empty():
		for option_index in values.size():
			(value_menu as MenuButton).get_popup().add_item(str(values[option_index]), option_index)
		if nonselectable_first:
			(value_menu as MenuButton).get_popup().set_item_disabled(0, true)
		(value_menu as MenuButton).get_popup().id_pressed.connect(func(option_index: int):
			if nonselectable_first and option_index == 0:
				return
			state["index"] = option_index
			value_menu.text = str(values[option_index])
			changed.call(option_index))
	else:
		var backstory_ids := CHILDHOOD_IDS if chooser_kind == "childhood" else ADULTHOOD_IDS
		value_menu.mouse_entered.connect(func():
			if get_node_or_null("PreparationOptionDialog") == null:
				_show_preparation_entry_hover(value_menu, _preparation_option_detail(chooser_kind, str(backstory_ids[int(state["index"])]), str(values[int(state["index"])]))))
		value_menu.mouse_exited.connect(_hide_preparation_entry_hover)
		value_menu.pressed.connect(func():
			var ids := backstory_ids
			_open_preparation_option_dialog(chooser_kind, ids, values, str(ids[int(state["index"])]), func(id: String):
				var option_index := ids.find(id)
				if option_index >= 0:
					state["index"] = option_index
					value_menu.text = str(values[option_index])
					changed.call(option_index)))
	var previous := _preparation_classic_bare_button("<", func():
		state["index"] = posmod(int(state["index"]) - 1, values.size())
		if nonselectable_first and int(state["index"]) == 0:
			state["index"] = values.size() - 1
		value_menu.text = str(values[int(state["index"])] )
		changed.call(int(state["index"])), 14, 29, 17)
	row.add_child(previous)
	var bar := PanelContainer.new()
	bar.custom_minimum_size = Vector2(_value_width, 29)
	var bar_style := _style(Color("#17191b"), Color("#292b2d"), 0)
	bar_style.set_content_margin_all(0)
	bar.add_theme_stylebox_override("panel", bar_style)
	bar.add_child(value_menu)
	row.add_child(bar)
	var next := _preparation_classic_bare_button(">", func():
		state["index"] = posmod(int(state["index"]) + 1, values.size())
		if nonselectable_first and int(state["index"]) == 0:
			state["index"] = 1
		value_menu.text = str(values[int(state["index"])] )
		changed.call(int(state["index"])), 14, 29, 17)
	row.add_child(next)
	state["row"] = row
	state["value_menu"] = value_menu
	return state


func _preparation_option_filters(kind: String) -> Array:
	var result: Array = [{"id": "all", "label": _prep_local("All", "Tümü", "Wszystkie")}]
	if kind in ["childhood", "adulthood"]:
		result.append({"id": "no_restrictions", "label": _prep_local("No work restrictions", "İş kısıtlaması yok", "Bez ograniczeń pracy")})
		result.append({"id": "no_penalties", "label": _prep_local("No skill penalties", "Beceri eksisi yok", "Bez kar umiejętności")})
		for skill in CLASSIC_SKILL_IDS:
			result.append({"id": "skill:" + str(skill), "label": _localized_skill(str(skill)) + " +"})
	elif kind == "trait":
		result.append({"id": "positive", "label": _prep_local("Positive", "Olumlu", "Pozytywne")})
		result.append({"id": "negative", "label": _prep_local("Negative", "Olumsuz", "Negatywne")})
		result.append({"id": "work_restriction", "label": _prep_local("Work restriction", "İş kısıtlaması", "Ograniczenie pracy")})
		result.append({"id": "mood_effect", "label": _prep_local("Mood effect", "Ruh hali etkisi", "Wpływ na nastrój")})
		result.append({"id": "movement_effect", "label": _prep_local("Movement effect", "Hareket etkisi", "Wpływ na ruch")})
		result.append({"id": "work_speed_effect", "label": _prep_local("Work speed effect", "İş hızı etkisi", "Wpływ na szybkość pracy")})
		result.append({"id": "social_effect", "label": _prep_local("Social effect", "Sosyal etki", "Wpływ społeczny")})
	elif kind == "health":
		result.append({"id": "capacity", "label": _prep_local("Capacity effects", "Kapasite etkileri", "Wpływ na zdolność")})
		result.append({"id": "injury", "label": _prep_local("Injuries", "Yaralanmalar", "Obrażenia")})
		result.append({"id": "pain", "label": _prep_local("Pain", "Acı", "Ból")})
	return result


func _preparation_option_matches(kind: String, option_id: String, filter_id: String) -> bool:
	if filter_id == "all": return true
	if kind in ["childhood", "adulthood"]:
		var adjustments: Dictionary = PreparationRules.BACKSTORY_SKILLS.get(option_id, {})
		if filter_id == "no_restrictions":
			return PreparationRules.incapable_of(option_id if kind == "childhood" else "", option_id if kind == "adulthood" else "", [], []).is_empty()
		if filter_id == "no_penalties":
			for skill in adjustments:
				if int(adjustments[skill]) < 0: return false
			return true
		if filter_id.begins_with("skill:"):
			return int(adjustments.get(filter_id.trim_prefix("skill:"), 0)) > 0
	if kind == "trait":
		var trait_cost := int(GameModel.TRAIT_COSTS.get(option_id, 0))
		match filter_id:
			"positive": return trait_cost > 0
			"negative": return trait_cost < 0
			"work_restriction": return not PreparationRules.incapable_of("", "", [option_id], []).is_empty()
			"mood_effect": return option_id in ["calm", "night_owl", "kind"]
			"movement_effect": return option_id in ["quick", "fast_walker"]
			"work_speed_effect": return option_id in ["hardworking", "lazy", "curious"]
			"social_effect": return option_id in ["kind", "abrasive", "ugly"]
		return false
	if kind == "health":
		if filter_id == "capacity": return option_id in ["asthma", "bad_back"]
		if filter_id == "injury": return PreparationRules.CONDITION_INJURIES.has(option_id)
		if filter_id == "pain": return option_id == "scar" or PreparationRules.CONDITION_INJURIES.has(option_id)
		return false
	return true


func _preparation_option_description(kind: String, option_id: String) -> String:
	if kind in ["childhood", "adulthood"]:
		match option_id:
			"unknown": return _prep_local("No known background; no skill or work effects.", "Bilinen geçmişi yok; beceriye veya işe etkisi yok.", "Brak znanej przeszłości; bez wpływu na umiejętności i pracę.")
			"rural_child": return _prep_local("Raised near fields and livestock; learned practical outdoor work.", "Tarlalar ve hayvanlar arasında büyüdü; temel açık hava işlerini öğrendi.", "Dorastał na wsi i poznał pracę w polu.")
			"town_child": return _prep_local("Grew up among traders and workshops.", "Esnaf ve atölyeler arasında büyüdü.", "Dorastał wśród warsztatów i kupców.")
			"apprentice": return _prep_local("Worked with a craftsperson from an early age.", "Küçük yaştan itibaren bir ustanın yanında çalıştı.", "Od dziecka uczył się rzemiosła.")
			"vatgrown_soldier": return _prep_local("Trained for combat in a vatgrown program; lost everyday social and care skills.", "Tankta yetiştirme programında savaş için eğitildi; sosyal ve bakım işlerinden uzak kaldı.", "Wychowany do walki; bez praktyki społecznej.")
			"farmer": return _prep_local("Worked on crop fields. Improves growing, not animal handling.", "Ekin tarlalarında çalıştı. Hayvancılık yerine yetiştirmeyi geliştirir.", "Pracował na polach uprawnych.")
			"builder": return _prep_local("Built shelters and structures.", "Barınaklar ve yapılar inşa etti.", "Budował schronienia i konstrukcje.")
			"medic": return _prep_local("Treated illnesses and injuries.", "Hastalık ve yaralanmaları tedavi etti.", "Leczył choroby i urazy.")
			"scholar": return _prep_local("Spent years studying; avoids carrying loads.", "Yıllarını araştırmaya ayırdı; yük taşımaktan kaçınır.", "Lata spędził na badaniach.")
	elif kind == "trait":
		match option_id:
			"hardworking": return _prep_local("Completes work 20% faster.", "İşleri %20 daha hızlı tamamlar.", "Pracuje o 20% szybciej.")
			"calm": return _prep_local("Mood target increases by 8.", "Hedef ruh hali 8 artar.", "Nastrój wzrasta o 8.")
			"quick": return _prep_local("Can take an extra step every second tick.", "Her ikinci zaman adımında ek bir kare ilerleyebilir.", "Dodatkowy krok co drugi takt.")
			"curious": return _prep_local("Researches 30% faster.", "Araştırması %30 hızlanır.", "Badania +30%.")
			"kind":
				var effects := PreparationRules.trait_effects("kind")
				return _prep_local("Every sixth pleasant conversation can give the other person +%d mood and +%d opinion. Ignores Ugly first-impression penalties.", "Her altıncı olumlu konuşmada karşısındakine +%d ruh hali ve +%d görüş verebilir. Çirkin özelliğinin ilk izlenim cezasını yok sayar.", "Co szósta miła rozmowa: +%d nastroju i +%d opinii; ignoruje brzydotę.") % [int(effects.get("kind_words_mood", 0)), int(effects.get("kind_words_opinion", 0))]
			"night_owl": return _prep_local("Mood +16 from 23:00 to 06:00; −10 from 11:00 to 18:00.", "23.00–06.00 arası ruh hali +16; 11.00–18.00 arası −10.", "Nastrój +16 nocą (23–06), −10 w dzień (11–18).")
			"timid": return _prep_local("Deals 25% less combat damage.", "Savaşta %25 daha az hasar verir.", "Zadaje o 25% mniej obrażeń.")
			"abrasive": return _prep_local("Every third conversation with another colonist becomes an argument.", "Başka bir kolonistle her üçüncü konuşması tartışmaya dönüşür.", "Co trzecia rozmowa staje się kłótnią.")
			"lazy": return _prep_local("Completes work 20% slower.", "İşleri %20 daha yavaş tamamlar.", "Pracuje o 20% wolniej.")
			"pyromaniac": return _prep_local("Cannot fight fires.", "Yangın söndürme işini yapamaz.", "Nie gasi pożarów.")
			"fast_walker": return _prep_local("Can take an extra step every second tick.", "Her ikinci zaman adımında ek bir kare ilerleyebilir.", "Dodatkowy krok co drugi takt.")
			"ugly": return _prep_local("Other colonists start with −20 opinion on first meeting, except Kind colonists.", "İlk tanışmada diğer kolonistlerin görüşü −20 olur; İyi kalpliler etkilenmez.", "Pierwsze wrażenie: −20 opinii, z wyjątkiem życzliwych.")
	elif kind == "health":
		match option_id:
			"asthma": return _prep_local("Work speed −13%.", "İş hızı %13 azalır.", "Praca −13%.")
			"bad_back": return _prep_local("Starts with 92 health; mining, hauling and building speed −24%.", "92 canla başlar; madencilik, taşıma ve inşaat hızı %24 azalır.", "92 zdrowia; praca fizyczna wolniejsza.")
			"scar": return _prep_local("Permanent tissue damage; severity reduces the part's capacity. Scars do not bleed.", "Kalıcı doku hasarı; şiddet, bölgenin kapasitesini düşürür. Yara izi kanamaz.", "Trwałe uszkodzenie tkanki; nasilenie zmniejsza sprawność części ciała. Blizna nie krwawi.")
			"cut_light": return _prep_local("A cut causes 1.25% pain per severity and bleeding. It heals over time.", "Kesik, her şiddet puanı için %1,25 acı ve kanamaya yol açar. Zamanla iyileşir.", "Skaleczenie powoduje ból i krwawienie; goi się z czasem.")
			"cut_deep": return _prep_local("A deeper cut causes 1.25% pain per severity and bleeding. It heals over time.", "Derin kesik, her şiddet puanı için %1,25 acı ve kanamaya yol açar. Zamanla iyileşir.", "Głębokie skaleczenie powoduje ból i krwawienie; goi się z czasem.")
			"bruise": return _prep_local("A blunt injury causes 1.25% pain per severity, without bleeding.", "Künt darbe, her şiddet puanı için %1,25 acıya yol açar; kanamaz.", "Stłuczenie powoduje ból bez krwawienia.")
			"burn": return _prep_local("A burn causes 1.875% pain per severity, without bleeding.", "Yanık, her şiddet puanı için %1,875 acıya yol açar; kanamaz.", "Oparzenie powoduje ból bez krwawienia.")
			"scratch": return _prep_local("An animal scratch causes 1.25% pain per severity and bleeding.", "Hayvan çiziği, her şiddet puanı için %1,25 acı ve kanamaya yol açar.", "Zadrapanie zwierzęcia powoduje ból i krwawienie.")
	return ""


func _preparation_option_detail(kind: String, option_id: String, display_name: String) -> String:
	var lines: Array[String] = [display_name, "", _preparation_option_description(kind, option_id)]
	var changes: Dictionary = PreparationRules.BACKSTORY_SKILLS.get(option_id, {}) if kind in ["childhood", "adulthood"] else PreparationRules.TRAIT_SKILLS.get(option_id, {}) if kind == "trait" else PreparationRules.CONDITION_SKILLS.get(option_id, {})
	if not changes.is_empty():
		lines.append("")
		lines.append(_prep_local("Skill changes", "Beceri değişimleri", "Zmiany umiejętności"))
		for skill in changes:
			lines.append("%s  %+d" % [_localized_skill(str(skill)), int(changes[skill])])
	var incapable := PreparationRules.incapable_of(option_id if kind == "childhood" else "", option_id if kind == "adulthood" else "", [option_id] if kind == "trait" else [], [])
	if not incapable.is_empty():
		lines.append("")
		lines.append(_prep_local("Incapable of", "Yapamadığı işler", "Niezdolność") + ": " + ", ".join(incapable.map(func(work: Variant): return _preparation_incapable_name(str(work)))))
	if kind == "trait":
		lines.append("")
		lines.append(_prep_local("Preparation points", "Hazırlık puanı", "Punkty przygotowania") + ": %+d" % (int(GameModel.TRAIT_COSTS.get(option_id, 0)) * 20))
	elif kind == "health":
		lines.append("")
		lines.append(_prep_local("Preparation points", "Hazırlık puanı", "Punkty przygotowania") + ": %+d" % (int(GameModel.HEALTH_CONDITION_COSTS.get(option_id, 0)) * 20))
	return "\n".join(lines)


func _show_preparation_entry_hover(source: Control, detail: String) -> void:
	_hide_preparation_entry_hover()
	var popup := PanelContainer.new()
	popup.name = "PreparationEntryHover"
	popup.z_index = 80
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.custom_minimum_size = Vector2(320, 0)
	var popup_style := _style(Color("#202224"), Color("#b29a69"), 2)
	popup_style.set_content_margin_all(12)
	popup.add_theme_stylebox_override("panel", popup_style)
	add_child(popup)
	var description := _label(detail, 13, CREAM)
	description.name = "PreparationEntryHoverText"
	description.custom_minimum_size.x = 296
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.add_child(description)
	popup.reset_size()
	var source_rect := source.get_global_rect()
	var viewport_size := get_viewport_rect().size
	var popup_size := popup.get_combined_minimum_size()
	var hover_x := source_rect.end.x + 8.0
	if hover_x + popup_size.x > viewport_size.x - 8.0:
		hover_x = source_rect.position.x - popup_size.x - 8.0
	var hover_y := clampf(source_rect.position.y, 8.0, maxf(8.0, viewport_size.y - popup_size.y - 8.0))
	popup.position = Vector2(maxf(8.0, hover_x), hover_y) - global_position


func _hide_preparation_entry_hover() -> void:
	var popup := get_node_or_null("PreparationEntryHover")
	if popup != null:
		remove_child(popup)
		popup.queue_free()


func _remove_preparation_dialog_filter(active_filters: Array[String], filter_id: String, refresh_state: Dictionary) -> void:
	active_filters.erase(filter_id)
	var refresh: Callable = refresh_state.get("call", Callable())
	if refresh.is_valid():
		refresh.call()


func _open_preparation_option_dialog(kind: String, ids: Array, names: Array, current_id: String, selected: Callable, unavailable: Array = []) -> void:
	_hide_preparation_entry_hover()
	var previous := get_node_or_null("PreparationOptionDialog")
	if previous != null:
		previous.queue_free()
	var dialog := PanelContainer.new()
	dialog.name = "PreparationOptionDialog"
	dialog.z_index = 40
	dialog.position = Vector2(maxf(8.0, (size.x - 610.0) * 0.5), maxf(8.0, (size.y - 410.0) * 0.5))
	dialog.custom_minimum_size = Vector2(610, 410)
	dialog.size = Vector2(610, 410)
	var frame := _style(Color("#242628"), Color("#72716c"), 0)
	frame.set_content_margin_all(10)
	dialog.add_theme_stylebox_override("panel", frame)
	add_child(dialog)
	var content := _vbox(8)
	dialog.add_child(content)
	var header := _hbox(5)
	content.add_child(header)
	var heading := _prep_local("Backstory", "Geçmiş", "Przeszłość") if kind in ["childhood", "adulthood"] else _prep_local("Traits", "Özellikler", "Cechy") if kind == "trait" else _prep_local("Health", "Sağlık", "Zdrowie")
	header.add_child(_label(heading, 19, CREAM))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	header.add_child(_preparation_classic_bare_button("×", dialog.queue_free, 24, 24, 19))
	var tools_row := _hbox(8)
	content.add_child(tools_row)
	var filters := _preparation_option_filters(kind)
	var active_filters: Array[String] = []
	var filter_button := _preparation_classic_gold_menu(_prep_local("Add filter", "Filtre ekle", "Dodaj filtr"), 170, 27)
	filter_button.name = "PreparationChoiceFilter"
	tools_row.add_child(filter_button)
	for filter_index in filters.size():
		filter_button.get_popup().add_item(str(filters[filter_index]["label"]), filter_index)
	var search := LineEdit.new()
	search.name = "PreparationChoiceSearch"
	search.placeholder_text = _prep_local("Search", "Ara", "Szukaj")
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.add_theme_stylebox_override("normal", _style(Color("#161819"), Color("#4a4c4d"), 0))
	search.add_theme_stylebox_override("focus", _style(Color("#161819"), GOLD, 0))
	tools_row.add_child(search)
	var filter_chips := _hbox(5)
	filter_chips.name = "PreparationActiveFilters"
	filter_chips.custom_minimum_size.y = 20
	content.add_child(filter_chips)
	var columns := _hbox(8)
	columns.custom_minimum_size.y = 290
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	var list_back := PanelContainer.new()
	list_back.custom_minimum_size.x = 270
	list_back.add_theme_stylebox_override("panel", _style(Color("#17191b"), Color("#3c3f41"), 0))
	columns.add_child(list_back)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_back.add_child(scroll)
	var option_rows := _vbox(1)
	option_rows.name = "PreparationChoiceRows"
	option_rows.custom_minimum_size.x = 260
	scroll.add_child(option_rows)
	var detail_back := PanelContainer.new()
	detail_back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detail_style := _style(Color("#1b1d1f"), Color("#3c3f41"), 0)
	detail_style.set_content_margin_all(10)
	detail_back.add_theme_stylebox_override("panel", detail_style)
	columns.add_child(detail_back)
	var details := _label("", 13, CREAM)
	details.name = "PreparationChoiceDetails"
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_back.add_child(details)
	var current_index := ids.find(current_id)
	if current_index >= 0:
		details.text = _preparation_option_detail(kind, current_id, str(names[current_index]))
	var refresh_state := {"call": Callable()}
	var refresh: Callable
	refresh = func():
		for old_chip in filter_chips.get_children():
			filter_chips.remove_child(old_chip)
			old_chip.queue_free()
		for filter_entry in filters:
			var chip_id := str(filter_entry["id"])
			if not active_filters.has(chip_id): continue
			var chip := PanelContainer.new()
			chip.add_theme_stylebox_override("panel", _style(Color("#35383a"), Color("#646360"), 0))
			var chip_content := _hbox(2)
			chip.add_child(chip_content)
			chip_content.add_child(_label(str(filter_entry["label"]), 11, CREAM))
			var remove_filter := _preparation_classic_bare_button("×", _remove_preparation_dialog_filter.bind(active_filters, chip_id, refresh_state), 17, 20, 14)
			remove_filter.name = "PreparationFilterRemove_" + chip_id.replace(":", "_")
			remove_filter.tooltip_text = _prep_local("Remove filter", "Filtreyi kaldır", "Usuń filtr")
			chip_content.add_child(remove_filter)
			filter_chips.add_child(chip)
		for old_row in option_rows.get_children():
			option_rows.remove_child(old_row)
			old_row.queue_free()
		for option_index in ids.size():
			var option_id := str(ids[option_index])
			var option_name := str(names[option_index])
			if unavailable.has(option_id):
				continue
			var passes_filters := true
			for filter_id in active_filters:
				if not _preparation_option_matches(kind, option_id, filter_id):
					passes_filters = false
					break
			if not passes_filters: continue
			if not search.text.is_empty() and not option_name.to_lower().contains(search.text.to_lower()):
				continue
			var row := Button.new()
			row.text = option_name
			row.alignment = HORIZONTAL_ALIGNMENT_LEFT
			row.custom_minimum_size = Vector2(257, 28)
			row.add_theme_font_size_override("font_size", 12)
			row.add_theme_color_override("font_color", CREAM)
			for state_name in ["normal", "hover", "pressed"]:
				var row_color := Color("#333638") if state_name == "hover" else Color("#292b2d") if option_id == current_id else Color("#202224")
				row.add_theme_stylebox_override(state_name, _style(row_color, Color.TRANSPARENT, 0))
			row.mouse_entered.connect(func(): details.text = _preparation_option_detail(kind, option_id, option_name))
			row.pressed.connect(func():
				dialog.queue_free()
				selected.call(option_id))
			option_rows.add_child(row)
	refresh_state["call"] = refresh
	filter_button.get_popup().id_pressed.connect(func(filter_index: int):
		var filter_id := str(filters[filter_index]["id"])
		if filter_id == "all":
			active_filters.clear()
		elif not active_filters.has(filter_id):
			active_filters.append(filter_id)
		refresh.call())
	search.text_changed.connect(func(_value: String): refresh.call())
	refresh.call()


func _preparation_choice_chips(parent: Control, ids: Array, names: Array, selected_ids: Array, add_caption: String, header: HBoxContainer = null, start_y := 37.0, show_empty := true) -> Array:
	var states: Array = []
	for selected_id in selected_ids:
		var choice_index := ids.find(str(selected_id))
		if choice_index > 0 and not _preparation_index_taken(states, choice_index):
			states.append({"index": choice_index})
	var scroller := ScrollContainer.new()
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_preparation_place(parent, scroller, 15, start_y, 295, maxf(36.0, parent.custom_minimum_size.y - start_y - 5.0))
	var rows := _vbox(3)
	scroller.add_child(rows)
	var kind := "trait" if ids.size() == TRAIT_IDS.size() else "health"
	for slot in range(states.size()):
		var choice_index := int(states[slot]["index"])
		var target_slot := slot
		var chip_row := _hbox(4)
		chip_row.custom_minimum_size = Vector2(277, 25)
		rows.add_child(chip_row)
		var value_button := Button.new()
		value_button.name = "PreparationTraitEntry" if kind == "trait" else "PreparationHealthEntry"
		value_button.text = "•  " + str(names[choice_index])
		value_button.custom_minimum_size = Vector2(250, 25)
		value_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		value_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		value_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		value_button.add_theme_font_size_override("font_size", 13)
		value_button.add_theme_color_override("font_color", CREAM)
		value_button.add_theme_color_override("font_hover_color", GOLD)
		value_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		value_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		value_button.add_theme_stylebox_override("hover", _style(Color("#323538"), Color.TRANSPARENT, 0))
		value_button.add_theme_stylebox_override("pressed", _style(Color("#383c3d"), Color.TRANSPARENT, 0))
		value_button.pressed.connect(func():
			var unavailable: Array = []
			for other_slot in range(states.size()):
				if other_slot != target_slot:
					unavailable.append(str(ids[int(states[other_slot]["index"])]))
			_open_preparation_option_dialog(kind, ids.slice(1), names.slice(1), str(ids[int(states[target_slot]["index"])]), func(selected_id: String):
				states[target_slot]["index"] = ids.find(selected_id)
				_save_character_inputs()
				_show_characters(), unavailable))
		value_button.mouse_entered.connect(_show_preparation_entry_hover.bind(value_button, _preparation_option_detail(kind, str(ids[choice_index]), str(names[choice_index]))))
		value_button.mouse_exited.connect(_hide_preparation_entry_hover)
		chip_row.add_child(value_button)
		var remove := _preparation_classic_bare_button("×", func():
			_hide_preparation_entry_hover()
			states.remove_at(target_slot)
			_save_character_inputs()
			_show_characters(), 22, 25, 17)
		for state_name in ["normal", "hover", "pressed", "focus"]:
			remove.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
		remove.tooltip_text = _prep_local("Remove", "Kaldır", "Usuń")
		chip_row.add_child(remove)
	if states.is_empty() and show_empty:
		rows.add_child(_label(_prep_local("No traits", "Özellik yok", "Brak cech"), 12, MUTED))
	if states.size() < ids.size() - 1:
		var add_choice := Button.new()
		add_choice.text = "+" if header != null else "+  " + add_caption
		add_choice.tooltip_text = add_caption
		add_choice.custom_minimum_size = Vector2(22, 23) if header != null else Vector2(180, 27)
		if header != null:
			add_choice.flat = true
			for state_name in ["normal", "hover", "pressed", "focus"]:
				add_choice.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
		add_choice.pressed.connect(func():
			var unavailable: Array = []
			for selection in states:
				unavailable.append(str(ids[int(selection["index"])]))
			_open_preparation_option_dialog(kind, ids.slice(1), names.slice(1), "", func(selected_id: String):
				states.append({"index": ids.find(selected_id)})
				_save_character_inputs()
				_show_characters(), unavailable))
		if header != null:
			header.add_child(add_choice)
		else:
			parent.add_child(add_choice)
	return states


func _preparation_migrate_legacy_injuries(spec_index: int) -> void:
	if spec_index < 0 or spec_index >= character_specs.size():
		return
	var spec: Dictionary = character_specs[spec_index]
	var conditions: Array = spec.get("condition_ids", [])
	var chronic: Array = []
	var injuries: Array = spec.get("health_injuries", []).duplicate(true)
	var changed := false
	for condition in conditions:
		var condition_id := str(condition)
		if INJURY_KIND_IDS.has(condition_id):
			injuries.append({"kind": condition_id,
				"body_part": str(PreparationRules.LEGACY_INJURY_PARTS.get(condition_id, "torso")), "count": 1})
			changed = true
		else:
			chronic.append(condition_id)
	if changed:
		spec["condition_ids"] = chronic
		spec["health_injuries"] = injuries
		character_specs[spec_index] = spec


func _preparation_body_part_label(part: String) -> String:
	match part:
		"head": return _prep_local("Head", "Kafa", "Głowa")
		"torso": return _prep_local("Torso", "Gövde", "Tułów")
		"left_arm": return _prep_local("Left arm", "Sol kol", "Lewe ramię")
		"right_arm": return _prep_local("Right arm", "Sağ kol", "Prawe ramię")
		"left_leg": return _prep_local("Left leg", "Sol bacak", "Lewa noga")
		"right_leg": return _prep_local("Right leg", "Sağ bacak", "Prawa noga")
	return part


func _preparation_injury_cause_label(cause: String) -> String:
	match cause:
		"unknown": return _prep_local("Unknown", "Bilinmiyor", "Nieznana")
		"human_fist": return _prep_local("Human fist", "İnsan yumruğu", "Ludzka pięść")
		"animal_strike": return _prep_local("Animal strike", "Hayvan darbesi", "Uderzenie zwierzęcia")
		"blunt_weapon": return _prep_local("Blunt weapon", "Künt silah", "Broń obuchowa")
		"fall": return _prep_local("Fall", "Düşme", "Upadek")
		"knife": return _prep_local("Knife", "Bıçak", "Nóż")
		"sword": return _prep_local("Sword", "Kılıç", "Miecz")
		"glass": return _prep_local("Glass", "Cam", "Szkło")
		"animal_claw": return _prep_local("Animal claw", "Hayvan pençesi", "Pazur zwierzęcia")
		"fire": return _prep_local("Fire", "Ateş", "Ogień")
		"hot_surface": return _prep_local("Hot surface", "Sıcak yüzey", "Gorąca powierzchnia")
		"old_cut": return _prep_local("Old cut", "Eski kesik", "Stare skaleczenie")
		"old_burn": return _prep_local("Old burn", "Eski yanık", "Stare oparzenie")
		"old_scratch": return _prep_local("Old scratch", "Eski çizik", "Stare zadrapanie")
	return _preparation_injury_cause_label("unknown")


func _preparation_injury_tier_label(tier: String, injury_id: String = "") -> String:
	if injury_id == "bruise" and tier == "severe":
		return _prep_local("Moderate", "Orta", "Umiarkowany")
	if injury_id == "bruise" and tier == "extreme":
		return _prep_local("Older value", "Eski değer", "Starsza wartość")
	match tier:
		"minor": return _prep_local("Minor", "Hafif", "Lekki")
		"moderate": return _prep_local("Moderate", "Orta", "Umiarkowany")
		"severe": return _prep_local("Severe", "Ağır", "Ciężki")
		"extreme": return _prep_local("Extreme", "Çok ağır", "Skrajny")
	return ""


func _preparation_injury_label(entry: Dictionary) -> String:
	var label := "%d× %s · %s" % [int(entry.get("count", 1)), _preparation_condition_label(str(entry.get("kind", "bruise"))),
		_preparation_body_part_label(str(entry.get("body_part", "torso")))]
	if str(entry.get("cause", "unknown")) != "unknown":
		label += " · " + _preparation_injury_cause_label(str(entry.get("cause", "unknown")))
	return label


func _preparation_injury_detail(entry: Dictionary) -> String:
	var kind := str(entry.get("kind", "bruise"))
	var rule: Dictionary = PreparationRules.prepared_injuries({"health_injuries": [entry]})[0]
	var count := int(entry.get("count", 1))
	var severity := float(rule.get("severity", 0.0))
	var pain := PreparationRules.wound_pain(rule) * 100.0
	return "%s\n%s: %s\n%s: %s\n%s: %d\n%s: %s (%.0f)  ·  %s: %.1f%%\n%s" % [
		_preparation_condition_label(kind), _prep_local("Body part", "Vücut bölgesi", "Część ciała"),
		_preparation_body_part_label(str(entry.get("body_part", "torso"))),
		_prep_local("Cause", "Neden", "Przyczyna"), _preparation_injury_cause_label(str(entry.get("cause", "unknown"))),
		_prep_local("Count", "Adet", "Liczba"), count,
		_prep_local("Severity each", "Her birinin şiddeti", "Nasilanie"), _preparation_injury_tier_label(str(entry.get("severity_tier", "")), kind), severity,
		_prep_local("Pain each", "Her birinin acısı", "Ból"), pain,
		_preparation_option_description("health", kind)]


func _build_preparation_health_editor(parent: Control, header: HBoxContainer, selected_ids: Array, injuries: Array) -> Array:
	var states: Array = []
	for selected_id in selected_ids:
		var choice_index := CONDITION_IDS.find(str(selected_id))
		if choice_index > 0 and choice_index < CHRONIC_CONDITION_IDS.size() and not _preparation_index_taken(states, choice_index):
			states.append({"index": choice_index})
	var add_menu := MenuButton.new()
	add_menu.name = "PreparationHealthAdd"
	add_menu.text = "+"
	add_menu.flat = true
	add_menu.custom_minimum_size = Vector2(22, 23)
	add_menu.tooltip_text = _prep_local("Add an injury or condition", "Yara veya rahatsızlık ekle", "Dodaj uraz lub chorobę")
	for state_name in ["normal", "hover", "pressed", "focus"]:
		add_menu.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	header.add_child(add_menu)
	add_menu.get_popup().add_item(_prep_local("Injury...", "Yara...", "Uraz..."), 0)
	add_menu.get_popup().add_item(_prep_local("Condition...", "Rahatsızlık...", "Schorzenie..."), 1)
	add_menu.get_popup().id_pressed.connect(func(choice: int):
		if choice == 0:
			_open_preparation_injury_dialog(-1)
			return
		var unavailable: Array = []
		for selection in states:
			unavailable.append(str(CONDITION_IDS[int(selection["index"])]))
		_open_preparation_option_dialog("health", CHRONIC_CONDITION_IDS.slice(1), _preparation_condition_names().slice(1, CHRONIC_CONDITION_IDS.size()), "", func(selected_id: String):
			states.append({"index": CONDITION_IDS.find(selected_id)})
			_save_character_inputs()
			_show_characters(), unavailable))
	var scroller := ScrollContainer.new()
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_preparation_place(parent, scroller, 15, 36, 295, 140)
	var rows := _vbox(2)
	scroller.add_child(rows)
	for slot in range(states.size()):
		var target_slot := slot
		var condition_id := str(CONDITION_IDS[int(states[slot]["index"])])
		var row := _hbox(4)
		row.custom_minimum_size = Vector2(277, 25)
		rows.add_child(row)
		var value := _preparation_health_row_button("•  " + _preparation_condition_label(condition_id), "PreparationHealthEntry")
		value.pressed.connect(func():
			var unavailable: Array = []
			for other_slot in range(states.size()):
				if other_slot != target_slot:
					unavailable.append(str(CONDITION_IDS[int(states[other_slot]["index"])]))
			_open_preparation_option_dialog("health", CHRONIC_CONDITION_IDS.slice(1), _preparation_condition_names().slice(1, CHRONIC_CONDITION_IDS.size()), condition_id, func(selected_id: String):
				states[target_slot]["index"] = CONDITION_IDS.find(selected_id)
				_save_character_inputs()
				_show_characters(), unavailable))
		value.mouse_entered.connect(_show_preparation_entry_hover.bind(value,
			_preparation_option_detail("health", condition_id, _preparation_condition_label(condition_id))))
		value.mouse_exited.connect(_hide_preparation_entry_hover)
		row.add_child(value)
		var remove := _preparation_classic_bare_button("×", func():
			_hide_preparation_entry_hover()
			states.remove_at(target_slot)
			_save_character_inputs()
			_show_characters(), 22, 25, 17)
		row.add_child(remove)
	for slot in range(injuries.size()):
		if not injuries[slot] is Dictionary:
			continue
		var target_slot := slot
		var entry: Dictionary = injuries[slot]
		var row := _hbox(4)
		row.custom_minimum_size = Vector2(277, 25)
		rows.add_child(row)
		var value := _preparation_health_row_button("•  " + _preparation_injury_label(entry), "PreparationInjuryEntry_%d" % slot)
		value.pressed.connect(func(): _open_preparation_injury_dialog(target_slot))
		value.mouse_entered.connect(_show_preparation_entry_hover.bind(value, _preparation_injury_detail(entry)))
		value.mouse_exited.connect(_hide_preparation_entry_hover)
		row.add_child(value)
		var remove := _preparation_classic_bare_button("×", func():
			_hide_preparation_entry_hover()
			_save_character_inputs()
			var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
			var remaining: Array = spec.get("health_injuries", []).duplicate(true)
			remaining.remove_at(target_slot)
			spec["health_injuries"] = remaining
			character_specs[_editing_character_index] = spec
			_show_characters(), 22, 25, 17)
		row.add_child(remove)
	if states.is_empty() and injuries.is_empty():
		rows.add_child(_label(_prep_local("No injuries or conditions", "Yara veya rahatsızlık yok", "Brak urazów i chorób"), 12, MUTED))
	return states


func _preparation_health_row_button(caption: String, node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = caption
	button.custom_minimum_size = Vector2(250, 25)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.clip_text = true
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", _style(Color("#323538"), Color.TRANSPARENT, 0))
	button.add_theme_stylebox_override("pressed", _style(Color("#383c3d"), Color.TRANSPARENT, 0))
	return button


func _preparation_injury_selector(parent: VBoxContainer, caption: String, ids: Array, labels: Array, selected: Dictionary, key: String) -> MenuButton:
	var row := _hbox(7)
	parent.add_child(row)
	var title := _label(caption, 12, MUTED)
	title.custom_minimum_size.x = 82
	row.add_child(title)
	var index := maxi(0, ids.find(selected.get(key, ids[0])))
	var menu := _preparation_classic_gold_menu(str(labels[index]), 216, 27)
	menu.name = "PreparationInjury_%s" % key
	row.add_child(menu)
	for option_index in ids.size():
		menu.get_popup().add_item(str(labels[option_index]), option_index)
	menu.get_popup().id_pressed.connect(func(option_index: int):
		selected[key] = ids[option_index]
		menu.text = str(labels[option_index]))
	return menu


func _preparation_refresh_injury_severity_menu(menu: MenuButton, selected: Dictionary) -> void:
	var injury_id := str(selected.get("kind", "cut_light"))
	var tiers := PreparationRules.injury_severity_tiers(injury_id)
	var popup := menu.get_popup()
	popup.clear()
	for tier in tiers:
		popup.add_item("%s (%d)" % [_preparation_injury_tier_label(str(tier)),
			roundi(PreparationRules.injury_severity(injury_id, str(tier)))])
	var selected_tier := str(selected.get("severity_tier", ""))
	var index := tiers.find(selected_tier)
	if index >= 0:
		menu.text = popup.get_item_text(index)
	else:
		menu.text = "%s (%d)" % [_preparation_injury_tier_label(selected_tier, injury_id),
			roundi(PreparationRules.injury_severity(injury_id, selected_tier))]


func _preparation_refresh_injury_cause_menu(menu: MenuButton, selected: Dictionary) -> void:
	var causes := PreparationRules.injury_causes(str(selected.get("kind", "cut_light")))
	var popup := menu.get_popup()
	popup.clear()
	for cause in causes:
		popup.add_item(_preparation_injury_cause_label(str(cause)))
	var index := maxi(0, causes.find(str(selected.get("cause", "unknown"))))
	menu.text = popup.get_item_text(index)


func _preparation_injury_dynamic_selector(parent: VBoxContainer, caption: String,
		selected: Dictionary, key: String) -> MenuButton:
	var row := _hbox(7)
	parent.add_child(row)
	var title := _label(caption, 12, MUTED)
	title.custom_minimum_size.x = 82
	row.add_child(title)
	var menu := _preparation_classic_gold_menu("", 216, 27)
	menu.name = "PreparationInjury_%s" % key
	row.add_child(menu)
	if key == "severity_tier":
		_preparation_refresh_injury_severity_menu(menu, selected)
		menu.get_popup().id_pressed.connect(func(option_index: int):
			selected[key] = PreparationRules.injury_severity_tiers(str(selected.get("kind", "cut_light")))[option_index]
			_preparation_refresh_injury_severity_menu(menu, selected))
	else:
		_preparation_refresh_injury_cause_menu(menu, selected)
		menu.get_popup().id_pressed.connect(func(option_index: int):
			selected[key] = PreparationRules.injury_causes(str(selected.get("kind", "cut_light")))[option_index]
			_preparation_refresh_injury_cause_menu(menu, selected))
	return menu


func _open_preparation_injury_dialog(entry_index: int) -> void:
	var existing := get_node_or_null("PreparationInjuryDialog")
	if existing != null:
		existing.queue_free()
	var spec: Dictionary = character_specs[_editing_character_index]
	var injuries: Array = spec.get("health_injuries", [])
	var selected: Dictionary = injuries[entry_index].duplicate(true) if entry_index >= 0 and entry_index < injuries.size() else \
		{"kind": "cut_light", "body_part": "left_arm", "count": 1}
	if not selected.has("severity_tier"):
		selected["severity_tier"] = PreparationRules.injury_default_tier(str(selected.get("kind", "cut_light")))
	if not selected.has("cause"):
		selected["cause"] = "unknown"
	var dialog := PanelContainer.new()
	dialog.name = "PreparationInjuryDialog"
	dialog.z_index = 35
	dialog.position = Vector2(maxf(12.0, (size.x - 350.0) * 0.5), maxf(12.0, (size.y - 330.0) * 0.5))
	dialog.custom_minimum_size = Vector2(350, 330)
	var style := _style(Color("#252729"), GOLD, 0)
	style.set_content_margin_all(13)
	dialog.add_theme_stylebox_override("panel", style)
	add_child(dialog)
	var content := _vbox(9)
	dialog.add_child(content)
	content.add_child(_label(_prep_local("Injury", "Yara", "Uraz"), 18, CREAM))
	var kind_labels: Array = []
	for kind in INJURY_KIND_IDS:
		kind_labels.append(_preparation_condition_label(str(kind)))
	var kind_menu := _preparation_injury_selector(content, _prep_local("Type", "Tür", "Rodzaj"), INJURY_KIND_IDS, kind_labels, selected, "kind")
	var part_labels: Array = []
	for body_part in INJURY_BODY_PART_IDS:
		part_labels.append(_preparation_body_part_label(str(body_part)))
	_preparation_injury_selector(content, _prep_local("Body part", "Bölge", "Część ciała"), INJURY_BODY_PART_IDS, part_labels, selected, "body_part")
	var tier_menu := _preparation_injury_dynamic_selector(content, _prep_local("Severity", "Şiddet", "Nasilenie"), selected, "severity_tier")
	var cause_menu := _preparation_injury_dynamic_selector(content, _prep_local("Cause", "Neden", "Przyczyna"), selected, "cause")
	kind_menu.get_popup().id_pressed.connect(func(_option_index: int):
		selected["severity_tier"] = PreparationRules.injury_default_tier(str(selected["kind"]))
		selected["cause"] = "unknown"
		_preparation_refresh_injury_severity_menu(tier_menu, selected)
		_preparation_refresh_injury_cause_menu(cause_menu, selected))
	_preparation_injury_selector(content, _prep_local("Count", "Adet", "Liczba"), [1, 2, 3], ["1", "2", "3"], selected, "count")
	var error_label := _label("", 11, RED)
	error_label.custom_minimum_size.y = 27
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(error_label)
	var actions := _hbox(8)
	actions.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(actions)
	actions.add_child(_preparation_classic_gold_button(_prep_local("Cancel", "İptal", "Anuluj"), dialog.queue_free, 90, 29))
	var apply := _preparation_classic_gold_button(_prep_local("Apply", "Uygula", "Zastosuj"), func():
		_save_character_inputs()
		var updated: Dictionary = character_specs[_editing_character_index].duplicate(true)
		var candidate: Array = updated.get("health_injuries", []).duplicate(true)
		if entry_index < 0:
			candidate.append(selected.duplicate(true))
		else:
			candidate[entry_index] = selected.duplicate(true)
		var injury_error := PreparationRules.preparation_injury_error({
			"health_conditions": updated.get("condition_ids", []), "health_injuries": candidate})
		if not injury_error.is_empty():
			error_label.text = _prep_local(injury_error,
				"Bu yaralar başlangıç için fazla ağır veya tekrarlı. Bölgeyi, türü ya da adedi azalt.",
				"Te obrażenia są zbyt ciężkie lub powtórzone. Zmień część ciała, rodzaj albo liczbę.")
			return
		updated["health_injuries"] = candidate
		character_specs[_editing_character_index] = updated
		dialog.queue_free()
		_show_characters(), 90, 29)
	actions.add_child(apply)


func _preparation_index_taken(states: Array, candidate: int) -> bool:
	for state in states:
		if int(state["index"]) == candidate:
			return true
	return false


func _preparation_skill_field(parent: Control, title: String, initial_index: int, changed: Callable, initial_passion: int = 0, row_y := 0.0) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, 20), "passion": clampi(initial_passion, 0, 2)}
	var row := _hbox(0)
	_preparation_place(parent, row, 14, row_y, 233, 22)
	var caption := _label(title, 13, MUTED)
	caption.custom_minimum_size.x = 88
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(caption)
	var passion := PassionFlame.new()
	passion.custom_minimum_size = Vector2(22, 21)
	passion.level = int(state["passion"])
	passion.tooltip_text = _prep_local("Click to change passion: none, interested, burning", "Tutkuyu değiştirmek için tıkla: yok, ilgili, çok tutkulu", "Kliknij, aby zmienić pasję")
	passion.level_changed.connect(func(next_level: int): state["passion"] = next_level; changed.call())
	row.add_child(passion)
	state["passion_button"] = passion
	var level := PrepStepper.new(int(state["index"]), 0, 20, "skill")
	row.add_child(level)
	level.changed.connect(func(value: int):
		state["index"] = value
		changed.call())
	state["level"] = level
	var dash := _label("−", 18, MUTED)
	dash.custom_minimum_size = Vector2(128, 21)
	dash.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dash.visible = false
	row.add_child(dash)
	state["dash"] = dash
	return state


func _set_preparation_skill_disabled(field: Dictionary, disabled: bool) -> void:
	(field["level"] as Control).visible = not disabled
	(field["passion_button"] as Control).visible = not disabled
	(field["dash"] as Control).visible = disabled


func _preparation_palette(parent: VBoxContainer, title: String, colors: Array, field: Dictionary) -> Dictionary:
	var row := _hbox(5)
	parent.add_child(row)
	var caption := _label(title, 11, MUTED)
	caption.custom_minimum_size.x = 75
	row.add_child(caption)
	var buttons: Array[Button] = []
	for color_index in colors.size():
		var choice := color_index
		var swatch := Button.new()
		swatch.custom_minimum_size = Vector2(23, 23)
		swatch.tooltip_text = str(field["values"][color_index])
		swatch.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		swatch.pressed.connect(func():
			field["index"] = choice
			(field["option"] as OptionButton).select(choice)
			_refresh_character_editor())
		row.add_child(swatch)
		buttons.append(swatch)
	return {"colors": colors, "buttons": buttons, "field": field}


func _refresh_preparation_palette(palette: Dictionary) -> void:
	var buttons: Array = palette["buttons"]
	var colors: Array = palette["colors"]
	var field: Dictionary = palette["field"]
	for i in buttons.size():
		var selected: bool = i == int(field["index"])
		var swatch: Button = buttons[i]
		for style_name in ["normal", "hover", "pressed"]:
			var style := _style(Color(str(colors[i])), GOLD if selected else Color("#53626a"), 2)
			style.border_width_left = 3 if selected else 1
			style.border_width_top = 3 if selected else 1
			style.border_width_right = 3 if selected else 1
			style.border_width_bottom = 3 if selected else 1
			style.content_margin_left = 0
			style.content_margin_right = 0
			style.content_margin_top = 0
			style.content_margin_bottom = 0
			swatch.add_theme_stylebox_override(style_name, style)


func _hair_options() -> Array:
	if preferences.language == "tr":
		return ["Kısa", "Dalgalı", "Uzun", "Kıvırcık", "Kazınmış"]
	if preferences.language == "pl":
		return ["Krótkie", "Falowane", "Długie", "Kręcone", "Wygolone"]
	return HAIR_OPTIONS


func _preparation_trait_names() -> Array:
	if preferences.language == "tr":
		return ["Yok", "Çalışkan", "Sakin", "Çevik", "Meraklı", "İyi kalpli", "Gece kuşu", "Çekingen", "Geçimsiz", "Tembel", "Piroman", "Hızlı yürür", "Çirkin"]
	if preferences.language == "pl":
		return ["Brak", "Pracowity", "Spokojny", "Zwinny", "Ciekawski", "Życzliwy", "Nocny marek", "Nieśmiały", "Opryskliwy", "Leniwy", "Piroman", "Szybki chód", "Brzydki"]
	return TRAIT_NAMES


func _preparation_condition_names() -> Array:
	if preferences.language == "tr":
		return ["Yok", "Astım", "Bel sorunu", "Yara izi", "Hafif kesik", "Derin kesik", "Ezik", "Yanık", "Çizik"]
	if preferences.language == "pl":
		return ["Brak", "Astma", "Ból pleców", "Blizna", "Lekkie skaleczenie", "Głębokie skaleczenie", "Stłuczenie", "Oparzenie", "Zadrapanie"]
	return CONDITION_NAMES


func _preparation_condition_label(condition_id: String) -> String:
	var index := CONDITION_IDS.find(condition_id)
	return str(_preparation_condition_names()[index]) if index >= 0 else condition_id.capitalize()


func _preparation_wound_label(kind: String) -> String:
	match kind:
		"scar": return _prep_local("Scar", "Yara izi", "Blizna")
		"cut": return _prep_local("Cut", "Kesik", "Skaleczenie")
		"bruise": return _prep_local("Bruise", "Ezik", "Stłuczenie")
		"burn": return _prep_local("Burn", "Yanık", "Oparzenie")
		"scratch": return _prep_local("Scratch", "Çizik", "Zadrapanie")
	return kind.capitalize()

func _save_character_inputs() -> void:
	for input in _character_inputs:
		var spec: Dictionary = character_specs[int(input.index)].duplicate(true)
		spec["nickname"] = _normalize_prepared_nickname((input.name as LineEdit).text)
		spec["first_name"] = (input.first_name as LineEdit).text.strip_edges()
		spec["last_name"] = (input.last_name as LineEdit).text.strip_edges()
		spec["name"] = _prepared_display_name(spec)
		spec["hair_index"] = int(input.hair["index"])
		var chosen_hair_ids := MALE_HAIR_IDS if int(input.sex["index"]) == 1 else FEMALE_HAIR_IDS
		spec["hair_style"] = chosen_hair_ids[clampi(int(input.hair["index"]), 0, chosen_hair_ids.size() - 1)]
		spec["body_type"] = int(input.body_type["index"])
		spec["head_type"] = int(input.head_type["index"])
		if input.hair_color is PrepColorButton:
			spec["hair_color"] = "#" + (input.hair_color as PrepColorButton).color.to_html(false)
		if input.skin is PrepColorButton:
			spec["skin_color"] = "#" + (input.skin as PrepColorButton).color.to_html(false)
		spec["sex"] = ["female", "male"][int(input.sex["index"])]
		spec["age"] = int((input.age as PrepStepper).value)
		spec["chronological_age"] = maxi(int((input.chronological_age as PrepStepper).value), spec["age"])
		spec["childhood"] = CHILDHOOD_IDS[int(input.childhood["index"])]
		spec["adulthood"] = ADULTHOOD_IDS[int(input.adulthood["index"])]
		var traits: Array = []
		for selection in input.traits:
			var trait_id: String = str(TRAIT_IDS[int(selection["index"])])
			if not trait_id.is_empty(): traits.append(trait_id)
		spec["trait_ids"] = traits
		var conditions: Array = []
		for selection in input.conditions:
			var condition_id: String = str(CONDITION_IDS[int(selection["index"])])
			if not condition_id.is_empty(): conditions.append(condition_id)
		spec["condition_ids"] = conditions
		var skills: Dictionary = {}
		var passions: Dictionary = {}
		for skill in input.skills:
			skills[skill] = clampi(int(input.skills[skill]["index"]) - int(input.modifiers.get(skill, 0)), 0, 20)
			passions[skill] = int(input.skills[skill]["passion"])
		spec["skills"] = _derive_work_skills(skills)
		spec["passions"] = passions
		character_specs[int(input.index)] = spec

func _refresh_character_editor() -> void:
	if _character_inputs.is_empty():
		return
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	var input: Dictionary = _character_inputs[0]
	var modifiers: Dictionary = PreparationRules.skill_modifiers(str(spec.get("childhood", "rural_child")), str(spec.get("adulthood", "farmer")), spec.get("trait_ids", []), spec.get("condition_ids", []))
	var incapable: Array = PreparationRules.incapable_of(str(spec.get("childhood", "rural_child")), str(spec.get("adulthood", "farmer")), spec.get("trait_ids", []), spec.get("condition_ids", []))
	for skill in input.skills:
		var next_level := clampi(int(spec.get("skills", {}).get(skill, 0)) + int(modifiers.get(skill, 0)), 0, 20)
		input.skills[skill]["index"] = next_level
		(input.skills[skill]["level"] as PrepStepper).set_value(next_level, false)
		_set_preparation_skill_disabled(input.skills[skill], incapable.has(skill))
	input["modifiers"] = modifiers
	var incapable_names: Array[String] = []
	for work in incapable:
		incapable_names.append(_preparation_incapable_name(str(work)))
	(input.incapable_text as Label).text = ", ".join(incapable_names) if not incapable_names.is_empty() else _prep_local("Nothing", "Yok", "Brak")
	(input.preview as Control).call("set_appearance", _spec_appearance(spec))
	(input.childhood_note as Label).text = [
		_prep_local("Grew up among fields and practical work.", "Tarlalar ve günlük işler arasında büyüdü.", "Dorastał pośród pól i codziennej pracy."),
		_prep_local("Learned to adapt to a crowded town.", "Kalabalık bir kasabada uyum sağlamayı öğrendi.", "Nauczył się żyć w zatłoczonym mieście."),
		_prep_local("Spent their early years learning a trade.", "İlk yıllarını bir zanaat öğrenerek geçirdi.", "Młode lata spędził na nauce fachu."),
		_prep_local("Raised as a soldier in a growth vat.", "Büyüme tankında asker olarak yetiştirildi.", "Wychowany w kadzi jako żołnierz."),
		_prep_local("No known childhood; no effects.", "Bilinen çocukluğu yok; etkisi yok.", "Nieznane dzieciństwo; bez efektów."),
	][int(input.childhood["index"])]
	(input.adulthood_note as Label).text = [
		_prep_local("Worked the land before this expedition.", "Bu yolculuktan önce toprağı işledi.", "Przed wyprawą pracował na roli."),
		_prep_local("Helped raise and repair settlements.", "Yerleşkeler kurup onarmaya yardım etti.", "Pomagał budować i naprawiać osady."),
		_prep_local("Cared for the injured and sick.", "Yaralılarla ve hastalarla ilgilendi.", "Opiekował się rannymi i chorymi."),
		_prep_local("Studied and pursued new discoveries.", "Çalışıp yeni keşiflerin peşinden gitti.", "Studiował i szukał nowych odkryć."),
		_prep_local("No known adulthood; no effects.", "Bilinen yetişkinlik geçmişi yok; etkisi yok.", "Nieznana dorosłość; bez efektów."),
	][int(input.adulthood["index"])]
	(input.childhood["row"] as Control).tooltip_text = ""
	(input.adulthood["row"] as Control).tooltip_text = ""
	for i in mini(_roster_buttons.size(), character_specs.size()):
		var roster_spec: Dictionary = character_specs[i]
		var card: Button = _roster_buttons[i]
		var roster_name := card.get_node_or_null("RosterName") as Label
		var roster_role := card.get_node_or_null("RosterRole") as Label
		var roster_portrait := card.get_node_or_null("RosterPortrait") as PawnPortrait
		if roster_name != null:
			roster_name.text = _prepared_display_name(roster_spec)
			roster_name.tooltip_text = roster_name.text
			card.tooltip_text = roster_name.text
		if roster_role != null:
			roster_role.text = _preparation_roster_role(roster_spec)
		if roster_portrait != null:
			roster_portrait.set_appearance(_spec_appearance(roster_spec))
	_refresh_character_points()

func _refresh_character_points() -> void:
	if not is_instance_valid(_character_points) or character_specs.is_empty():
		return
	var spent := _preparation_spent_for_specs(character_specs)
	var budget := int(Game.preparation_budget(scenario_id))
	_character_points.text = (_prep_local("Points Remaining: %d", "Kalan Puan: %d", "Pozostałe punkty: %d") % (budget - spent)) if point_limit_enabled else (_prep_local("Points Spent: %d", "Harcanan Puan: %d", "Wydane Punkty: %d") % spent)
	_character_points.tooltip_text = _prep_local("Scenario point limit: %d", "Senaryo puan sınırı: %d", "Limit punktów scenariusza: %d") % budget
	_character_points.add_theme_color_override("font_color", RED if point_limit_enabled and spent > budget else MUTED)


func _preparation_spent_for_specs(specs: Array) -> int:
	var people: Array = []
	for spec in specs:
		people.append({"traits": spec.get("trait_ids", []), "health_conditions": spec.get("condition_ids", []),
			"health_injuries": spec.get("health_injuries", []),
			"childhood": spec.get("childhood", "rural_child"), "adulthood": spec.get("adulthood", "farmer"),
			"skills": spec.get("skills", {}), "passions": spec.get("passions", {}), "starting_gear": spec.get("starting_gear", {})})
	return int(Game.preparation_total_points(people, starting_cargo))


func _preparation_random_candidate_fits(candidate: Dictionary) -> bool:
	if not PreparationRules.preparation_injury_error({"health_conditions": candidate.get("condition_ids", []),
		"health_injuries": candidate.get("health_injuries", [])}).is_empty():
		return false
	if not point_limit_enabled:
		return true
	var specs := character_specs.duplicate(true)
	specs[_editing_character_index] = candidate
	return _preparation_spent_for_specs(specs) <= int(Game.preparation_budget(scenario_id))


func _select_character_editor(index: int) -> void:
	_save_character_inputs()
	_editing_character_index = index
	_show_characters()


func _update_character_preview(preview: Control, hair: OptionButton, hair_color: OptionButton, skin: OptionButton, outfit: OptionButton) -> void:
	var hair_ids := ["short", "wavy", "long", "curly", "shaved"]
	preview.call("set_appearance", {"hair": hair_ids[hair.selected], "hair_color": HAIR_COLOR_OPTIONS[hair_color.selected], "skin": SKIN_OPTIONS[skin.selected], "outfit": OUTFIT_OPTIONS[outfit.selected]})


func _return_to_world_from_characters() -> void:
	_save_character_inputs()
	_show_world_selection()


func _advance_to_lobby() -> void:
	_save_character_inputs()
	for spec in character_specs:
		if _prepared_display_name(spec).is_empty():
			_notice(_prep_local("Every colonist needs a name.", "Her kolonistin bir adı olmalı.", "Każdy kolonista musi mieć imię."))
			return
	var prepared := _game_setup_config()
	var validation: Dictionary = Game.validate_setup(prepared)
	if not bool(validation.get("ok", false)):
		_notice(str(validation.get("error", "Colonist setup is invalid.")))
		return
	# Naming happens after the colonists have spent time in their new home.
	# It must never block starting a solo or multiplayer colony.
	if session_kind == "join":
		_submit_joiner_setup()
	elif session_kind == "solo":
		_start_prepared_game()
	else:
		_show_lobby()


func _show_lobby() -> void:
	screen = "lobby"
	var root := _clear_screen()
	_add_menu_backdrop()
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel := _panel(Vector2(600, 0))
	center.add_child(panel)
	var inner := _vbox(12)
	panel.add_child(inner)
	inner.add_child(_label(_prep_local("Multiplayer lobby", "Çok oyunculu lobi", "Poczekalnia wieloosobowa"), 23, GOLD))
	inner.add_child(_label("%s  ·  %d %s  ·  Seed %s" % [_mode_label(), colonist_count, _prep_local("colonists", "kolonist", "kolonistów"), setup_seed], 14, MUTED))
	inner.add_child(HSeparator.new())
	if session_kind == "host":
		var lobby: Dictionary = Net.get_lobby()
		inner.add_child(_label(_prep_local("Connected players", "Bağlanan oyuncular", "Połączeni gracze"), 15, GOLD))
		for player_id in lobby.get("players", []):
			var ready: Dictionary = lobby.get("ready", {})
			var name := _prep_local("Host", "Ev sahibi", "Gospodarz") if int(player_id) == 1 else "%s %s" % [_prep_local("Player", "Oyuncu", "Gracz"), str(player_id)]
			inner.add_child(_label("● %s — %s" % [name, _prep_local("Ready", "Hazır", "Gotowy") if bool(ready.get(str(player_id), false)) else _prep_local("Preparing", "Hazırlanıyor", "Przygotowuje się")], 15, CREAM))
		if setup_mode == "competitive" and (lobby.get("players", []) as Array).size() < 2:
			inner.add_child(_label(_prep_local("Waiting for another player.", "Başka bir oyuncu bekleniyor.", "Oczekiwanie na drugiego gracza."), 14, RED))
	var buttons := _hbox(8)
	inner.add_child(buttons)
	buttons.add_child(_button(_prep_local("Edit colonists", "Kolonistleri düzenle", "Edytuj kolonistów"), _show_characters))
	buttons.add_child(_button(_prep_local("Start game", "Oyunu başlat", "Rozpocznij grę"), _start_prepared_game, true, Vector2(170, 38)))


func _mode_label() -> String:
	if setup_mode == "coop":
		return "Co-op"
	if setup_mode == "competitive":
		return _prep_local("Separate colonies", "Ayrı koloniler", "Osobne kolonie")
	return _prep_local("Single player", "Tek oyunculu", "Jeden gracz")


func _show_waiting_room(message: String) -> void:
	screen = "waiting"
	var root := _clear_screen()
	_add_menu_backdrop()
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel := _panel(Vector2(600, 0))
	center.add_child(panel)
	var inner := _vbox(14)
	panel.add_child(inner)
	inner.add_child(_label(_prep_local("Multiplayer lobby", "Çok oyunculu lobi", "Poczekalnia wieloosobowa"), 23, GOLD))
	inner.add_child(_label(message, 20, CREAM))
	inner.add_child(_label(_prep_local("The game begins when the host starts the world.", "Ev sahibi dünyayı başlattığında oyuna geçeceksin.", "Gra rozpocznie się, gdy gospodarz uruchomi świat."), 15, MUTED))
	if session_kind == "join" and setup_mode == "coop":
		inner.add_child(_button(_prep_local("Ready", "Hazırım", "Gotowy"), _submit_coop_ready, true))
	inner.add_child(_button(_prep_local("Main menu", "Ana menü", "Menu główne"), _show_menu))


func _submit_coop_ready() -> void:
	var result = Net.submit_player_setup({})
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", _prep_local("Could not send ready status.", "Hazır durumu gönderilemedi.", "Nie można przesłać gotowości."))))
		return
	_show_waiting_room(_prep_local("You are ready. Waiting for the host to start.", "Hazırsın. Ev sahibinin başlaması bekleniyor.", "Gotowość potwierdzona. Oczekiwanie na gospodarza."))


func _submit_joiner_setup() -> void:
	var spec := _build_faction_spec()
	var result = Net.submit_player_setup(spec)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", _prep_local("Could not send colony setup.", "Hazırlık gönderilemedi.", "Nie można przesłać ustawień kolonii."))))
		return
	_show_waiting_room(_prep_local("Your colony is ready. Waiting for the host to start.", "Kolonin hazır. Ev sahibinin oyunu başlatması bekleniyor.", "Twoja kolonia jest gotowa. Oczekiwanie na gospodarza."))


func _on_lobby_changed(lobby: Dictionary) -> void:
	if session_kind == "host" and screen == "lobby":
		_show_lobby()
	elif session_kind == "join" and screen == "waiting" and not bool(lobby.get("started", false)):
		setup_mode = str(lobby.get("mode", "coop"))
		setup_seed = str(lobby.get("seed", ""))
		if character_specs.is_empty():
			colonist_count = clampi(int(lobby.get("colonists_per_faction", 3)), 1, 8)
		world_options = (lobby.get("world_options", {}) as Dictionary).duplicate(true)
		scenario_id = str(lobby.get("scenario_id", "landfall"))
		storyteller_id = str(lobby.get("storyteller_id", "steady"))
		difficulty_id = str(lobby.get("difficulty_id", "frontier"))
		if starting_cargo.is_empty():
			starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
		if setup_mode == "competitive" and character_specs.is_empty():
			world_preview = Game.preview_world(setup_seed, world_options)
			selected_site_id = ""
			for site in world_preview.get("sites", []):
				if str(site.get("kind", "")) == "vacant":
					selected_site_id = str(site.get("id", ""))
					break
			_show_world_selection()
		elif setup_mode == "coop" and (Net.get_lobby().get("ready", {}) as Dictionary).get(str(Net.get_local_peer_id()), false):
			_show_waiting_room(_prep_local("You are ready. Waiting for the host to start.", "Hazırsın. Ev sahibinin başlaması bekleniyor.", "Gotowość potwierdzona. Oczekiwanie na gospodarza."))
		elif setup_mode == "coop":
			_show_waiting_room(_prep_local("Connected to a co-op room. You share the colony and colonists.", "Co-op odasına bağlandın. Aynı koloni ve karakterleri yöneteceksin.", "Połączono z pokojem kooperacyjnym. Dzielicie kolonię i kolonistów."))


func _on_connection_changed(connected: bool, message: String) -> void:
	if session_kind == "join" and not connected and screen == "waiting" and message != _prep_local("Connecting to server…", "Sunucuya bağlanılıyor…", "Łączenie z serwerem…"):
		_notice(message)


func _on_network_snapshot(snapshot: Dictionary) -> void:
	if session_kind == "join" and screen != "game" and not snapshot.is_empty():
		for faction in _values_array(snapshot.get("factions", [])):
			if faction is Dictionary and (faction.get("players", []) as Array).has(Net.get_local_peer_id()):
				selected_site_id = str(faction.get("site_id", ""))
				faction_name = str(faction.get("name", _prep_local("Colony", "Koloni", "Kolonia")))
				settlement_name = str(faction.get("settlement_name", _prep_local("Settlement", "Yerleşke", "Osada")))
				break
		_show_game()


func _start_prepared_game() -> void:
	if screen == "game":
		return
	if session_kind == "host" and setup_mode == "competitive" and (Net.get_lobby().get("players", []) as Array).size() < 2:
		_notice(_prep_local("Separate colonies requires at least one other player.", "Ayrı Koloniler için en az bir oyuncu daha bağlanmalı.", "Osobne kolonie wymagają co najmniej jeszcze jednego gracza."))
		return
	var config := _game_setup_config()
	var result = Net.start_game(config)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", _prep_local("Could not start the game.", "Oyun başlatılamadı.", "Nie można rozpocząć gry."))))
		return
	_show_game()


func _game_setup_config() -> Dictionary:
	return {"seed": setup_seed, "mode": setup_mode, "colonists_per_faction": colonist_count,
		"point_limit_enabled": point_limit_enabled, "faction_specs": [_build_faction_spec()],
		"scenario_id": scenario_id, "storyteller_id": storyteller_id,
		"difficulty_id": difficulty_id, "world_options": world_options.duplicate(true)}


func _build_faction_spec() -> Dictionary:
	var people: Array = []
	for spec in character_specs:
		people.append({
			"name": _prepared_display_name(spec),
			"first_name": str(spec.get("first_name", spec.get("name", "Colonist"))),
			"nickname": str(spec.get("nickname", "")),
			"last_name": str(spec.get("last_name", "")),
			"sex": str(spec.get("sex", "female")),
			"gender": "woman" if str(spec.get("sex", "female")) == "female" else "man",
			"age": int(spec.get("age", 25)),
			"chronological_age": int(spec.get("chronological_age", spec.get("age", 25))),
			"favorite_color": str(spec.get("favorite_color", "#8d985d")),
			"childhood": str(spec.get("childhood", "rural_child")),
			"adulthood": str(spec.get("adulthood", "farmer")),
			"starting_gear": spec.get("starting_gear", {"weapon": "fists", "shirt": "tshirt", "pants": "pants"}).duplicate(true),
			"starting_relationships": spec.get("starting_relationships", {}).duplicate(true),
			"skills": spec.get("skills", {}).duplicate(true),
			"passions": spec.get("passions", {}).duplicate(true),
			"health_conditions": spec.get("condition_ids", []).duplicate(),
			"health_injuries": spec.get("health_injuries", []).duplicate(true),
			"appearance": _spec_appearance(spec),
			"traits": spec.get("trait_ids", []).duplicate()
		})
	var world_people: Array = []
	for spec in world_character_specs:
		world_people.append({
			"name": _prepared_display_name(spec),
			"first_name": str(spec.get("first_name", spec.get("name", "World person"))),
			"nickname": str(spec.get("nickname", "")),
			"last_name": str(spec.get("last_name", "")),
			"sex": str(spec.get("sex", "female")),
			"age": int(spec.get("age", 25)),
			"chronological_age": int(spec.get("chronological_age", spec.get("age", 25))),
			"appearance": _spec_appearance(spec)
		})
	return {
		"id": 1,
		"colonist_count": colonist_count,
		"name": faction_name,
		"settlement_name": settlement_name,
		"site_id": selected_site_id,
		"starting_cargo": starting_cargo.duplicate(true),
		"players": [1],
		"colonists": people,
		"world_characters": world_people,
		"external_relationships": external_relationships.duplicate(true)
	}


func _choose_rival_site() -> String:
	for site in world_preview.get("sites", []):
		var id := str(site.get("id", ""))
		if id != selected_site_id and (str(site.get("kind", "")) == "vacant" or str(site.get("kind", "")) == "player"):
			return id
	return selected_site_id


func _snapshot() -> Dictionary:
	# The local UI only reads model data. Copies are made for saves and remote
	# peers, avoiding repeated 50×50 map clones during every screen refresh.
	return Game.state


func _show_game() -> void:
	screen = "game"
	_active_alerts.clear()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_root = root
	var terrain_layer := MapViewScript.new()
	terrain_layer.render_terrain_only = true
	root.add_child(terrain_layer)
	terrain_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_map_view = MapViewScript.new()
	_map_view.terrain_layer = terrain_layer
	_map_view.map_pressed.connect(_on_map_pressed)
	_map_view.set_simulation_rate(speed * NORMAL_STEPS_PER_REAL_SECOND)
	root.add_child(_map_view)
	_map_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var overlay := Control.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_resource_stack = _vbox(1)
	_resource_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(_resource_stack)
	_place(_resource_stack, 0.0, 0.0, 0.0, 0.0, 8, 7, 105, 132)
	var portraits_center := CenterContainer.new()
	portraits_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(portraits_center)
	_place(portraits_center, 0.0, 0.0, 1.0, 0.0, 110, 0, -110, 68)
	_portrait_strip = _hbox(3)
	portraits_center.add_child(_portrait_strip)
	_portrait_signature = ""
	_alert_stack = _vbox(3)
	_alert_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(_alert_stack)
	_place(_alert_stack, 1.0, 0.52, 1.0, 0.82, -285, 0, -8, 0)
	_notice_label = _label("", 13, GOLD)
	_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(_notice_label)
	_place(_notice_label, 1.0, 0.0, 1.0, 0.0, -390, 12, -8, 90)
	var tab_background := PanelContainer.new()
	tab_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_background.add_theme_stylebox_override("panel", _hud_style(HUD_BG))
	overlay.add_child(tab_background)
	_place(tab_background, 0.0, 1.0, 1.0, 1.0, 0, -38, 0, 0)
	var tab_row := _hbox(1)
	overlay.add_child(tab_row)
	_place(tab_row, 0.0, 1.0, 1.0, 1.0, 1, -37, -1, -1)
	_tab_buttons.clear()
	for entry in [["Emirler", "tabs.architect"], ["İşler", "tabs.work"], ["Günlük plan", "tabs.schedule"],
		["Araştırma", "tabs.research"], ["Dünya", "tabs.world"]]:
		var name_copy: String = entry[0]
		var tab_label := _tr(entry[1])
		var tab_button := _hud_button(tab_label, func(): _set_tab(name_copy), name_copy == current_tab, Vector2(138, 36))
		tab_row.add_child(tab_button)
		_tab_buttons[name_copy] = tab_button
	_update_tab_shortcut_hints()
	var tab_spacer := Control.new()
	tab_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_row.add_child(tab_spacer)
	_tool_panel = _panel()
	_tool_panel.add_theme_stylebox_override("panel", _hud_style(HUD_PANEL))
	overlay.add_child(_tool_panel)
	_place(_tool_panel, 0.0, 1.0, 0.78, 1.0, 8, -292, -8, -42)
	var sidebar_scroll := ScrollContainer.new()
	sidebar_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tool_panel.add_child(sidebar_scroll)
	_sidebar = _vbox(6)
	_sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.add_child(_sidebar)
	_tool_panel.visible = not current_tab.is_empty()
	_pawn_panel = _panel()
	_pawn_panel.add_theme_stylebox_override("panel", _hud_style(HUD_PANEL))
	overlay.add_child(_pawn_panel)
	_place(_pawn_panel, 0.0, 1.0, 0.0, 1.0, 0, -175, 468, -41)
	_pawn_summary = _vbox(4)
	_pawn_panel.add_child(_pawn_summary)
	_pawn_panel.visible = false
	_pawn_detail_panel = _panel()
	_pawn_detail_panel.add_theme_stylebox_override("panel", _hud_style(HUD_PANEL))
	overlay.add_child(_pawn_detail_panel)
	_place(_pawn_detail_panel, 0.0, 1.0, 0.0, 1.0, 0, -584, 548, -177)
	var detail_scroll := ScrollContainer.new()
	_pawn_detail_panel.add_child(detail_scroll)
	_pawn_detail_content = _vbox(6)
	detail_scroll.add_child(_pawn_detail_content)
	_pawn_detail_panel.visible = false
	_command_strip = _hbox(3)
	overlay.add_child(_command_strip)
	_place(_command_strip, 0.0, 1.0, 0.0, 1.0, 478, -108, 1010, -42)
	_command_strip.visible = false
	_time_label = _label("", 13, CREAM)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_time_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_time_label.add_theme_constant_override("shadow_offset_x", 1)
	_time_label.add_theme_constant_override("shadow_offset_y", 1)
	overlay.add_child(_time_label)
	_place(_time_label, 1.0, 1.0, 1.0, 1.0, -255, -139, -10, -113)
	var speeds := _hbox(3)
	overlay.add_child(speeds)
	_place(speeds, 1.0, 1.0, 1.0, 1.0, -213, -108, -10, -67)
	_speed_buttons.clear()
	for entry in [["Ⅱ", 0.0], ["▶", 1.0], ["▶▶", 3.0], ["▶▶▶", 6.0]]:
		var speed_value: float = entry[1]
		var speed_button := _hud_button(str(entry[0]), func(): _set_speed(speed_value), false, Vector2(48, 33))
		speed_button.tooltip_text = _prep_local("Pause", "Duraklat", "Pauza") if speed_value == 0.0 else "%d×" % int(speed_value)
		speeds.add_child(speed_button)
		_speed_buttons[str(entry[0])] = speed_button
	_update_speed_buttons()
	_context_menu = PopupMenu.new()
	_context_menu.id_pressed.connect(_context_selected)
	add_child(_context_menu)
	_render_game()
	if not current_tab.is_empty():
		_render_sidebar(_snapshot())
	_map_view.call_deferred("focus_tile", Vector2i(25, 25))
	var my_faction := _my_faction(_snapshot())
	if session_kind != "join" and _faction_still_unnamed(my_faction):
		call_deferred("_open_naming_prompt")


func _hud_style(fill: Color, edge: Color = HUD_BORDER) -> StyleBoxFlat:
	var style := _style(fill, edge, 0)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style


func _hud_button(title: String, action: Callable, active: bool = false, minimum: Vector2 = Vector2(80, 32)) -> Button:
	var button := _button(title, action, false, minimum)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", CREAM)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _hud_style(HUD_ACTIVE if active else HUD_TAB))
	button.add_theme_stylebox_override("hover", _hud_style(Color("#586c76")))
	button.add_theme_stylebox_override("pressed", _hud_style(Color("#374750")))
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button

func _place(control: Control, left_anchor: float, top_anchor: float, right_anchor: float, bottom_anchor: float, left_offset: float, top_offset: float, right_offset: float, bottom_offset: float) -> void:
	control.anchor_left = left_anchor
	control.anchor_top = top_anchor
	control.anchor_right = right_anchor
	control.anchor_bottom = bottom_anchor
	control.offset_left = left_offset
	control.offset_top = top_offset
	control.offset_right = right_offset
	control.offset_bottom = bottom_offset


func _set_tab(name: String) -> void:
	if _naming_prompt_open:
		return
	if name == "Sağlık":
		if selected_ids.is_empty():
			_notice(_prep_local("Select a colonist to see health.", "Sağlığı görmek için bir kolonist seç.", "Wybierz kolonistę, aby zobaczyć zdrowie."))
		else:
			pawn_tab = "" if pawn_tab == "Health" else "Health"
			_render_selected_pawn(_snapshot())
		return
	if name == "Ticaret":
		_notice(_prep_local("Select a colonist and speak to a visiting trader, or use World for colony offers.", "Bir kolonist seçip gelen tüccarla konuş veya koloniler arası teklif için Dünya'yı aç.", "Wybierz kolonistę i porozmawiaj z handlarzem albo otwórz Świat, aby handlować z kolonią."))
		return
	if is_instance_valid(_command_strip):
		_command_strip.set_meta("pending_direct_action", "")
	current_tab = "" if current_tab == name else name
	current_tool = ""
	if not current_tab.is_empty():
		selected_ids.clear()
		pawn_tab = ""
		_render_game()
	if is_instance_valid(_tool_panel):
		_tool_panel.visible = not current_tab.is_empty()
		_tool_panel.offset_top = -185 if current_tab == "Emirler" else -292
	if is_instance_valid(_notice_label):
		_notice_label.text = ""
	for tab_name in _tab_buttons:
		var button := _tab_buttons[tab_name] as Button
		button.add_theme_stylebox_override("normal", _hud_style(HUD_ACTIVE if tab_name == current_tab else HUD_TAB))
	if not current_tab.is_empty():
		_render_sidebar(_snapshot())


func _toggle_pause() -> void:
	game_paused = not game_paused
	_update_speed_buttons()


func _set_speed(value: float) -> void:
	if _naming_prompt_open:
		return
	if value == 0.0:
		game_paused = true
	else:
		game_paused = false
		speed = value
		if is_instance_valid(_map_view):
			_map_view.set_simulation_rate(speed * NORMAL_STEPS_PER_REAL_SECOND)
	_update_speed_buttons()

func _update_speed_buttons() -> void:
	var speed_for_button := {"Ⅱ": 0.0, "▶": 1.0, "▶▶": 3.0, "▶▶▶": 6.0}
	for key in _speed_buttons:
		var button := _speed_buttons[key] as Button
		var active: bool = (game_paused and key == "Ⅱ") or (not game_paused and is_equal_approx(speed, float(speed_for_button[key])))
		button.add_theme_stylebox_override("normal", _hud_style(HUD_ACTIVE if active else HUD_TAB))
		button.add_theme_color_override("font_color", Color.WHITE if active else CREAM)

func _tr(key: String, values: Dictionary = {}) -> String:
	return I18n.t(key, preferences.language, values)

func _show_settings() -> void:
	if is_instance_valid(_settings_overlay):
		return
	_settings_return_paused = game_paused
	if screen == "game":
		game_paused = true
		_update_speed_buttons()
	_settings_overlay = ColorRect.new()
	_settings_overlay.color = Color(0.01, 0.02, 0.025, 0.72)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_settings_overlay)
	_settings_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_settings_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := _panel(Vector2(760, 530))
	var frame := _style(Color("#171c20"), Color("#8a806d"), 1)
	frame.content_margin_left = 18
	frame.content_margin_top = 15
	frame.content_margin_right = 18
	frame.content_margin_bottom = 15
	panel.add_theme_stylebox_override("panel", frame)
	center.add_child(panel)
	var content := _vbox(14)
	panel.add_child(content)
	var title_row := _hbox(8)
	content.add_child(title_row)
	var title := _label(_tr("settings.title"), 24, CREAM)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	title_row.add_child(_button("×", _close_settings, false, Vector2(34, 32)))
	content.add_child(HSeparator.new())
	var columns := _hbox(18)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(columns)
	var categories := _vbox(6)
	categories.custom_minimum_size.x = 165
	columns.add_child(categories)
	var divider := VSeparator.new()
	columns.add_child(divider)
	var page := _vbox(12)
	page.custom_minimum_size = Vector2(500, 0)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var page_scroll := ScrollContainer.new()
	page_scroll.custom_minimum_size = Vector2(510, 0)
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	columns.add_child(page_scroll)
	page_scroll.add_child(page)
	var draft := {
		"window_mode": preferences.window_mode,
		"display_index": preferences.display_index,
		"resolution": preferences.resolution,
		"language": preferences.language,
		"master_volume": preferences.master_volume,
		"music_volume": preferences.music_volume,
		"effects_volume": preferences.effects_volume,
		"autosave_interval_minutes": preferences.autosave_interval_minutes,
		"autosave_count": preferences.autosave_count,
		"keybinds": preferences.keybinds.duplicate(),
	}
	_settings_draft = draft
	_settings_page = page
	var selected_category := ["general"]
	var category_buttons: Dictionary = {}
	for entry in [["general", "settings.general"], ["graphics", "settings.display"], ["audio", "settings.audio"], ["controls", "settings.controls"]]:
		var category_id := str(entry[0])
		var button := _button(_tr(str(entry[1])), func():
			_capture_keybind_action = ""
			selected_category[0] = category_id
			_build_settings_page(page, category_id, draft)
			for key in category_buttons:
				(category_buttons[key] as Button).add_theme_stylebox_override("normal", _style(Color("#665136") if key == category_id else PANEL_ALT, Color("#8a7855") if key == category_id else HUD_BORDER))
		, false, Vector2(160, 36))
		categories.add_child(button)
		category_buttons[category_id] = button
	(category_buttons["general"] as Button).add_theme_stylebox_override("normal", _style(Color("#665136"), Color("#8a7855")))
	_build_settings_page(page, "general", draft)
	content.add_child(HSeparator.new())
	var actions := _hbox(8)
	content.add_child(actions)
	actions.add_child(_button(_tr("common.cancel"), _close_settings, false, Vector2(110, 34)))
	var action_spacer := Control.new()
	action_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(action_spacer)
	actions.add_child(_button(_tr("settings.restore"), func():
		var defaults = SettingsScript.new()
		draft["window_mode"] = defaults.window_mode
		draft["display_index"] = defaults.display_index
		draft["resolution"] = defaults.resolution
		draft["language"] = defaults.language
		draft["master_volume"] = defaults.master_volume
		draft["music_volume"] = defaults.music_volume
		draft["effects_volume"] = defaults.effects_volume
		draft["autosave_interval_minutes"] = defaults.autosave_interval_minutes
		draft["autosave_count"] = defaults.autosave_count
		draft["keybinds"] = defaults.keybinds.duplicate()
		for volume_key in ["master_volume", "music_volume", "effects_volume"]:
			AudioDirector.preview_volume(volume_key, float(draft[volume_key]))
		_build_settings_page(page, str(selected_category[0]), draft)
	, false, Vector2(140, 34)))
	actions.add_child(_button(_tr("common.apply"), func():
		preferences.window_mode = str(draft["window_mode"])
		preferences.display_index = int(draft["display_index"])
		preferences.resolution = draft["resolution"]
		preferences.language = str(draft["language"])
		preferences.master_volume = float(draft["master_volume"])
		preferences.music_volume = float(draft["music_volume"])
		preferences.effects_volume = float(draft["effects_volume"])
		preferences.autosave_interval_minutes = int(draft["autosave_interval_minutes"])
		preferences.autosave_count = int(draft["autosave_count"])
		preferences.keybinds = (draft["keybinds"] as Dictionary).duplicate()
		preferences.apply_settings()
		var saved := preferences.save_settings()
		_close_settings()
		_update_tab_shortcut_hints()
		if screen == "game": _render_selected_pawn(_snapshot())
		if screen == "menu":
			_show_menu()
		_notice(_tr("settings.saved") if saved else _tr("settings.save_failed"))
	, true, Vector2(110, 34)))


func _build_settings_page(page: VBoxContainer, category: String, draft: Dictionary) -> void:
	for child in page.get_children():
		page.remove_child(child)
		child.queue_free()
	match category:
		"general":
			page.add_child(_label(_tr("settings.general"), 19, GOLD))
			page.add_child(_label(_tr("settings.language"), 14, CREAM))
			var languages := OptionButton.new()
			_compact_option(languages)
			var options := I18n.language_options()
			for option in options:
				languages.add_item(str(option["label"]))
				if str(option["id"]) == str(draft["language"]):
					languages.select(languages.item_count - 1)
			languages.item_selected.connect(func(index: int): draft["language"] = str(options[index]["id"]))
			page.add_child(languages)
			var hint := _label(_tr("settings.language_hint"), 13, MUTED)
			hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			page.add_child(hint)
			page.add_child(HSeparator.new())
			page.add_child(_label(_tr("settings.save_folder"), 14, CREAM))
			var save_path := _label(ProjectSettings.globalize_path("user://"), 12, MUTED)
			save_path.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			page.add_child(save_path)
			page.add_child(_button(_tr("settings.open_folder"), func():
				var path := ProjectSettings.globalize_path("user://")
				DirAccess.make_dir_recursive_absolute(path)
				OS.shell_open(path)
			, false, Vector2(145, 32)))
			page.add_child(HSeparator.new())
			page.add_child(_label(_prep_local("Autosave interval", "Otomatik kayıt sıklığı", "Odstęp autozapisu"), 14, CREAM))
			var intervals := OptionButton.new()
			_compact_option(intervals)
			var interval_values := [0, 1, 5, 10, 20, 30, 60]
			for minutes in interval_values:
				intervals.add_item(_prep_local("Off", "Kapalı", "Wyłączone") if minutes == 0 else _prep_local("%d minutes" % minutes, "%d dakika" % minutes, "%d minut" % minutes))
				if minutes == int(draft["autosave_interval_minutes"]):
					intervals.select(intervals.item_count - 1)
			intervals.item_selected.connect(func(index: int): draft["autosave_interval_minutes"] = interval_values[index])
			page.add_child(intervals)
			page.add_child(_label(_prep_local("Autosaves to keep", "Saklanacak otomatik kayıt", "Liczba autozapisów"), 14, CREAM))
			var autosave_count := SpinBox.new()
			autosave_count.min_value = 1
			autosave_count.max_value = 20
			autosave_count.step = 1
			autosave_count.value = int(draft["autosave_count"])
			autosave_count.value_changed.connect(func(value: float): draft["autosave_count"] = int(value))
			page.add_child(autosave_count)
		"graphics":
			page.add_child(_label(_tr("settings.display"), 19, GOLD))
			page.add_child(_label(_prep_local("Display", "Ekran", "Ekran"), 14, CREAM))
			var displays := OptionButton.new()
			_compact_option(displays)
			var display_count := maxi(1, DisplayServer.get_screen_count())
			for screen_index in display_count:
				var screen_size := DisplayServer.screen_get_size(screen_index) if DisplayServer.get_name() != "headless" else Vector2i.ZERO
				displays.add_item(_prep_local("Display %d", "Ekran %d", "Ekran %d") % (screen_index + 1) + "  ·  %d × %d" % [screen_size.x, screen_size.y])
				if screen_index == int(draft["display_index"]):
					displays.select(screen_index)
			displays.item_selected.connect(func(index: int):
				draft["display_index"] = index
				call_deferred("_build_settings_page", page, "graphics", draft))
			page.add_child(displays)
			page.add_child(_label(_tr("settings.window_mode"), 14, CREAM))
			var modes := OptionButton.new()
			_compact_option(modes)
			var mode_ids := ["fullscreen", "borderless", "windowed"]
			for mode_id in mode_ids:
				modes.add_item(_tr("settings." + mode_id))
				if mode_id == str(draft["window_mode"]):
					modes.select(modes.item_count - 1)
			page.add_child(modes)
			page.add_child(_label(_tr("settings.resolution"), 14, CREAM))
			var resolutions := OptionButton.new()
			_compact_option(resolutions)
			resolutions.get_popup().max_size = Vector2i(4096, 320)
			var sizes: Array[Vector2i] = SettingsScript.resolution_options(int(draft["display_index"]))
			if not sizes.has(draft["resolution"]):
				sizes.append(draft["resolution"])
			for size in sizes:
				resolutions.add_item("%d × %d" % [size.x, size.y])
				if size == draft["resolution"]:
					resolutions.select(resolutions.item_count - 1)
			resolutions.disabled = str(draft["window_mode"]) == "fullscreen"
			resolutions.item_selected.connect(func(index: int): draft["resolution"] = sizes[index])
			modes.item_selected.connect(func(index: int):
				draft["window_mode"] = mode_ids[index]
				resolutions.disabled = mode_ids[index] == "fullscreen")
			page.add_child(resolutions)
			var hint := _label(_tr("settings.resolution_hint"), 13, MUTED)
			hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			page.add_child(hint)
		"audio":
			page.add_child(_label(_tr("settings.audio"), 19, GOLD))
			for entry in [["master_volume", "settings.master_volume"], ["music_volume", "settings.music_volume"], ["effects_volume", "settings.effects_volume"]]:
				var key := str(entry[0])
				page.add_child(_label(_tr(str(entry[1])), 14, CREAM))
				var row := _hbox(12)
				page.add_child(row)
				var slider := HSlider.new()
				slider.min_value = 0.0
				slider.max_value = 1.0
				slider.step = 0.01
				slider.value = float(draft[key])
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(slider)
				var value := _label("%d%%" % roundi(slider.value * 100.0), 13, MUTED)
				value.custom_minimum_size.x = 44
				row.add_child(value)
				slider.value_changed.connect(func(level: float):
					draft[key] = level
					value.text = "%d%%" % roundi(level * 100.0)
					AudioDirector.preview_volume(key, level))
		"controls":
			page.add_child(_label(_tr("settings.controls"), 19, GOLD))
			var groups := [
				[_prep_local("Time", "Zaman", "Czas"), [
					["pause", "Pause / resume", "Duraklat / sürdür", "Pauza / wznów"],
					["speed_1", "Speed 1", "Hız 1", "Prędkość 1"],
					["speed_2", "Speed 2", "Hız 2", "Prędkość 2"],
					["speed_3", "Speed 3", "Hız 3", "Prędkość 3"],
				]],
				[_prep_local("Colony panels", "Koloni panelleri", "Panele kolonii"), [
					["tab_orders", "Orders", "Emirler", "Rozkazy"],
					["tab_work", "Work", "İşler", "Praca"],
					["tab_schedule", "Schedule", "Günlük plan", "Harmonogram"],
					["tab_health", "Health", "Sağlık", "Zdrowie"],
					["tab_research", "Research", "Araştırma", "Badania"],
					["tab_world", "World", "Dünya", "Świat"],
				]],
				[_prep_local("Colonists", "Kolonistler", "Koloniści"), [
					["previous_colonist", "Previous colonist", "Önceki kolonist", "Poprzedni kolonista"],
					["next_colonist", "Next colonist", "Sonraki kolonist", "Następny kolonista"],
					["focus_colonist", "Center selected", "Seçilene odaklan", "Wyśrodkuj wybranego"],
					["draft", "Draft selected / all", "Seçili / herkesi hazırla", "Mobilizuj wybranych / wszystkich"],
					["clear_order", "Clear selected orders", "Seçili emirleri temizle", "Wyczyść wybrane rozkazy"],
				]],
				[_prep_local("Camera", "Kamera", "Kamera"), [
					["pan_up", "Pan up", "Yukarı kaydır", "Przesuń w górę"],
					["pan_down", "Pan down", "Aşağı kaydır", "Przesuń w dół"],
					["pan_left", "Pan left", "Sola kaydır", "Przesuń w lewo"],
					["pan_right", "Pan right", "Sağa kaydır", "Przesuń w prawo"],
					["zoom_in", "Zoom in", "Yakınlaştır", "Przybliż"],
					["zoom_out", "Zoom out", "Uzaklaştır", "Oddal"],
				]],
			]
			for group in groups:
				page.add_child(_label(str(group[0]), 16, GOLD))
				for entry in group[1]:
					var action := str(entry[0])
					var row := _hbox(8)
					page.add_child(row)
					var title := _label(_prep_local(str(entry[1]), str(entry[2]), str(entry[3])), 14, CREAM)
					title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					row.add_child(title)
					var code := int((draft["keybinds"] as Dictionary).get(action, 0))
					var key_button := _button(OS.get_keycode_string(code), func(): _capture_keybind_action = action, false, Vector2(135, 30))
					key_button.pressed.connect(func():
						key_button.text = _prep_local("Press a key…", "Bir tuşa bas…", "Naciśnij klawisz…")
						key_button.release_focus())
					row.add_child(key_button)
			page.add_child(HSeparator.new())
			var tip := _label(_prep_local("Click a key to change it. Escape cancels; F11 is reserved for display mode. Conflicts swap keys.", "Değiştirmek için tuşa tıkla. Esc iptal eder; F11 görüntü modu içindir. Çakışan tuşlar yer değiştirir.", "Kliknij klawisz, aby go zmienić. Escape anuluje; F11 jest zarezerwowany dla trybu ekranu. Konflikty zamieniają klawisze."), 12, MUTED)
			tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			page.add_child(tip)


func _close_settings() -> void:
	_capture_keybind_action = ""
	_settings_draft = {}
	_settings_page = null
	AudioDirector.restore_volumes(preferences)
	if is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
	_settings_overlay = null
	if screen == "game":
		game_paused = _settings_return_paused
		_update_speed_buttons()


func _update_tab_shortcut_hints() -> void:
	var mappings := {
		"Emirler": "tab_orders", "İşler": "tab_work", "Günlük plan": "tab_schedule",
		"Sağlık": "tab_health", "Araştırma": "tab_research", "Dünya": "tab_world",
	}
	for tab_name in mappings:
		if _tab_buttons.has(tab_name) and is_instance_valid(_tab_buttons[tab_name]):
			var code := int(preferences.keybinds.get(mappings[tab_name], 0))
			(_tab_buttons[tab_name] as Button).tooltip_text = OS.get_keycode_string(code)


func _show_pause_menu() -> void:
	if _pause_menu_open or _naming_prompt_open:
		return
	_pause_menu_open = true
	var resume_paused := game_paused
	game_paused = true
	_update_speed_buttons()
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var menu := _vbox(8)
	menu.custom_minimum_size = Vector2(290, 0)
	popup.add_child(menu)
	menu.add_child(_label(_prep_local("Paused", "Duraklatıldı", "Pauza"), 23, GOLD))
	menu.add_child(_button(_prep_local("Resume", "Devam et", "Wznów"), func(): popup.hide()))
	menu.add_child(_button(_tr("game.save_game"), func(): popup.hide(); call_deferred("_save_game")))
	menu.add_child(_button(_tr("game.load_game"), func(): popup.hide(); call_deferred("_load_saved_game")))
	menu.add_child(_button(_tr("settings.title"), func(): popup.hide(); _show_settings()))
	menu.add_child(_button(_prep_local("Main menu", "Ana menü", "Menu główne"), func(): popup.hide(); call_deferred("_request_exit", true)))
	menu.add_child(_button(_prep_local("Quit Foxtopia", "Foxtopia'dan çık", "Zamknij Foxtopia"), func(): popup.hide(); call_deferred("_request_exit", false)))
	popup.popup_hide.connect(func():
		_pause_menu_open = false
		game_paused = resume_paused
		_update_speed_buttons()
		popup.queue_free())
	popup.popup_centered(Vector2i(320, 370))


func _request_exit(to_main_menu: bool) -> void:
	if _exit_warning_open or _naming_prompt_open:
		return
	if session_kind == "join" or not Game.has_unsaved_changes():
		_finish_exit(to_main_menu)
		return
	_exit_return_paused = game_paused
	_exit_warning_open = true
	game_paused = true
	_update_speed_buttons()
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(10)
	content.custom_minimum_size = Vector2(340, 0)
	popup.add_child(content)
	content.add_child(_label(_prep_local("Unsaved colony", "Kaydedilmemiş koloni", "Niezapisana kolonia"), 21, GOLD))
	var warning := _label(_prep_local("Save your progress before leaving?", "Çıkmadan önce ilerlemeni kaydetmek ister misin?", "Zapisać postęp przed wyjściem?"), 14, CREAM)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(warning)
	var save_and_leave := _prep_local("Save and return to menu", "Kaydet ve ana menüye dön", "Zapisz i wróć do menu") if to_main_menu else _prep_local("Save and quit", "Kaydet ve oyundan çık", "Zapisz i zakończ")
	content.add_child(_button(save_and_leave, func():
		if Game.save_game():
			popup.hide()
			_finish_exit(to_main_menu)
		else:
			_notice(_prep_local("Save failed. Still in game.", "Kayıt başarısız. Oyunda kaldın.", "Nie udało się zapisać. Gra trwa dalej."))
	, true))
	content.add_child(_button(_prep_local("Leave without saving", "Kaydetmeden çık", "Wyjdź bez zapisu"), func(): popup.hide(); _finish_exit(to_main_menu)))
	content.add_child(_button(_tr("common.cancel"), func(): popup.hide()))
	popup.popup_hide.connect(func():
		_exit_warning_open = false
		if screen == "game":
			game_paused = _exit_return_paused
			_update_speed_buttons()
		popup.queue_free())
	popup.popup_centered(Vector2i(380, 220))


func _finish_exit(to_main_menu: bool) -> void:
	if to_main_menu:
		Net.start_solo()
		_show_menu()
	else:
		get_tree().quit()


func _values_array(value: Variant) -> Array:
	if value is Array:
		return value
	if value is Dictionary:
		return value.values()
	return []


func _site_id(snapshot: Dictionary) -> String:
	if not selected_site_id.is_empty():
		return selected_site_id
	for faction in _values_array(snapshot.get("factions", [])):
		if faction is Dictionary and (faction.get("players", []) as Array).has(Net.get_local_peer_id()):
			return str(faction.get("site_id", ""))
	var maps = snapshot.get("maps", {})
	if maps is Dictionary and not maps.is_empty():
		return str(maps.keys()[0])
	return ""


func _local_map(snapshot: Dictionary) -> Dictionary:
	var maps = snapshot.get("maps", {})
	var id := _site_id(snapshot)
	if maps is Dictionary and maps.has(id):
		return maps[id]
	if maps is Array and not maps.is_empty():
		return maps[0]
	return {"width": 50, "height": 50, "terrain": [], "resources": [], "structures": []}


func _local_colonists(snapshot: Dictionary) -> Array:
	var people: Array = []
	for person in _values_array(snapshot.get("colonists", [])):
		if person is Dictionary and str(person.get("site_id", _site_id(snapshot))) == _site_id(snapshot):
			people.append(person)
	return people


func _local_raiders(snapshot: Dictionary) -> Array:
	var enemies: Array = []
	for enemy in _values_array(snapshot.get("raiders", [])):
		if enemy is Dictionary and str(enemy.get("site_id", _site_id(snapshot))) == _site_id(snapshot):
			enemies.append(enemy)
	return enemies


func _selected_person(snapshot: Dictionary) -> Dictionary:
	if selected_ids.is_empty():
		return {}
	for person in _local_colonists(snapshot):
		if str(person.get("id", "")) == selected_ids[0]:
			return person
	return {}


func _render_game(immediate_hud: bool = true) -> void:
	if screen != "game" or not is_instance_valid(_map_view):
		return
	var data := _snapshot()
	var resources := _local_resources(data)
	_map_view.set_world(_local_map(data), _local_colonists(data), _local_raiders(data), _local_caravans(data), _local_orders(data), selected_ids)
	_map_view.set_stockpile_inventory(resources)
	if _map_view.has_method("set_day_time"):
		_map_view.call("set_day_time", int(data.get("time", 0)), int(data.get("day_length", 600)))
	var now := Time.get_ticks_msec()
	if not immediate_hud and now - _last_hud_render_ms < 500:
		return
	_last_hud_render_ms = now
	_render_resources(resources)
	_render_alerts(data, resources)
	_render_clock(data)
	_render_portraits(data)
	_render_selected_pawn(data)

func _render_resources(resources: Dictionary) -> void:
	if not is_instance_valid(_resource_stack):
		return
	for child in _resource_stack.get_children():
		child.queue_free()
	for entry in [["wood", "Wood"], ["stone", "Stone"], ["food", "Food"], ["silver", "Silver"]]:
		var row := _hbox(3)
		_resource_stack.add_child(row)
		var icon := TextureRect.new()
		icon.texture = load("res://assets/item_%s.svg" % str(entry[0]))
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(21, 21)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var label := _label("%d" % int(resources.get(entry[0], 0)), 13, CREAM)
		label.tooltip_text = str(entry[1])
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		row.add_child(label)

func _render_alerts(snapshot: Dictionary, resources: Dictionary) -> void:
	if not is_instance_valid(_alert_stack):
		return
	for child in _alert_stack.get_children():
		child.queue_free()
	var alerts: Array[String] = []
	if int(resources.get("food", 0)) <= 5:
		alerts.append("low_food")
	for person in _local_colonists(snapshot):
		if float(person.get("needs", {}).get("hunger", 100)) < 25.0:
			alerts.append("hungry_colonist")
			break
	var has_bench := false
	for structure in _local_map(snapshot).get("structures", []):
		if str(structure.get("kind", "")) == "research_bench":
			has_bench = true
			break
	if not has_bench:
		alerts.append("research_bench")
	for alert in alerts:
		if not _active_alerts.has(alert):
			AudioDirector.play_effect("alert")
			break
	_active_alerts = alerts
	for alert in alerts:
		var description := ""
		match alert:
			"low_food": description = _prep_local("Low food", "Yiyecek az", "Mało żywności")
			"hungry_colonist": description = _prep_local("Colonist needs food", "Kolonistin yiyeceğe ihtiyacı var", "Kolonista potrzebuje jedzenia")
			"research_bench": description = _prep_local("Research bench needed", "Araştırma masası gerekli", "Potrzebny stół badawczy")
		var label := _label("!  " + description, 13, CREAM)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_alert_stack.add_child(label)

func _render_clock(snapshot: Dictionary) -> void:
	if not is_instance_valid(_time_label):
		return
	var elapsed := maxi(0, int(snapshot.get("time", 0)))
	var day_length := maxi(1, int(snapshot.get("day_length", 600)))
	var date := ClimateCalendar.date_from_steps(elapsed, day_length)
	var minute_of_day := (480 + int(float(elapsed % day_length) * 1440.0 / float(day_length))) % 1440
	_time_label.text = "%d %s, %d    %02d:%02d" % [int(date["period_day"]), _climate_period_name(int(date["period_index"])), int(date["year"]), minute_of_day / 60, minute_of_day % 60]


func _local_resources(snapshot: Dictionary) -> Dictionary:
	for faction in _values_array(snapshot.get("factions", [])):
		if faction is Dictionary and str(faction.get("site_id", "")) == _site_id(snapshot):
			return faction.get("inventory", {})
	return {}


func _local_orders(snapshot: Dictionary) -> Array:
	var result: Array = []
	for order in _values_array(snapshot.get("orders", [])):
		if str(order.get("site_id", "")) == _site_id(snapshot):
			result.append(order)
	return result


func _local_caravans(snapshot: Dictionary) -> Array:
	var result: Array = []
	for caravan in _values_array(snapshot.get("caravans", [])):
		if str(caravan.get("site_id", "")) == _site_id(snapshot):
			result.append(caravan)
	return result


func _render_portraits(snapshot: Dictionary) -> void:
	if not is_instance_valid(_portrait_strip):
		return
	var people := _local_colonists(snapshot)
	var signature_parts: Array = []
	for person in people:
		signature_parts.append([person.get("id", ""), person.get("name", ""), person.get("appearance", {}), person.get("drafted", false)])
	var signature := JSON.stringify(signature_parts)
	if signature != _portrait_signature or _portrait_strip.get_child_count() != people.size():
		_portrait_signature = signature
		for child in _portrait_strip.get_children():
			_portrait_strip.remove_child(child)
			child.queue_free()
		for person in people:
			var id := str(person.get("id", ""))
			var button := _hud_button("", func(): _select_colonist(id), false, Vector2(58, 64))
			button.set_meta("colonist_id", id)
			button.tooltip_text = str(person.get("name", "Colonist"))
			var portrait := PawnPortrait.new()
			portrait.appearance = person.get("appearance", {})
			portrait.is_drafted = bool(person.get("drafted", false))
			portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(portrait)
			_place(portrait, 0.0, 0.0, 1.0, 1.0, 2, 0, -2, -17)
			var caption := _label(str(person.get("name", "Colonist")), 11, CREAM)
			caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			caption.clip_text = true
			caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(caption)
			_place(caption, 0.0, 1.0, 1.0, 1.0, 0, -19, 0, -5)
			_portrait_strip.add_child(button)
	_update_portrait_selection()


func _update_portrait_selection() -> void:
	for node in _portrait_strip.get_children():
		var button := node as Button
		var selected := selected_ids.has(str(button.get_meta("colonist_id", "")))
		button.add_theme_stylebox_override("normal", _hud_style(Color("#293239a8") if selected else Color("#17202770"), GOLD if selected else Color("#65717a7f")))
		button.add_theme_stylebox_override("hover", _hud_style(Color("#34424bb8"), GOLD if selected else Color("#65717a7f")))
		var portrait := button.get_child(0) as PawnPortrait
		portrait.is_selected = selected
		portrait.queue_redraw()

func _render_selected_pawn(snapshot: Dictionary) -> void:
	if not is_instance_valid(_pawn_panel):
		return
	var person := _selected_person(snapshot)
	_pawn_panel.visible = not person.is_empty()
	_pawn_detail_panel.visible = not person.is_empty() and not pawn_tab.is_empty()
	if pawn_tab == "Health":
		var health: Dictionary = person.get("health", {})
		_pawn_detail_panel.offset_top = -307 - mini(6, (health.get("wounds", []) as Array).size() + (health.get("conditions", []) as Array).size()) * 22
	else:
		_pawn_detail_panel.offset_top = -365 if pawn_tab == "Gear" else -485 if pawn_tab in ["Needs", "Bio"] else -435
	_command_strip.visible = not person.is_empty()
	if person.is_empty():
		return
	for child in _pawn_summary.get_children():
		_pawn_summary.remove_child(child)
		child.queue_free()
	for child in _command_strip.get_children():
		_command_strip.remove_child(child)
		child.queue_free()
	var person_id := str(person.get("id", ""))
	var hp := int(person.get("health", {}).get("hp", 100))
	var needs: Dictionary = person.get("needs", {})
	var tabs := _hbox(1)
	_pawn_summary.add_child(tabs)
	for entry in [["Log", "Log"], ["Gear", "Gear"], ["Social", "Social"], ["Bio", "Bio"], ["Needs", "Needs"], ["Health", "Health"]]:
		var name: String = entry[0]
		tabs.add_child(_hud_button(str(entry[1]), func(): _set_pawn_tab(name), pawn_tab == name, Vector2(74, 25)))
	var title_row := _hbox(8)
	_pawn_summary.add_child(title_row)
	title_row.add_child(_label(str(person.get("name", "Colonist")), 17, CREAM))
	var identity := _label(_prep_local("Female", "Kadın", "Kobieta") if str(person.get("sex", "female")) == "female" else _prep_local("Male", "Erkek", "Mężczyzna"), 11, MUTED)
	identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_row.add_child(identity)
	var condition_row := _hbox(6)
	_pawn_summary.add_child(condition_row)
	condition_row.add_child(_hud_status_bar("Health", hp, TEAL if hp >= 65 else RED))
	condition_row.add_child(_hud_status_bar("Mood", int(needs.get("mood", 75)), Color("#d6bf83")))
	var activity := _prep_local("Idle", "Boşta", "Bezczynny")
	if bool(person.get("resting", false)):
		activity = _prep_local("Resting", "Dinleniyor", "Odpoczywa")
	elif not (person.get("manual", {}) as Dictionary).is_empty():
		activity = _display_work(str(person.get("manual", {}).get("action", "work")))
	elif not str(person.get("current_order", "")).is_empty():
		activity = _prep_local("Working", "Çalışıyor", "Pracuje")
	_pawn_summary.add_child(_label("%s    ·    %s" % [_prep_local("Drafted", "Savaşta", "Zmobilizowany") if bool(person.get("drafted", false)) else _prep_local("Undrafted", "Sivil", "Niezmobilizowany"), activity], 12, MUTED))
	var equipment: Dictionary = person.get("equipment", {})
	_pawn_summary.add_child(_label(_prep_local("Weapon: %s    Clothes: %s / %s", "Silah: %s    Kıyafet: %s / %s", "Broń: %s    Ubranie: %s / %s") % [_display_item(str(equipment.get("weapon", "fists"))), _display_item(str(equipment.get("shirt", "none"))), _display_item(str(equipment.get("pants", "none")))], 11, MUTED))
	var draft_key := OS.get_keycode_string(int(preferences.keybinds.get("draft", KEY_R)))
	var draft_button := _hud_action_button(("DRAFT" if not bool(person.get("drafted", false)) else "UNDRAFT") + "\n" + draft_key, func(): _send_command({"type": "set_draft", "colonist_id": person_id, "drafted": not bool(person.get("drafted", false))}), bool(person.get("drafted", false)))
	draft_button.tooltip_text = "Toggle combat control (%s)" % draft_key
	_command_strip.add_child(draft_button)
	var clear_key := OS.get_keycode_string(int(preferences.keybinds.get("clear_order", KEY_C)))
	var clear_button := _hud_action_button("CLEAR\n" + clear_key, func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "clear"}))
	clear_button.tooltip_text = "Cancel the current direct order (%s)" % clear_key
	_command_strip.add_child(clear_button)
	if pawn_tab.is_empty():
		return
	for child in _pawn_detail_content.get_children():
		child.queue_free()
	_pawn_detail_content.add_child(_label("%s — %s" % [str(person.get("name", "Colonist")), pawn_tab], 18, GOLD))
	_pawn_detail_content.add_child(HSeparator.new())
	match pawn_tab:
		"Needs": _build_pawn_needs(person)
		"Health": _build_pawn_health(person)
		"Bio": _build_pawn_bio(person)
		"Gear": _build_pawn_gear(person)
		"Social": _build_pawn_social(person)
		"Log": _build_pawn_log(snapshot, person)


func _hud_status_bar(label_text: String, amount: int, fill: Color) -> Control:
	var row := _hbox(3)
	row.add_child(_label(label_text, 11, MUTED))
	var background := ColorRect.new()
	background.color = Color("#090d10")
	background.custom_minimum_size = Vector2(72, 9)
	background.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(background)
	var bar := ColorRect.new()
	bar.color = fill
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_child(bar)
	_place(bar, 0.0, 0.0, clampf(float(amount) / 100.0, 0.0, 1.0), 1.0, 0, 0, 0, 0)
	row.add_child(_label("%d%%" % amount, 11, MUTED))
	return row


func _hud_action_button(title: String, action: Callable, active: bool = false) -> Button:
	var button := _hud_button(title, action, active, Vector2(62, 64))
	button.add_theme_font_size_override("font_size", 11)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button


func _arm_direct_action(action: String) -> void:
	if selected_ids.is_empty() or not is_instance_valid(_command_strip):
		return
	var pending := str(_command_strip.get_meta("pending_direct_action", ""))
	_command_strip.set_meta("pending_direct_action", "" if pending == action else action)
	_render_selected_pawn(_snapshot())
	if pending != action:
		_notice(_prep_local("Choose a target on the map for %s.", "%s için haritada bir hedef seç.", "Wybierz cel na mapie dla: %s.") % action.capitalize())


func _send_armed_action(tile: Vector2i, enemy_id: String) -> void:
	var action := str(_command_strip.get_meta("pending_direct_action", ""))
	if action.is_empty() or selected_ids.is_empty():
		return
	var target_id := ""
	match action:
		"move":
			if not _map_tile_passable(tile):
				_notice(_prep_local("That tile is blocked.", "Bu hücreye gidilemez.", "To pole jest zablokowane."))
				AudioDirector.play_rejection()
				return
		"work":
			target_id = _order_at(tile)
			if target_id.is_empty():
				var resource_kind := str(_resource_at_tile(tile).get("kind", ""))
				var designation: String = {"tree": "chop", "stone": "mine", "berry": "harvest"}.get(resource_kind, "")
				if designation.is_empty():
					_notice(_prep_local("Select an existing job or a harvestable resource.", "Mevcut bir iş veya toplanabilir bir kaynak seç.", "Wybierz istniejące zadanie lub zasób do zebrania."))
					AudioDirector.play_rejection()
					return
				if not _send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": tile.x, "y": tile.y, "kind": designation, "priority": default_order_priority}):
					return
		"haul":
			var has_drop := false
			for drop in _local_map(_snapshot()).get("drops", []):
				if int(drop.get("x", -1)) == tile.x and int(drop.get("y", -1)) == tile.y and _has_stockpile_for_kind(str(drop.get("kind", ""))):
					has_drop = true
					break
			if not has_drop:
				_notice(_prep_local("Select supplies with an available stockpile.", "Uygun deposu olan bir malzeme seç.", "Wybierz zapasy, dla których istnieje magazyn."))
				AudioDirector.play_rejection()
				return
		"attack":
			if enemy_id.is_empty():
				_notice(_prep_local("Select an enemy.", "Bir düşman seç.", "Wybierz wroga."))
				AudioDirector.play_rejection()
				return
			target_id = enemy_id
		"trade":
			target_id = _caravan_at(tile)
			if target_id.is_empty():
				_notice(_prep_local("Select a visiting trader.", "Gelen bir tüccar seç.", "Wybierz odwiedzającego handlarza."))
				AudioDirector.play_rejection()
				return
	var command := {"type": "direct", "colonist_id": selected_ids[0], "action": action, "x": tile.x, "y": tile.y}
	if not target_id.is_empty():
		command["target_id"] = target_id
	if _send_command(command):
		if action == "trade":
			_trade_caravan_pending_id = target_id
		_command_strip.set_meta("pending_direct_action", "")
		_render_selected_pawn(_snapshot())


func _set_pawn_tab(name: String) -> void:
	pawn_tab = "" if pawn_tab == name else name
	_render_selected_pawn(_snapshot())

func _build_pawn_needs(person: Dictionary) -> void:
	var needs: Dictionary = person.get("needs", {})
	for pair in [["Food", "hunger"], ["Rest", "rest"], ["Mood", "mood"]]:
		var row := _hbox(7)
		_pawn_detail_content.add_child(row)
		var name := _label(str(pair[0]), 13)
		name.custom_minimum_size = Vector2(76, 0)
		row.add_child(name)
		var bar := ProgressBar.new()
		bar.max_value = 100
		bar.value = float(needs.get(pair[1], 0))
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(260, 15)
		row.add_child(bar)
		row.add_child(_label("%d%%" % int(needs.get(pair[1], 0)), 12, MUTED))
	_pawn_detail_content.add_child(HSeparator.new())
	var thoughts: Array = needs.get("thoughts", [])
	if thoughts.is_empty():
		_pawn_detail_content.add_child(_label("No recent mood factors.", 12, MUTED))
	for polarity in [1, -1]:
		var group: Array = []
		for thought in thoughts:
			if not thought is Dictionary: continue
			var value := int(thought.get("mood", thought.get("value", 0)))
			if (value >= 0 and polarity == 1) or (value < 0 and polarity == -1):
				group.append(thought)
		if group.is_empty(): continue
		_pawn_detail_content.add_child(_label(_tr("needs.positive") if polarity == 1 else _tr("needs.negative"), 14, GOLD))
		for thought in group:
			var value := int(thought.get("mood", thought.get("value", 0)))
			_pawn_detail_content.add_child(_label("%s    %+d" % [str(thought.get("label", thought.get("kind", "Thought"))), value], 12, TEAL if value >= 0 else RED))

func _build_pawn_health(person: Dictionary) -> void:
	var health: Dictionary = person.get("health", {})
	_pawn_detail_content.add_child(_label(_prep_local("Overall health  %d / %d", "Genel sağlık  %d / %d", "Stan zdrowia  %d / %d") % [int(health.get("hp", 100)), int(health.get("max_hp", 100))], 14, CREAM))
	if float(health.get("bleeding", 0)) > 0:
		_pawn_detail_content.add_child(_label(_prep_local("Bleeding  %.1f", "Kanama  %.1f", "Krwawienie  %.1f") % float(health.get("bleeding", 0)), 13, RED))
	var pain_percent := roundi(float(health.get("pain", PreparationRules.health_pain(health))) * 100.0)
	if pain_percent > 0:
		_pawn_detail_content.add_child(_label(_prep_local("Pain  %d%%", "Acı  %d%%", "Ból  %d%%") % pain_percent, 13, RED))
	var groups: Dictionary = {}
	for wound in health.get("wounds", []):
		var kind := _preparation_wound_label(str(wound.get("kind", "wound")))
		var part := _preparation_body_part_label(str(wound.get("body_part", "torso")))
		var group_key := "%s · %s" % [kind, part]
		var cause := str(wound.get("cause", "unknown"))
		if cause != "unknown": group_key += " · " + _preparation_injury_cause_label(cause)
		var severity := int(wound.get("severity", 0))
		if not groups.has(group_key):
			groups[group_key] = {"count": 0, "severity": 0, "scar": str(wound.get("kind", "")) == "scar",
				"kind": str(wound.get("kind", "")), "tier": str(wound.get("severity_tier", ""))}
		groups[group_key]["count"] = int(groups[group_key]["count"]) + 1
		if severity >= int(groups[group_key]["severity"]):
			groups[group_key]["severity"] = severity
			groups[group_key]["tier"] = str(wound.get("severity_tier", ""))
	for group_key in groups:
		var count := int(groups[group_key]["count"])
		var severity := int(groups[group_key]["severity"])
		var tier := str(groups[group_key]["tier"])
		var severity_name := _preparation_injury_tier_label(tier, str(groups[group_key]["kind"])) if not tier.is_empty() else _prep_local("Light", "Hafif", "Lekkie") if severity <= 4 else _prep_local("Moderate", "Orta", "Średnie") if severity <= 8 else _prep_local("Severe", "Ağır", "Ciężkie")
		if bool(groups[group_key]["scar"]): severity_name = _prep_local("Permanent", "Kalıcı", "Stała") + " · " + severity_name
		_pawn_detail_content.add_child(_label("%s%s    %s" % [group_key, " ×%d" % count if count > 1 else "", severity_name], 13, RED if severity >= 8 else CREAM))
	var conditions: Array = health.get("conditions", [])
	for condition in conditions:
		if str(condition) == "scar":
			_pawn_detail_content.add_child(_label(_prep_local("Scar · unknown body part", "Yara izi · bölge bilinmiyor", "Blizna · nieznana część ciała"), 13, MUTED))
			continue
		if PreparationRules.CONDITION_INJURIES.has(str(condition)):
			continue
		_pawn_detail_content.add_child(_label(_preparation_condition_label(str(condition)), 13, MUTED))
	if groups.is_empty() and conditions.is_empty():
		_pawn_detail_content.add_child(_label(_prep_local("No injuries or conditions.", "Yaralanma veya rahatsızlık yok.", "Brak urazów i schorzeń."), 13, TEAL))

func _build_pawn_bio(person: Dictionary) -> void:
	_pawn_detail_content.add_child(_label(_prep_local("Age %d    Sex %s", "Yaş %d    Biyolojik cinsiyet %s", "Wiek %d    Płeć %s") % [int(person.get("age", 25)), _prep_local("Female", "Kadın", "Kobieta") if str(person.get("sex", "female")) == "female" else _prep_local("Male", "Erkek", "Mężczyzna")], 13))
	_pawn_detail_content.add_child(_label(_prep_local("Childhood  %s", "Çocukluk  %s", "Dzieciństwo  %s") % _display_background(str(person.get("childhood", "rural_child"))), 13))
	_pawn_detail_content.add_child(_label(_prep_local("Adulthood  %s", "Yetişkinlik  %s", "Dorosłość  %s") % _display_background(str(person.get("adulthood", "farmer"))), 13))
	var traits: Array = person.get("traits", [])
	var trait_names: PackedStringArray = []
	for trait_id in traits:
		trait_names.append(_display_trait(str(trait_id)))
	_pawn_detail_content.add_child(_label(_prep_local("Traits  %s", "Özellikler  %s", "Cechy  %s") % ", ".join(trait_names), 13))
	_pawn_detail_content.add_child(HSeparator.new())
	_pawn_detail_content.add_child(_label(_prep_local("Skills", "Beceriler", "Umiejętności"), 14, GOLD))
	for key in person.get("skills", {}).keys():
		_pawn_detail_content.add_child(_label("%s   %d" % [_localized_skill(str(key)), int(person["skills"][key])], 12))

func _build_pawn_gear(person: Dictionary) -> void:
	var equipment: Dictionary = person.get("equipment", {})
	_pawn_detail_content.add_child(_label(_prep_local("Weapon  %s", "Silah  %s", "Broń  %s") % _display_item(str(equipment.get("weapon", "none"))), 14))
	_pawn_detail_content.add_child(_label(_prep_local("Outerwear  %s", "Üst giyim  %s", "Odzież wierzchnia  %s") % _display_item(str(equipment.get("apparel", "none"))), 14))
	_pawn_detail_content.add_child(_label(_prep_local("Shirt  %s", "Tişört  %s", "Koszula  %s") % _display_item(str(equipment.get("shirt", "none"))), 14))
	_pawn_detail_content.add_child(_label(_prep_local("Pants  %s", "Pantolon  %s", "Spodnie  %s") % _display_item(str(equipment.get("pants", "none"))), 14))
	var carrying: Dictionary = person.get("carrying", {})
	if not carrying.is_empty():
		_pawn_detail_content.add_child(_label(_prep_local("Carrying  %s ×%d", "Taşıyor  %s ×%d", "Niesie  %s ×%d") % [_display_item(str(carrying.get("kind", ""))), int(carrying.get("amount", 1))], 13, MUTED))
	var inventory := _local_resources(_snapshot())
	var person_id := str(person.get("id", ""))
	if int(inventory.get("spear", 0)) > 0 and str(equipment.get("weapon", "")) != "spear":
		_pawn_detail_content.add_child(_button(_prep_local("Equip spear", "Mızrak kuşan", "Załóż włócznię"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "spear"})))
	if int(inventory.get("jacket", 0)) > 0 and str(equipment.get("apparel", "")) != "jacket":
		_pawn_detail_content.add_child(_button(_prep_local("Wear coat", "Kaban giy", "Załóż płaszcz"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"})))
	if int(inventory.get("tshirt", 0)) > 0 and str(equipment.get("shirt", "")) != "tshirt":
		_pawn_detail_content.add_child(_button(_prep_local("Wear T-shirt", "Tişört giy", "Załóż koszulkę"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "tshirt"})))
	if int(inventory.get("pants", 0)) > 0 and str(equipment.get("pants", "")) != "pants":
		_pawn_detail_content.add_child(_button(_prep_local("Wear pants", "Pantolon giy", "Załóż spodnie"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "pants"})))

func _build_pawn_social(person: Dictionary) -> void:
	var relationships: Dictionary = person.get("relationships", {})
	var relation_types: Dictionary = person.get("relationship_types", {})
	if relationships.is_empty():
		_pawn_detail_content.add_child(_label("No established relationships yet.", 13, MUTED))
	var names: Dictionary = {}
	for other in _local_colonists(_snapshot()): names[str(other.get("id", ""))] = str(other.get("name", "Colonist"))
	for other in _snapshot().get("world_people", []): names[str(other.get("id", ""))] = str(other.get("name", "World person"))
	for person_id in relationships:
		var relation_type := str(relation_types.get(str(person_id), "Acquaintance")).capitalize()
		_pawn_detail_content.add_child(_label("%s   %s   %+d" % [str(names.get(str(person_id), person_id)), relation_type, int(relationships[person_id])], 13))

func _build_pawn_log(snapshot: Dictionary, person: Dictionary) -> void:
	var count := 0
	for i in range((snapshot.get("events", []) as Array).size() - 1, -1, -1):
		var event: Dictionary = snapshot["events"][i]
		if (event.get("subject_ids", []) as Array).has(str(person.get("id", ""))) or \
				(str(event.get("message_key", "")) == "" and str(event.get("message", "")).contains(str(person.get("name", "")))):
			_pawn_detail_content.add_child(_label(I18n.localize_model_event(event, preferences.language), 12))
			count += 1
			if count >= 8:
				break
	if count == 0:
		_pawn_detail_content.add_child(_label("No recent events.", 13, MUTED))


func _select_colonist(id: String, open_health := false) -> void:
	if is_instance_valid(_command_strip):
		_command_strip.set_meta("pending_direct_action", "")
	selected_ids = [id]
	current_tool = ""
	if open_health:
		pawn_tab = "Health"
	current_tab = ""
	if is_instance_valid(_tool_panel):
		_tool_panel.visible = false
	for tab_name in _tab_buttons:
		var button := _tab_buttons[tab_name] as Button
		button.add_theme_stylebox_override("normal", _hud_style(HUD_TAB))
	_render_game()


func _on_map_pressed(tile: Vector2i, colonist_id: String, enemy_id: String, mouse_button: int) -> void:
	if _naming_prompt_open:
		return
	if mouse_button == MOUSE_BUTTON_RIGHT:
		if is_instance_valid(_command_strip):
			_command_strip.set_meta("pending_direct_action", "")
		_context_tile = tile
		_context_unit_id = colonist_id
		_context_enemy_id = enemy_id
		_context_order_id = _order_at(tile)
		_context_caravan_id = _caravan_at(tile)
		_context_structure_id = str(_structure_at_tile(tile).get("id", ""))
		_open_context_menu()
		return
	if is_instance_valid(_command_strip) and not str(_command_strip.get_meta("pending_direct_action", "")).is_empty():
		_send_armed_action(tile, enemy_id)
		return
	if not current_tool.is_empty():
		if current_tool == "stockpile_zone":
			_send_command({"type": "create_zone", "x": tile.x, "y": tile.y, "width": 3, "height": 3, "accepts": ITEM_PRICES.keys()})
		else:
			_send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": tile.x, "y": tile.y, "kind": current_tool, "priority": default_order_priority})
		return
	if not colonist_id.is_empty():
		_select_colonist(colonist_id)
		return
	selected_order_id = _order_at(tile)
	if not selected_order_id.is_empty():
		selected_ids.clear()
		pawn_tab = ""
		current_tab = ""
		_set_tab("Emirler")
	else:
		selected_ids.clear()
		pawn_tab = ""
		current_tab = ""
		if is_instance_valid(_tool_panel):
			_tool_panel.visible = false
		for tab_name in _tab_buttons:
			var button := _tab_buttons[tab_name] as Button
			button.add_theme_stylebox_override("normal", _hud_style(HUD_TAB))
		_render_game()


func _order_at(tile: Vector2i) -> String:
	for order in _values_array(_snapshot().get("orders", [])):
		if int(order.get("x", -1)) == tile.x and int(order.get("y", -1)) == tile.y and str(order.get("site_id", _site_id(_snapshot()))) == _site_id(_snapshot()):
			return str(order.get("id", ""))
	return ""


func _caravan_at(tile: Vector2i) -> String:
	for caravan in _local_caravans(_snapshot()):
		if int(caravan.get("x", -1)) == tile.x and int(caravan.get("y", -1)) == tile.y:
			return str(caravan.get("id", ""))
	return ""


func _structure_at_tile(tile: Vector2i) -> Dictionary:
	for structure in _local_map(_snapshot()).get("structures", []):
		if int(structure.get("x", -1)) == tile.x and int(structure.get("y", -1)) == tile.y:
			return structure
	return {}


func _open_context_menu() -> void:
	_context_menu.clear()
	var resource := _resource_at_tile(_context_tile)
	var resource_kind := str(resource.get("kind", ""))
	if selected_ids.is_empty():
		if resource_kind == "tree":
			_context_menu.add_item(_prep_local("Chop wood", "Ağaç kes", "Ścinaj drzewo"), 101)
		elif resource_kind == "stone":
			_context_menu.add_item(_prep_local("Mine stone", "Taş çıkar", "Wydobądź kamień"), 102)
		elif resource_kind == "berry":
			_context_menu.add_item(_prep_local("Harvest berries", "Meyveleri topla", "Zbierz jagody"), 103)
		if not _context_order_id.is_empty():
			_context_menu.add_item(_prep_local("Cancel order", "Emri iptal et", "Anuluj rozkaz"), 104)
	else:
		if _map_tile_passable(_context_tile):
			_context_menu.add_item(_tr("pawn.move"), 1)
		if not _context_order_id.is_empty():
			_context_menu.add_item(_prep_local("Prioritize this work", "Bu işe öncelik ver", "Nadaj priorytet tej pracy"), 2)
		elif resource_kind == "tree":
			_context_menu.add_item(_prep_local("Chop this tree", "Bu ağacı kes", "Ścinaj to drzewo"), 9)
		elif resource_kind == "stone":
			_context_menu.add_item(_prep_local("Mine this stone", "Bu taşı çıkar", "Wydobądź ten kamień"), 10)
		elif resource_kind == "berry":
			_context_menu.add_item(_prep_local("Harvest berries", "Meyveleri topla", "Zbierz jagody"), 11)
		for drop in _local_map(_snapshot()).get("drops", []):
			if int(drop.get("x", -1)) == _context_tile.x and int(drop.get("y", -1)) == _context_tile.y:
				if _has_stockpile_for_kind(str(drop.get("kind", ""))):
					_context_menu.add_item(_tr("pawn.carry"), 3)
				break
		if not _context_enemy_id.is_empty():
			_context_menu.add_item(_prep_local("Attack target", "Hedefe saldır", "Atakuj cel"), 4)
		if not _context_caravan_id.is_empty():
			var trader_name := _prep_local("trader", "tüccar", "handlarz")
			for caravan in _local_caravans(_snapshot()):
				if str(caravan.get("id", "")) == _context_caravan_id:
					trader_name = str(caravan.get("trader_name", trader_name))
					break
			_context_menu.add_item(_prep_local("Trade with %s", "%s ile ticaret yap", "Handluj z %s") % trader_name, 5)
		if str(_structure_at_tile(_context_tile).get("kind", "")) == "styling_table":
			_context_menu.add_item(_prep_local("Use styling table", "Görünüş masasını kullan", "Użyj stanowiska stylizacji"), 6)
	if _context_menu.item_count == 0:
		return
	_context_menu.position = Vector2i(get_viewport().get_mouse_position())
	_context_menu.popup()

func _resource_at_tile(tile: Vector2i) -> Dictionary:
	for resource in _local_map(_snapshot()).get("resources", []):
		if int(resource.get("x", -1)) == tile.x and int(resource.get("y", -1)) == tile.y:
			return resource
	return {}


func _map_tile_passable(tile: Vector2i) -> bool:
	var local_map := _local_map(_snapshot())
	var width := int(local_map.get("width", 50))
	var height := int(local_map.get("height", 50))
	if tile.x < 0 or tile.y < 0 or tile.x >= width or tile.y >= height:
		return false
	var terrain: Array = local_map.get("terrain", [])
	var index := tile.y * width + tile.x
	if index >= terrain.size() or str(terrain[index]) == "water":
		return false
	var structure := _structure_at_tile(tile)
	return structure.is_empty() or str(structure.get("kind", "")) not in ["wall", "stone_wall", "barrier"]


func _has_stockpile_for_kind(kind: String) -> bool:
	for zone in _local_map(_snapshot()).get("zones", []):
		if (zone.get("accepts", []) as Array).has(kind):
			return true
	return false


func _context_selected(id: int) -> void:
	if id >= 101:
		if id == 104:
			_send_command({"type": "cancel_order", "order_id": _context_order_id})
			return
		var kind := "chop" if id == 101 else "mine" if id == 102 else "harvest"
		_send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": _context_tile.x, "y": _context_tile.y, "kind": kind, "priority": default_order_priority})
		return
	if selected_ids.is_empty():
		return
	var person_id := selected_ids[0]
	if id in [9, 10, 11]:
		var kind := "chop" if id == 9 else "mine" if id == 10 else "harvest"
		if _send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": _context_tile.x, "y": _context_tile.y, "kind": kind, "priority": default_order_priority}):
			_send_command({"type": "direct", "colonist_id": person_id, "action": "work", "x": _context_tile.x, "y": _context_tile.y})
		return
	var action: String = str({1: "move", 2: "work", 3: "haul", 4: "attack", 5: "trade", 6: "style"}.get(id, "move"))
	var command := {"type": "direct", "colonist_id": person_id, "action": action, "x": _context_tile.x, "y": _context_tile.y}
	if id == 2:
		command["target_id"] = _context_order_id
	elif id == 4:
		command["target_id"] = _context_enemy_id
	elif id == 5:
		command["target_id"] = _context_caravan_id
		_trade_caravan_pending_id = _context_caravan_id
	elif id == 6:
		command["target_id"] = _context_structure_id
		_style_colonist_pending_id = person_id
	if not _send_command(command):
		if id == 5:
			_trade_caravan_pending_id = ""
		elif id == 6:
			_style_colonist_pending_id = ""


func _send_command(command: Dictionary) -> bool:
	var result = Net.send_command(command)
	if result is Dictionary and not bool(result.get("ok", true)):
		AudioDirector.play_rejection()
		_notice(str(result.get("error", _prep_local("Order could not be carried out.", "Komut uygulanamadı.", "Nie można wykonać rozkazu."))))
		return false
	elif result is bool and not result:
		AudioDirector.play_rejection()
		_notice(_prep_local("Order could not be carried out.", "Komut uygulanamadı.", "Nie można wykonać rozkazu."))
		return false
	else:
		_render_game()
		if not current_tab.is_empty():
			_render_sidebar(_snapshot())
		return true


func _on_state_changed(_snapshot_data: Dictionary) -> void:
	if screen == "game":
		_render_game(false)
	elif screen == "waiting" and session_kind == "join":
		_show_game()


func _on_event_emitted(event: Dictionary) -> void:
	if str(event.get("kind", "")) == "build":
		return
	var message := I18n.localize_model_event(event, preferences.language)
	if not message.is_empty():
		_notice(message)
	if str(event.get("kind", "")) == "naming_prompt" and str(event.get("site_id", "")) == _site_id(_snapshot()):
		_open_naming_prompt()
	if str(event.get("kind", "")) == "trade_ready" and not _trade_caravan_pending_id.is_empty():
		_open_trade_dialog(_trade_caravan_pending_id)
		_trade_caravan_pending_id = ""
	if str(event.get("kind", "")) == "styling_ready" and not _style_colonist_pending_id.is_empty():
		for person in _local_colonists(_snapshot()):
			if str(person.get("id", "")) == _style_colonist_pending_id:
				_open_customize_dialog(person)
				break
		_style_colonist_pending_id = ""

func _faction_still_unnamed(faction: Dictionary) -> bool:
	return str(faction.get("name", "")).strip_edges().is_empty() or str(faction.get("settlement_name", "")).strip_edges().is_empty() or str(faction.get("name", "")).begins_with("Unnamed") or str(faction.get("settlement_name", "")).begins_with("Unnamed")


func _open_naming_prompt() -> void:
	if _naming_prompt_open or screen != "game":
		return
	_naming_prompt_open = true
	var resume_paused := game_paused
	if session_kind != "join":
		game_paused = true
		_tick_accumulator = 0.0
		_update_speed_buttons()
	var faction := _my_faction(_snapshot())
	var overlay := ColorRect.new()
	overlay.color = Color(0.015, 0.02, 0.025, 0.78)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_naming_overlay = overlay
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_PASS
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 0)
	panel.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	center.add_child(panel)
	var content := _vbox(11)
	panel.add_child(content)
	content.add_child(_label(_prep_local("A name for this place", "Bu yere bir ad ver", "Nazwa tego miejsca"), 21, GOLD))
	var story := _label(_prep_local("Your settlers have begun making this place their home. What should they call their colony and settlement?", "Yerleşimciler burayı yurt edinmeye başladı. Kolonilerine ve yerleşkelerine ne ad verecekler?", "Osadnicy zaczęli zadomawiać się w tym miejscu. Jak nazwą kolonię i osadę?"), 14, CREAM)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(story)
	content.add_child(_label(_prep_local("Colony name", "Koloni adı", "Nazwa kolonii"), 12, MUTED))
	var colony_edit := LineEdit.new()
	var current_colony := str(faction.get("name", faction_name))
	colony_edit.text = "" if current_colony.begins_with("Unnamed") else current_colony
	content.add_child(colony_edit)
	content.add_child(_label(_prep_local("Settlement name", "Yerleşke adı", "Nazwa osady"), 12, MUTED))
	var settlement_edit := LineEdit.new()
	var current_settlement := str(faction.get("settlement_name", settlement_name))
	settlement_edit.text = "" if current_settlement.begins_with("Unnamed") else current_settlement
	content.add_child(settlement_edit)
	var error_label := _label("", 12, RED)
	content.add_child(error_label)
	var confirm := _button(_prep_local("Name our home", "Yurdumuzu adlandır", "Nazwij nasz dom"), func():
		var colony := colony_edit.text.strip_edges()
		var settlement := settlement_edit.text.strip_edges()
		if colony.is_empty() or settlement.is_empty() or colony.length() > 32 or settlement.length() > 32:
			error_label.text = _prep_local("Enter both names (1–32 characters each).", "İki adı da gir (her biri 1–32 karakter).", "Wpisz obie nazwy (po 1–32 znaki).")
			return
		if not _send_command({"type": "rename", "target": "faction", "name": colony}):
			error_label.text = _prep_local("Could not save the colony name.", "Koloni adı kaydedilemedi.", "Nie można zapisać nazwy kolonii.")
			return
		if not _send_command({"type": "rename", "target": "settlement", "name": settlement}):
			error_label.text = _prep_local("Could not save the settlement name.", "Yerleşke adı kaydedilemedi.", "Nie można zapisać nazwy osady.")
			return
		faction_name = colony
		settlement_name = settlement
		_naming_prompt_open = false
		overlay.queue_free()
		_naming_overlay = null
		if screen == "game" and session_kind != "join":
			game_paused = resume_paused
			_update_speed_buttons()
	, true)
	content.add_child(confirm)
	colony_edit.call_deferred("grab_focus")


func _notice(message: String) -> void:
	var displayed := I18n.localize_model_text(message, preferences.language)
	_status_text = displayed
	_status_timer = 4.0
	if screen == "game" and is_instance_valid(_notice_label):
		_notice_label.text = displayed
		_notice_label.visible = true
	else:
		var dialog := AcceptDialog.new()
		dialog.title = "Foxtopia"
		dialog.dialog_text = displayed
		add_child(dialog)
		dialog.visibility_changed.connect(func():
			if not dialog.visible:
				dialog.queue_free())
		dialog.popup_centered()


func _my_faction(snapshot: Dictionary) -> Dictionary:
	var player_map: Dictionary = snapshot.get("players", {})
	var faction_id := str(player_map.get(str(Net.get_local_peer_id()), ""))
	for faction in _values_array(snapshot.get("factions", [])):
		if faction is Dictionary and str(faction.get("id", "")) == faction_id:
			return faction
	return {}


func _render_sidebar(snapshot: Dictionary) -> void:
	if not is_instance_valid(_sidebar):
		return
	for child in _sidebar.get_children():
		child.queue_free()
	match current_tab:
		"Emirler": _build_orders_tab(snapshot)
		"İşler": _build_work_tab(snapshot)
		"Günlük plan": _build_schedule_tab(snapshot)
		"Araştırma": _build_research_tab(snapshot)
		"Sağlık": _build_health_tab(snapshot)
		"Ticaret": _build_trade_tab(snapshot)
		"Dünya": _build_world_tab(snapshot)


func _tab_title(title: String, explanation: String) -> void:
	var heading := _hbox(14)
	_sidebar.add_child(heading)
	heading.add_child(_label(title.to_upper(), 18, GOLD))
	heading.add_child(_label(explanation, 13, MUTED))
	_sidebar.add_child(HSeparator.new())


func _build_orders_tab(snapshot: Dictionary) -> void:
	_tab_title("Architect", "Choose a tool. Right-click it to set order priority (1–9).")
	var categories := _hbox(5)
	_sidebar.add_child(categories)
	for category in ["Designate", "Construction", "Zones"]:
		var name: String = category
		categories.add_child(_button(name, func(): order_category = name; _render_sidebar(_snapshot()), order_category == name, Vector2(124, 27)))
	var tools: Array = []
	match order_category:
		"Designate": tools = [["Chop wood", "chop"], ["Mine", "mine"], ["Harvest", "harvest"], ["Haul", "haul"]]
		"Construction": tools = [["Wood wall", "build_wall"], ["Stone wall", "build_stone_wall"], ["Bed", "build_bed"], ["Research bench", "build_research_bench"], ["Styling table", "build_styling_table"], ["Barrier", "build_barrier"], ["Grow zone", "build_farm"]]
		"Zones": tools = [["Stockpile zone", "stockpile_zone"]]
	var tool_row := HFlowContainer.new()
	tool_row.add_theme_constant_override("h_separation", 5)
	tool_row.add_theme_constant_override("v_separation", 5)
	tool_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sidebar.add_child(tool_row)
	for pair in tools:
		var label_text: String = pair[0]
		var kind: String = pair[1]
		var button := _button(label_text, func(): _choose_tool(kind), current_tool == kind, Vector2(120, 30))
		button.tooltip_text = "Left click: select tool. Right click: choose priority 1–9. Current: %d." % default_order_priority
		tool_row.add_child(button)
		if kind != "stockpile_zone":
			var priority_menu := PopupMenu.new()
			for p in range(1, 10):
				priority_menu.add_item("Priority %d" % p, p)
			button.add_child(priority_menu)
			priority_menu.id_pressed.connect(func(p: int): default_order_priority = p; _choose_tool(kind))
			button.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
					priority_menu.position = Vector2i(get_viewport().get_mouse_position())
					priority_menu.popup())
	if not current_tool.is_empty() or order_category == "Zones":
		var actions := _hbox(7)
		_sidebar.add_child(actions)
		if not current_tool.is_empty():
			actions.add_child(_button("Cancel tool", func(): _choose_tool(""), false, Vector2(105, 25)))
		if order_category == "Zones":
			actions.add_child(_label("Click the map to place a 3×3 stockpile.", 12, MUTED))
	var own_id := str(_my_faction(snapshot).get("id", ""))
	var pending := 0
	for order in _values_array(snapshot.get("orders", [])):
		if str(order.get("faction_id", "")) != own_id or str(order.get("status", "")) in ["done", "cancelled"]:
			continue
		pending += 1
		if str(order.get("id", "")) == selected_order_id:
			var row := _hbox(7)
			_sidebar.add_child(row)
			row.add_child(_label("Selected: %s  (%d, %d)" % [_order_name(str(order.get("kind", ""))), int(order.get("x", 0)), int(order.get("y", 0))], 13))
			var order_id := str(order.get("id", ""))
			var option := OptionButton.new()
			for p in range(1, 10): option.add_item(str(p))
			option.select(clampi(int(order.get("priority", 5)) - 1, 0, 8))
			option.item_selected.connect(func(index: int): _send_command({"type": "set_order_priority", "order_id": order_id, "priority": index + 1}))
			row.add_child(option)
			row.add_child(_button("Cancel", func(): _send_command({"type": "cancel_order", "order_id": order_id}), false, Vector2(65, 25)))
	if pending > 0:
		_sidebar.add_child(_label("Pending orders: %d" % pending, 12, MUTED))
	var extra_height := 0
	if not current_tool.is_empty() or order_category == "Zones":
		extra_height += 35
	if pending > 0:
		extra_height += 20
	if not selected_order_id.is_empty():
		extra_height += 32
	if get_viewport_rect().size.x < 1250.0 and order_category == "Construction":
		extra_height += 45
	_tool_panel.offset_top = -185 - extra_height


func _choose_tool(kind: String) -> void:
	current_tool = kind
	_render_sidebar(_snapshot())
	if not kind.is_empty():
		_notice(_prep_local("Choose a map tile for %s.", "%s için haritada bir hücre seç.", "Wybierz pole mapy dla: %s.") % _order_name(kind))


func _order_name(kind: String) -> String:
	var names := {"chop": "Chop wood", "mine": "Mine stone", "harvest": "Harvest", "haul": "Haul", "build_wall": "Wood wall", "build_bed": "Bed", "build_research_bench": "Research bench", "build_styling_table": "Styling table", "build_stone_wall": "Stone wall", "build_barrier": "Barrier", "build_farm": "Grow zone"}
	return str(names.get(kind, kind))


func _build_work_tab(snapshot: Dictionary) -> void:
	_tab_title(_tr("tabs.work"), _tr("work.priority_hint") + "  " + _tr("work.priority_off") + " = 0.")
	var table := GridContainer.new()
	table.columns = JOBS.size() + 1
	table.add_theme_constant_override("h_separation", 10)
	table.add_theme_constant_override("v_separation", 5)
	_sidebar.add_child(table)
	table.add_child(_label("KOLONİST" if preferences.language == "tr" else "KOLONISTA" if preferences.language == "pl" else "COLONIST", 13, GOLD))
	for title in JOB_LABELS:
		var heading := _label(title.to_upper(), 12, MUTED)
		heading.custom_minimum_size = Vector2(112, 0)
		table.add_child(heading)
	for person in _local_colonists(snapshot):
		var person_id := str(person.get("id", ""))
		var name := _label(str(person.get("name", "Colonist")), 15, CREAM)
		name.custom_minimum_size = Vector2(150, 0)
		table.add_child(name)
		var priorities: Dictionary = person.get("work_priorities", {})
		for j in JOBS.size():
			var work: String = JOBS[j]
			var choice := OptionButton.new()
			choice.custom_minimum_size = Vector2(112, 27)
			_compact_option(choice)
			choice.add_item(_tr("work.priority_off"), 0)
			for p in range(1, 10):
				choice.add_item(str(p), p)
			choice.select(clampi(int(priorities.get(work, 5)), 0, 9))
			choice.item_selected.connect(func(index: int): _send_command({"type": "set_work_priority", "colonist_id": person_id, "work": work, "priority": index}))
			table.add_child(choice)


func _build_schedule_tab(snapshot: Dictionary) -> void:
	_tab_title(_tr("tabs.schedule"), _prep_local("Paint a daily plan for each colonist.", "Her kolonist için günlük planı boya.", "Ustal plan dnia dla każdego kolonisty."))
	var palette := _hbox(5)
	_sidebar.add_child(palette)
	for entry in [["anything", _prep_local("Anything", "Serbest", "Dowolnie")],
		["work", _prep_local("Work", "Çalış", "Praca")],
		["recreation", _prep_local("Recreation", "Eğlen", "Rekreacja")],
		["sleep", _prep_local("Sleep", "Uyu", "Sen")]]:
		var brush_id: String = entry[0]
		palette.add_child(_hud_button(str(entry[1]), func():
			schedule_brush = brush_id
			_render_sidebar(_snapshot()), brush_id == schedule_brush, Vector2(126, 30)))
	var table := GridContainer.new()
	table.columns = 25
	table.add_theme_constant_override("h_separation", 2)
	table.add_theme_constant_override("v_separation", 4)
	_sidebar.add_child(table)
	var name_heading := _label(_prep_local("COLONIST", "KOLONİST", "KOLONISTA"), 11, GOLD)
	name_heading.custom_minimum_size.x = 136
	table.add_child(name_heading)
	for hour in 24:
		var heading := _label(str(hour), 10, MUTED)
		heading.custom_minimum_size.x = 31
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		table.add_child(heading)
	for person in _local_colonists(snapshot):
		var person_id := str(person.get("id", ""))
		var name := _label(str(person.get("name", "Colonist")), 13)
		name.clip_text = true
		name.custom_minimum_size.x = 136
		table.add_child(name)
		var plan: Array = person.get("schedule", [])
		for hour in 24:
			var slot := hour
			var activity := str(plan[slot]) if slot < plan.size() else "anything"
			var button := _hud_button("S" if activity == "sleep" else "W" if activity == "work" else "R" if activity == "recreation" else "·",
				func(): _send_command({"type": "set_schedule", "colonist_id": person_id, "hour": slot, "activity": schedule_brush}), false, Vector2(31, 28))
			button.tooltip_text = "%s · %02d:00 · %s" % [str(person.get("name", "Colonist")), slot, activity.capitalize()]
			button.add_theme_stylebox_override("normal", _hud_style(Color("#435b79") if activity == "sleep" else Color("#786545") if activity == "work" else Color("#684f74") if activity == "recreation" else Color("#475157")))
			table.add_child(button)


func _build_research_tab(snapshot: Dictionary) -> void:
	_tab_title(_tr("tabs.research"), _tr("research.no_bench"))
	var has_bench := false
	for structure in _local_map(snapshot).get("structures", []):
		if str(structure.get("kind", "")) == "research_bench":
			has_bench = true
			break
	if not has_bench:
		_sidebar.add_child(_label(_tr("research.no_bench"), 16, MUTED))
		return
	var faction := _my_faction(snapshot)
	var research: Dictionary = faction.get("research", {})
	var active := str(research.get("project", ""))
	var unlocked: Array = research.get("unlocked", [])
	if not active.is_empty():
		_sidebar.add_child(_label(_prep_local("ACTIVE  %s  ·  %d progress", "AKTİF  %s  ·  %d ilerleme", "AKTYWNE  %s  ·  %d postępu") % [_research_name(active), int(research.get("progress", 0))], 13, TEAL))
	var project_row := _hbox(8)
	_sidebar.add_child(project_row)
	for project in RESEARCH_PROJECTS:
		var id := str(project.id)
		var card := _panel()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		project_row.add_child(card)
		var inner := _vbox(6)
		card.add_child(inner)
		inner.add_child(_label(SetupCatalog.localized(project.name, preferences.language).to_upper(), 14, GOLD if active == id else CREAM))
		inner.add_child(_label(SetupCatalog.localized(project.detail, preferences.language), 12, MUTED))
		if unlocked.has(id):
			inner.add_child(_label(_tr("research.completed"), 12, TEAL))
		else:
			inner.add_child(_button(_prep_local("Selected", "Seçili", "Wybrane") if active == id else _tr("research.select"), func(): _send_command({"type": "set_research", "project": id}), active == id, Vector2(90, 27)))


func _research_name(id: String) -> String:
	for project in RESEARCH_PROJECTS:
		if str(project.id) == id:
			return SetupCatalog.localized(project.name, preferences.language)
	return id


func _build_health_tab(snapshot: Dictionary) -> void:
	_tab_title(_prep_local("Colonists and health", "Karakter ve Sağlık", "Koloniści i zdrowie"), _prep_local("Select a colonist from the portrait bar or the map.", "Üst portreden veya haritadaki kolonistten seçim yap.", "Wybierz kolonistę z portretu u góry lub na mapie."))
	var person := _selected_person(snapshot)
	if person.is_empty():
		for colonist in _local_colonists(snapshot):
			var colonist_id := str(colonist.get("id", ""))
			var hp := roundi(float(colonist.get("health", {}).get("hp", 100.0)))
			_sidebar.add_child(_hud_button("%s   ·   %d%%" % [str(colonist.get("name", "Colonist")), hp],
				func(): _select_colonist(colonist_id, true), false, Vector2(190, 34)))
		return
	var person_id := str(person.get("id", ""))
	var body := _hbox(18)
	_sidebar.add_child(body)
	var profile := _vbox(5)
	profile.custom_minimum_size = Vector2(440, 0)
	profile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(profile)
	var traits: Array = person.get("traits", [])
	var trait_label := _display_trait(str(traits[0])) if not traits.is_empty() else _prep_local("No trait", "Özellik yok", "Brak cechy")
	var profile_header := _hbox(8)
	profile.add_child(profile_header)
	profile_header.add_child(_label("%s  ·  %s" % [str(person.get("name", "Colonist")), trait_label], 17, GOLD))
	profile_header.add_child(_button(_prep_local("Edit appearance", "Görünüşü düzenle", "Edytuj wygląd"), func(): _open_customize_dialog(person), false, Vector2(155, 27)))
	var skills: Dictionary = person.get("skills", {})
	var skill_grid := GridContainer.new()
	skill_grid.columns = 4
	skill_grid.add_theme_constant_override("h_separation", 12)
	skill_grid.add_theme_constant_override("v_separation", 3)
	profile.add_child(skill_grid)
	for j in JOBS.size():
		skill_grid.add_child(_label("%s %d" % [_display_work(JOBS[j]), int(skills.get(JOBS[j], 0))], 12, MUTED))
	var needs_column := _vbox(3)
	needs_column.custom_minimum_size = Vector2(225, 0)
	needs_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(needs_column)
	needs_column.add_child(_label(_tr("tabs.needs").to_upper(), 12, GOLD))
	var needs: Dictionary = person.get("needs", {})
	for pair in [[_tr("needs.food"), "hunger"], [_tr("needs.rest"), "rest"], [_tr("needs.mood"), "mood"]]:
		var need_row := _hbox(5)
		needs_column.add_child(need_row)
		need_row.add_child(_label("%s %d" % [pair[0], int(needs.get(pair[1], 0))], 12))
		var bar := ProgressBar.new()
		bar.max_value = 100
		bar.value = float(needs.get(pair[1], 0))
		bar.show_percentage = false
		bar.custom_minimum_size = Vector2(110, 13)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		need_row.add_child(bar)
	var action_column := _vbox(4)
	action_column.custom_minimum_size = Vector2(460, 0)
	action_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(action_column)
	var health: Dictionary = person.get("health", {})
	var health_row := _hbox(12)
	action_column.add_child(health_row)
	health_row.add_child(_label("%s %d / %d" % [_tr("tabs.health").to_upper(), int(health.get("hp", 100)), int(health.get("max_hp", 100))], 13, GOLD))
	health_row.add_child(_label("%s %.1f" % [_tr("health.bleeding"), float(health.get("bleeding", 0))], 12, RED if float(health.get("bleeding", 0)) > 0 else MUTED))
	health_row.add_child(_label(_prep_local("Pain %d%%", "Acı %d%%", "Ból %d%%") % roundi(float(health.get("pain", PreparationRules.health_pain(health))) * 100.0), 12, RED if float(health.get("pain", 0.0)) > 0.0 else MUTED))
	for wound in health.get("wounds", []):
		var wound_name := "%s · %s" % [_preparation_wound_label(str(wound.get("kind", "wound"))), _preparation_body_part_label(str(wound.get("body_part", "torso")))]
		if str(wound.get("cause", "unknown")) != "unknown":
			wound_name += " · " + _preparation_injury_cause_label(str(wound.get("cause", "unknown")))
		var tier := _preparation_injury_tier_label(str(wound.get("severity_tier", "")), str(wound.get("kind", "")))
		if str(wound.get("kind", "")) == "scar":
			action_column.add_child(_label("• %s · %s%s" % [wound_name, _prep_local("permanent", "kalıcı", "stała"), " · " + tier if not tier.is_empty() else ""], 12))
		else:
			action_column.add_child(_label(_prep_local("• %s · severity %d", "• %s · şiddet %d", "• %s · nasilenie %d") % [wound_name, int(wound.get("severity", 0))] + (" · " + tier if not tier.is_empty() else ""), 12))
	var equipment: Dictionary = person.get("equipment", {})
	action_column.add_child(_label(_prep_local("Weapon: %s   Apparel: %s", "Silah: %s   Kıyafet: %s", "Broń: %s   Ubranie: %s") % [_display_item(str(equipment.get("weapon", "none"))), _display_item(str(equipment.get("apparel", "none")))], 12))
	var buttons := _hbox(5)
	action_column.add_child(buttons)
	buttons.add_child(_button(_prep_local("Equip spear", "Mızrak kuşan", "Załóż włócznię"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "spear"}), false, Vector2(114, 27)))
	buttons.add_child(_button(_prep_local("Wear coat", "Kaban giy", "Załóż płaszcz"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"}), false, Vector2(86, 27)))
	buttons.add_child(_button(_prep_local("Draft: %s", "Savaş: %s", "Mobilizacja: %s") % (_tr("common.on") if bool(person.get("drafted", false)) else _tr("common.off")), func(): _send_command({"type": "set_draft", "colonist_id": person_id, "drafted": not bool(person.get("drafted", false))}), false, Vector2(105, 27)))
	buttons.add_child(_button(_prep_local("Cancel order", "Emri iptal et", "Anuluj rozkaz"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "clear"}), false, Vector2(110, 27)))


func _open_customize_dialog(person: Dictionary) -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, TEAL))
	add_child(popup)
	var content := _vbox(10)
	popup.add_child(content)
	content.add_child(_label(_prep_local("%s · Appearance", "%s · Görünüş", "%s · Wygląd") % str(person.get("name", "Colonist")), 21, GOLD))
	var appearance: Dictionary = person.get("appearance", {})
	var row := _hbox(12)
	content.add_child(row)
	var preview := PawnPreviewScript.new()
	row.add_child(preview)
	var fields := _vbox(8)
	row.add_child(fields)
	var hair := OptionButton.new()
	for label_text in _hair_options():
		hair.add_item(label_text)
	hair.select(maxi(0, ["short", "wavy", "long", "curly", "shaved"].find(str(appearance.get("hair", "short")))))
	fields.add_child(hair)
	var hair_color := OptionButton.new()
	for label_text in [_prep_local("Dark brown", "Koyu kahve", "Ciemny brąz"), _prep_local("Chestnut", "Kestane", "Kasztan"), _prep_local("Blond", "Sarı", "Blond"), _prep_local("Black", "Siyah", "Czarny"), _prep_local("Copper", "Bakır", "Miedziany")]:
		hair_color.add_item(label_text)
	hair_color.select(maxi(0, HAIR_COLOR_OPTIONS.find(str(appearance.get("hair_color", HAIR_COLOR_OPTIONS[0])))))
	fields.add_child(hair_color)
	var skin := OptionButton.new()
	for j in SKIN_OPTIONS.size():
		skin.add_item(_prep_local("Skin tone %d", "Ten rengi %d", "Odcień skóry %d") % (j + 1))
	skin.select(maxi(0, SKIN_OPTIONS.find(str(appearance.get("skin", SKIN_OPTIONS[0])))))
	fields.add_child(skin)
	var outfit := OptionButton.new()
	for j in OUTFIT_OPTIONS.size():
		outfit.add_item(_prep_local("Outfit %d", "Kıyafet %d", "Strój %d") % (j + 1))
	outfit.select(maxi(0, OUTFIT_OPTIONS.find(str(appearance.get("outfit", OUTFIT_OPTIONS[0])))))
	fields.add_child(outfit)
	for option in [hair, hair_color, skin, outfit]:
		option.item_selected.connect(func(_index: int): _update_character_preview(preview, hair, hair_color, skin, outfit))
	_update_character_preview(preview, hair, hair_color, skin, outfit)
	content.add_child(_button(_prep_local("Save changes", "Değişiklikleri kaydet", "Zapisz zmiany"), func():
		var hair_ids := ["short", "wavy", "long", "curly", "shaved"]
		_send_command({"type": "customize_colonist", "colonist_id": str(person.get("id", "")), "appearance": {"hair": hair_ids[hair.selected], "hair_color": HAIR_COLOR_OPTIONS[hair_color.selected], "skin": SKIN_OPTIONS[skin.selected], "outfit": OUTFIT_OPTIONS[outfit.selected]}})
		popup.hide()
		popup.queue_free()
	, true))
	popup.popup_centered(Vector2i(510, 310))


func _open_trade_dialog(caravan_id: String) -> void:
	var snapshot := _snapshot()
	if caravan_id.is_empty():
		_open_colony_trade_dialog(snapshot)
		return
	var caravan: Dictionary = {}
	for candidate in _local_caravans(snapshot):
		if str(candidate.get("id", "")) == caravan_id:
			caravan = candidate
			break
	if caravan.is_empty():
		_notice(_prep_local("The trader has left.", "Tüccar ayrıldı.", "Handlarz już odszedł."))
		return
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(8)
	content.custom_minimum_size = Vector2(650, 0)
	popup.add_child(content)
	content.add_child(_label(I18n.localize_caravan_name(str(caravan.get("name", "Trade caravan")), preferences.language), 22, GOLD))
	var inventory := _local_resources(snapshot)
	content.add_child(_label(_prep_local("Your silver: %d    Trader silver: %d", "Gümüşün: %d    Tüccarın gümüşü: %d", "Twoje srebro: %d    Srebro handlarza: %d") % [int(inventory.get("silver", 0)), int(caravan.get("stock", {}).get("silver", 0))], 14, MUTED))
	var columns := _hbox(15)
	content.add_child(columns)
	var buy_column := _vbox(4)
	buy_column.custom_minimum_size = Vector2(315, 0)
	columns.add_child(buy_column)
	buy_column.add_child(_label(_prep_local("Buy", "Satın al", "Kup"), 16, GOLD))
	var sell_column := _vbox(4)
	sell_column.custom_minimum_size = Vector2(315, 0)
	columns.add_child(sell_column)
	sell_column.add_child(_label(_prep_local("Sell", "Sat", "Sprzedaj"), 16, GOLD))
	var buy_fields: Dictionary = {}
	var sell_fields: Dictionary = {}
	for item in ITEM_PRICES:
		var available := int(caravan.get("stock", {}).get(item, 0))
		if available > 0:
			var row := _hbox(5)
			buy_column.add_child(row)
			var label := _label("%s  ·  %d %s  (%d)" % [_cargo_label(str(item)), int(ITEM_PRICES[item]), _cargo_label("silver"), available], 12)
			label.custom_minimum_size = Vector2(215, 0)
			row.add_child(label)
			var amount := SpinBox.new()
			amount.min_value = 0
			amount.max_value = available
			amount.custom_minimum_size = Vector2(75, 24)
			row.add_child(amount)
			buy_fields[item] = amount
		var owned := int(inventory.get(item, 0))
		if owned > 0:
			var sell_row := _hbox(5)
			sell_column.add_child(sell_row)
			var sell_label := _label("%s  ·  %d %s  (%d)" % [_cargo_label(str(item)), int(ITEM_PRICES[item]), _cargo_label("silver"), owned], 12)
			sell_label.custom_minimum_size = Vector2(215, 0)
			sell_row.add_child(sell_label)
			var sell_amount := SpinBox.new()
			sell_amount.min_value = 0
			sell_amount.max_value = owned
			sell_amount.custom_minimum_size = Vector2(75, 24)
			sell_row.add_child(sell_amount)
			sell_fields[item] = sell_amount
	var buttons := _hbox(8)
	content.add_child(buttons)
	buttons.add_child(_button(_prep_local("Close", "Kapat", "Zamknij"), func(): popup.hide()))
	buttons.add_child(_button(_prep_local("Confirm trade", "Ticareti onayla", "Potwierdź handel"), func():
		var buy: Dictionary = {}
		var sell: Dictionary = {}
		for item in buy_fields:
			var amount := int((buy_fields[item] as SpinBox).value)
			if amount > 0: buy[item] = amount
		for item in sell_fields:
			var amount := int((sell_fields[item] as SpinBox).value)
			if amount > 0: sell[item] = amount
		if buy.is_empty() and sell.is_empty():
			_notice(_prep_local("Choose an item first.", "Önce bir eşya seç.", "Najpierw wybierz przedmiot."))
			return
		_send_command({"type": "npc_trade", "caravan_id": caravan_id, "buy": buy, "sell": sell})
		popup.hide()
	, true))
	popup.popup_hide.connect(func(): popup.queue_free())
	popup.popup_centered(Vector2i(700, 530))

func _open_colony_trade_dialog(snapshot: Dictionary) -> void:
	var mine := _my_faction(snapshot)
	var others: Array = []
	for faction in _values_array(snapshot.get("factions", [])):
		if str(faction.get("id", "")) != str(mine.get("id", "")):
			others.append(faction)
	if others.is_empty():
		_notice("No other player colony is available for trade.")
		return
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(9)
	content.custom_minimum_size = Vector2(430, 0)
	popup.add_child(content)
	content.add_child(_label("Trade offer", 21, GOLD))
	var target := OptionButton.new()
	for faction in others: target.add_item(str(faction.get("name", "Colony")))
	content.add_child(target)
	var give := OptionButton.new()
	var receive := OptionButton.new()
	for item in ITEM_PRICES:
		give.add_item(str(item))
		receive.add_item(str(item))
	content.add_child(_label("Offer", 13, MUTED))
	content.add_child(give)
	var give_amount := SpinBox.new()
	give_amount.min_value = 1
	give_amount.max_value = 99
	content.add_child(give_amount)
	content.add_child(_label("Request", 13, MUTED))
	content.add_child(receive)
	var receive_amount := SpinBox.new()
	receive_amount.min_value = 1
	receive_amount.max_value = 99
	content.add_child(receive_amount)
	var row := _hbox(8)
	content.add_child(row)
	row.add_child(_button("Close", func(): popup.hide()))
	row.add_child(_button("Send offer", func():
		_send_command({"type": "trade_offer", "to_faction": str(others[target.selected].get("id", "")), "give": {give.get_item_text(give.selected): int(give_amount.value)}, "receive": {receive.get_item_text(receive.selected): int(receive_amount.value)}})
		popup.hide()
	, true))
	popup.popup_hide.connect(func(): popup.queue_free())
	popup.popup_centered(Vector2i(470, 560))

func _build_trade_tab(snapshot: Dictionary) -> void:
	_tab_title(_prep_local("Trade", "Ticaret", "Handel"), _prep_local("Exchange goods with player colonies and visiting caravans.", "Oyuncu kolonileri ve gelen kervanlarla mal takası yap.", "Wymieniaj towary z koloniami graczy i karawanami."))
	var mine := _my_faction(snapshot)
	var my_id := str(mine.get("id", ""))
	var inventory: Dictionary = mine.get("inventory", {})
	_sidebar.add_child(_label(_prep_local("Stock: %d wood · %d stone · %d food · %d silver", "Depo: %d odun · %d taş · %d yiyecek · %d gümüş", "Zapasy: %d drewna · %d kamienia · %d żywności · %d srebra") % [int(inventory.get("wood", 0)), int(inventory.get("stone", 0)), int(inventory.get("food", 0)), int(inventory.get("silver", 0))], 14, MUTED))
	var others: Array = []
	for faction in _values_array(snapshot.get("factions", [])):
		if str(faction.get("id", "")) != my_id:
			others.append(faction)
	if not others.is_empty():
		_sidebar.add_child(_label(_prep_local("Colony trade offer", "Koloniler arası teklif", "Oferta handlu między koloniami"), 18, GOLD))
		var target := OptionButton.new()
		for other in others:
			target.add_item(str(other.get("name", _prep_local("Colony", "Koloni", "Kolonia"))))
		_sidebar.add_child(target)
		var give_item := OptionButton.new()
		var receive_item := OptionButton.new()
		for item in ["wood", "stone", "food", "medicine", "spear", "jacket", "tshirt", "pants"]:
			give_item.add_item(item)
			receive_item.add_item(item)
		receive_item.select(1)
		_sidebar.add_child(_label(_prep_local("Offer item / amount", "Vereceğin eşya / miktar", "Oferowany przedmiot / ilość"), 14))
		_sidebar.add_child(give_item)
		var give_count := SpinBox.new()
		give_count.min_value = 1
		give_count.max_value = 99
		give_count.value = 2
		_sidebar.add_child(give_count)
		_sidebar.add_child(_label(_prep_local("Request item / amount", "İstediğin eşya / miktar", "Żądany przedmiot / ilość"), 14))
		_sidebar.add_child(receive_item)
		var receive_count := SpinBox.new()
		receive_count.min_value = 1
		receive_count.max_value = 99
		receive_count.value = 1
		_sidebar.add_child(receive_count)
		_sidebar.add_child(_button(_tr("trade.offer"), func(): _send_command({"type": "trade_offer", "to_faction": str(others[target.selected].get("id", "")), "give": {give_item.get_item_text(give_item.selected): int(give_count.value)}, "receive": {receive_item.get_item_text(receive_item.selected): int(receive_count.value)}}), true))
	for offer in _values_array(snapshot.get("trade_offers", [])):
		if str(offer.get("status", "")) != "pending":
			continue
		var offer_id := str(offer.get("id", ""))
		var card := _panel()
		_sidebar.add_child(card)
		var inner := _vbox(6)
		card.add_child(inner)
		inner.add_child(_label(_prep_local("Offer: %s → %s", "Teklif: %s → %s", "Oferta: %s → %s") % [offer.get("from_faction", ""), offer.get("to_faction", "")], 15))
		inner.add_child(_label(_prep_local("Give: %s   Receive: %s", "Verilen: %s   İstenen: %s", "Daj: %s   Otrzymaj: %s") % [str(offer.get("give", {})), str(offer.get("receive", {}))], 13, MUTED))
		if str(offer.get("to_faction", "")) == my_id:
			inner.add_child(_button(_tr("trade.accept"), func(): _send_command({"type": "trade_accept", "offer_id": offer_id}), true))
		inner.add_child(_button(_prep_local("Decline / withdraw", "Reddet / geri çek", "Odrzuć / wycofaj"), func(): _send_command({"type": "trade_decline", "offer_id": offer_id})))
	var caravans: Array = []
	for caravan in _values_array(snapshot.get("caravans", [])):
		if str(caravan.get("kind", "")) == "npc" and str(caravan.get("faction_id", "")) == my_id:
			caravans.append(caravan)
	if others.is_empty() and caravans.is_empty():
		_sidebar.add_child(_label(_prep_local("No caravan is here. Friendly settlements may visit as time passes.", "Şu anda kervan yok. Zamanla dost yerleşkeler ziyaret edebilir.", "Nie ma tu karawany. Przyjazne osady mogą odwiedzić kolonię z czasem."), 15, MUTED))
	if not caravans.is_empty():
		_sidebar.add_child(HSeparator.new())
		_sidebar.add_child(_label(_prep_local("Visiting traders", "Gelen tüccarlar", "Przybyli kupcy"), 18, GOLD))
	for caravan in caravans:
		var caravan_id := str(caravan.get("id", ""))
		_sidebar.add_child(_label(_prep_local("Caravan %s  ·  (%d, %d)", "Kervan %s  ·  (%d, %d)", "Karawana %s  ·  (%d, %d)") % [caravan_id, int(caravan.get("x", 0)), int(caravan.get("y", 0))], 15))
		var stock: Dictionary = caravan.get("stock", {})
		var product := OptionButton.new()
		for item in stock.keys():
			if item != "silver" and int(stock[item]) > 0:
				product.add_item(str(item))
		_sidebar.add_child(product)
		if product.item_count > 0:
			_sidebar.add_child(_button(_prep_local("Buy 1", "1 adet satın al", "Kup 1"), func(): _send_command({"type": "npc_trade", "caravan_id": caravan_id, "buy": {product.get_item_text(product.selected): 1}, "sell": {}}), true))
		var sell_item := OptionButton.new()
		for item in ["wood", "stone", "food", "medicine", "spear", "jacket", "tshirt", "pants"]:
			if int(inventory.get(item, 0)) > 0:
				sell_item.add_item(item)
		_sidebar.add_child(sell_item)
		if sell_item.item_count > 0:
			_sidebar.add_child(_button(_prep_local("Sell 1", "1 adet sat", "Sprzedaj 1"), func(): _send_command({"type": "npc_trade", "caravan_id": caravan_id, "buy": {}, "sell": {sell_item.get_item_text(sell_item.selected): 1}})))


func _build_world_tab(snapshot: Dictionary) -> void:
	_tab_title(_tr("tabs.world"), _prep_local("Settlements and relations", "Yerleşkeler ve ilişkiler", "Osady i relacje"))
	var faction := _my_faction(snapshot)
	_sidebar.add_child(_label("%s · %s" % [faction.get("name", faction_name), faction.get("settlement_name", settlement_name)], 18, GOLD))
	_sidebar.add_child(_button(_prep_local("Open world map", "Dünya haritasını aç", "Otwórz mapę świata"), func(): _open_world_overview(snapshot), true))
	_sidebar.add_child(_label(_prep_local("Friendly settlements may send caravans; hostile settlements may send raids.", "Dost yerleşkeler kervan, düşman yerleşkeler baskın gönderebilir.", "Przyjazne osady mogą wysyłać karawany, a wrogie — najazdy."), 14, MUTED))
	_sidebar.add_child(HSeparator.new())
	var mine_id := str(faction.get("id", ""))
	var has_other_player_colony := false
	for other in _values_array(snapshot.get("factions", [])):
		if str(other.get("id", "")) != mine_id:
			has_other_player_colony = true
			break
	if has_other_player_colony:
		_sidebar.add_child(_button(_prep_local("Trade with another colony", "Başka koloniyle ticaret yap", "Handluj z inną kolonią"), func(): _open_colony_trade_dialog(_snapshot())))
	for offer in _values_array(snapshot.get("trade_offers", [])):
		if str(offer.get("status", "")) != "pending" or str(offer.get("to_faction", "")) != mine_id:
			continue
		var offer_id := str(offer.get("id", ""))
		_sidebar.add_child(_label(_prep_local("Offer from %s · give %s · receive %s", "%s teklif etti · ver %s · al %s", "Oferta od %s · daj %s · otrzymaj %s") % [str(offer.get("from_faction", "")), str(offer.get("give", {})), str(offer.get("receive", {}))], 13))
		var actions := _hbox(5)
		_sidebar.add_child(actions)
		actions.add_child(_button(_tr("trade.accept"), func(): _send_command({"type": "trade_accept", "offer_id": offer_id})))
		actions.add_child(_button(_tr("trade.decline"), func(): _send_command({"type": "trade_decline", "offer_id": offer_id})))
	_sidebar.add_child(HSeparator.new())
	var world: Dictionary = snapshot.get("world", {})
	for site in world.get("sites", []):
		if str(site.get("kind", "")) != "vacant":
			_sidebar.add_child(_label("• %s — %s" % [I18n.localize_site_name(str(site.get("name", _prep_local("Settlement", "Yerleşke", "Osada"))), preferences.language), _display_site_kind(str(site.get("kind", "")))], 14, MUTED))


func _open_world_overview(snapshot: Dictionary) -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, TEAL))
	add_child(popup)
	var viewer := WorldViewScript.new()
	viewer.custom_minimum_size = Vector2(900, 560)
	viewer.set_preview(snapshot.get("world", {}), _site_id(snapshot))
	popup.add_child(viewer)
	popup.popup_centered(Vector2i(940, 600))


func _save_game() -> void:
	if session_kind == "join":
		_notice(_prep_local("Only the host can save this game.", "Bu oyunu yalnızca ev sahibi kaydedebilir.", "Tylko gospodarz może zapisać tę grę."))
		return
	_open_save_picker(true)


func _load_saved_game() -> void:
	if session_kind == "join":
		_notice(_prep_local("A guest cannot load a save.", "Konuk kayıtlı oyun yükleyemez.", "Gość nie może wczytać zapisu."))
		return
	_open_save_picker(false)


func _open_save_picker(save_mode: bool) -> void:
	if _save_picker_open:
		return
	_save_picker_open = true
	var resume_paused := game_paused
	if screen == "game" and session_kind == "solo":
		game_paused = true
		_update_speed_buttons()
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(8)
	content.custom_minimum_size = Vector2(470, 0)
	popup.add_child(content)
	content.add_child(_label(_tr("game.save_game") if save_mode else _tr("game.load_game"), 22, GOLD))
	if save_mode:
		var name_edit := LineEdit.new()
		name_edit.placeholder_text = _prep_local("Save name", "Kayıt adı", "Nazwa zapisu")
		name_edit.text = "save_%d" % Time.get_unix_time_from_system()
		content.add_child(name_edit)
		content.add_child(_button(_prep_local("Create new save", "Yeni kayıt oluştur", "Utwórz nowy zapis"), func():
			var slot := name_edit.text.strip_edges().replace(" ", "_")
			for existing in Game.list_saved_games():
				if str(existing.get("id", "")) == slot:
					_confirm_overwrite_save(slot, popup)
					return
			var saved := Game.save_game(slot)
			_notice(_prep_local("Game saved.", "Oyun kaydedildi.", "Gra zapisana.") if saved else _prep_local("Could not save. Use letters, numbers, _ or -.", "Kaydedilemedi. Harf, sayı, _ veya - kullan.", "Nie można zapisać. Użyj liter, cyfr, _ lub -."))
			if saved: popup.hide()
		, true))
	var saves: Array = Game.list_saved_games()
	if saves.is_empty():
		content.add_child(_label(_tr("saves.empty"), 14, MUTED))
	else:
		content.add_child(_label(_prep_local("Existing saves", "Mevcut kayıtlar", "Istniejące zapisy"), 14, MUTED))
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(470, minf(320.0, float(saves.size()) * 50.0))
		content.add_child(scroll)
		var rows := _vbox(5)
		scroll.add_child(rows)
		for saved in saves:
			var slot_id := str(saved.get("id", ""))
			var colonies: Array = saved.get("colonies", [])
			var auto_label := _prep_local("AUTO  ", "OTOMATİK  ", "AUTO  ") if bool(saved.get("is_autosave", false)) else ""
			var label_text := _prep_local("%s%s  ·  %s  ·  day %d", "%s%s  ·  %s  ·  gün %d", "%s%s  ·  %s  ·  dzień %d") % [auto_label, slot_id, ", ".join(colonies), int(saved.get("time", 0)) / 600 + 1]
			var row := _hbox(5)
			rows.add_child(row)
			if save_mode and not bool(saved.get("is_autosave", false)):
				row.add_child(_button(_prep_local("Overwrite  ", "Üzerine yaz  ", "Nadpisz  ") + label_text, func():
					_confirm_overwrite_save(slot_id, popup)
				))
			else:
				row.add_child(_button(label_text, func(): popup.hide(); _load_slot(slot_id)))
			row.add_child(_button(_prep_local("Delete", "Sil", "Usuń"), func(): _confirm_delete_save(slot_id, popup, save_mode), false, Vector2(68, 32)))
	content.add_child(_button(_tr("common.close"), func(): popup.hide()))
	popup.popup_hide.connect(func():
		_save_picker_open = false
		if screen == "game" and session_kind == "solo":
			game_paused = resume_paused
			_update_speed_buttons()
		popup.queue_free())
	popup.popup_centered(Vector2i(510, 500))


func _confirm_overwrite_save(slot_id: String, picker: PopupPanel) -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = _prep_local("Overwrite save", "Kaydın üzerine yaz", "Nadpisz zapis")
	confirmation.dialog_text = _prep_local("Replace '%s' with the current colony?" % slot_id, "'%s' kaydını mevcut koloniyle değiştir?" % slot_id, "Zastąpić zapis '%s' bieżącą kolonią?" % slot_id)
	add_child(confirmation)
	confirmation.confirmed.connect(func():
		var saved_ok := Game.save_game(slot_id)
		_notice(_prep_local("Game saved.", "Oyun kaydedildi.", "Gra zapisana.") if saved_ok else _prep_local("Could not save the game.", "Oyun kaydedilemedi.", "Nie można zapisać gry."))
		confirmation.hide()
		if saved_ok:
			picker.hide())
	confirmation.visibility_changed.connect(func():
		if not confirmation.visible:
			confirmation.queue_free())
	confirmation.popup_centered()


func _confirm_delete_save(slot_id: String, picker: PopupPanel, save_mode: bool) -> void:
	var confirmation := ConfirmationDialog.new()
	confirmation.title = _prep_local("Delete save", "Kaydı sil", "Usuń zapis")
	confirmation.dialog_text = _prep_local("Delete '%s' permanently?" % slot_id, "'%s' kaydı kalıcı silinsin mi?" % slot_id, "Usunąć '%s' na stałe?" % slot_id)
	add_child(confirmation)
	confirmation.confirmed.connect(func():
		var deleted := Game.delete_saved_game(slot_id)
		confirmation.hide()
		if deleted:
			picker.hide()
			_open_save_picker(save_mode)
		else:
			_notice(_prep_local("Could not delete save.", "Kayıt silinemedi.", "Nie udało się usunąć zapisu.")))
	confirmation.visibility_changed.connect(func():
		if not confirmation.visible:
			confirmation.queue_free())
	confirmation.popup_centered()


func _load_slot(slot_id: String) -> void:
	Net.start_solo()
	if not Game.load_game(slot_id):
		_notice(_prep_local("Could not open this save.", "Bu kayıt açılamadı.", "Nie można otworzyć tego zapisu."))
		return
	session_kind = "solo"
	var data := Game.get_snapshot()
	var mine := _my_faction(data)
	faction_name = str(mine.get("name", _prep_local("Colony", "Koloni", "Kolonia")))
	settlement_name = str(mine.get("settlement_name", _prep_local("Settlement", "Yerleşke", "Osada")))
	selected_site_id = str(mine.get("site_id", ""))
	game_paused = false
	_show_game()
