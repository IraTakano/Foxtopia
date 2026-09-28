extends Control

const MapViewScript = preload("res://scripts/ui/map_view.gd")
const WorldViewScript = preload("res://scripts/ui/world_view.gd")
const PawnPreviewScript = preload("res://scripts/ui/pawn_preview.gd")

const BG := Color("#1b1d1e")
const PANEL := Color("#282b2c")
const PANEL_ALT := Color("#35393a")
const CREAM := Color("#e5e1d6")
const MUTED := Color("#aaa9a0")
const GOLD := Color("#c8af79")
const TEAL := Color("#a2b8a4")
const RED := Color("#d18a7e")

const JOBS := ["chop", "mine", "harvest", "haul", "build", "treat", "research"]
const JOB_LABELS := ["Odun", "Taş", "Hasat", "Taşıma", "İnşa", "Bakım", "Araştırma"]
const TRAITS := ["Çalışkan", "Sakin", "Çevik", "Merhametli", "Ürkek", "Meraklı"]
const HAIR_OPTIONS := ["Kısa", "Dalgalı", "Uzun", "Kıvırcık", "Kazınmış"]
const SKIN_OPTIONS := ["#f1c99f", "#dca979", "#b98057", "#80563f", "#52392d"]
const OUTFIT_OPTIONS := ["#527a81", "#b16f59", "#7b8664", "#92759a", "#b89c65"]
const HAIR_COLOR_OPTIONS := ["#4d3c32", "#8b6449", "#bb9b69", "#343a3a", "#8c5f56"]
const RESEARCH_PROJECTS := [
	{"id": "farming", "name": "Tarım", "detail": "Ekim alanları ve güvenilir yiyecek üretimi."},
	{"id": "first_aid", "name": "İlk Yardım", "detail": "Daha etkili bakım ve iyileşme."},
	{"id": "stonework", "name": "Taş İşçiliği", "detail": "Dayanıklı taş duvarlar."},
	{"id": "barriers", "name": "Barikat", "detail": "Yerleşkeyi baskınlara karşı güçlendir."}
]

var screen := "menu"
var session_kind := "solo"
var setup_mode := "solo"
var setup_seed := ""
var colonist_count := 3
var faction_count := 2
var host_port := 24567
var selected_site_id := ""
var world_preview: Dictionary = {}
var faction_name := "Tilki Kolonisi"
var settlement_name := "Yeni Yuva"
var character_specs: Array = []
var current_tab := "Emirler"
var selected_ids: Array[String] = []
var selected_order_id := ""
var default_order_priority := 5
var current_tool := ""
var game_paused := false
var speed := 1.0
var _tick_accumulator := 0.0
var _status_text := ""
var _status_timer := 0.0
var _game_root: VBoxContainer
var _map_view: Control
var _sidebar: VBoxContainer
var _top_info: Label
var _resource_info: Label
var _portrait_strip: HBoxContainer
var _tab_buttons: Dictionary = {}
var _context_menu: PopupMenu
var _context_tile := Vector2i.ZERO
var _context_unit_id := ""
var _context_enemy_id := ""
var _context_order_id := ""
var _context_caravan_id := ""
var _world_view: Control
var _site_info: Label
var _seed_edit: LineEdit
var _mode_option: OptionButton
var _count_option: OptionButton
var _host_port_input: SpinBox
var _faction_name_edit: LineEdit
var _settlement_name_edit: LineEdit
var _character_inputs: Array = []
var _editing_character_index := 0


func _ready() -> void:
	Game.state_changed.connect(_on_state_changed)
	Game.event_emitted.connect(_on_event_emitted)
	Net.connection_changed.connect(_on_connection_changed)
	Net.lobby_changed.connect(_on_lobby_changed)
	Net.snapshot_received.connect(_on_network_snapshot)
	_show_menu()


func _process(delta: float) -> void:
	if _status_timer > 0.0:
		_status_timer -= delta
	if screen != "game" or game_paused:
		return
	_tick_accumulator += delta * speed
	while _tick_accumulator >= 0.25:
		_tick_accumulator -= 0.25
		if session_kind != "join":
			Game.tick(0.25)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F11:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1440, 900))
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and screen == "game":
		_show_pause_menu()
		get_viewport().set_input_as_handled()


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
	var content := _vbox(0 if screen == "game" else 12)
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
	var backdrop := TextureRect.new()
	backdrop.texture = load("res://assets/menu_background.png")
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
	_screen_header(root, "FOXTOPIA", "Küçük bir dünyada kendi hikâyeni kur.")
	var stage := _hbox(0)
	stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(stage)
	var illustration_space := Control.new()
	illustration_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage.add_child(illustration_space)
	var choices := _vbox(10)
	choices.custom_minimum_size = Vector2(350, 0)
	choices.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stage.add_child(choices)
	choices.add_child(_label("YERLEŞKEN SENİ BEKLİYOR", 19, GOLD))
	var menu_description := _label("Kolonistlerini hazırla, dünyada bir yer seç ve yaşam kur.", 14, CREAM)
	menu_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	choices.add_child(menu_description)
	choices.add_child(HSeparator.new())
	choices.add_child(_button("Tek Oyunculu", func(): _begin_session("solo"), true, Vector2(0, 44)))
	choices.add_child(_button("Çok Oyunculu Oda Kur", func(): _begin_session("host"), false, Vector2(0, 42)))
	choices.add_child(_button("Odaya Katıl", _show_join, false, Vector2(0, 42)))
	choices.add_child(_button("Kayıtlı Oyunu Aç", _load_saved_game, false, Vector2(0, 42)))
	root.add_child(_label("İlk oynanabilir sürüm   •   50×50 harita   •   1–3 başlangıç kolonisti", 13, CREAM))


func _begin_session(kind: String) -> void:
	session_kind = kind
	setup_mode = "solo" if kind == "solo" else "coop"
	setup_seed = str(randi())
	selected_site_id = ""
	character_specs.clear()
	_editing_character_index = 0
	if kind == "solo":
		Net.start_solo()
	_show_setup()


func _show_join() -> void:
	screen = "join"
	var root := _clear_screen()
	_screen_header(root, "Odaya Katıl", "Ev sahibinin adresini gir.")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel := _panel(Vector2(600, 0))
	center.add_child(panel)
	var inner := _vbox(16)
	panel.add_child(inner)
	inner.add_child(_label("Sunucu adresi", 18))
	var address := LineEdit.new()
	address.text = "127.0.0.1"
	address.placeholder_text = "IP veya alan adı"
	inner.add_child(address)
	inner.add_child(_label("Port", 18))
	var port := SpinBox.new()
	port.min_value = 1024
	port.max_value = 65535
	port.value = 24567
	inner.add_child(port)
	var row := _hbox()
	inner.add_child(row)
	row.add_child(_button("Geri", _show_menu))
	row.add_child(_button("Bağlan", func(): _connect_to_host(address.text, int(port.value)), true))


func _connect_to_host(address: String, port: int) -> void:
	var result = Net.join(address.strip_edges(), port)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Bağlanılamadı.")))
		return
	session_kind = "join"
	_show_waiting_room("Ev sahibinin oyunu başlatması bekleniyor. Bağlantı kurulduğunda dünya açılır.")


