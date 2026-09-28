extends Control

const MapViewScript = preload("res://scripts/ui/map_view.gd")
const WorldViewScript = preload("res://scripts/ui/world_view.gd")
const TerrainPreviewScript = preload("res://scripts/ui/terrain_preview.gd")
const PawnPreviewScript = preload("res://scripts/ui/pawn_preview.gd")
const PawnVisualScript = preload("res://scripts/ui/pawn_visual.gd")
const SettingsScript = preload("res://scripts/ui/settings.gd")
const I18n = preload("res://scripts/ui/i18n.gd")
const SetupCatalog = preload("res://scripts/model/setup_catalog.gd")

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
const TRAITS := ["Çalışkan", "Sakin", "Çevik", "Merhametli", "Ürkek", "Meraklı"]
const TRAIT_IDS := ["", "hardworking", "calm", "quick", "curious", "kind", "night_owl", "timid", "abrasive", "lazy"]
const TRAIT_NAMES := ["None", "Hardworking (+6)", "Calm (+4)", "Quick (+4)", "Curious (+3)", "Kind (+3)", "Night owl (+2)", "Timid (-4)", "Abrasive (-4)", "Lazy (-6)"]
const CONDITION_IDS := ["", "asthma", "bad_back", "scar"]
const CONDITION_NAMES := ["None", "Asthma (-4)", "Bad back (-5)", "Scar (-2)"]
const SKILL_IDS := ["chop", "mine", "harvest", "haul", "build", "research", "treat", "combat"]
const HAIR_OPTIONS := ["Short", "Wavy", "Long", "Curly", "Shaved"]
const SKIN_OPTIONS := ["#f1c99f", "#dca979", "#b98057", "#80563f", "#52392d"]
const OUTFIT_OPTIONS := ["#527a81", "#b16f59", "#7b8664", "#92759a", "#b89c65"]
const HAIR_COLOR_OPTIONS := ["#4d3c32", "#8b6449", "#bb9b69", "#343a3a", "#8c5f56"]
const ITEM_PRICES := {"wood": 2, "stone": 3, "food": 4, "medicine": 12, "spear": 18, "jacket": 11}
const RESEARCH_PROJECTS := [
	{"id": "farming", "name": "Tarım", "detail": "Ekim alanları ve güvenilir yiyecek üretimi."},
	{"id": "first_aid", "name": "İlk Yardım", "detail": "Daha etkili bakım ve iyileşme."},
	{"id": "stonework", "name": "Taş İşçiliği", "detail": "Dayanıklı taş duvarlar."},
	{"id": "barriers", "name": "Barikat", "detail": "Yerleşkeyi baskınlara karşı güçlendir."}
]

class PawnPortrait extends Control:
	const PawnDrawer = preload("res://scripts/ui/pawn_visual.gd")
	var appearance: Dictionary = {}
	var is_selected := false
	var is_drafted := false

	func _draw() -> void:
		PawnDrawer.draw_pawn(self, Vector2(size.x * 0.5, size.y * 0.45), minf(size.x, size.y) * 0.78, appearance, is_selected, false, is_drafted)

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
var colonist_count := 3
var faction_count := 2
var host_port := 24567
var selected_site_id := ""
var world_preview: Dictionary = {}
var faction_name := "Unnamed colony"
var settlement_name := "Unnamed settlement"
var character_specs: Array = []
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
var _site_info: Label
var _terrain_preview: Control
var _seed_edit: LineEdit
var _mode_option: OptionButton
var _count_option: OptionButton
var _host_port_input: SpinBox
var _faction_name_edit: LineEdit
var _settlement_name_edit: LineEdit
var _character_inputs: Array = []
var _roster_buttons: Array[Button] = []
var _character_points: Label
var _editing_character_index := 0
var preparation_tab := "characters"
var preferences = SettingsScript.load_settings()
var _menu_overlay: Control
var _settings_overlay: Control
var _settings_return_paused := false


func _ready() -> void:
	preferences.apply_settings()
	Game.state_changed.connect(_on_state_changed)
	Game.event_emitted.connect(_on_event_emitted)
	Net.connection_changed.connect(_on_connection_changed)
	Net.lobby_changed.connect(_on_lobby_changed)
	Net.snapshot_received.connect(_on_network_snapshot)
	_show_menu()


func _process(delta: float) -> void:
	if _status_timer > 0.0:
		_status_timer -= delta
		if _status_timer <= 0.0 and is_instance_valid(_notice_label):
			_notice_label.visible = false
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
	character_specs.clear()
	starting_cargo.clear()
	_cargo_search_text = ""
	_editing_character_index = 0
	preparation_tab = "characters"
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
	var inner := _setup_stage(_prep_local("New game", "Yeni oyun", "Nowa gra"),
		_prep_local("Choose how many people will share each colony.", "Her kolonide kaç kişi başlayacağını seç.", "Wybierz liczbę osób na początku każdej kolonii."))
	var body := _hbox(24)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var choices := _vbox(16)
	choices.custom_minimum_size = Vector2(470, 0)
	body.add_child(choices)
	choices.add_child(_label(_prep_local("Play mode", "Oyun modu", "Tryb gry"), 19, GOLD))
	_mode_option = OptionButton.new()
	_mode_option.add_item(_tr("setup.mode_solo"), 0)
	_mode_option.add_item(_tr("setup.mode_coop"), 1)
	_mode_option.add_item(_tr("setup.mode_competitive"), 2)
	_mode_option.select(0 if setup_mode == "solo" else 1 if setup_mode == "coop" else 2)
	_mode_option.disabled = session_kind == "solo"
	choices.add_child(_mode_option)
	choices.add_child(_label(_tr("setup.colonists"), 19, GOLD))
	_count_option = OptionButton.new()
	for i in range(1, 4):
		_count_option.add_item(_tr("setup.colonist_count", {"count": i}), i)
	_count_option.select(colonist_count - 1)
	choices.add_child(_count_option)
	if session_kind == "host":
		choices.add_child(_label(_prep_local("Host port", "Oda portu", "Port gospodarza"), 18, GOLD))
		_host_port_input = SpinBox.new()
		_host_port_input.min_value = 1024
		_host_port_input.max_value = 65535
		_host_port_input.value = host_port
		choices.add_child(_host_port_input)
	var explanation := _panel()
	explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(explanation)
	var copy := _vbox(15)
	explanation.add_child(copy)
	copy.add_child(_label(_prep_local("A shared story or separate settlements", "Ortak hikâye veya ayrı yerleşkeler", "Wspólna opowieść albo osobne osady"), 21, GOLD))
	var text_body := _prep_local("Single player controls one colony. In co-op, everyone controls the same people. Separate colonies begin in different places of the same generated world. Each player can choose a different settlement map.", "Tek oyunculu tek koloniyi yönetir. Ortak oyunda herkes aynı insanları yönetir. Ayrı koloniler aynı oluşturulan dünyanın farklı yerlerinde başlar; her oyuncu farklı bir yerleşke haritası seçebilir.", "W grze jednoosobowej zarządzasz jedną kolonią. W kooperacji wszyscy kontrolują tych samych ludzi. Osobne kolonie zaczynają w różnych miejscach tego samego świata; każdy wybiera własną mapę osady.")
	var explanation_text := _label(text_body, 16, CREAM)
	explanation_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(explanation_text)
	_setup_footer(inner, _show_menu, _advance_to_scenario)


func _setup_stage(title: String, subtitle: String) -> VBoxContainer:
	var root := _clear_screen()
	_add_menu_backdrop()
	var frame := _panel()
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", _style(Color("#171b20f4"), Color("#6e6453"), 1))
	root.add_child(frame)
	var inner := _vbox(13)
	frame.add_child(inner)
	inner.add_child(_label(title, 25, CREAM))
	inner.add_child(_label(subtitle, 14, MUTED))
	inner.add_child(HSeparator.new())
	return inner


func _setup_footer(parent: VBoxContainer, back_action: Callable, next_action: Callable) -> void:
	parent.add_child(HSeparator.new())
	var row := _hbox(12)
	parent.add_child(row)
	row.add_child(_button(_tr("common.back"), back_action, false, Vector2(150, 38)))
	var filler := Control.new()
	filler.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(filler)
	row.add_child(_button(_prep_local("Next", "İleri", "Dalej"), next_action, true, Vector2(150, 38)))


func _advance_to_scenario() -> void:
	setup_mode = ["solo", "coop", "competitive"][_mode_option.selected]
	colonist_count = _count_option.selected + 1
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
	var list := _vbox(7)
	list.custom_minimum_size = Vector2(330, 0)
	body.add_child(list)
	for entry in SetupCatalog.SCENARIOS:
		var chosen_id := str(entry["id"])
		var button_text := "%s\n%s" % [SetupCatalog.localized(entry["name"], preferences.language), SetupCatalog.localized(entry["summary"], preferences.language)]
		var button := _button(button_text, func(): _select_scenario(chosen_id), chosen_id == scenario_id, Vector2(0, 72))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		list.add_child(button)
	var selected: Dictionary = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id)
	var detail := _panel()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail)
	var description := _vbox(12)
	detail.add_child(description)
	description.add_child(_label(SetupCatalog.localized(selected["name"], preferences.language), 24, GOLD))
	var story := _label(SetupCatalog.localized(selected["story"], preferences.language), 17, CREAM)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_child(story)
	description.add_child(HSeparator.new())
	description.add_child(_label(_prep_local("Starting supplies", "Başlangıç erzakı", "Zapas początkowy"), 18, GOLD))
	for kind in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
		description.add_child(_label("%s  × %d" % [kind.capitalize(), int(selected["inventory"].get(kind, 0))], 15))
	description.add_child(_spacer())
	description.add_child(_label(_prep_local("Crew size is chosen separately: 1, 2 or 3 people.", "Ekip büyüklüğü ayrı seçilir: 1, 2 veya 3 kişi.", "Liczebność załogi wybierasz osobno: 1, 2 lub 3 osoby."), 13, MUTED))
	_setup_footer(inner, _show_setup, _show_storyteller_selection)


func _select_scenario(id: String) -> void:
	scenario_id = id
	starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	_show_scenario_selection()