func _show_setup() -> void:
	screen = "setup"
	var root := _clear_screen()
	_screen_header(root, "Yeni Dünya", "1 / 4  •  Oyun kuralları")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var panel := _panel(Vector2(700, 0))
	center.add_child(panel)
	var inner := _vbox(17)
	panel.add_child(inner)
	inner.add_child(_label("Nasıl oynayacağız?", 24, GOLD))
	_mode_option = OptionButton.new()
	_mode_option.add_item("Tek Oyunculu", 0)
	_mode_option.add_item("Co-op — aynı koloni", 1)
	_mode_option.add_item("Ayrı Koloniler — ayrı yerleşkeler", 2)
	_mode_option.select(0 if setup_mode == "solo" else 1 if setup_mode == "coop" else 2)
	_mode_option.disabled = session_kind == "solo"
	inner.add_child(_mode_option)
	inner.add_child(_label("Koloni başına başlangıç insanı", 18))
	_count_option = OptionButton.new()
	for i in range(1, 4):
		_count_option.add_item("%d insan" % i, i)
	_count_option.select(colonist_count - 1)
	inner.add_child(_count_option)
	inner.add_child(_label("Dünya tohumu", 18))
	_seed_edit = LineEdit.new()
	_seed_edit.text = setup_seed
	_seed_edit.placeholder_text = "İstersen kendi tohumunu yaz"
	inner.add_child(_seed_edit)
	inner.add_child(_label("Aynı tohum aynı dünya ve yerleşke seçeneklerini oluşturur.", 14, MUTED))
	if session_kind == "host":
		inner.add_child(_label("Oda portu", 18))
		_host_port_input = SpinBox.new()
		_host_port_input.min_value = 1024
		_host_port_input.max_value = 65535
		_host_port_input.value = host_port
		inner.add_child(_host_port_input)
	var row := _hbox()
	inner.add_child(row)
	row.add_child(_button("Geri", _show_menu))
	row.add_child(_button("Dünyayı Gör", _advance_to_world, true))


func _advance_to_world() -> void:
	setup_mode = ["solo", "coop", "competitive"][_mode_option.selected]
	colonist_count = _count_option.selected + 1
	setup_seed = _seed_edit.text.strip_edges()
	if setup_seed.is_empty():
		setup_seed = str(randi())
	if session_kind == "host":
		host_port = int(_host_port_input.value)
		var host_result = Net.host(host_port)
		if host_result is Dictionary and not bool(host_result.get("ok", true)):
			_notice(str(host_result.get("error", "Oda açılamadı.")))
			return
		Net.configure_lobby({"mode": setup_mode, "seed": setup_seed, "colonists_per_faction": colonist_count})
	world_preview = Game.preview_world(setup_seed)
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
	var root := _clear_screen()
	_screen_header(root, "Dünya Haritası", "2 / 4  •  Yerleşke noktanı seç")
	var row := _hbox(16)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(row)
	var map_panel := _panel(Vector2(640, 510))
	map_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(map_panel)
	_world_view = WorldViewScript.new()
	_world_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_world_view.set_preview(world_preview, selected_site_id)
	_world_view.site_selected.connect(_select_site)
	map_panel.add_child(_world_view)
	var side_panel := _panel(Vector2(320, 0))
	row.add_child(side_panel)
	var side := _vbox(12)
	side_panel.add_child(side)
	side.add_child(_label("Bir yer seç", 23, GOLD))
	_site_info = _label("", 16, CREAM)
	side.add_child(_site_info)
	side.add_child(_label("● Dost koloni    ● Düşman koloni\n● Boş bölge", 14, MUTED))
	side.add_child(_spacer())
	var site_hint := _label("Co-op tek yerleşkeyi paylaşır. Ayrı koloniler kendi yerleşkesini seçer ve kervanlarla ulaşır.", 15, MUTED)
	site_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side.add_child(site_hint)
	_update_site_info()
	var buttons := _hbox()
	root.add_child(buttons)
	buttons.add_child(_button("Geri", _show_setup))
	buttons.add_child(_button("İsimler ve Karakterler", _show_characters, true))


func _select_site(site_id: String) -> void:
	for site in world_preview.get("sites", []):
		if str(site.get("id", "")) == site_id and str(site.get("kind", "")) not in ["vacant", "player"]:
			_notice("Bu yerleşke dolu. Boş bir bölge seç.")
			_world_view.set_preview(world_preview, selected_site_id)
			return
	selected_site_id = site_id
	_update_site_info()


func _update_site_info() -> void:
	if not is_instance_valid(_site_info):
		return
	var chosen: Dictionary = {}
	for site in world_preview.get("sites", []):
		if str(site.get("id", "")) == selected_site_id:
			chosen = site
			break
	if chosen.is_empty():
		_site_info.text = "Haritada bir işaret seç."
		return
	_site_info.text = "%s\n\nBölge: %s\nKonum: %s, %s\nDurum: %s" % [str(chosen.get("name", "İsimsiz")), str(chosen.get("biome", "Orman")), str(chosen.get("x", 0)), str(chosen.get("y", 0)), str(chosen.get("kind", "Boş"))]


func _show_characters() -> void:
	screen = "characters"
	if character_specs.size() > colonist_count:
		character_specs.resize(colonist_count)
	while character_specs.size() < colonist_count:
		var i := character_specs.size()
		character_specs.append({"name": ["Ada", "Baran", "Deniz"][i], "hair_index": i % HAIR_OPTIONS.size(), "hair_color_index": 0, "skin_index": i % SKIN_OPTIONS.size(), "outfit_index": i % OUTFIT_OPTIONS.size(), "trait_index": i % TRAITS.size()})
	_editing_character_index = clampi(_editing_character_index, 0, colonist_count - 1)
	var root := _clear_screen()
	_screen_header(root, "Kolonini Hazırla", "3 / 4  •  Adlar, insanlar ve görünüş")
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var body := _hbox(12)
	body.custom_minimum_size = Vector2(1240, 600)
	center.add_child(body)
	var roster_panel := _panel(Vector2(280, 0))
	body.add_child(roster_panel)
	var roster := _vbox(9)
	roster_panel.add_child(roster)
	roster.add_child(_label("KOLONİ", 16, GOLD))
	roster.add_child(_label("Koloni adı", 13, MUTED))
	_faction_name_edit = LineEdit.new()
	_faction_name_edit.text = faction_name
	roster.add_child(_faction_name_edit)
	roster.add_child(_label("Yerleşke adı", 13, MUTED))
	_settlement_name_edit = LineEdit.new()
	_settlement_name_edit.text = settlement_name
	roster.add_child(_settlement_name_edit)
	roster.add_child(HSeparator.new())
	roster.add_child(_label("BAŞLANGIÇ EKİBİ  ·  %d KİŞİ" % colonist_count, 15, GOLD))
	for i in colonist_count:
		var spec: Dictionary = character_specs[i]
		var index_copy := i
		roster.add_child(_button("%02d   %s   ·   %s" % [i + 1, spec.get("name", "Kolonist"), TRAITS[int(spec.get("trait_index", 0))]], func(): _select_character_editor(index_copy), i == _editing_character_index, Vector2(0, 46)))
	roster.add_child(_spacer())
	var roster_hint := _label("Her kolonistin adını, kişiliğini ve görünüşünü oyuna girmeden önce hazırla.", 13, MUTED)
	roster_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	roster.add_child(roster_hint)
	var editor_panel := _panel()
	editor_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(editor_panel)
	var editor := _vbox(12)
	editor_panel.add_child(editor)
	editor.add_child(_label("%02d  /  KOLONİST DÜZENLE" % (_editing_character_index + 1), 18, GOLD))
	editor.add_child(HSeparator.new())
	_character_inputs.clear()
	var old: Dictionary = character_specs[_editing_character_index]
	var card_body := _hbox(22)
	editor.add_child(card_body)
	var preview := PawnPreviewScript.new()
	card_body.add_child(preview)
	preview.custom_minimum_size = Vector2(190, 210)
	var fields := _vbox(11)
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_body.add_child(fields)
	fields.add_child(_label("İSİM", 13, MUTED))
	var name_edit := LineEdit.new()
	name_edit.text = str(old.get("name", "Kolonist"))
	name_edit.placeholder_text = "İsim"
	fields.add_child(name_edit)
	fields.add_child(_label("KİŞİLİK ÖZELLİĞİ", 13, MUTED))
	var trait_option := OptionButton.new()
	for value in TRAITS:
		trait_option.add_item(value)
	trait_option.select(int(old.get("trait_index", 0)))
	fields.add_child(trait_option)
	fields.add_child(_label("GÖRÜNÜŞ", 13, MUTED))
	var appearance_row := _hbox(8)
	fields.add_child(appearance_row)
	var hair := OptionButton.new()
	for value in HAIR_OPTIONS:
		hair.add_item(value)
	hair.select(int(old.get("hair_index", 0)))
	appearance_row.add_child(hair)
	var hair_color := OptionButton.new()
	for color_name in ["Koyu Kahve", "Kestane", "Sarı", "Siyah", "Bakır"]:
		hair_color.add_item(color_name)
	hair_color.select(int(old.get("hair_color_index", 0)))
	appearance_row.add_child(hair_color)
	var skin := OptionButton.new()
	for j in SKIN_OPTIONS.size():
		skin.add_item("Ten %d" % (j + 1))
	skin.select(int(old.get("skin_index", 0)))
	appearance_row.add_child(skin)
	var outfit := OptionButton.new()
	for j in OUTFIT_OPTIONS.size():
		outfit.add_item("Kıyafet %d" % (j + 1))
	outfit.select(int(old.get("outfit_index", 0)))
	appearance_row.add_child(outfit)
	for option in [hair, hair_color, skin, outfit]:
		option.item_selected.connect(func(_index: int): _update_character_preview(preview, hair, hair_color, skin, outfit))
	_update_character_preview(preview, hair, hair_color, skin, outfit)
	editor.add_child(_label("Bu görünüş oyun haritasında da aynı şekilde görünür.", 13, MUTED))
	_character_inputs.append({"index": _editing_character_index, "name": name_edit, "hair": hair, "hair_color": hair_color, "skin": skin, "outfit": outfit, "trait": trait_option})
	var buttons := _hbox()
	root.add_child(buttons)
	buttons.add_child(_button("Dünyaya Dön", _return_to_world_from_characters))
	buttons.add_child(_button("Hazırlığı Tamamla", _advance_to_lobby, true))


func _save_character_inputs() -> void:
	for input in _character_inputs:
		character_specs[int(input.index)] = {"name": (input.name as LineEdit).text.strip_edges(), "hair_index": (input.hair as OptionButton).selected, "hair_color_index": (input.hair_color as OptionButton).selected, "skin_index": (input.skin as OptionButton).selected, "outfit_index": (input.outfit as OptionButton).selected, "trait_index": (input.trait as OptionButton).selected}
	if is_instance_valid(_faction_name_edit):
		faction_name = _faction_name_edit.text.strip_edges()
	if is_instance_valid(_settlement_name_edit):
		settlement_name = _settlement_name_edit.text.strip_edges()


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
	if faction_name.is_empty() or settlement_name.is_empty():
		_notice("Koloni ve yerleşke adlarını doldur.")
		return
	for spec in character_specs:
		if str(spec.get("name", "")).is_empty():
			_notice("Bütün kolonistlerin bir adı olmalı.")
			return
	if session_kind == "join":
		_submit_joiner_setup()
		return
	_show_lobby()


func _show_lobby() -> void:
	screen = "lobby"
	var root := _clear_screen()
	_screen_header(root, "Hazır mısın?", "4 / 4  •  Oyuna başlamadan önce son bakış")
	var panel := _panel(Vector2(700, 0))
	root.add_child(panel)
	var inner := _vbox(14)
	panel.add_child(inner)
	inner.add_child(_label("%s  ·  %s" % [faction_name, settlement_name], 27, GOLD))
	inner.add_child(_label("%s  ·  %d kolonist  ·  Tohum: %s" % [_mode_label(), colonist_count, setup_seed], 17, MUTED))
	for spec in character_specs:
		inner.add_child(_label("◆ %s  —  %s" % [spec.name, TRAITS[int(spec.trait_index)]], 17))
	inner.add_child(_label("Seçilen yerleşke: %s" % selected_site_id, 15, MUTED))
	if session_kind == "host":
		var lobby: Dictionary = Net.get_lobby()
		inner.add_child(_label("Oda portu: %d  ·  Bağlanan oyuncular" % host_port, 16, TEAL))
		for player_id in lobby.get("players", []):
			var ready: Dictionary = lobby.get("ready", {})
			var name := "Ev sahibi" if int(player_id) == 1 else "Oyuncu %s" % str(player_id)
			inner.add_child(_label("● %s — %s" % [name, "Hazır" if bool(ready.get(str(player_id), false)) else "Hazırlanıyor"], 16, CREAM))
		if setup_mode == "competitive" and (lobby.get("players", []) as Array).size() < 2:
			inner.add_child(_label("Ayrı Koloniler için en az bir oyuncu daha bağlanmalı.", 15, RED))
	var buttons := _hbox()
	root.add_child(buttons)
	buttons.add_child(_button("Karakterlere Dön", _show_characters))
	buttons.add_child(_button("Oyunu Başlat", _start_prepared_game, true, Vector2(190, 50)))


func _mode_label() -> String:
	if setup_mode == "coop":
		return "Co-op"
	if setup_mode == "competitive":
		return "Ayrı Koloniler"
	return "Tek Oyunculu"


func _show_waiting_room(message: String) -> void:
	screen = "waiting"
	var root := _clear_screen()
	_screen_header(root, "Oyun Odası", "Bağlantı ve hazırlık")
	var panel := _panel(Vector2(650, 0))
	root.add_child(panel)
	var inner := _vbox(14)
	panel.add_child(inner)
	inner.add_child(_label(message, 20, CREAM))
	inner.add_child(_label("Ev sahibi dünyayı başlattığında oyuna geçeceksin.", 15, MUTED))
	if session_kind == "join" and setup_mode == "coop":
		inner.add_child(_button("Hazırım", _submit_coop_ready, true))
	inner.add_child(_button("Ana Menü", _show_menu))