func _show_storyteller_selection() -> void:
	screen = "storyteller"
	var inner := _setup_stage(_prep_local("Story and difficulty", "Hikâye ve zorluk", "Opowieść i trudność"),
		_prep_local("Choose the pace of events and the danger level.", "Olay temposunu ve tehlike düzeyini seç.", "Wybierz tempo zdarzeń i poziom zagrożenia."))
	var body := _hbox(18)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inner.add_child(body)
	var storytellers := _vbox(8)
	storytellers.custom_minimum_size.x = 360
	body.add_child(storytellers)
	storytellers.add_child(_label(_prep_local("Storyteller", "Anlatıcı", "Narrator"), 21, GOLD))
	for entry in SetupCatalog.STORYTELLERS:
		var chosen_id := str(entry["id"])
		var text_value := "%s\n%s" % [SetupCatalog.localized(entry["name"], preferences.language), SetupCatalog.localized(entry["summary"], preferences.language)]
		var button := _button(text_value, func(): _select_storyteller(chosen_id), chosen_id == storyteller_id, Vector2(0, 78))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		storytellers.add_child(button)
	var difficulty := _vbox(8)
	difficulty.custom_minimum_size.x = 340
	body.add_child(difficulty)
	difficulty.add_child(_label(_prep_local("Difficulty", "Zorluk", "Trudność"), 21, GOLD))
	for entry in SetupCatalog.DIFFICULTIES:
		var chosen_id := str(entry["id"])
		var text_value := "%s\n%s" % [SetupCatalog.localized(entry["name"], preferences.language), SetupCatalog.localized(entry["summary"], preferences.language)]
		var button := _button(text_value, func(): _select_difficulty(chosen_id), chosen_id == difficulty_id, Vector2(0, 60))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		difficulty.add_child(button)
	var portrait_panel := _panel()
	portrait_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(portrait_panel)
	var portrait_content := _vbox(8)
	portrait_panel.add_child(portrait_content)
	var selected_storyteller: Dictionary = SetupCatalog.find_by_id(SetupCatalog.STORYTELLERS, storyteller_id)
	portrait_content.add_child(_label(SetupCatalog.localized(selected_storyteller["name"], preferences.language), 22, GOLD))
	var portrait := TextureRect.new()
	portrait.texture = load("res://assets/storyteller_%s.png" % {"steady": "mira", "gentle": "elian", "erratic": "rook"}.get(storyteller_id, "mira"))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait_content.add_child(portrait)
	var portrait_caption := _label(SetupCatalog.localized(selected_storyteller["summary"], preferences.language), 13, MUTED)
	portrait_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	portrait_content.add_child(portrait_caption)
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
	var controls := _vbox(15)
	controls.custom_minimum_size = Vector2(530, 0)
	body.add_child(controls)
	controls.add_child(_label(_tr("setup.seed"), 18, GOLD))
	_seed_edit = LineEdit.new()
	_seed_edit.text = setup_seed
	controls.add_child(_seed_edit)
	controls.add_child(_button(_prep_local("Randomize seed", "Yeni tohum üret", "Losuj klucz"), func():
		_seed_edit.text = str(randi())
		_refresh_world_settings_preview(), false, Vector2(190, 36)))
	_seed_edit.text_submitted.connect(func(_submitted: String): _refresh_world_settings_preview())
	_world_setting_row(controls, "coverage", _prep_local("Land coverage", "Kara oranı", "Udział lądu"), 0.25, 0.75)
	_world_setting_row(controls, "rainfall", _prep_local("Rainfall", "Yağış", "Opady"), 0.0, 1.0)
	_world_setting_row(controls, "temperature", _prep_local("Temperature", "Sıcaklık", "Temperatura"), 0.0, 1.0)
	_world_setting_row(controls, "population", _prep_local("Other settlements", "Diğer yerleşkeler", "Inne osady"), 0.0, 1.0)
	var detail := _panel()
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail)
	var detail_content := _vbox(12)
	detail.add_child(detail_content)
	detail_content.add_child(_label(_prep_local("Your planet", "Gezegenin", "Twoja planeta"), 22, GOLD))
	var world_copy := _label(_prep_local("Land coverage shapes continents and ocean. Rainfall and temperature affect local biomes. Other settlements changes how many friendly and hostile neighbors are generated. Select any unoccupied land tile after generating.", "Kara oranı kıtaları ve okyanusu biçimlendirir. Yağış ve sıcaklık yerel biyomları etkiler. Diğer yerleşkeler dost ve düşman komşuların sayısını değiştirir. Oluşturduktan sonra işgal edilmemiş herhangi bir kara parçasını seçebilirsin.", "Udział lądu kształtuje kontynenty i oceany. Opady oraz temperatura wpływają na lokalne biomy. Liczba osad zmienia liczbę przyjaznych i wrogich sąsiadów. Po wygenerowaniu możesz wybrać dowolny wolny obszar lądu."), 16)
	world_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_content.add_child(world_copy)
	_world_settings_preview = WorldViewScript.new()
	_world_settings_preview.custom_minimum_size = Vector2(580, 420)
	_world_settings_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_world_settings_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_content.add_child(_world_settings_preview)
	_refresh_world_settings_preview()
	var preview_hint := _label(_prep_local("The preview follows your seed and planet settings. Drag to inspect it.", "Önizleme tohum ve gezegen ayarlarını izler. İncelemek için sürükle.", "Podgląd odzwierciedla ustawienia planety. Przeciągnij, aby ją obejrzeć."), 12, MUTED)
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
		colonist_count = _count_option.selected + 1
	if is_instance_valid(_seed_edit) and _seed_edit.is_inside_tree():
		setup_seed = _seed_edit.text.strip_edges()
	if setup_seed.is_empty():
		setup_seed = str(randi())
	if session_kind == "host":
		var host_result = Net.host(host_port)
		if host_result is Dictionary and not bool(host_result.get("ok", true)):
			_notice(str(host_result.get("error", "Oda açılamadı.")))
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
	var info_panel := _panel()
	overlay.add_child(info_panel)
	_place(info_panel, 0.0, 0.31, 0.0, 1.0, 16, 0, 350, -57)
	info_panel.add_theme_stylebox_override("panel", _style(Color("#151a1eef"), Color("#667077"), 0))
	var info_content := _vbox(6)
	info_panel.add_child(info_content)
	info_content.add_child(_label(_tr("world.choose_tile"), 17, GOLD))
	var info_scroll := ScrollContainer.new()
	info_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info_content.add_child(info_scroll)
	_site_info = _label("", 13, CREAM)
	_site_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_site_info.custom_minimum_size.x = 315
	_site_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_scroll.add_child(_site_info)
	var terrain_panel := _panel()
	terrain_panel.add_theme_stylebox_override("panel", _style(Color("#151a1eef"), Color("#667077"), 0))
	overlay.add_child(terrain_panel)
	_place(terrain_panel, 1.0, 0.0, 1.0, 0.0, -355, 18, -16, 376)
	var terrain_content := _vbox(5)
	terrain_panel.add_child(terrain_content)
	terrain_content.add_child(_label(_prep_local("Landing area preview", "İniş bölgesi önizlemesi", "Podgląd miejsca lądowania"), 15, GOLD))
	_terrain_preview = TerrainPreviewScript.new()
	_terrain_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_terrain_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	terrain_content.add_child(_terrain_preview)
	_update_site_info()
	var back := _button(_tr("common.back"), _show_world_settings)
	overlay.add_child(back)
	_place(back, 0.0, 1.0, 0.0, 1.0, 16, -47, 100, -10)
	var random_button := _button(_prep_local("Random site", "Rastgele yer", "Losowe miejsce"), _select_random_site)
	overlay.add_child(random_button)
	_place(random_button, 0.0, 1.0, 0.0, 1.0, 110, -47, 272, -10)
	var next := _button(_tr("world.continue"), _show_characters, true)
	overlay.add_child(next)
	_place(next, 1.0, 1.0, 1.0, 1.0, -220, -47, -16, -10)
	var rotate_hint := _label(_prep_local("Drag to rotate  ·  Scroll to zoom", "Döndürmek için sürükle  ·  Yakınlaştırmak için kaydır", "Przeciągnij, aby obrócić  ·  Przewiń, aby przybliżyć"), 13, MUTED)
	overlay.add_child(rotate_hint)
	_place(rotate_hint, 0.5, 1.0, 0.5, 1.0, -175, -41, 175, -12)


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
	var chosen: Dictionary = Game.describe_site(world_preview, selected_site_id)
	if chosen.is_empty():
		_site_info.text = _tr("world.choose_tile")
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
	var info_lines := [
		str(chosen.get("name", "Unsettled land")),
		"%s  ·  %s" % [str(chosen.get("biome", "plains")).capitalize(), str(chosen.get("terrain", "Flat"))],
		"%.1f° %s  ·  %.1f° %s" % [absf(float(chosen.get("latitude", 0.0))), "N" if float(chosen.get("latitude", 0.0)) >= 0.0 else "S", absf(float(chosen.get("longitude", 0.0))), "E" if float(chosen.get("longitude", 0.0)) >= 0.0 else "W"],
		"",
		"Elevation                 %d m" % int(chosen.get("elevation", 0)),
		"Temperature            %.1f °C" % float(chosen.get("temperature", 0.0)),
		"Rainfall                    %d mm/year" % int(chosen.get("rainfall", 0)),
		"Growing season         %d days" % int(chosen.get("growing_days", 0)),
		"Coast                        %s" % ("Yes" if bool(chosen.get("coastal", false)) else "No"),
		"Stone                       %s" % ", ".join(chosen.get("stone_types", [])),
		"",
		"Nearby friendly          %d" % nearby_friendly,
		"Nearby hostile           %d" % nearby_hostile,
	]
	_site_info.text = "\n".join(info_lines)
	if is_instance_valid(_terrain_preview):
		_terrain_preview.set_map(Game.preview_local_map(world_preview, selected_site_id))


func _select_random_site() -> void:
	var free_sites: Array = []
	for site in world_preview.get("sites", []):
		if str(site.get("kind", "")) == "vacant": free_sites.append(str(site.get("id", "")))
	if free_sites.is_empty(): return
	selected_site_id = str(free_sites[randi_range(0, free_sites.size() - 1)])
	_world_view.set_preview(world_preview, selected_site_id)
	_update_site_info()