func _submit_coop_ready() -> void:
	var result = Net.submit_player_setup({})
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Hazır durumu gönderilemedi.")))
		return
	_show_waiting_room("Hazırsın. Ev sahibinin başlaması bekleniyor.")


func _submit_joiner_setup() -> void:
	var spec := _build_faction_spec()
	var result = Net.submit_player_setup(spec)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Hazırlık gönderilemedi.")))
		return
	_show_waiting_room("Kolonin hazır. Ev sahibinin oyunu başlatması bekleniyor.")


func _on_lobby_changed(lobby: Dictionary) -> void:
	if session_kind == "host" and screen == "lobby":
		_show_lobby()
	elif session_kind == "join" and screen == "waiting" and not bool(lobby.get("started", false)):
		setup_mode = str(lobby.get("mode", "coop"))
		setup_seed = str(lobby.get("seed", ""))
		colonist_count = clampi(int(lobby.get("colonists_per_faction", 3)), 1, 3)
		if setup_mode == "competitive" and character_specs.is_empty():
			world_preview = Game.preview_world(setup_seed)
			selected_site_id = ""
			for site in world_preview.get("sites", []):
				if str(site.get("kind", "")) == "vacant":
					selected_site_id = str(site.get("id", ""))
					break
			_show_world_selection()
		elif setup_mode == "coop" and (Net.get_lobby().get("ready", {}) as Dictionary).get(str(Net.get_local_peer_id()), false):
			_show_waiting_room("Hazırsın. Ev sahibinin başlaması bekleniyor.")
		elif setup_mode == "coop":
			_show_waiting_room("Co-op odasına bağlandın. Aynı koloni ve karakterleri yöneteceksin.")


func _on_connection_changed(connected: bool, message: String) -> void:
	if session_kind == "join" and not connected and screen == "waiting" and not message.contains("bağlanılıyor"):
		_notice(message)


func _on_network_snapshot(snapshot: Dictionary) -> void:
	if session_kind == "join" and screen != "game" and not snapshot.is_empty():
		for faction in _values_array(snapshot.get("factions", [])):
			if faction is Dictionary and (faction.get("players", []) as Array).has(Net.get_local_peer_id()):
				selected_site_id = str(faction.get("site_id", ""))
				faction_name = str(faction.get("name", "Koloni"))
				settlement_name = str(faction.get("settlement_name", "Yerleşke"))
				break
		_show_game()


func _start_prepared_game() -> void:
	if session_kind == "host" and setup_mode == "competitive" and (Net.get_lobby().get("players", []) as Array).size() < 2:
		_notice("Ayrı Koloniler için en az bir oyuncu daha bağlanmalı.")
		return
	var config := {"seed": setup_seed, "mode": setup_mode, "colonists_per_faction": colonist_count, "faction_specs": [_build_faction_spec()]}
	var result = Net.start_game(config)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Oyun başlatılamadı.")))
		return
	_show_game()


func _build_faction_spec() -> Dictionary:
	var appearances := ["short", "wavy", "long", "curly", "shaved"]
	var trait_ids := ["hardworking", "calm", "quick", "kind", "timid", "curious"]
	var people: Array = []
	for spec in character_specs:
		people.append({
			"name": str(spec.get("name", "Kolonist")),
			"appearance": {
				"hair": appearances[int(spec.get("hair_index", 0))],
				"hair_color": HAIR_COLOR_OPTIONS[int(spec.get("hair_color_index", 0))],
				"skin": SKIN_OPTIONS[int(spec.get("skin_index", 0))],
				"outfit": OUTFIT_OPTIONS[int(spec.get("outfit_index", 0))]
			},
			"traits": [trait_ids[int(spec.get("trait_index", 0))]]
		})
	return {
		"id": 1,
		"name": faction_name,
		"settlement_name": settlement_name,
		"site_id": selected_site_id,
		"players": [1],
		"colonists": people
	}


func _choose_rival_site() -> String:
	for site in world_preview.get("sites", []):
		var id := str(site.get("id", ""))
		if id != selected_site_id and (str(site.get("kind", "")) == "vacant" or str(site.get("kind", "")) == "player"):
			return id
	return selected_site_id


func _snapshot() -> Dictionary:
	var data = Net.get_snapshot()
	if data is Dictionary and not data.is_empty():
		return data
	return Game.get_snapshot()


func _show_game() -> void:
	screen = "game"
	var root := _clear_screen()
	_game_root = root
	var header_panel := _panel(Vector2(0, 40))
	root.add_child(header_panel)
	var header := _hbox(8)
	header_panel.add_child(header)
	var title := _label("FOXTOPIA", 19, GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.custom_minimum_size = Vector2(110, 0)
	header.add_child(title)
	_top_info = _label("", 13, MUTED)
	_top_info.autowrap_mode = TextServer.AUTOWRAP_OFF
	_top_info.custom_minimum_size = Vector2(190, 0)
	_top_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_top_info)
	header.add_child(_button("Kaydet", _save_game, false, Vector2(68, 27)))
	header.add_child(_button("Yükle", _load_saved_game, false, Vector2(65, 27)))
	header.add_child(_button("II", _toggle_pause, false, Vector2(32, 27)))
	header.add_child(_button("1×", func(): _set_speed(1.0), false, Vector2(36, 27)))
	header.add_child(_button("2×", func(): _set_speed(2.0), false, Vector2(36, 27)))
	header.add_child(_button("3×", func(): _set_speed(3.0), false, Vector2(36, 27)))
	header.add_child(_button("Menü", _show_pause_menu, false, Vector2(62, 27)))
	var overview_panel := _panel(Vector2(0, 66))
	root.add_child(overview_panel)
	var overview := _hbox(14)
	overview_panel.add_child(overview)
	_resource_info = _label("", 13, CREAM)
	_resource_info.autowrap_mode = TextServer.AUTOWRAP_OFF
	_resource_info.custom_minimum_size = Vector2(350, 0)
	overview.add_child(_resource_info)
	var portrait_scroll := ScrollContainer.new()
	portrait_scroll.custom_minimum_size = Vector2(365, 46)
	portrait_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	portrait_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	overview.add_child(portrait_scroll)
	_portrait_strip = _hbox(5)
	portrait_scroll.add_child(_portrait_strip)
	overview.add_child(_button("Merkeze Git", func(): _map_view.focus_tile(Vector2i(25, 25)), false, Vector2(95, 27)))
	_map_view = MapViewScript.new()
	_map_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_map_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_map_view.map_pressed.connect(_on_map_pressed)
	root.add_child(_map_view)
	var tab_panel := _panel(Vector2(0, 40))
	root.add_child(tab_panel)
	var tab_row := _hbox(4)
	tab_panel.add_child(tab_row)
	_tab_buttons.clear()
	for tab_name in ["Emirler", "İşler", "Araştırma", "Sağlık", "Ticaret", "Dünya"]:
		var name_copy: String = tab_name
		var tab_button := _button(tab_name, func(): _set_tab(name_copy), tab_name == current_tab, Vector2(103, 29))
		tab_row.add_child(tab_button)
		_tab_buttons[tab_name] = tab_button
	var inspector_panel := _panel(Vector2(0, 172))
	root.add_child(inspector_panel)
	var sidebar_scroll := ScrollContainer.new()
	sidebar_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector_panel.add_child(sidebar_scroll)
	_sidebar = _vbox(6)
	_sidebar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sidebar_scroll.add_child(_sidebar)
	var status := _label("Sol tık: seç / işaretle    Sağ tık: doğrudan emir    Orta tuş: kaydır    Tekerlek: yakınlaştır", 12, MUTED)
	status.name = "StatusLine"
	status.custom_minimum_size = Vector2(0, 22)
	root.add_child(status)
	_context_menu = PopupMenu.new()
	_context_menu.id_pressed.connect(_context_selected)
	add_child(_context_menu)
	_render_game()
	_map_view.call_deferred("focus_tile", Vector2i(25, 25))


func _set_tab(name: String) -> void:
	current_tab = name
	current_tool = ""
	for tab_name in _tab_buttons:
		var button := _tab_buttons[tab_name] as Button
		button.add_theme_stylebox_override("normal", _style(GOLD if tab_name == name else PANEL_ALT, Color("#555957", 0.8)))
		button.add_theme_color_override("font_color", BG if tab_name == name else CREAM)
	_render_sidebar(_snapshot())


func _toggle_pause() -> void:
	game_paused = not game_paused
	_notice("Oyun duraklatıldı." if game_paused else "Oyun devam ediyor.")


func _set_speed(value: float) -> void:
	speed = value
	game_paused = false
	_notice("Oyun hızı: %d×" % int(value))


func _show_pause_menu() -> void:
	game_paused = true
	var dialog := AcceptDialog.new()
	dialog.title = "Foxtopia"
	dialog.dialog_text = "Oyun duraklatıldı. Kaydetmek için üstteki Kaydet düğmesini kullan."
	dialog.ok_button_text = "Devam Et"
	dialog.confirmed.connect(func(): game_paused = false)
	add_child(dialog)
	dialog.popup_centered()


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


func _render_game() -> void:
	if screen != "game" or not is_instance_valid(_map_view):
		return
	var data := _snapshot()
	var site := _site_id(data)
	_top_info.text = "%s  /  %s  ·  Gün %d" % [faction_name, settlement_name, int(data.get("time", 0))]
	var resources := _local_resources(data)
	_resource_info.text = "ODUN %d    TAŞ %d    YEMEK %d    GÜMÜŞ %d" % [int(resources.get("wood", 0)), int(resources.get("stone", 0)), int(resources.get("food", 0)), int(resources.get("silver", 0))]
	_map_view.set_world(_local_map(data), _local_colonists(data), _local_raiders(data), _local_caravans(data), _local_orders(data), selected_ids)
	_render_portraits(data)
	_render_sidebar(data)


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
	for child in _portrait_strip.get_children():
		child.queue_free()
	for person in _local_colonists(snapshot):
		var id := str(person.get("id", ""))
		var health := int((person.get("health", {}) as Dictionary).get("hp", 100))
		var label_text := "%s%s  %d%%" % ["◆ " if selected_ids.has(id) else "● ", str(person.get("name", "Kolonist")), health]
		var button := _button(label_text, func(): _select_colonist(id), selected_ids.has(id), Vector2(155, 52))
		_portrait_strip.add_child(button)


func _select_colonist(id: String) -> void:
	selected_ids = [id]
	current_tool = ""
	_set_tab("Sağlık")
	_render_game()


func _on_map_pressed(tile: Vector2i, colonist_id: String, enemy_id: String, mouse_button: int) -> void:
	if mouse_button == MOUSE_BUTTON_RIGHT:
		_context_tile = tile
		_context_unit_id = colonist_id
		_context_enemy_id = enemy_id
		_context_order_id = _order_at(tile)
		_context_caravan_id = _caravan_at(tile)
		_open_context_menu()
		return
	if not current_tool.is_empty():
		_send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": tile.x, "y": tile.y, "kind": current_tool, "priority": default_order_priority})
		return
	if not colonist_id.is_empty():
		_select_colonist(colonist_id)
		return
	selected_order_id = _order_at(tile)
	if not selected_order_id.is_empty():
		_set_tab("Emirler")
	else:
		_render_sidebar(_snapshot())


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


func _open_context_menu() -> void:
	_context_menu.clear()
	if selected_ids.is_empty():
		_context_menu.add_item("Burada ağaç kes", 101)
		_context_menu.add_item("Burada taş çıkar", 102)
		_context_menu.add_item("Buraya duvar planla", 103)
	else:
		_context_menu.add_item("Buraya git", 1)
		if not _context_order_id.is_empty():
			_context_menu.add_item("Buradaki işe öncelik ver", 2)
		for drop in _local_map(_snapshot()).get("drops", []):
			if int(drop.get("x", -1)) == _context_tile.x and int(drop.get("y", -1)) == _context_tile.y:
				_context_menu.add_item("Buradan taşı", 3)
				break
		if not _context_enemy_id.is_empty():
			_context_menu.add_item("Hedefe saldır", 4)
		if not _context_caravan_id.is_empty():
			_context_menu.add_item("Tüccarla konuş", 5)
		_context_menu.add_item("Mızrak Kuşan", 6)
		_context_menu.add_separator()
		_context_menu.add_item("Savaş moduna al", 7)
		_context_menu.add_item("Savaş modundan çıkar", 8)
	_context_menu.position = Vector2i(get_viewport().get_mouse_position())
	_context_menu.popup()


func _context_selected(id: int) -> void:
	if id >= 101:
		var kind := "chop" if id == 101 else "mine" if id == 102 else "build_wall"
		_send_command({"type": "designate", "site_id": _site_id(_snapshot()), "x": _context_tile.x, "y": _context_tile.y, "kind": kind, "priority": default_order_priority})
		return
	if selected_ids.is_empty():
		return
	var person_id := selected_ids[0]
	if id == 7 or id == 8:
		_send_command({"type": "set_draft", "colonist_id": person_id, "drafted": id == 7})
		return
	var action: String = str({1: "move", 2: "work", 3: "haul", 4: "attack", 5: "trade", 6: "equip"}.get(id, "move"))
	var command := {"type": "direct", "colonist_id": person_id, "action": action, "x": _context_tile.x, "y": _context_tile.y}
	if id == 2:
		command["target_id"] = _context_order_id
	elif id == 4:
		command["target_id"] = _context_enemy_id
	elif id == 5:
		command["target_id"] = _context_caravan_id
	if id == 6:
		command["item"] = "spear"
	_send_command(command)


func _send_command(command: Dictionary) -> void:
	var result = Net.send_command(command)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Komut uygulanamadı.")))
	elif result is bool and not result:
		_notice("Komut uygulanamadı.")
	else:
		_render_game()