func _show_characters() -> void:
	screen = "characters"
	if character_specs.size() > colonist_count:
		character_specs.resize(colonist_count)
	while character_specs.size() < colonist_count:
		var i := character_specs.size()
		character_specs.append({"name": ["Ada", "Baran", "Deniz"][i], "hair_index": i % HAIR_OPTIONS.size(), "hair_color_index": 0, "skin_index": i % SKIN_OPTIONS.size(), "outfit_index": i % OUTFIT_OPTIONS.size(), "trait_ids": ["hardworking"] if i == 0 else ["calm"] if i == 1 else ["quick"], "condition_ids": [], "sex": "female" if i != 1 else "male", "gender": "woman" if i != 1 else "man", "age": 25 + i * 4, "childhood": "rural_child", "adulthood": ["farmer", "builder", "medic"][i], "starting_gear": {"weapon": "fists", "apparel": "clothes"}, "starting_relationships": {}, "skills": {}})
	_editing_character_index = clampi(_editing_character_index, 0, colonist_count - 1)
	var root := _clear_screen()
	var heading := _hbox(12)
	root.add_child(heading)
	heading.add_child(_label(_tr("characters.title"), 23))
	var head_fill := Control.new()
	head_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(head_fill)
	_character_points = _label("", 15, GOLD)
	heading.add_child(_character_points)
	var tabs := _hbox(3)
	root.add_child(tabs)
	for tab_id in ["characters", "relationships", "equipment"]:
		var chosen_tab: String = tab_id
		var tab_name := _prep_local("Characters", "Karakterler", "Postacie") if tab_id == "characters" else _prep_local("Relationships", "İlişkiler", "Relacje") if tab_id == "relationships" else _prep_local("Equipment", "Ekipman", "Wyposażenie")
		tabs.add_child(_button(tab_name, func(): _switch_preparation_tab(chosen_tab), tab_id == preparation_tab, Vector2(150, 32)))
	var tab_fill := Control.new()
	tab_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab_fill)
	var limit_toggle := CheckButton.new()
	limit_toggle.text = _prep_local("Use point limit", "Puan sınırını kullan", "Włącz limit punktów")
	limit_toggle.button_pressed = point_limit_enabled
	limit_toggle.toggled.connect(func(enabled: bool): point_limit_enabled = enabled; _refresh_character_points())
	tabs.add_child(limit_toggle)
	root.add_child(HSeparator.new())
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(center)
	var body := _hbox(8)
	body.custom_minimum_size = Vector2(minf(1280.0, get_viewport_rect().size.x - 40.0), 580)
	body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	body.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(body)
	_character_inputs.clear()
	_roster_buttons.clear()
	if preparation_tab == "relationships":
		_build_preparation_relationships(body)
	elif preparation_tab == "equipment":
		_build_preparation_equipment(body)
	else:
		_build_preparation_character(body)
	_refresh_character_points()
	var footer := _hbox(8)
	root.add_child(footer)
	footer.add_child(_button(_tr("common.back"), _return_to_world_from_characters, false, Vector2(120, 36)))
	var foot_fill := Control.new()
	foot_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(foot_fill)
	footer.add_child(_button(_prep_local("Load preset", "Hazır ayar yükle", "Wczytaj zestaw"), _load_preparation_preset))
	footer.add_child(_button(_prep_local("Save preset", "Hazır ayar kaydet", "Zapisz zestaw"), _save_preparation_preset))
	var foot_fill_right := Control.new()
	foot_fill_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(foot_fill_right)
	footer.add_child(_button(_tr("characters.start"), _advance_to_lobby, true, Vector2(170, 36)))


func _prep_local(en: String, tr: String, pl: String) -> String:
	return tr if preferences.language == "tr" else pl if preferences.language == "pl" else en


func _switch_preparation_tab(tab_id: String) -> void:
	_save_character_inputs()
	preparation_tab = tab_id
	_show_characters()


func _preparation_roster(body: HBoxContainer) -> void:
	var panel := _panel(Vector2(206, 0))
	body.add_child(panel)
	var roster := _vbox(6)
	panel.add_child(roster)
	roster.add_child(_label(_prep_local("COLONISTS", "KOLONİSTLER", "KOLONIŚCI"), 14, GOLD))
	for i in colonist_count:
		var spec: Dictionary = character_specs[i]
		var index_copy := i
		var row := _hbox(3)
		roster.add_child(row)
		var portrait := PawnPortrait.new()
		portrait.custom_minimum_size = Vector2(36, 43)
		portrait.appearance = _spec_appearance(spec)
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(portrait)
		var button := _button(str(spec.get("name", "Colonist")), func(): _select_character_editor(index_copy), i == _editing_character_index, Vector2(142, 43))
		button.add_theme_font_size_override("font_size", 12)
		row.add_child(button)
		_roster_buttons.append(button)
	roster.add_child(HSeparator.new())
	roster.add_child(_label(_prep_local("Starting crew: %d" % colonist_count, "Başlangıç ekibi: %d" % colonist_count, "Załoga: %d" % colonist_count), 13, MUTED))
	roster.add_child(_spacer())
	var hint := _label(_prep_local("Negative traits and health conditions return points.", "Olumsuz özellikler ve sağlık sorunları puan kazandırır.", "Wady i choroby zwracają punkty."), 12, MUTED)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	roster.add_child(hint)


func _build_preparation_character(body: HBoxContainer) -> void:
	_preparation_roster(body)
	var old: Dictionary = character_specs[_editing_character_index]
	var editor := _vbox(7)
	editor.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	body.add_child(editor)
	var name_row := _hbox(5)
	editor.add_child(name_row)
	name_row.add_child(_button("⚄", _randomize_prepared_colonist, false, Vector2(38, 36)))
	name_row.add_child(_label(_prep_local("Name", "Ad", "Imię"), 13, MUTED))
	var name_edit := LineEdit.new()
	name_edit.text = str(old.get("name", "Colonist"))
	name_edit.custom_minimum_size = Vector2(230, 34)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_edit)
	name_row.add_child(_button(_prep_local("Load character", "Karakter yükle", "Wczytaj postać"), _load_character_preset))
	name_row.add_child(_button(_prep_local("Save character", "Karakter kaydet", "Zapisz postać"), _save_character_preset))
	var columns := _hbox(7)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.add_child(columns)
	var appearance_panel := _panel(Vector2(255, 0))
	columns.add_child(appearance_panel)
	var appearance_fields := _vbox(5)
	appearance_panel.add_child(appearance_fields)
	appearance_fields.add_child(_label(_prep_local("APPEARANCE", "GÖRÜNÜŞ", "WYGLĄD"), 14, GOLD))
	var preview := PawnPreviewScript.new()
	appearance_fields.add_child(preview)
	preview.custom_minimum_size = Vector2(235, 230)
	preview.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var sex := _cycle_field(appearance_fields, _prep_local("Sex", "Cinsiyet", "Płeć"), [_prep_local("Female", "Kadın", "Kobieta"), _prep_local("Male", "Erkek", "Mężczyzna")], 0 if str(old.get("sex", "female")) == "female" else 1, _refresh_character_editor, 75, 79)
	var gender := _cycle_field(appearance_fields, _tr("characters.gender"), [_tr("characters.gender_female"), _tr("characters.gender_male"), _tr("characters.gender_nonbinary")], maxi(0, ["woman", "man", "nonbinary"].find(str(old.get("gender", "woman")))), _refresh_character_editor, 75, 79)
	var hair := _cycle_field(appearance_fields, _tr("characters.hair"), _hair_options(), int(old.get("hair_index", 0)), _refresh_character_editor, 75, 79)
	var hair_color := _cycle_field(appearance_fields, _tr("characters.hair_color"), [_prep_local("Dark brown", "Koyu kahve", "Ciemny brąz"), _prep_local("Chestnut", "Kestane", "Kasztan"), _prep_local("Blond", "Sarı", "Blond"), _prep_local("Black", "Siyah", "Czarny"), _prep_local("Copper", "Bakır", "Miedziany")], int(old.get("hair_color_index", 0)), _refresh_character_editor, 75, 79)
	var skin := _cycle_field(appearance_fields, _tr("characters.skin"), [_prep_local("Light", "Açık", "Jasna"), _prep_local("Fair", "Buğday", "Śniada"), _prep_local("Medium", "Orta", "Średnia"), _prep_local("Brown", "Esmer", "Brązowa"), _prep_local("Dark", "Koyu", "Ciemna")], int(old.get("skin_index", 0)), _refresh_character_editor, 75, 79)
	var outfit := _cycle_field(appearance_fields, _tr("characters.outfit"), [_prep_local("Blue", "Mavi", "Niebieski"), _prep_local("Rust", "Kızıl", "Rdzawy"), _prep_local("Olive", "Zeytin", "Oliwkowy"), _prep_local("Purple", "Mor", "Fioletowy"), _prep_local("Ochre", "Hardal", "Ochra")], int(old.get("outfit_index", 0)), _refresh_character_editor, 75, 79)
	var history_panel := _panel(Vector2(375, 0))
	columns.add_child(history_panel)
	var history := _vbox(6)
	history_panel.add_child(history)
	history.add_child(_label(_prep_local("BACKSTORY", "GEÇMİŞ", "HISTORIA"), 14, GOLD))
	var age_row := _hbox(5)
	history.add_child(age_row)
	age_row.add_child(_label(_prep_local("Age", "Yaş", "Wiek"), 12, MUTED))
	var age := SpinBox.new()
	age.min_value = 18
	age.max_value = 80
	age.value = int(old.get("age", 25))
	age.custom_minimum_size = Vector2(82, 29)
	age.value_changed.connect(func(_value: float): _refresh_character_editor())
	age_row.add_child(age)
	var age_fill := Control.new()
	age_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	age_row.add_child(age_fill)
	age_row.add_child(_label(_prep_local("biological years", "biyolojik yıl", "lat biologicznych"), 11, MUTED))
	var childhood_ids := ["rural_child", "town_child", "apprentice"]
	var adulthood_ids := ["farmer", "builder", "medic", "scholar"]
	var childhood := _cycle_field(history, _prep_local("Childhood", "Çocukluk", "Dzieciństwo"), [_prep_local("Rural child", "Köy çocuğu", "Dziecko ze wsi"), _prep_local("Town child", "Kasaba çocuğu", "Dziecko z miasta"), _prep_local("Apprentice", "Çırak", "Uczeń")], maxi(0, childhood_ids.find(str(old.get("childhood", "rural_child")))), _refresh_character_editor, 95, 118)
	var adulthood := _cycle_field(history, _prep_local("Adulthood", "Yetişkinlik", "Dorosłość"), [_prep_local("Farmer", "Çiftçi", "Rolnik"), _prep_local("Builder", "İnşaatçı", "Budowniczy"), _prep_local("Medic", "Sağlıkçı", "Medyk"), _prep_local("Scholar", "Araştırmacı", "Badacz")], maxi(0, adulthood_ids.find(str(old.get("adulthood", "farmer")))), _refresh_character_editor, 95, 118)
	history.add_child(HSeparator.new())
	history.add_child(_label(_prep_local("TRAITS", "ÖZELLİKLER", "CECHY"), 14, GOLD))
	var old_traits: Array = old.get("trait_ids", [TRAIT_IDS[clampi(int(old.get("trait_index", 0)) + 1, 1, TRAIT_IDS.size() - 1)]])
	var trait_fields: Array = []
	for slot in range(3):
		var trait_id: String = str(old_traits[slot]) if slot < old_traits.size() else ""
		trait_fields.append(_cycle_field(history, _prep_local("Trait %d" % (slot + 1), "Özellik %d" % (slot + 1), "Cecha %d" % (slot + 1)), _preparation_trait_names(), maxi(0, TRAIT_IDS.find(trait_id)), _refresh_character_editor, 95, 118))
	history.add_child(HSeparator.new())
	history.add_child(_label(_tr("characters.health").to_upper(), 14, GOLD))
	var old_conditions: Array = old.get("condition_ids", [])
	var condition_fields: Array = []
	for slot in range(3):
		var condition_id: String = str(old_conditions[slot]) if slot < old_conditions.size() else ""
		condition_fields.append(_cycle_field(history, _prep_local("Condition %d" % (slot + 1), "Durum %d" % (slot + 1), "Stan %d" % (slot + 1)), _preparation_condition_names(), maxi(0, CONDITION_IDS.find(condition_id)), _refresh_character_editor, 95, 118))
	var skill_panel := _panel(Vector2(242, 0))
	columns.add_child(skill_panel)
	var skill_column := _vbox(5)
	skill_panel.add_child(skill_column)
	skill_column.add_child(_label(_tr("characters.skills").to_upper(), 14, GOLD))
	skill_column.add_child(_label(_prep_local("Levels above 5 cost points", "5 üstü seviyeler puan harcar", "Poziomy powyżej 5 kosztują punkty"), 11, MUTED))
	var skill_fields: Dictionary = {}
	var old_skills: Dictionary = old.get("skills", {})
	var levels: Array = []
	for rating in range(11): levels.append(str(rating))
	for skill in SKILL_IDS:
		var level := _cycle_field(skill_column, str(skill).capitalize(), levels, clampi(int(old_skills.get(skill, 5)), 0, 10), _refresh_character_editor, 88, 24)
		skill_fields[skill] = level
	skill_column.add_child(HSeparator.new())
	skill_column.add_child(_label(_prep_local("INCAPABLE OF", "YAPAMADIĞI İŞLER", "NIEZDOLNOŚCI"), 13, GOLD))
	var incapable := _label(_prep_local("None", "Yok", "Brak"), 12, MUTED)
	skill_column.add_child(incapable)
	_character_inputs.append({"index": _editing_character_index, "name": name_edit, "age": age, "childhood": childhood, "adulthood": adulthood, "sex": sex, "gender": gender, "hair": hair, "hair_color": hair_color, "skin": skin, "outfit": outfit, "traits": trait_fields, "conditions": condition_fields, "skills": skill_fields, "preview": preview})
	name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	_refresh_character_editor()