func _on_state_changed(_snapshot_data: Dictionary) -> void:
	if screen == "game":
		_render_game()
	elif screen == "waiting" and session_kind == "join":
		_show_game()


func _on_event_emitted(event: Dictionary) -> void:
	var message := str(event.get("message", ""))
	if not message.is_empty():
		_notice(message)


func _notice(message: String) -> void:
	_status_text = message
	_status_timer = 6.0
	if screen == "game" and is_instance_valid(_game_root):
		var status_line := _game_root.get_node_or_null("StatusLine") as Label
		if status_line != null:
			status_line.text = message
			status_line.add_theme_color_override("font_color", GOLD)
	else:
		var dialog := AcceptDialog.new()
		dialog.title = "Foxtopia"
		dialog.dialog_text = message
		add_child(dialog)
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
	_tab_title("Emirler", "Haritada bir işi işaretle. 1 en yüksek, 9 en düşük önceliktir.")
	var body := _hbox(14)
	_sidebar.add_child(body)
	var controls := _vbox(5)
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(controls)
	var priority_row := _hbox(6)
	controls.add_child(priority_row)
	priority_row.add_child(_label("YENİ EMİR ÖNCELİĞİ", 13, MUTED))
	var priority := OptionButton.new()
	for p in range(1, 10):
		priority.add_item(str(p))
	priority.select(default_order_priority - 1)
	priority.item_selected.connect(func(index: int): default_order_priority = index + 1)
	priority_row.add_child(priority)
	priority_row.add_child(_button("İşaretlemeyi Bırak", func(): _choose_tool(""), false, Vector2(155, 27)))
	var tools := [
		["Ağaç kes", "chop"], ["Taş çıkar", "mine"], ["Hasat et", "harvest"],
		["Taşı", "haul"], ["Ahşap duvar", "build_wall"], ["Yatak", "build_bed"],
		["Araştırma masası", "build_research_bench"], ["Taş duvar", "build_stone_wall"],
		["Barikat", "build_barrier"], ["Ekim alanı", "build_farm"]
	]
	var tool_grid := GridContainer.new()
	tool_grid.columns = 5
	tool_grid.add_theme_constant_override("h_separation", 5)
	tool_grid.add_theme_constant_override("v_separation", 5)
	controls.add_child(tool_grid)
	for pair in tools:
		var label_text: String = pair[0]
		var kind: String = pair[1]
		tool_grid.add_child(_button(("✓ " if current_tool == kind else "+ ") + label_text, func(): _choose_tool(kind), current_tool == kind, Vector2(125, 29)))
	var pending := _vbox(5)
	pending.custom_minimum_size = Vector2(390, 0)
	pending.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(pending)
	pending.add_child(_label("BEKLEYEN İŞLER", 14, GOLD))
	var pending_scroll := ScrollContainer.new()
	pending_scroll.custom_minimum_size = Vector2(0, 88)
	pending_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pending.add_child(pending_scroll)
	var pending_list := _vbox(3)
	pending_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pending_scroll.add_child(pending_list)
	var own: Dictionary = _my_faction(snapshot)
	var own_id := str(own.get("id", ""))
	var count := 0
	for order in _values_array(snapshot.get("orders", [])):
		if str(order.get("faction_id", "")) != own_id or str(order.get("status", "")) in ["done", "cancelled"]:
			continue
		count += 1
		var order_id := str(order.get("id", ""))
		var row := _hbox(5)
		pending_list.add_child(row)
		var order_label := _label("%s  (%d, %d)" % [_order_name(str(order.get("kind", ""))), int(order.get("x", 0)), int(order.get("y", 0))], 13)
		order_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(order_label)
		var option := OptionButton.new()
		for p in range(1, 10):
			option.add_item(str(p))
		option.select(clampi(int(order.get("priority", 5)) - 1, 0, 8))
		option.item_selected.connect(func(index: int): _send_command({"type": "set_order_priority", "order_id": order_id, "priority": index + 1}))
		row.add_child(option)
		row.add_child(_button("İptal", func(): _send_command({"type": "cancel_order", "order_id": order_id}), false, Vector2(45, 27)))
	if count == 0:
		pending_list.add_child(_label("Henüz işaretlenmiş iş yok.", 13, MUTED))


func _choose_tool(kind: String) -> void:
	current_tool = kind
	_render_sidebar(_snapshot())
	if not kind.is_empty():
		_notice("Haritada %s için bir hücre seç." % _order_name(kind))


func _order_name(kind: String) -> String:
	var names := {"chop": "Ağaç kes", "mine": "Taş çıkar", "harvest": "Hasat et", "haul": "Taşı", "build_wall": "Duvar inşa et", "build_bed": "Yatak inşa et", "build_research_bench": "Araştırma masası", "build_stone_wall": "Taş duvar", "build_barrier": "Barikat", "build_farm": "Ekim alanı"}
	return str(names.get(kind, kind))


func _build_work_tab(snapshot: Dictionary) -> void:
	_tab_title("İşler", "Her kolonistin iş önceliğini ayrı ayarla. Kapalı = 0.")
	var table := GridContainer.new()
	table.columns = JOBS.size() + 1
	table.add_theme_constant_override("h_separation", 10)
	table.add_theme_constant_override("v_separation", 5)
	_sidebar.add_child(table)
	table.add_child(_label("KOLONİST", 13, GOLD))
	for title in JOB_LABELS:
		var heading := _label(title.to_upper(), 12, MUTED)
		heading.custom_minimum_size = Vector2(112, 0)
		table.add_child(heading)
	for person in _local_colonists(snapshot):
		var person_id := str(person.get("id", ""))
		var name := _label(str(person.get("name", "Kolonist")), 15, CREAM)
		name.custom_minimum_size = Vector2(150, 0)
		table.add_child(name)
		var priorities: Dictionary = person.get("work_priorities", {})
		for j in JOBS.size():
			var work: String = JOBS[j]
			var choice := OptionButton.new()
			choice.custom_minimum_size = Vector2(112, 27)
			_compact_option(choice)
			choice.add_item("Kapalı", 0)
			for p in range(1, 10):
				choice.add_item(str(p), p)
			choice.select(clampi(int(priorities.get(work, 5)), 0, 9))
			choice.item_selected.connect(func(index: int): _send_command({"type": "set_work_priority", "colonist_id": person_id, "work": work, "priority": index}))
			table.add_child(choice)


func _build_research_tab(snapshot: Dictionary) -> void:
	_tab_title("Araştırma", "Araştırma masası kur ve bir koloniste araştırma işi ver.")
	var faction := _my_faction(snapshot)
	var research: Dictionary = faction.get("research", {})
	var active := str(research.get("project", ""))
	var unlocked: Array = research.get("unlocked", [])
	if not active.is_empty():
		_sidebar.add_child(_label("AKTİF  %s  ·  %d ilerleme" % [_research_name(active), int(research.get("progress", 0))], 13, TEAL))
	var project_row := _hbox(8)
	_sidebar.add_child(project_row)
	for project in RESEARCH_PROJECTS:
		var id := str(project.id)
		var card := _panel()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		project_row.add_child(card)
		var inner := _vbox(6)
		card.add_child(inner)
		inner.add_child(_label(str(project.name).to_upper(), 14, GOLD if active == id else CREAM))
		inner.add_child(_label(str(project.detail), 12, MUTED))
		if unlocked.has(id):
			inner.add_child(_label("Tamamlandı", 12, TEAL))
		else:
			inner.add_child(_button("Seçili" if active == id else "Araştır", func(): _send_command({"type": "set_research", "project": id}), active == id, Vector2(90, 27)))