func _spec_appearance(spec: Dictionary) -> Dictionary:
	return {"hair": ["short", "wavy", "long", "curly", "shaved"][clampi(int(spec.get("hair_index", 0)), 0, 4)],
		"hair_color": HAIR_COLOR_OPTIONS[clampi(int(spec.get("hair_color_index", 0)), 0, HAIR_COLOR_OPTIONS.size() - 1)],
		"skin": SKIN_OPTIONS[clampi(int(spec.get("skin_index", 0)), 0, SKIN_OPTIONS.size() - 1)],
		"outfit": OUTFIT_OPTIONS[clampi(int(spec.get("outfit_index", 0)), 0, OUTFIT_OPTIONS.size() - 1)]}


func _build_preparation_relationships(body: HBoxContainer) -> void:
	var panel := _panel()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(panel)
	var content := _vbox(12)
	panel.add_child(content)
	content.add_child(_label(_prep_local("STARTING RELATIONSHIPS", "BAŞLANGIÇ İLİŞKİLERİ", "RELACJE POCZĄTKOWE"), 17, GOLD))
	content.add_child(_label(_prep_local("Choose how your colonists know one another. These bonds affect their social opinions from the first day.", "Kolonistlerin birbirini nasıl tanıdığını seç. Bu bağlar ilk günden itibaren sosyal görüşlerini etkiler.", "Wybierz, jak koloniści znają się nawzajem. Więzi wpływają na ich opinie od pierwszego dnia."), 13, MUTED))
	content.add_child(HSeparator.new())
	if colonist_count < 2:
		content.add_child(_label(_prep_local("A second colonist is needed to create a relationship.", "İlişki kurmak için ikinci bir kolonist gerekir.", "Do utworzenia relacji potrzeba drugiego kolonisty."), 15))
	for i in range(colonist_count):
		for j in range(i + 1, colonist_count):
			var first: Dictionary = character_specs[i]
			var second: Dictionary = character_specs[j]
			var row_panel := _panel()
			content.add_child(row_panel)
			var row := _hbox(14)
			row_panel.add_child(row)
			var first_portrait := PawnPortrait.new()
			first_portrait.custom_minimum_size = Vector2(46, 48)
			first_portrait.appearance = _spec_appearance(first)
			row.add_child(first_portrait)
			var pair_label := _label("%s  ↔  %s" % [str(first.get("name", "Colonist")), str(second.get("name", "Colonist"))], 15)
			pair_label.custom_minimum_size = Vector2(280, 0)
			row.add_child(pair_label)
			var second_portrait := PawnPortrait.new()
			second_portrait.custom_minimum_size = Vector2(46, 48)
			second_portrait.appearance = _spec_appearance(second)
			row.add_child(second_portrait)
			var relation_ids := ["none", "friend", "rival", "partner", "parent", "child", "sibling"]
			var known: Dictionary = first.get("starting_relationships", {})
			var relation_state: Dictionary = {}
			var first_index := i
			var second_index := j
			relation_state = _cycle_field(row, _prep_local("Bond", "Bağ", "Więź"), [_prep_local("None", "Yok", "Brak"), _prep_local("Friends", "Arkadaş", "Przyjaciele"), _prep_local("Rivals", "Rakip", "Rywale"), _prep_local("Partners", "Partner", "Partnerzy"), _prep_local("Parent of", "Ebeveyni", "Rodzic"), _prep_local("Child of", "Çocuğu", "Dziecko"), _prep_local("Siblings", "Kardeş", "Rodzeństwo")], maxi(0, relation_ids.find(str(known.get(str(j), "none")))), func(): _set_starting_relation(first_index, second_index, relation_ids[int(relation_state["index"])]), 45, 100)
	content.add_child(_spacer())
	content.add_child(_label(_prep_local("Relationship choices are shared by both colonists.", "İlişki seçimi iki kolonist için de geçerlidir.", "Wybór relacji dotyczy obojga kolonistów."), 12, MUTED))


func _set_starting_relation(first_index: int, second_index: int, relation_id: String) -> void:
	var spec: Dictionary = character_specs[first_index].duplicate(true)
	var relationships: Dictionary = spec.get("starting_relationships", {})
	if relation_id == "none":
		relationships.erase(str(second_index))
	else:
		relationships[str(second_index)] = relation_id
	spec["starting_relationships"] = relationships
	character_specs[first_index] = spec


func _build_preparation_equipment(body: HBoxContainer) -> void:
	_preparation_roster(body)
	var spec: Dictionary = character_specs[_editing_character_index]
	var gear: Dictionary = spec.get("starting_gear", {"weapon": "fists", "apparel": "clothes"})
	if starting_cargo.is_empty():
		starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	var available_panel := _panel(Vector2(350, 0))
	available_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(available_panel)
	var available := _vbox(7)
	available_panel.add_child(available)
	available.add_child(_label(_prep_local("AVAILABLE CARGO", "KULLANILABİLİR YÜK", "DOSTĘPNY ŁADUNEK"), 16, GOLD))
	var search := LineEdit.new()
	search.placeholder_text = _prep_local("Search items...", "Eşya ara...", "Szukaj przedmiotów...")
	search.text = _cargo_search_text
	available.add_child(search)
	available.add_child(HSeparator.new())
	var available_rows: Dictionary = {}
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
		var chosen_id: String = item_id
		var button := _button("+  %s" % _cargo_label(chosen_id), func(): _adjust_starting_cargo(chosen_id, 1), false, Vector2(0, 43))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		available.add_child(button)
		available_rows[chosen_id] = button
		button.visible = _cargo_search_text.is_empty() or _cargo_label(chosen_id).to_lower().contains(_cargo_search_text.to_lower())
	search.text_changed.connect(func(value: String):
		_cargo_search_text = value
		for id in available_rows.keys():
			(available_rows[id] as Control).visible = value.is_empty() or _cargo_label(str(id)).to_lower().contains(value.to_lower()))
	available.add_child(_spacer())
	var help := _label(_prep_local("Choose what arrives with this colony. Your scenario supplies are the starting template.", "Bu koloniyle gelecek yükü seç. Senaryo erzakı başlangıç şablonudur.", "Wybierz ładunek kolonii. Zapasy scenariusza to szablon początkowy."), 12, MUTED)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	available.add_child(help)
	var selected_panel := _panel(Vector2(490, 0))
	selected_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(selected_panel)
	var selected := _vbox(6)
	selected_panel.add_child(selected)
	selected.add_child(_label(_prep_local("START WITH", "BAŞLANGIÇ YÜKÜ", "ŁADUNEK POCZĄTKOWY"), 16, GOLD))
	selected.add_child(HSeparator.new())
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
		var chosen_id: String = item_id
		var row := _hbox(8)
		selected.add_child(row)
		var item_label := _label(_cargo_label(chosen_id), 14)
		item_label.custom_minimum_size.x = 180
		row.add_child(item_label)
		var count := SpinBox.new()
		count.min_value = 0
		count.max_value = 999
		count.step = 1
		count.value = int(starting_cargo.get(chosen_id, 0))
		count.custom_minimum_size = Vector2(105, 32)
		count.value_changed.connect(func(value: float): starting_cargo[chosen_id] = int(value))
		row.add_child(count)
		row.add_child(_button("−10", func(): count.value = maxi(0, int(count.value) - 10), false, Vector2(51, 32)))
		row.add_child(_button("+10", func(): count.value = mini(999, int(count.value) + 10), false, Vector2(51, 32)))
	selected.add_child(HSeparator.new())
	selected.add_child(_label(_prep_local("EQUIP SELECTED COLONIST", "SEÇİLİ KOLONİSTİ KUŞAN", "WYPOSAŻ WYBRANEGO KOLONISTĘ"), 14, GOLD))
	for item in [{"slot": "weapon", "id": "fists", "en": "Unarmed", "tr": "Silahsız", "pl": "Bez broni"}, {"slot": "weapon", "id": "spear", "en": "Spear", "tr": "Mızrak", "pl": "Włócznia"}, {"slot": "apparel", "id": "clothes", "en": "Clothes", "tr": "Giysi", "pl": "Ubranie"}, {"slot": "apparel", "id": "jacket", "en": "Jacket", "tr": "Ceket", "pl": "Kurtka"}]:
		var slot_id := str(item["slot"])
		var item_id := str(item["id"])
		var is_equipped := str(gear.get(slot_id, "")) == item_id
		var label_text := _prep_local(str(item["en"]), str(item["tr"]), str(item["pl"]))
		selected.add_child(_button("✓  %s" % label_text if is_equipped else label_text, func(): _set_starting_gear(slot_id, item_id), is_equipped, Vector2(0, 33)))