func _research_name(id: String) -> String:
	for project in RESEARCH_PROJECTS:
		if str(project.id) == id:
			return str(project.name)
	return id


func _build_health_tab(snapshot: Dictionary) -> void:
	_tab_title("Karakter ve Sağlık", "Üst portreden veya haritadaki kolonistten seçim yap.")
	var person := _selected_person(snapshot)
	if person.is_empty():
		_sidebar.add_child(_label("Bir kolonist seç.", 17, MUTED))
		return
	var person_id := str(person.get("id", ""))
	var body := _hbox(18)
	_sidebar.add_child(body)
	var profile := _vbox(5)
	profile.custom_minimum_size = Vector2(440, 0)
	profile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(profile)
	var traits: Array = person.get("traits", [])
	var trait_names := {"hardworking": "Çalışkan", "calm": "Sakin", "quick": "Çevik", "kind": "Merhametli", "timid": "Ürkek", "curious": "Meraklı"}
	var trait_label := str(trait_names.get(str(traits[0]), str(traits[0]))) if not traits.is_empty() else "Özellik yok"
	var profile_header := _hbox(8)
	profile.add_child(profile_header)
	profile_header.add_child(_label("%s  ·  %s" % [str(person.get("name", "Kolonist")), trait_label], 17, GOLD))
	profile_header.add_child(_button("Görünüşü Düzenle", func(): _open_customize_dialog(person), false, Vector2(155, 27)))
	var skills: Dictionary = person.get("skills", {})
	var skill_grid := GridContainer.new()
	skill_grid.columns = 4
	skill_grid.add_theme_constant_override("h_separation", 12)
	skill_grid.add_theme_constant_override("v_separation", 3)
	profile.add_child(skill_grid)
	for j in JOBS.size():
		skill_grid.add_child(_label("%s %d" % [JOB_LABELS[j], int(skills.get(JOBS[j], 0))], 12, MUTED))
	var needs_column := _vbox(3)
	needs_column.custom_minimum_size = Vector2(225, 0)
	needs_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(needs_column)
	needs_column.add_child(_label("İHTİYAÇLAR", 12, GOLD))
	var needs: Dictionary = person.get("needs", {})
	for pair in [["Açlık", "hunger"], ["Dinlenme", "rest"], ["Ruh hâli", "mood"]]:
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
	health_row.add_child(_label("SAĞLIK %d / %d" % [int(health.get("hp", 100)), int(health.get("max_hp", 100))], 13, GOLD))
	health_row.add_child(_label("Kanama %d" % int(health.get("bleeding", 0)), 12, RED if float(health.get("bleeding", 0)) > 0 else MUTED))
	for wound in health.get("wounds", []):
		action_column.add_child(_label("• %s · şiddet %d" % [str(wound.get("kind", "Yara")), int(wound.get("severity", 0))], 12))
	var equipment: Dictionary = person.get("equipment", {})
	action_column.add_child(_label("Silah: %s   Kıyafet: %s" % [equipment.get("weapon", "Yok"), equipment.get("apparel", "Yok")], 12))
	var buttons := _hbox(5)
	action_column.add_child(buttons)
	buttons.add_child(_button("Mızrak Kuşan", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "spear"}), false, Vector2(114, 27)))
	buttons.add_child(_button("Ceket Giy", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"}), false, Vector2(86, 27)))
	buttons.add_child(_button("Savaş: %s" % ("Açık" if bool(person.get("drafted", false)) else "Kapalı"), func(): _send_command({"type": "set_draft", "colonist_id": person_id, "drafted": not bool(person.get("drafted", false))}), false, Vector2(105, 27)))
	buttons.add_child(_button("Emri İptal Et", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "clear"}), false, Vector2(110, 27)))


func _open_customize_dialog(person: Dictionary) -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, TEAL))
	add_child(popup)
	var content := _vbox(10)
	popup.add_child(content)
	content.add_child(_label("%s · Görünüş" % str(person.get("name", "Kolonist")), 21, GOLD))
	var appearance: Dictionary = person.get("appearance", {})
	var row := _hbox(12)
	content.add_child(row)
	var preview := PawnPreviewScript.new()
	row.add_child(preview)
	var fields := _vbox(8)
	row.add_child(fields)
	var hair := OptionButton.new()
	for label_text in HAIR_OPTIONS:
		hair.add_item(label_text)
	hair.select(maxi(0, ["short", "wavy", "long", "curly", "shaved"].find(str(appearance.get("hair", "short")))))
	fields.add_child(hair)
	var hair_color := OptionButton.new()
	for label_text in ["Koyu Kahve", "Kestane", "Sarı", "Siyah", "Bakır"]:
		hair_color.add_item(label_text)
	hair_color.select(maxi(0, HAIR_COLOR_OPTIONS.find(str(appearance.get("hair_color", HAIR_COLOR_OPTIONS[0])))))
	fields.add_child(hair_color)
	var skin := OptionButton.new()
	for j in SKIN_OPTIONS.size():
		skin.add_item("Ten %d" % (j + 1))
	skin.select(maxi(0, SKIN_OPTIONS.find(str(appearance.get("skin", SKIN_OPTIONS[0])))))
	fields.add_child(skin)
	var outfit := OptionButton.new()
	for j in OUTFIT_OPTIONS.size():
		outfit.add_item("Kıyafet %d" % (j + 1))
	outfit.select(maxi(0, OUTFIT_OPTIONS.find(str(appearance.get("outfit", OUTFIT_OPTIONS[0])))))
	fields.add_child(outfit)
	for option in [hair, hair_color, skin, outfit]:
		option.item_selected.connect(func(_index: int): _update_character_preview(preview, hair, hair_color, skin, outfit))
	_update_character_preview(preview, hair, hair_color, skin, outfit)
	content.add_child(_button("Değişiklikleri Kaydet", func():
		var hair_ids := ["short", "wavy", "long", "curly", "shaved"]
		_send_command({"type": "customize_colonist", "colonist_id": str(person.get("id", "")), "appearance": {"hair": hair_ids[hair.selected], "hair_color": HAIR_COLOR_OPTIONS[hair_color.selected], "skin": SKIN_OPTIONS[skin.selected], "outfit": OUTFIT_OPTIONS[outfit.selected]}})
		popup.hide()
		popup.queue_free()
	, true))
	popup.popup_centered(Vector2i(510, 310))