func _cargo_label(item_id: String) -> String:
	match item_id:
		"wood": return _prep_local("Wood", "Odun", "Drewno")
		"stone": return _prep_local("Stone", "Taş", "Kamień")
		"food": return _prep_local("Food", "Yiyecek", "Żywność")
		"medicine": return _prep_local("Medicine", "İlaç", "Lekarstwa")
		"silver": return _prep_local("Silver", "Gümüş", "Srebro")
		"spear": return _prep_local("Spear", "Mızrak", "Włócznia")
		"jacket": return _prep_local("Jacket", "Ceket", "Kurtka")
	return item_id.capitalize()


func _adjust_starting_cargo(item_id: String, delta: int) -> void:
	starting_cargo[item_id] = clampi(int(starting_cargo.get(item_id, 0)) + delta, 0, 999)
	_show_characters()


func _set_starting_gear(slot_id: String, item_id: String) -> void:
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {"weapon": "fists", "apparel": "clothes"})
	gear[slot_id] = item_id
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_prepared_colonist() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var names := ["Robin", "Mara", "Elin", "Soren", "Iris", "Tomas", "Nadia", "Leon"]
	spec["name"] = names[randi() % names.size()]
	spec["sex"] = "female" if randi() % 2 == 0 else "male"
	spec["gender"] = "woman" if spec["sex"] == "female" else "man"
	spec["age"] = randi_range(19, 61)
	spec["hair_index"] = randi() % HAIR_OPTIONS.size()
	spec["hair_color_index"] = randi() % HAIR_COLOR_OPTIONS.size()
	spec["skin_index"] = randi() % SKIN_OPTIONS.size()
	spec["outfit_index"] = randi() % OUTFIT_OPTIONS.size()
	spec["childhood"] = ["rural_child", "town_child", "apprentice"][randi() % 3]
	spec["adulthood"] = ["farmer", "builder", "medic", "scholar"][randi() % 4]
	spec["trait_ids"] = [["hardworking"], ["calm", "curious"], ["quick", "kind"], ["night_owl", "timid"]][randi() % 4].duplicate()
	spec["condition_ids"] = []
	var randomized_skills: Dictionary = {}
	for skill in SKILL_IDS: randomized_skills[skill] = randi_range(2, 5)
	spec["skills"] = randomized_skills
	character_specs[_editing_character_index] = spec
	_show_characters()


func _save_character_preset() -> void:
	_save_character_inputs()
	var file := FileAccess.open("user://prepared_character.json", FileAccess.WRITE)
	if file == null:
		_notice(_prep_local("Could not save character.", "Karakter kaydedilemedi.", "Nie można zapisać postaci."))
		return
	file.store_string(JSON.stringify(character_specs[_editing_character_index]))
	_notice(_prep_local("Character saved for later starts.", "Karakter sonraki oyunlar için kaydedildi.", "Postać zapisana na przyszłość."))


func _load_character_preset() -> void:
	if not FileAccess.file_exists("user://prepared_character.json"):
		_notice(_prep_local("No saved character yet.", "Henüz kayıtlı karakter yok.", "Brak zapisanej postaci."))
		return
	var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://prepared_character.json"))
	if not loaded is Dictionary or not (loaded as Dictionary).has("name"):
		_notice(_prep_local("Character preset is invalid.", "Karakter kaydı geçersiz.", "Zapis postaci jest nieprawidłowy."))
		return
	character_specs[_editing_character_index] = (loaded as Dictionary).duplicate(true)
	_show_characters()


func _save_preparation_preset() -> void:
	_save_character_inputs()
	var file := FileAccess.open("user://preparation_preset.json", FileAccess.WRITE)
	if file == null:
		_notice(_prep_local("Could not save preset.", "Hazır ayar kaydedilemedi.", "Nie można zapisać zestawu."))
		return
	file.store_string(JSON.stringify({"colonist_count": colonist_count, "point_limit_enabled": point_limit_enabled, "characters": character_specs}))
	_notice(_prep_local("Starting crew saved as a preset.", "Başlangıç ekibi hazır ayar olarak kaydedildi.", "Załoga zapisana jako zestaw."))


func _load_preparation_preset() -> void:
	if not FileAccess.file_exists("user://preparation_preset.json"):
		_notice(_prep_local("No saved preset yet.", "Henüz kayıtlı hazır ayar yok.", "Brak zapisanego zestawu."))
		return
	var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string("user://preparation_preset.json"))
	if not loaded is Dictionary or not (loaded as Dictionary).get("characters", null) is Array:
		_notice(_prep_local("Preset is invalid.", "Hazır ayar geçersiz.", "Zestaw jest nieprawidłowy."))
		return
	var data: Dictionary = loaded
	colonist_count = clampi(int(data.get("colonist_count", 3)), 1, 3)
	point_limit_enabled = bool(data.get("point_limit_enabled", true))
	character_specs = (data["characters"] as Array).duplicate(true)
	_editing_character_index = 0
	preparation_tab = "characters"
	_show_characters()


func _cycle_field(parent: Control, title: String, values: Array, initial_index: int, changed: Callable, label_width := 112, value_width := 170) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, values.size() - 1)}
	var row := _hbox(5)
	parent.add_child(row)
	var title_label := _label(title, 12, MUTED)
	title_label.custom_minimum_size = Vector2(label_width, 0)
	row.add_child(title_label)
	var value_label := _label(str(values[int(state["index"])]), 13, CREAM)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.custom_minimum_size = Vector2(value_width, 0)
	row.add_child(_button("◀", func():
		state["index"] = (int(state["index"]) - 1 + values.size()) % values.size()
		value_label.text = str(values[int(state["index"])])
		changed.call()
	, false, Vector2(28, 25)))
	row.add_child(value_label)
	row.add_child(_button("▶", func():
		state["index"] = (int(state["index"]) + 1) % values.size()
		value_label.text = str(values[int(state["index"])])
		changed.call()
	, false, Vector2(28, 25)))
	return state


func _hair_options() -> Array:
	if preferences.language == "tr":
		return ["Kısa", "Dalgalı", "Uzun", "Kıvırcık", "Kazınmış"]
	if preferences.language == "pl":
		return ["Krótkie", "Falowane", "Długie", "Kręcone", "Wygolone"]
	return HAIR_OPTIONS


func _preparation_trait_names() -> Array:
	if preferences.language == "tr":
		return ["Yok", "Çalışkan (+6)", "Sakin (+4)", "Çevik (+4)", "Meraklı (+3)", "İyi kalpli (+3)", "Gece kuşu (+2)", "Çekingen (-4)", "Geçimsiz (-4)", "Tembel (-6)"]
	if preferences.language == "pl":
		return ["Brak", "Pracowity (+6)", "Spokojny (+4)", "Zwinny (+4)", "Ciekawski (+3)", "Życzliwy (+3)", "Nocny marek (+2)", "Nieśmiały (-4)", "Opryskliwy (-4)", "Leniwy (-6)"]
	return TRAIT_NAMES


func _preparation_condition_names() -> Array:
	if preferences.language == "tr":
		return ["Yok", "Astım (-4)", "Bel sorunu (-5)", "Yara izi (-2)"]
	if preferences.language == "pl":
		return ["Brak", "Astma (-4)", "Ból pleców (-5)", "Blizna (-2)"]
	return CONDITION_NAMES

func _save_character_inputs() -> void:
	for input in _character_inputs:
		var spec: Dictionary = character_specs[int(input.index)].duplicate(true)
		spec["name"] = (input.name as LineEdit).text.strip_edges()
		for key in ["hair", "hair_color", "skin", "outfit"]:
			spec[key + "_index"] = int(input[key]["index"])
		spec["sex"] = ["female", "male"][int(input.sex["index"])]
		spec["gender"] = ["woman", "man", "nonbinary"][int(input.gender["index"])]
		spec["age"] = int((input.age as SpinBox).value)
		spec["childhood"] = ["rural_child", "town_child", "apprentice"][int(input.childhood["index"])]
		spec["adulthood"] = ["farmer", "builder", "medic", "scholar"][int(input.adulthood["index"])]
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
		for skill in input.skills:
			skills[skill] = int(input.skills[skill]["index"])
		spec["skills"] = skills
		character_specs[int(input.index)] = spec

func _refresh_character_editor() -> void:
	if _character_inputs.is_empty():
		return
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	var input: Dictionary = _character_inputs[0]
	(input.preview as Control).call("set_appearance", _spec_appearance(spec))
	for i in mini(_roster_buttons.size(), character_specs.size()):
		var traits: Array = character_specs[i].get("trait_ids", [])
		var first_trait := str(traits[0]).replace("_", " ").capitalize() if not traits.is_empty() else _prep_local("No trait", "Özellik yok", "Brak cechy")
		_roster_buttons[i].text = "%s\n%s" % [str(character_specs[i].get("name", "Colonist")), first_trait]
	_refresh_character_points()

func _refresh_character_points() -> void:
	if not is_instance_valid(_character_points) or character_specs.is_empty():
		return
	var spec: Dictionary = character_specs[_editing_character_index]
	var person := {"traits": spec.get("trait_ids", []), "health_conditions": spec.get("condition_ids", []), "skills": spec.get("skills", {}), "starting_gear": spec.get("starting_gear", {})}
	var spent := int(Game.preparation_points(person)) if Game.has_method("preparation_points") else 0
	_character_points.text = _tr("characters.points", {"used": spent, "limit": "12" if point_limit_enabled else "∞"})
	_character_points.add_theme_color_override("font_color", RED if point_limit_enabled and spent > 12 else GOLD)


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
		if str(spec.get("name", "")).is_empty():
			_notice("Every colonist needs a name.")
			return
	var prepared := _game_setup_config()
	var validation: Dictionary = Game.validate_setup(prepared)
	if not bool(validation.get("ok", false)):
		_notice(str(validation.get("error", "Colonist setup is invalid.")))
		return
	if session_kind == "join":
		_submit_joiner_setup()
		return
	if session_kind == "solo":
		_start_prepared_game()
		return
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
	if screen == "game":
		return
	if session_kind == "host" and setup_mode == "competitive" and (Net.get_lobby().get("players", []) as Array).size() < 2:
		_notice("Ayrı Koloniler için en az bir oyuncu daha bağlanmalı.")
		return
	var config := _game_setup_config()
	var result = Net.start_game(config)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Oyun başlatılamadı.")))
		return
	_show_game()


func _game_setup_config() -> Dictionary:
	return {"seed": setup_seed, "mode": setup_mode, "colonists_per_faction": colonist_count,
		"point_limit_enabled": point_limit_enabled, "faction_specs": [_build_faction_spec()],
		"scenario_id": scenario_id, "storyteller_id": storyteller_id,
		"difficulty_id": difficulty_id, "world_options": world_options.duplicate(true)}


func _build_faction_spec() -> Dictionary:
	var appearances := ["short", "wavy", "long", "curly", "shaved"]
	var people: Array = []
	for spec in character_specs:
		people.append({
			"name": str(spec.get("name", "Kolonist")),
			"sex": str(spec.get("sex", "female")),
			"gender": str(spec.get("gender", "woman")),
			"age": int(spec.get("age", 25)),
			"childhood": str(spec.get("childhood", "rural_child")),
			"adulthood": str(spec.get("adulthood", "farmer")),
			"starting_gear": spec.get("starting_gear", {"weapon": "fists", "apparel": "clothes"}).duplicate(true),
			"starting_relationships": spec.get("starting_relationships", {}).duplicate(true),
			"skills": spec.get("skills", {}).duplicate(true),
			"health_conditions": spec.get("condition_ids", []).duplicate(),
			"appearance": {
				"hair": appearances[int(spec.get("hair_index", 0))],
				"hair_color": HAIR_COLOR_OPTIONS[int(spec.get("hair_color_index", 0))],
				"skin": SKIN_OPTIONS[int(spec.get("skin_index", 0))],
				"outfit": OUTFIT_OPTIONS[int(spec.get("outfit_index", 0))]
			},
			"traits": spec.get("trait_ids", []).duplicate()
		})
	return {
		"id": 1,
		"name": faction_name,
		"settlement_name": settlement_name,
		"site_id": selected_site_id,
		"starting_cargo": starting_cargo.duplicate(true),
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
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_root = root
	_map_view = MapViewScript.new()
	_map_view.map_pressed.connect(_on_map_pressed)
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
		["Araştırma", "tabs.research"], ["Sağlık", "tabs.health"], ["Ticaret", "trade"], ["Dünya", "tabs.world"]]:
		var name_copy: String = entry[0]
		var tab_label := _prep_local("Trade", "Ticaret", "Handel") if entry[1] == "trade" else _tr(entry[1])
		var tab_button := _hud_button(tab_label, func(): _set_tab(name_copy), name_copy == current_tab, Vector2(138, 36))
		tab_row.add_child(tab_button)
		_tab_buttons[name_copy] = tab_button
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
	for entry in [["Ⅱ", 0.0], ["▶", 1.0], ["▶▶", 2.0], ["▶▶▶", 3.0]]:
		var speed_value: float = entry[1]
		var speed_button := _hud_button(str(entry[0]), func(): _set_speed(speed_value), false, Vector2(48, 33))
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
	current_tab = "" if current_tab == name else name
	current_tool = ""
	if not current_tab.is_empty():
		selected_ids.clear()
		pawn_tab = ""
		_render_game()
	if is_instance_valid(_tool_panel):
		_tool_panel.visible = not current_tab.is_empty()
	for tab_name in _tab_buttons:
		var button := _tab_buttons[tab_name] as Button
		button.add_theme_stylebox_override("normal", _hud_style(HUD_ACTIVE if tab_name == current_tab else HUD_TAB))
	if not current_tab.is_empty():
		_render_sidebar(_snapshot())


func _toggle_pause() -> void:
	game_paused = not game_paused
	_update_speed_buttons()


func _set_speed(value: float) -> void:
	if value == 0.0:
		game_paused = true
	else:
		game_paused = false
		speed = value
	_update_speed_buttons()