func _build_trade_tab(snapshot: Dictionary) -> void:
	_tab_title("Ticaret", "Oyuncu kolonilerine teklif gönder veya gelen kervanla alışveriş yap.")
	var mine := _my_faction(snapshot)
	var my_id := str(mine.get("id", ""))
	var inventory: Dictionary = mine.get("inventory", {})
	_sidebar.add_child(_label("Depo: %d odun · %d taş · %d yiyecek · %d gümüş" % [int(inventory.get("wood", 0)), int(inventory.get("stone", 0)), int(inventory.get("food", 0)), int(inventory.get("silver", 0))], 14, MUTED))
	var others: Array = []
	for faction in _values_array(snapshot.get("factions", [])):
		if str(faction.get("id", "")) != my_id:
			others.append(faction)
	if not others.is_empty():
		_sidebar.add_child(_label("Koloniler arası teklif", 18, GOLD))
		var target := OptionButton.new()
		for other in others:
			target.add_item(str(other.get("name", "Koloni")))
		_sidebar.add_child(target)
		var give_item := OptionButton.new()
		var receive_item := OptionButton.new()
		for item in ["wood", "stone", "food", "medicine", "spear", "jacket"]:
			give_item.add_item(item)
			receive_item.add_item(item)
		receive_item.select(1)
		_sidebar.add_child(_label("Vereceğin eşya / miktar", 14))
		_sidebar.add_child(give_item)
		var give_count := SpinBox.new()
		give_count.min_value = 1
		give_count.max_value = 99
		give_count.value = 2
		_sidebar.add_child(give_count)
		_sidebar.add_child(_label("İstediğin eşya / miktar", 14))
		_sidebar.add_child(receive_item)
		var receive_count := SpinBox.new()
		receive_count.min_value = 1
		receive_count.max_value = 99
		receive_count.value = 1
		_sidebar.add_child(receive_count)
		_sidebar.add_child(_button("Teklif Gönder", func(): _send_command({"type": "trade_offer", "to_faction": str(others[target.selected].get("id", "")), "give": {give_item.get_item_text(give_item.selected): int(give_count.value)}, "receive": {receive_item.get_item_text(receive_item.selected): int(receive_count.value)}}), true))
	for offer in _values_array(snapshot.get("trade_offers", [])):
		if str(offer.get("status", "")) != "pending":
			continue
		var offer_id := str(offer.get("id", ""))
		var card := _panel()
		_sidebar.add_child(card)
		var inner := _vbox(6)
		card.add_child(inner)
		inner.add_child(_label("Teklif: %s → %s" % [offer.get("from_faction", ""), offer.get("to_faction", "")], 15))
		inner.add_child(_label("Verilen: %s   İstenen: %s" % [str(offer.get("give", {})), str(offer.get("receive", {}))], 13, MUTED))
		if str(offer.get("to_faction", "")) == my_id:
			inner.add_child(_button("Kabul Et", func(): _send_command({"type": "trade_accept", "offer_id": offer_id}), true))
		inner.add_child(_button("Reddet / Geri Çek", func(): _send_command({"type": "trade_decline", "offer_id": offer_id})))
	var caravans: Array = []
	for caravan in _values_array(snapshot.get("caravans", [])):
		if str(caravan.get("kind", "")) == "npc" and str(caravan.get("faction_id", "")) == my_id:
			caravans.append(caravan)
	if not caravans.is_empty():
		_sidebar.add_child(HSeparator.new())
		_sidebar.add_child(_label("Gelen Tüccarlar", 18, GOLD))
	for caravan in caravans:
		var caravan_id := str(caravan.get("id", ""))
		_sidebar.add_child(_label("Kervan %s  ·  (%d, %d)" % [caravan_id, int(caravan.get("x", 0)), int(caravan.get("y", 0))], 15))
		var stock: Dictionary = caravan.get("stock", {})
		var product := OptionButton.new()
		for item in stock.keys():
			if item != "silver" and int(stock[item]) > 0:
				product.add_item(str(item))
		_sidebar.add_child(product)
		if product.item_count > 0:
			_sidebar.add_child(_button("1 Adet Satın Al", func(): _send_command({"type": "npc_trade", "caravan_id": caravan_id, "buy": {product.get_item_text(product.selected): 1}, "sell": {}}), true))
		var sell_item := OptionButton.new()
		for item in ["wood", "stone", "food", "medicine", "spear", "jacket"]:
			if int(inventory.get(item, 0)) > 0:
				sell_item.add_item(item)
		_sidebar.add_child(sell_item)
		if sell_item.item_count > 0:
			_sidebar.add_child(_button("1 Adet Sat", func(): _send_command({"type": "npc_trade", "caravan_id": caravan_id, "buy": {}, "sell": {sell_item.get_item_text(sell_item.selected): 1}})))


func _build_world_tab(snapshot: Dictionary) -> void:
	_tab_title("Dünya", "Yerleşkeler, ilişkiler ve adlandırma.")
	var faction := _my_faction(snapshot)
	_sidebar.add_child(_label("%s · %s" % [faction.get("name", faction_name), faction.get("settlement_name", settlement_name)], 18, GOLD))
	_sidebar.add_child(_button("Dünya Haritasını Aç", func(): _open_world_overview(snapshot), true))
	_sidebar.add_child(_label("Dost yerleşkelerden kervanlar gelebilir. Düşman yerleşkeler baskın gönderir.", 14, MUTED))
	_sidebar.add_child(HSeparator.new())
	_sidebar.add_child(_label("Koloni adını değiştir", 15))
	var colony_edit := LineEdit.new()
	colony_edit.text = str(faction.get("name", faction_name))
	_sidebar.add_child(colony_edit)
	_sidebar.add_child(_button("Koloni Adını Kaydet", func(): _send_command({"type": "rename", "target": "faction", "name": colony_edit.text.strip_edges()})))
	_sidebar.add_child(_label("Yerleşke adını değiştir", 15))
	var site_edit := LineEdit.new()
	site_edit.text = str(faction.get("settlement_name", settlement_name))
	_sidebar.add_child(site_edit)
	_sidebar.add_child(_button("Yerleşke Adını Kaydet", func(): _send_command({"type": "rename", "target": "settlement", "name": site_edit.text.strip_edges()})))
	_sidebar.add_child(HSeparator.new())
	var world: Dictionary = snapshot.get("world", {})
	for site in world.get("sites", []):
		if str(site.get("kind", "")) != "vacant":
			_sidebar.add_child(_label("• %s — %s" % [site.get("name", "Yerleşke"), site.get("kind", "")], 14, MUTED))


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
		_notice("Kaydı ev sahibi oluşturabilir.")
		return
	_notice("Oyun kaydedildi." if Game.save_game() else "Kayıt oluşturulamadı.")


func _load_saved_game() -> void:
	if session_kind == "join":
		_notice("Bu oturumda kayıt yüklenemez.")
		return
	Net.start_solo()
	if not Game.load_game():
		_notice("Kayıt bulunamadı veya açılamadı.")
		return
	session_kind = "solo"
	var data := Game.get_snapshot()
	var mine := _my_faction(data)
	faction_name = str(mine.get("name", "Koloni"))
	settlement_name = str(mine.get("settlement_name", "Yerleşke"))
	selected_site_id = str(mine.get("site_id", ""))
	game_paused = false
	_show_game()