func _update_speed_buttons() -> void:
	for key in _speed_buttons:
		var button := _speed_buttons[key] as Button
		var active: bool = (game_paused and key == "Ⅱ") or (not game_paused and key == "▶".repeat(int(speed)))
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
	columns.add_child(page)
	var draft := {
		"window_mode": preferences.window_mode,
		"resolution": preferences.resolution,
		"language": preferences.language,
		"master_volume": preferences.master_volume,
		"music_volume": preferences.music_volume,
		"effects_volume": preferences.effects_volume,
	}
	var selected_category := ["general"]
	var category_buttons: Dictionary = {}
	for entry in [["general", "settings.general"], ["graphics", "settings.display"], ["audio", "settings.audio"], ["controls", "settings.controls"]]:
		var category_id := str(entry[0])
		var button := _button(_tr(str(entry[1])), func():
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
		draft["resolution"] = defaults.resolution
		draft["language"] = defaults.language
		draft["master_volume"] = defaults.master_volume
		draft["music_volume"] = defaults.music_volume
		draft["effects_volume"] = defaults.effects_volume
		_build_settings_page(page, str(selected_category[0]), draft)
	, false, Vector2(140, 34)))
	actions.add_child(_button(_tr("common.apply"), func():
		preferences.window_mode = str(draft["window_mode"])
		preferences.resolution = draft["resolution"]
		preferences.language = str(draft["language"])
		preferences.master_volume = float(draft["master_volume"])
		preferences.music_volume = float(draft["music_volume"])
		preferences.effects_volume = float(draft["effects_volume"])
		preferences.apply_settings()
		var saved := preferences.save_settings()
		_close_settings()
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
		"graphics":
			page.add_child(_label(_tr("settings.display"), 19, GOLD))
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
			var sizes: Array[Vector2i] = SettingsScript.resolution_options()
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
					value.text = "%d%%" % roundi(level * 100.0))
		"controls":
			page.add_child(_label(_tr("settings.controls"), 19, GOLD))
			for key in ["settings.control_pause", "settings.control_display", "settings.control_select", "settings.control_order", "settings.control_zoom"]:
				page.add_child(_label(_tr(key), 14, CREAM))


func _close_settings() -> void:
	if is_instance_valid(_settings_overlay):
		_settings_overlay.queue_free()
	_settings_overlay = null
	if screen == "game":
		game_paused = _settings_return_paused
		_update_speed_buttons()


func _show_pause_menu() -> void:
	var resume_paused := game_paused
	game_paused = true
	_update_speed_buttons()
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var menu := _vbox(8)
	menu.custom_minimum_size = Vector2(290, 0)
	popup.add_child(menu)
	menu.add_child(_label("Paused", 23, GOLD))
	menu.add_child(_button("Resume", func(): popup.hide()))
	menu.add_child(_button("Save game", _save_game))
	menu.add_child(_button("Load game", func(): popup.hide(); _load_saved_game()))
	menu.add_child(_button("Settings", func(): popup.hide(); _show_settings()))
	menu.add_child(_button("Main menu", func(): popup.hide(); Net.start_solo(); _show_menu()))
	menu.add_child(_button("Quit Foxtopia", func(): get_tree().quit()))
	popup.popup_hide.connect(func():
		game_paused = resume_paused
		_update_speed_buttons()
		popup.queue_free())
	popup.popup_centered(Vector2i(320, 370))


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
	var resources := _local_resources(data)
	_map_view.set_world(_local_map(data), _local_colonists(data), _local_raiders(data), _local_caravans(data), _local_orders(data), selected_ids)
	_map_view.set_stockpile_inventory(resources)
	if _map_view.has_method("set_day_time"):
		_map_view.call("set_day_time", int(data.get("time", 0)), int(data.get("day_length", 600)))
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
		alerts.append("Low food")
	for person in _local_colonists(snapshot):
		if float(person.get("needs", {}).get("hunger", 100)) < 25.0:
			alerts.append("Colonist needs food")
			break
	var has_bench := false
	for structure in _local_map(snapshot).get("structures", []):
		if str(structure.get("kind", "")) == "research_bench":
			has_bench = true
			break
	if not has_bench:
		alerts.append("Research bench needed")
	for alert in alerts:
		var label := _label("!  " + alert, 13, CREAM)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_alert_stack.add_child(label)

func _render_clock(snapshot: Dictionary) -> void:
	if not is_instance_valid(_time_label):
		return
	var elapsed := maxi(0, int(snapshot.get("time", 0)))
	var day_length := maxi(1, int(snapshot.get("day_length", 600)))
	var day := 1 + elapsed / day_length
	var minute_of_day := (480 + int(float(elapsed % day_length) * 1440.0 / float(day_length))) % 1440
	_time_label.text = "Day %d, 5500    %02d:%02d" % [day, minute_of_day / 60, minute_of_day % 60]


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
	var signature_parts: Array = []
	for person in _local_colonists(snapshot):
		signature_parts.append([person.get("id", ""), person.get("name", ""), person.get("appearance", {}), person.get("drafted", false), person.get("health", {}), selected_ids.has(str(person.get("id", "")))])
	var signature := JSON.stringify(signature_parts)
	if signature == _portrait_signature:
		return
	_portrait_signature = signature
	for child in _portrait_strip.get_children():
		child.queue_free()
	for person in _local_colonists(snapshot):
		var id := str(person.get("id", ""))
		var button := _hud_button("", func(): _select_colonist(id), selected_ids.has(id), Vector2(58, 64))
		button.add_theme_stylebox_override("normal", _hud_style(Color("#293239a8") if selected_ids.has(id) else Color("#17202770"), GOLD if selected_ids.has(id) else Color("#65717a7f")))
		button.tooltip_text = str(person.get("name", "Colonist"))
		var portrait := PawnPortrait.new()
		portrait.appearance = person.get("appearance", {})
		portrait.is_selected = selected_ids.has(id)
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
		var health_bar := ColorRect.new()
		health_bar.color = TEAL if float(person.get("health", {}).get("hp", 100)) >= 65.0 else RED
		health_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(health_bar)
		_place(health_bar, 0.0, 1.0, clampf(float(person.get("health", {}).get("hp", 100)) / 100.0, 0.0, 1.0), 1.0, 2, -4, -2, -2)
		_portrait_strip.add_child(button)

func _render_selected_pawn(snapshot: Dictionary) -> void:
	if not is_instance_valid(_pawn_panel):
		return
	var person := _selected_person(snapshot)
	_pawn_panel.visible = not person.is_empty()
	_pawn_detail_panel.visible = not person.is_empty() and not pawn_tab.is_empty()
	_command_strip.visible = not person.is_empty()
	if person.is_empty():
		return
	for child in _pawn_summary.get_children():
		child.queue_free()
	for child in _command_strip.get_children():
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
	var identity := _label("%s · %s" % [str(person.get("sex", "human")).capitalize(), str(person.get("gender", "person")).capitalize()], 11, MUTED)
	identity.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_row.add_child(identity)
	var condition_row := _hbox(6)
	_pawn_summary.add_child(condition_row)
	condition_row.add_child(_hud_status_bar("Health", hp, TEAL if hp >= 65 else RED))
	condition_row.add_child(_hud_status_bar("Mood", int(needs.get("mood", 75)), Color("#d6bf83")))
	var activity := "Idle"
	if bool(person.get("resting", false)):
		activity = "Resting"
	elif not (person.get("manual", {}) as Dictionary).is_empty():
		activity = str(person.get("manual", {}).get("action", "Working")).capitalize()
	elif not str(person.get("current_order", "")).is_empty():
		activity = "Working"
	_pawn_summary.add_child(_label("%s    ·    %s" % ["Drafted" if bool(person.get("drafted", false)) else "Undrafted", activity], 12, MUTED))
	var equipment: Dictionary = person.get("equipment", {})
	_pawn_summary.add_child(_label("Weapon: %s    Apparel: %s" % [str(equipment.get("weapon", "fists")).capitalize(), str(equipment.get("apparel", "clothes")).capitalize()], 11, MUTED))
	var draft_button := _hud_action_button("DRAFT" if not bool(person.get("drafted", false)) else "UNDRAFT", func(): _send_command({"type": "set_draft", "colonist_id": person_id, "drafted": not bool(person.get("drafted", false))}), bool(person.get("drafted", false)))
	draft_button.tooltip_text = "Toggle combat control"
	_command_strip.add_child(draft_button)
	var clear_button := _hud_action_button("CANCEL\nORDER", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "clear"}))
	clear_button.tooltip_text = "Cancel the current direct order"
	_command_strip.add_child(clear_button)
	_command_strip.add_child(_hud_action_button("GEAR", func(): _set_pawn_tab("Gear"), pawn_tab == "Gear"))
	_command_strip.add_child(_hud_action_button("HEALTH", func(): _set_pawn_tab("Health"), pawn_tab == "Health"))
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
	var button := _hud_button(title, action, active, Vector2(73, 64))
	button.add_theme_font_size_override("font_size", 11)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return button

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
	_pawn_detail_content.add_child(_label("Overall health  %d / %d" % [int(health.get("hp", 100)), int(health.get("max_hp", 100))], 14, CREAM))
	if float(health.get("bleeding", 0)) > 0:
		_pawn_detail_content.add_child(_label("Bleeding  %d" % int(health.get("bleeding", 0)), 13, RED))
	var groups: Dictionary = {}
	for wound in health.get("wounds", []):
		var kind := str(wound.get("kind", "Wound")).capitalize()
		var severity := int(wound.get("severity", 0))
		if not groups.has(kind):
			groups[kind] = {"count": 0, "severity": 0}
		groups[kind]["count"] = int(groups[kind]["count"]) + 1
		groups[kind]["severity"] = maxi(int(groups[kind]["severity"]), severity)
	for kind in groups:
		var count := int(groups[kind]["count"])
		var severity := int(groups[kind]["severity"])
		var severity_name := "Minor" if severity < 4 else "Moderate" if severity < 8 else "Severe" if severity < 12 else "Critical"
		_pawn_detail_content.add_child(_label("%s ×%d    %s" % [kind, count, severity_name], 13, RED if severity >= 8 else CREAM))
	var conditions: Array = health.get("conditions", [])
	for condition in conditions:
		_pawn_detail_content.add_child(_label(str(condition).capitalize(), 13, MUTED))
	if groups.is_empty() and conditions.is_empty():
		_pawn_detail_content.add_child(_label("No injuries or conditions.", 13, TEAL))

func _build_pawn_bio(person: Dictionary) -> void:
	_pawn_detail_content.add_child(_label("Age  %d    Sex  %s    Gender  %s" % [int(person.get("age", 25)), str(person.get("sex", "Unspecified")).capitalize(), str(person.get("gender", "Unspecified")).capitalize()], 13))
	_pawn_detail_content.add_child(_label("Childhood  %s" % str(person.get("childhood", "rural_child")).replace("_", " ").capitalize(), 13))
	_pawn_detail_content.add_child(_label("Adulthood  %s" % str(person.get("adulthood", "farmer")).capitalize(), 13))
	var traits: Array = person.get("traits", [])
	_pawn_detail_content.add_child(_label("Traits  %s" % ", ".join(traits), 13))
	_pawn_detail_content.add_child(HSeparator.new())
	_pawn_detail_content.add_child(_label("Skills", 14, GOLD))
	for key in person.get("skills", {}).keys():
		_pawn_detail_content.add_child(_label("%s   %d" % [str(key).capitalize(), int(person["skills"][key])], 12))

func _build_pawn_gear(person: Dictionary) -> void:
	var equipment: Dictionary = person.get("equipment", {})
	_pawn_detail_content.add_child(_label("Weapon  %s" % str(equipment.get("weapon", "None")), 14))
	_pawn_detail_content.add_child(_label("Apparel  %s" % str(equipment.get("apparel", "None")), 14))
	var carrying: Dictionary = person.get("carrying", {})
	if not carrying.is_empty():
		_pawn_detail_content.add_child(_label("Carrying  %s ×%d" % [str(carrying.get("kind", "Item")), int(carrying.get("amount", 1))], 13, MUTED))
	var inventory := _local_resources(_snapshot())
	var person_id := str(person.get("id", ""))
	if int(inventory.get("spear", 0)) > 0 and str(equipment.get("weapon", "")) != "spear":
		_pawn_detail_content.add_child(_button("Equip spear", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "spear"})))
	if int(inventory.get("jacket", 0)) > 0 and str(equipment.get("apparel", "")) != "jacket":
		_pawn_detail_content.add_child(_button("Wear jacket", func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"})))

func _build_pawn_social(person: Dictionary) -> void:
	var relationships: Dictionary = person.get("relationships", {})
	var relation_types: Dictionary = person.get("relationship_types", {})
	if relationships.is_empty():
		_pawn_detail_content.add_child(_label("No established relationships yet.", 13, MUTED))
	var names: Dictionary = {}
	for other in _local_colonists(_snapshot()): names[str(other.get("id", ""))] = str(other.get("name", "Colonist"))
	for person_id in relationships:
		var relation_type := str(relation_types.get(str(person_id), "Acquaintance")).capitalize()
		_pawn_detail_content.add_child(_label("%s   %s   %+d" % [str(names.get(str(person_id), person_id)), relation_type, int(relationships[person_id])], 13))

func _build_pawn_log(snapshot: Dictionary, person: Dictionary) -> void:
	var count := 0
	for i in range((snapshot.get("events", []) as Array).size() - 1, -1, -1):
		var event: Dictionary = snapshot["events"][i]
		if str(event.get("message", "")).contains(str(person.get("name", ""))):
			_pawn_detail_content.add_child(_label(str(event.get("message", "")), 12))
			count += 1
			if count >= 8:
				break
	if count == 0:
		_pawn_detail_content.add_child(_label("No recent events.", 13, MUTED))


func _select_colonist(id: String, open_health := false) -> void:
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
	if mouse_button == MOUSE_BUTTON_RIGHT:
		_context_tile = tile
		_context_unit_id = colonist_id
		_context_enemy_id = enemy_id
		_context_order_id = _order_at(tile)
		_context_caravan_id = _caravan_at(tile)
		_context_structure_id = str(_structure_at_tile(tile).get("id", ""))
		_open_context_menu()
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
			_context_menu.add_item("Chop wood", 101)
		elif resource_kind == "stone":
			_context_menu.add_item("Mine stone", 102)
		elif resource_kind == "berry":
			_context_menu.add_item("Harvest berries", 103)
		if not _context_order_id.is_empty():
			_context_menu.add_item("Cancel order", 104)
	else:
		if _map_tile_passable(_context_tile):
			_context_menu.add_item(_tr("pawn.move"), 1)
		if not _context_order_id.is_empty():
			_context_menu.add_item("Prioritize this work", 2)
		elif resource_kind == "tree":
			_context_menu.add_item("Chop this tree", 9)
		elif resource_kind == "stone":
			_context_menu.add_item("Mine this stone", 10)
		elif resource_kind == "berry":
			_context_menu.add_item("Harvest berries", 11)
		for drop in _local_map(_snapshot()).get("drops", []):
			if int(drop.get("x", -1)) == _context_tile.x and int(drop.get("y", -1)) == _context_tile.y:
				if _has_stockpile_for_kind(str(drop.get("kind", ""))):
					_context_menu.add_item(_tr("pawn.carry"), 3)
				break
		if not _context_enemy_id.is_empty():
			_context_menu.add_item("Attack target", 4)
		if not _context_caravan_id.is_empty():
			_context_menu.add_item("Talk to trader", 5)
		if str(_structure_at_tile(_context_tile).get("kind", "")) == "styling_table":
			_context_menu.add_item("Use styling table", 6)
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
	_send_command(command)


func _send_command(command: Dictionary) -> bool:
	var result = Net.send_command(command)
	if result is Dictionary and not bool(result.get("ok", true)):
		_notice(str(result.get("error", "Komut uygulanamadı.")))
		return false
	elif result is bool and not result:
		_notice("Komut uygulanamadı.")
		return false
	else:
		_render_game()
		if not current_tab.is_empty():
			_render_sidebar(_snapshot())
		return true


func _on_state_changed(_snapshot_data: Dictionary) -> void:
	if screen == "game":
		_render_game()
	elif screen == "waiting" and session_kind == "join":
		_show_game()


func _on_event_emitted(event: Dictionary) -> void:
	var message := str(event.get("message", ""))
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

func _open_naming_prompt() -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(9)
	content.custom_minimum_size = Vector2(440, 0)
	popup.add_child(content)
	content.add_child(_label("A name for this place", 21, GOLD))
	var story := _label("Two settlers talk by the camp. It is time to give their new home a name.", 14, CREAM)
	story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(story)
	content.add_child(_label("Colony name", 12, MUTED))
	var colony_edit := LineEdit.new()
	colony_edit.text = "Foxtopia"
	content.add_child(colony_edit)
	content.add_child(_label("Settlement name", 12, MUTED))
	var settlement_edit := LineEdit.new()
	settlement_edit.text = "New Haven"
	content.add_child(settlement_edit)
	content.add_child(_button("Name our home", func():
		var colony := colony_edit.text.strip_edges()
		var settlement := settlement_edit.text.strip_edges()
		if colony.is_empty() or settlement.is_empty():
			_notice("Both names are required.")
			return
		_send_command({"type": "rename", "target": "faction", "name": colony})
		_send_command({"type": "rename", "target": "settlement", "name": settlement})
		faction_name = colony
		settlement_name = settlement
		popup.hide()
	, true))
	popup.popup_hide.connect(func(): popup.queue_free())
	popup.popup_centered(Vector2i(470, 330))


func _notice(message: String) -> void:
	_status_text = message
	_status_timer = 4.0
	if screen == "game" and is_instance_valid(_notice_label):
		_notice_label.text = message
		_notice_label.visible = true
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
	var tool_row := _hbox(5)
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
	var actions := _hbox(7)
	_sidebar.add_child(actions)
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
	_sidebar.add_child(_label("Pending orders: %d" % pending, 12, MUTED))


func _choose_tool(kind: String) -> void:
	current_tool = kind
	_render_sidebar(_snapshot())
	if not kind.is_empty():
		_notice("Haritada %s için bir hücre seç." % _order_name(kind))


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
		var name := _label(str(person.get("name", "Kolonist")), 15, CREAM)
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
		_notice("The trader has left.")
		return
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(8)
	content.custom_minimum_size = Vector2(650, 0)
	popup.add_child(content)
	content.add_child(_label(str(caravan.get("name", "Trade caravan")), 22, GOLD))
	var inventory := _local_resources(snapshot)
	content.add_child(_label("Your silver: %d    Trader silver: %d" % [int(inventory.get("silver", 0)), int(caravan.get("stock", {}).get("silver", 0))], 14, MUTED))
	var columns := _hbox(15)
	content.add_child(columns)
	var buy_column := _vbox(4)
	buy_column.custom_minimum_size = Vector2(315, 0)
	columns.add_child(buy_column)
	buy_column.add_child(_label("Buy", 16, GOLD))
	var sell_column := _vbox(4)
	sell_column.custom_minimum_size = Vector2(315, 0)
	columns.add_child(sell_column)
	sell_column.add_child(_label("Sell", 16, GOLD))
	var buy_fields: Dictionary = {}
	var sell_fields: Dictionary = {}
	for item in ITEM_PRICES:
		var available := int(caravan.get("stock", {}).get(item, 0))
		if available > 0:
			var row := _hbox(5)
			buy_column.add_child(row)
			var label := _label("%s  ·  %d silver  (%d)" % [str(item).capitalize(), int(ITEM_PRICES[item]), available], 12)
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
			var sell_label := _label("%s  ·  %d silver  (%d)" % [str(item).capitalize(), int(ITEM_PRICES[item]), owned], 12)
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
	buttons.add_child(_button("Close", func(): popup.hide()))
	buttons.add_child(_button("Confirm trade", func():
		var buy: Dictionary = {}
		var sell: Dictionary = {}
		for item in buy_fields:
			var amount := int((buy_fields[item] as SpinBox).value)
			if amount > 0: buy[item] = amount
		for item in sell_fields:
			var amount := int((sell_fields[item] as SpinBox).value)
			if amount > 0: sell[item] = amount
		if buy.is_empty() and sell.is_empty():
			_notice("Choose an item first.")
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
	if others.is_empty() and caravans.is_empty():
		_sidebar.add_child(_label(_prep_local("No caravan is here. Friendly settlements may visit as time passes.", "Şu anda kervan yok. Zamanla dost yerleşkeler ziyaret edebilir.", "Nie ma tu karawany. Przyjazne osady mogą odwiedzić kolonię z czasem."), 15, MUTED))
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
	_tab_title(_tr("tabs.world"), "Settlements and relations")
	var faction := _my_faction(snapshot)
	_sidebar.add_child(_label("%s · %s" % [faction.get("name", faction_name), faction.get("settlement_name", settlement_name)], 18, GOLD))
	_sidebar.add_child(_button("Open world map", func(): _open_world_overview(snapshot), true))
	_sidebar.add_child(_label("Friendly settlements may send caravans; hostile settlements may send raids.", 14, MUTED))
	_sidebar.add_child(HSeparator.new())
	var mine_id := str(faction.get("id", ""))
	var has_other_player_colony := false
	for other in _values_array(snapshot.get("factions", [])):
		if str(other.get("id", "")) != mine_id:
			has_other_player_colony = true
			break
	if has_other_player_colony:
		_sidebar.add_child(_button("Trade with another colony", func(): _open_colony_trade_dialog(_snapshot())))
	for offer in _values_array(snapshot.get("trade_offers", [])):
		if str(offer.get("status", "")) != "pending" or str(offer.get("to_faction", "")) != mine_id:
			continue
		var offer_id := str(offer.get("id", ""))
		_sidebar.add_child(_label("Offer from %s · give %s · receive %s" % [str(offer.get("from_faction", "")), str(offer.get("give", {})), str(offer.get("receive", {}))], 13))
		var actions := _hbox(5)
		_sidebar.add_child(actions)
		actions.add_child(_button(_tr("trade.accept"), func(): _send_command({"type": "trade_accept", "offer_id": offer_id})))
		actions.add_child(_button(_tr("trade.decline"), func(): _send_command({"type": "trade_decline", "offer_id": offer_id})))
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
		_notice("Only the host can save this game.")
		return
	_open_save_picker(true)


func _load_saved_game() -> void:
	if session_kind == "join":
		_notice("A guest cannot load a save.")
		return
	_open_save_picker(false)


func _open_save_picker(save_mode: bool) -> void:
	var popup := PopupPanel.new()
	popup.add_theme_stylebox_override("panel", _style(PANEL, GOLD))
	add_child(popup)
	var content := _vbox(8)
	content.custom_minimum_size = Vector2(470, 0)
	popup.add_child(content)
	content.add_child(_label("Save game" if save_mode else "Load game", 22, GOLD))
	if save_mode:
		var name_edit := LineEdit.new()
		name_edit.placeholder_text = "Save name"
		name_edit.text = "save_%d" % Time.get_unix_time_from_system()
		content.add_child(name_edit)
		content.add_child(_button("Create new save", func():
			var slot := name_edit.text.strip_edges().replace(" ", "_")
			var saved := Game.save_game(slot)
			_notice("Game saved." if saved else "Could not save. Use letters, numbers, _ or -.")
			if saved: popup.hide()
		, true))
	var saves: Array = Game.list_saved_games()
	if saves.is_empty():
		content.add_child(_label("No saved games yet.", 14, MUTED))
	else:
		content.add_child(_label("Existing saves", 14, MUTED))
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(470, minf(320.0, float(saves.size()) * 50.0))
		content.add_child(scroll)
		var rows := _vbox(5)
		scroll.add_child(rows)
		for saved in saves:
			var slot_id := str(saved.get("id", ""))
			var colonies: Array = saved.get("colonies", [])
			var label_text := "%s  ·  %s  ·  day %d" % [slot_id, ", ".join(colonies), int(saved.get("time", 0)) / 600 + 1]
			if save_mode:
				rows.add_child(_button("Overwrite  " + label_text, func():
					var saved_ok := Game.save_game(slot_id)
					_notice("Game saved." if saved_ok else "Could not save the game.")
					if saved_ok: popup.hide()
				))
			else:
				rows.add_child(_button(label_text, func(): popup.hide(); _load_slot(slot_id)))
	content.add_child(_button("Close", func(): popup.hide()))
	popup.popup_hide.connect(func(): popup.queue_free())
	popup.popup_centered(Vector2i(510, 500))


func _load_slot(slot_id: String) -> void:
	Net.start_solo()
	if not Game.load_game(slot_id):
		_notice("Could not open this save.")
		return
	session_kind = "solo"
	var data := Game.get_snapshot()
	var mine := _my_faction(data)
	faction_name = str(mine.get("name", "Koloni"))
	settlement_name = str(mine.get("settlement_name", "Yerleşke"))
	selected_site_id = str(mine.get("site_id", ""))
	game_paused = false
	_show_game()
