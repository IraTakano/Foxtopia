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
const TRAIT_IDS := ["", "hardworking", "calm", "quick", "curious", "kind", "night_owl", "timid", "abrasive", "lazy"]
const TRAIT_NAMES := ["None", "Hardworking (+6)", "Calm (+4)", "Quick (+4)", "Curious (+3)", "Kind (+3)", "Night owl (+2)", "Timid (-4)", "Abrasive (-4)", "Lazy (-6)"]
const CONDITION_IDS := ["", "asthma", "bad_back", "scar"]
const CONDITION_NAMES := ["None", "Asthma (-4)", "Bad back (-5)", "Scar (-2)"]
const SKILL_IDS := ["chop", "mine", "harvest", "haul", "build", "research", "treat", "combat"]
const HAIR_OPTIONS := ["Short", "Wavy", "Long", "Curly", "Shaved"]
const SKIN_OPTIONS := ["#f8dcc3", "#efc69f", "#e7ad82", "#d99568", "#cb875d", "#b97952", "#a86b48", "#925b3d", "#7d4e36", "#6a422f", "#573729", "#442c23"]
const OUTFIT_OPTIONS := ["#527a81", "#b16f59", "#7b8664", "#92759a", "#b89c65"]
const HAIR_COLOR_OPTIONS := ["#282421", "#4d3c32", "#704934", "#8b6449", "#ad7850", "#bb9b69", "#d1b880", "#8c5f56", "#754d48", "#a2a2a0", "#e5dfd2", "#343a3a"]
const MALE_HAIR_IDS := ["short", "sidepart", "curly", "shaved"]
const FEMALE_HAIR_IDS := ["bob", "wavy", "long", "braid"]
const ITEM_PRICES := {"wood": 2, "stone": 3, "food": 4, "medicine": 12, "spear": 18, "jacket": 11, "tshirt": 8, "pants": 9}
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
	var appearance: Dictionary = {}
	var is_selected := false
	var is_drafted := false

	func _ready() -> void:
		texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	func set_appearance(next_appearance: Dictionary) -> void:
		appearance = next_appearance
		queue_redraw()

	func _draw() -> void:
		PawnDrawer.draw_pawn(self, Vector2(size.x * 0.5, size.y * 0.45), minf(size.x, size.y) * 0.78, appearance, is_selected, false, is_drafted)


class FamilyGraph extends Control:
	var clusters: Array = []
	var edges: Array = []

	func _draw() -> void:
		for cluster in clusters:
			var rect: Rect2 = cluster
			draw_rect(rect, Color("#212224"))
			draw_rect(rect, Color("#3c3d3f"), false, 1.0)
		for edge in edges:
			var start: Vector2 = edge["start"]
			var finish: Vector2 = edge["finish"]
			var active: bool = edge["active"]
			var color := Color("#8c8b87") if active else Color("#57595b")
			var middle_y := (start.y + finish.y) * 0.5
			if str(edge.get("kind", "parent")) == "sibling" or absf(finish.y - start.y) < 12.0:
				_segment(start, finish, color, not active)
			else:
				_segment(start, Vector2(start.x, middle_y), color, not active)
				_segment(Vector2(start.x, middle_y), Vector2(finish.x, middle_y), color, not active)
				_segment(Vector2(finish.x, middle_y), finish, color, not active)

	func _segment(start: Vector2, finish: Vector2, color: Color, dashed: bool) -> void:
		if not dashed:
			draw_line(start, finish, color, 2.0)
			return
		var length := start.distance_to(finish)
		if length < 1.0:
			return
		var direction := (finish - start) / length
		for offset in range(0, int(length), 10):
			draw_line(start + direction * float(offset), start + direction * minf(float(offset + 5), length), color, 1.0)


class PassionFlame extends Button:
	signal level_changed(next_level: int)
	var level := 0

	func _ready() -> void:
		flat = true
		custom_minimum_size = Vector2(27, 25)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		pressed.connect(_cycle)

	func _cycle() -> void:
		level = (level + 1) % 3
		level_changed.emit(level)
		queue_redraw()

	func _draw() -> void:
		var count := 2 if level == 2 else 1
		for flame_index in range(count):
			var scale_factor := 0.65 if count == 2 else 0.86
			var origin := Vector2(1.5 + float(flame_index) * 11.0, 2.0) if count == 2 else Vector2(4.0, 1.0)
			var points := PackedVector2Array([
				origin + Vector2(8, 0) * scale_factor,
				origin + Vector2(12, 7) * scale_factor,
				origin + Vector2(15, 4) * scale_factor,
				origin + Vector2(17, 13) * scale_factor,
				origin + Vector2(15, 20) * scale_factor,
				origin + Vector2(10, 23) * scale_factor,
				origin + Vector2(4, 20) * scale_factor,
				origin + Vector2(2, 14) * scale_factor,
				origin + Vector2(6, 10) * scale_factor
			])
			draw_colored_polygon(points, Color("#f1953c") if level > 0 else Color("#56575a"))
			if level > 0:
				var center := origin + Vector2(10, 17) * scale_factor
				draw_circle(center, 2.8 * scale_factor, Color("#ffd071"))

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
	var style := _style(Color("#1b1d20") if outer else Color("#262729"), Color("#4b4c4e") if outer else Color("#2b2d2f"), 1)
	style.content_margin_left = 10
	style.content_margin_top = 9
	style.content_margin_right = 10
	style.content_margin_bottom = 9
	card.add_theme_stylebox_override("panel", style)
	return card


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
		var style := _style(fill, Color("#777779") if selected else Color("#555658"), 1)
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
	starting_cargo.clear()
	_cargo_search_text = ""
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
		_prep_local("Choose how you will play. Your scenario sets the starting crew.", "Nasıl oynayacağını seç. Başlangıç ekibini senaryo belirler.", "Wybierz tryb gry. Scenariusz określa początkową załogę."))
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
	colonist_count = int(selected.get("colonist_count", 3))
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
	screen = "characters"
	if character_specs.size() > colonist_count:
		character_specs.resize(colonist_count)
	while character_specs.size() < colonist_count:
		var i := character_specs.size()
		character_specs.append({"name": ["Ada", "Baran", "Deniz"][i], "hair_index": i % 4, "hair_color": HAIR_COLOR_OPTIONS[i + 1], "skin_color": SKIN_OPTIONS[i * 3], "body_type": i % 2, "head_type": i % 2, "trait_ids": ["hardworking"] if i == 0 else ["calm"] if i == 1 else ["quick"], "condition_ids": [], "sex": "female" if i != 1 else "male", "age": 25 + i * 4, "childhood": "rural_child", "adulthood": ["farmer", "builder", "medic"][i], "starting_gear": {"weapon": "fists", "shirt": "tshirt", "pants": "pants", "shirt_color": OUTFIT_OPTIONS[i % OUTFIT_OPTIONS.size()], "pants_color": "#5f6768"}, "starting_relationships": {}, "skills": {}})
	_editing_character_index = clampi(_editing_character_index, 0, colonist_count - 1)
	var root := _clear_screen()
	var frame_row := _hbox(0)
	frame_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(frame_row)
	var left_margin := Control.new()
	left_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_row.add_child(left_margin)
	var frame_height := maxf(490.0, size.y - 24.0)
	var frame := _preparation_panel(Vector2(maxf(760.0, size.x - 24.0), frame_height), true)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame_row.add_child(frame)
	var right_margin := Control.new()
	right_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame_row.add_child(right_margin)
	var inner := _vbox(5)
	frame.add_child(inner)
	var heading := _hbox(10)
	inner.add_child(heading)
	heading.add_child(_label(_prep_local("Prepare Carefully", "Özenle Hazırla", "Przygotuj starannie"), 21, CREAM))
	var head_fill := Control.new()
	head_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(head_fill)
	var limit_toggle := CheckButton.new()
	limit_toggle.text = _prep_local("Use point limits", "Puan sınırını kullan", "Włącz limit punktów")
	limit_toggle.button_pressed = point_limit_enabled
	limit_toggle.toggled.connect(func(enabled: bool): point_limit_enabled = enabled; _refresh_character_points())
	heading.add_child(limit_toggle)
	var points_fill := Control.new()
	points_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(points_fill)
	_character_points = _label("", 13, MUTED)
	heading.add_child(_character_points)
	var tabs := _hbox(0)
	inner.add_child(tabs)
	for tab_id in ["characters", "relationships", "equipment"]:
		var chosen_tab: String = tab_id
		var tab_name := _prep_local("Characters", "Karakterler", "Postacie") if tab_id == "characters" else _prep_local("Relationships", "İlişkiler", "Relacje") if tab_id == "relationships" else _prep_local("Equipment", "Ekipman", "Wyposażenie")
		var tab_button := _preparation_tab_button(tab_name, func(): _switch_preparation_tab(chosen_tab), tab_id == preparation_tab)
		for tab_state in ["normal", "hover", "pressed"]:
			var tab_style := tab_button.get_theme_stylebox(tab_state).duplicate() as StyleBoxFlat
			tab_style.corner_radius_top_left = 16
			tab_style.corner_radius_top_right = 16
			tab_style.corner_radius_bottom_left = 0
			tab_style.corner_radius_bottom_right = 0
			tab_button.add_theme_stylebox_override(tab_state, tab_style)
		tabs.add_child(tab_button)
	var tab_fill := Control.new()
	tab_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab_fill)
	var body_scroll := ScrollContainer.new()
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	inner.add_child(body_scroll)
	var body := _hbox(5)
	body.custom_minimum_size = Vector2(maxf(1176.0, minf(1320.0, size.x - 100.0)), maxf(370.0, frame_height - 130.0))
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
	var footer := _hbox(8)
	inner.add_child(footer)
	footer.add_child(_setup_button("←  " + _tr("common.back"), _return_to_world_from_characters, true, Vector2(120, 35)))
	var foot_fill := Control.new()
	foot_fill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(foot_fill)
	footer.add_child(_setup_button(_prep_local("Load preset", "Hazır ayar yükle", "Wczytaj zestaw"), _load_preparation_preset, true, Vector2(120, 35)))
	footer.add_child(_setup_button(_prep_local("Save preset", "Hazır ayar kaydet", "Zapisz zestaw"), _save_preparation_preset, true, Vector2(120, 35)))
	var foot_fill_right := Control.new()
	foot_fill_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(foot_fill_right)
	footer.add_child(_setup_button(_prep_local("Start", "Başlat", "Rozpocznij") + "  →", _advance_to_lobby, true, Vector2(145, 35)))


func _prep_local(en: String, tr: String, pl: String) -> String:
	return tr if preferences.language == "tr" else pl if preferences.language == "pl" else en


func _switch_preparation_tab(tab_id: String) -> void:
	_save_character_inputs()
	preparation_tab = tab_id
	_show_characters()


func _on_preparation_sex_changed() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	spec["hair_index"] = 0
	_show_characters()


func _hair_options_for_sex(sex: String) -> Array:
	if sex == "male":
		return [_prep_local("Short", "Kısa", "Krótkie"), _prep_local("Side part", "Yandan ayrık", "Z przedziałkiem"), _prep_local("Curly", "Kıvırcık", "Kręcone"), _prep_local("Shaved", "Kazınmış", "Wygolone")]
	return [_prep_local("Bob", "Küt", "Bob"), _prep_local("Wavy", "Dalgalı", "Falowane"), _prep_local("Long", "Uzun", "Długie"), _prep_local("Braid", "Örgü", "Warkocz")]


func _preparation_color_field(parent: VBoxContainer, title: String, initial_color: String, presets: Array, changed: Callable) -> ColorPickerButton:
	var row := _hbox(5)
	parent.add_child(row)
	var caption := _label(title, 11, MUTED)
	caption.custom_minimum_size.x = 75
	row.add_child(caption)
	var picker := ColorPickerButton.new()
	picker.custom_minimum_size = Vector2(132, 29)
	picker.color = Color(initial_color)
	picker.edit_alpha = false
	picker.tooltip_text = _prep_local("Choose any color", "İstediğin rengi seç", "Wybierz dowolny kolor")
	picker.color_changed.connect(func(_color: Color): changed.call())
	row.add_child(picker)
	var swatches := GridContainer.new()
	swatches.columns = 6
	swatches.add_theme_constant_override("h_separation", 3)
	swatches.add_theme_constant_override("v_separation", 3)
	parent.add_child(swatches)
	for hex_color in presets:
		var picked_color := Color(str(hex_color))
		var swatch := Button.new()
		swatch.custom_minimum_size = Vector2(22, 21)
		swatch.tooltip_text = str(hex_color)
		swatch.add_theme_stylebox_override("normal", _style(picked_color, Color("#53626a"), 1))
		swatch.add_theme_stylebox_override("hover", _style(picked_color.lightened(0.12), GOLD, 2))
		swatch.pressed.connect(func(): picker.color = picked_color; changed.call())
		swatches.add_child(swatch)
	return picker


func _preparation_roster(body: HBoxContainer) -> void:
	var panel := _preparation_panel(Vector2(195, 0))
	panel.name = "PreparationRoster"
	body.add_child(panel)
	var roster := _vbox(4)
	panel.add_child(roster)
	roster.add_child(_label(_prep_local("Colony", "Koloni", "Kolonia"), 18, CREAM))
	for i in colonist_count:
		var spec: Dictionary = character_specs[i]
		var index_copy := i
		var row := _hbox(3)
		roster.add_child(row)
		var portrait := PawnPortrait.new()
		portrait.custom_minimum_size = Vector2(39, 46)
		portrait.appearance = _spec_appearance(spec)
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(portrait)
		var button := _preparation_tab_button(str(spec.get("name", "Colonist")), func(): _select_character_editor(index_copy), i == _editing_character_index)
		button.custom_minimum_size = Vector2(128, 46)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 12)
		row.add_child(button)
		_roster_buttons.append(button)
	roster.add_child(HSeparator.new())
	roster.add_child(_label(_prep_local("Starting crew: %d" % colonist_count, "Başlangıç ekibi: %d" % colonist_count, "Załoga: %d" % colonist_count), 12, MUTED))
	roster.add_child(_spacer())


func _build_preparation_character(body: HBoxContainer) -> void:
	_preparation_roster(body)
	var old: Dictionary = character_specs[_editing_character_index]
	var editor := _vbox(5)
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(editor)
	var name_row := _hbox(5)
	editor.add_child(name_row)
	var random_button := _setup_button("⚄", _randomize_prepared_colonist, false, Vector2(34, 31))
	random_button.tooltip_text = _prep_local("Randomize this colonist", "Bu kolonisti rastgele oluştur", "Wylosuj tę postać")
	name_row.add_child(random_button)
	name_row.add_child(_label(_prep_local("Name", "Ad", "Imię"), 12, MUTED))
	var first_name_edit := LineEdit.new()
	first_name_edit.text = str(old.get("first_name", old.get("name", "Colonist")))
	first_name_edit.placeholder_text = _prep_local("First", "İlk ad", "Imię")
	first_name_edit.tooltip_text = _prep_local("First name", "İlk ad", "Imię")
	first_name_edit.custom_minimum_size = Vector2(90, 31)
	first_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(first_name_edit)
	var name_edit := LineEdit.new()
	name_edit.text = str(old.get("nickname", old.get("name", "Colonist")))
	name_edit.placeholder_text = _prep_local("Nickname", "Takma ad", "Pseudonim")
	name_edit.tooltip_text = _prep_local("Nickname shown above the colonist", "Kolonistin üzerinde görünen takma ad", "Pseudonim nad postacią")
	name_edit.custom_minimum_size = Vector2(90, 31)
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(name_edit)
	var last_name_edit := LineEdit.new()
	last_name_edit.text = str(old.get("last_name", ""))
	last_name_edit.placeholder_text = _prep_local("Last", "Soyad", "Nazwisko")
	last_name_edit.tooltip_text = _prep_local("Last name", "Soyad", "Nazwisko")
	last_name_edit.custom_minimum_size = Vector2(90, 31)
	last_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(last_name_edit)
	var compact_name_actions := size.x < 1300.0
	var load_character_button := _setup_button(_prep_local("Load", "Yükle", "Wczytaj") if compact_name_actions else _prep_local("Load character", "Karakter yükle", "Wczytaj postać"), _load_character_preset, true, Vector2(76 if compact_name_actions else 120, 31))
	load_character_button.tooltip_text = _prep_local("Load character", "Karakter yükle", "Wczytaj postać")
	name_row.add_child(load_character_button)
	var save_character_button := _setup_button(_prep_local("Save", "Kaydet", "Zapisz") if compact_name_actions else _prep_local("Save character", "Karakter kaydet", "Zapisz postać"), _save_character_preset, true, Vector2(76 if compact_name_actions else 120, 31))
	save_character_button.tooltip_text = _prep_local("Save character", "Karakter kaydet", "Zapisz postać")
	name_row.add_child(save_character_button)
	var columns := _hbox(5)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.add_child(columns)
	var appearance_panel := _preparation_panel(Vector2(248, 0))
	appearance_panel.name = "PreparationAppearance"
	appearance_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(appearance_panel)
	var appearance_fields := _vbox(5)
	appearance_panel.add_child(appearance_fields)
	appearance_fields.add_child(_label(_prep_local("Appearance", "Görünüş", "Wygląd"), 18, CREAM))
	var preview := PawnPreviewScript.new()
	appearance_fields.add_child(preview)
	preview.custom_minimum_size = Vector2(215, 188)
	preview.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var hair := _choice_field(appearance_fields, _tr("characters.hair"), _hair_options_for_sex(str(old.get("sex", "female"))), clampi(int(old.get("hair_index", 0)), 0, 3), _refresh_character_editor, 75, 135)
	var sex := _choice_field(appearance_fields, _prep_local("Biology", "Biyoloji", "Biologia"), [_prep_local("Female", "Kadın", "Kobieta"), _prep_local("Male", "Erkek", "Mężczyzna")], 0 if str(old.get("sex", "female")) == "female" else 1, _on_preparation_sex_changed, 75, 135)
	(sex["row"] as Control).tooltip_text = _prep_local("Biological sex in this colonist's record.", "Kolonistin kaydındaki biyolojik cinsiyet.", "Płeć biologiczna w karcie kolonisty.")
	var body_type := _choice_field(appearance_fields, _prep_local("Body", "Gövde", "Sylwetka"), [_prep_local("Type 1", "Tip 1", "Typ 1"), _prep_local("Type 2", "Tip 2", "Typ 2")], clampi(int(old.get("body_type", 0)), 0, 1), _refresh_character_editor, 75, 135)
	var head_type := _choice_field(appearance_fields, _prep_local("Head", "Kafa", "Głowa"), [_prep_local("Type 1", "Tip 1", "Typ 1"), _prep_local("Type 2", "Tip 2", "Typ 2")], clampi(int(old.get("head_type", 0)), 0, 1), _refresh_character_editor, 75, 135)
	var hair_color := _preparation_color_field(appearance_fields, _tr("characters.hair_color"), str(old.get("hair_color", HAIR_COLOR_OPTIONS[clampi(int(old.get("hair_color_index", 1)), 0, HAIR_COLOR_OPTIONS.size() - 1)])), HAIR_COLOR_OPTIONS, _refresh_character_editor)
	var skin := _preparation_color_field(appearance_fields, _tr("characters.skin"), str(old.get("skin_color", SKIN_OPTIONS[clampi(int(old.get("skin_index", 0)), 0, SKIN_OPTIONS.size() - 1)])), SKIN_OPTIONS, _refresh_character_editor)
	var kit_panel := _preparation_panel(Vector2(216, 0))
	kit_panel.name = "PreparationApparel"
	kit_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(kit_panel)
	var kit := _vbox(7)
	kit_panel.add_child(kit)
	kit.add_child(_label(_prep_local("Apparel", "Giysiler", "Odzież"), 18, CREAM))
	var equipped_gear: Dictionary = old.get("starting_gear", {})
	for garment in [{"slot": "shirt", "id": "tshirt", "color": "shirt_color"}, {"slot": "pants", "id": "pants", "color": "pants_color"}, {"slot": "apparel", "id": "jacket", "color": "apparel_color"}]:
		var garment_row := _hbox(7)
		kit.add_child(garment_row)
		var garment_id := str(garment["id"])
		var default_item := "clothes" if str(garment["slot"]) == "apparel" else garment_id
		var worn := str(equipped_gear.get(str(garment["slot"]), default_item)) == garment_id
		var icon := ApparelIconScript.new()
		icon.item_id = garment_id
		icon.tint = Color(str(equipped_gear.get(str(garment["color"]), "#735f50" if garment_id == "jacket" else "#78928b"))) if worn else Color("#737777")
		garment_row.add_child(icon)
		var garment_label := _label(_cargo_label(garment_id) if worn else _prep_local("None", "Yok", "Brak"), 13)
		garment_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		garment_row.add_child(garment_label)
		_preparation_inline_color(garment_row, str(garment["color"]), str(equipped_gear.get(str(garment["color"]), "#735f50" if garment_id == "jacket" else "#78928b")), preview)
		var garment_slot := str(garment["slot"])
		var apparel_choice := MenuButton.new()
		apparel_choice.text = _prep_local("Change", "Değiştir", "Zmień")
		apparel_choice.custom_minimum_size = Vector2(68, 29)
		for menu_state in ["normal", "hover", "pressed"]:
			apparel_choice.add_theme_stylebox_override(menu_state, _style(Color("#343638") if menu_state == "normal" else Color("#484a4c"), Color("#626365"), 2))
		var choice_popup := apparel_choice.get_popup()
		choice_popup.add_item(_prep_local("Wear", "Giy", "Załóż"), 0)
		choice_popup.add_item(_prep_local("Remove", "Çıkar", "Zdejmij"), 1)
		choice_popup.id_pressed.connect(func(choice_id: int): _set_starting_gear(garment_slot, garment_id if choice_id == 0 else "none"))
		garment_row.add_child(apparel_choice)
	var weapon_row := _hbox(5)
	kit.add_child(weapon_row)
	weapon_row.add_child(_label(_prep_local("Weapon", "Silah", "Broń"), 12, MUTED))
	var weapon_choice := MenuButton.new()
	weapon_choice.text = _cargo_label("spear") if str(equipped_gear.get("weapon", "fists")) == "spear" else _prep_local("Unarmed", "Silahsız", "Bez broni")
	weapon_choice.custom_minimum_size = Vector2(130, 29)
	for menu_state in ["normal", "hover", "pressed"]:
		weapon_choice.add_theme_stylebox_override(menu_state, _style(Color("#343638") if menu_state == "normal" else Color("#484a4c"), Color("#626365"), 2))
	weapon_choice.get_popup().add_item(_prep_local("Unarmed", "Silahsız", "Bez broni"), 0)
	weapon_choice.get_popup().add_item(_cargo_label("spear"), 1)
	weapon_choice.get_popup().id_pressed.connect(func(choice_id: int): _set_starting_gear("weapon", "spear" if choice_id == 1 else "fists"))
	weapon_row.add_child(weapon_choice)
	kit.add_child(HSeparator.new())
	kit.add_child(_label(_prep_local("Possessions", "Başlangıç yükü", "Zapasy"), 18, CREAM))
	var cargo: Dictionary = starting_cargo if not starting_cargo.is_empty() else SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {})
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "tshirt", "pants", "jacket"]:
		var count := int(cargo.get(item_id, 0))
		if count > 0:
			var cargo_row := _hbox(4)
			kit.add_child(cargo_row)
			cargo_row.add_child(_label(_cargo_label(item_id), 12, CREAM))
			var cargo_spacer := Control.new()
			cargo_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cargo_row.add_child(cargo_spacer)
			cargo_row.add_child(_label(str(count), 12, MUTED))
	kit.add_child(HSeparator.new())
	kit.add_child(_label(_prep_local("Titles", "Unvanlar", "Tytuły"), 18, CREAM))
	kit.add_child(_label(_prep_local("None", "Yok", "Brak"), 12, MUTED))
	kit.add_child(HSeparator.new())
	kit.add_child(_label(_prep_local("Abilities", "Yetenekler", "Zdolności"), 18, CREAM))
	kit.add_child(_label(_prep_local("None", "Yok", "Brak"), 12, MUTED))
	var biography_stack := _vbox(7)
	biography_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(biography_stack)
	var history_panel := _preparation_panel(Vector2(282, 0))
	history_panel.name = "PreparationBackstory"
	history_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	biography_stack.add_child(history_panel)
	var history := _vbox(6)
	history_panel.add_child(history)
	history.add_child(_label(_prep_local("Age", "Yaş", "Wiek"), 18, CREAM))
	var age_row := _hbox(5)
	history.add_child(age_row)
	age_row.add_child(_label(_prep_local("Biological", "Biyolojik", "Biologiczny"), 12, MUTED))
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
	age_row.add_child(_label(_prep_local("years", "yıl", "lat"), 11, MUTED))
	var chronological_row := _hbox(5)
	history.add_child(chronological_row)
	chronological_row.add_child(_label(_prep_local("Chronological", "Kronolojik", "Chronologiczny"), 12, MUTED))
	var chronological_age := SpinBox.new()
	chronological_age.min_value = 18
	chronological_age.max_value = 1200
	chronological_age.value = int(old.get("chronological_age", old.get("age", 25)))
	chronological_age.custom_minimum_size = Vector2(82, 29)
	chronological_age.value_changed.connect(func(_value: float): _refresh_character_editor())
	chronological_row.add_child(chronological_age)
	history.add_child(HSeparator.new())
	history.add_child(_label(_prep_local("Backstory", "Geçmiş", "Przeszłość"), 18, CREAM))
	var childhood_ids := ["rural_child", "town_child", "apprentice"]
	var adulthood_ids := ["farmer", "builder", "medic", "scholar"]
	var childhood := _choice_field(history, _prep_local("Childhood", "Çocukluk", "Dzieciństwo"), [_prep_local("Rural child", "Köy çocuğu", "Dziecko ze wsi"), _prep_local("Town child", "Kasaba çocuğu", "Dziecko z miasta"), _prep_local("Apprentice", "Çırak", "Uczeń")], maxi(0, childhood_ids.find(str(old.get("childhood", "rural_child")))), _refresh_character_editor, 95, 154)
	var adulthood := _choice_field(history, _prep_local("Adulthood", "Yetişkinlik", "Dorosłość"), [_prep_local("Farmer", "Çiftçi", "Rolnik"), _prep_local("Builder", "İnşaatçı", "Budowniczy"), _prep_local("Medic", "Sağlıkçı", "Medyk"), _prep_local("Scholar", "Araştırmacı", "Badacz")], maxi(0, adulthood_ids.find(str(old.get("adulthood", "farmer")))), _refresh_character_editor, 95, 154)
	var favorite_color := _preparation_color_field(history, _prep_local("Favorite", "Sevdiği renk", "Ulubiony"), str(old.get("favorite_color", "#8d985d")), OUTFIT_OPTIONS, _refresh_character_editor)
	var childhood_note := _setup_copy("", 12, MUTED)
	history.add_child(childhood_note)
	childhood_note.visible = false
	var adulthood_note := _setup_copy("", 12, MUTED)
	history.add_child(adulthood_note)
	adulthood_note.visible = false
	var traits_panel := _preparation_panel(Vector2(282, 0))
	traits_panel.name = "PreparationTraitsHealth"
	traits_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	biography_stack.add_child(traits_panel)
	var traits_column := _vbox(6)
	traits_panel.add_child(traits_column)
	traits_column.add_child(_label(_prep_local("Traits", "Özellikler", "Cechy"), 18, CREAM))
	var old_traits: Array = old.get("trait_ids", [TRAIT_IDS[clampi(int(old.get("trait_index", 0)) + 1, 1, TRAIT_IDS.size() - 1)]])
	var trait_fields := _preparation_choice_chips(traits_column, TRAIT_IDS, _preparation_trait_names(), old_traits,
		_prep_local("Add trait", "Özellik ekle", "Dodaj cechę"))
	traits_column.add_child(HSeparator.new())
	traits_column.add_child(_label(_tr("characters.health"), 18, CREAM))
	var old_conditions: Array = old.get("condition_ids", [])
	var condition_fields := _preparation_choice_chips(traits_column, CONDITION_IDS, _preparation_condition_names(), old_conditions,
		_prep_local("Add condition", "Sağlık durumu ekle", "Dodaj schorzenie"))
	var skill_panel := _preparation_panel(Vector2(215, 0))
	skill_panel.name = "PreparationSkills"
	skill_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(skill_panel)
	var skill_column := _vbox(5)
	skill_panel.add_child(skill_column)
	skill_column.add_child(_label(_prep_local("Skills", "Beceriler", "Umiejętności"), 18, CREAM))
	var skill_fields: Dictionary = {}
	var skill_bars: Dictionary = {}
	var old_skills: Dictionary = old.get("skills", {})
	var old_passions: Dictionary = old.get("passions", {})
	for skill in SKILL_IDS:
		var saved_level := clampi(int(old_skills.get(skill, 5)), 0, 10)
		var level := _preparation_skill_field(skill_column, _localized_skill(str(skill)), saved_level, _refresh_character_editor, int(old_passions.get(skill, 0)))
		skill_fields[skill] = level
		skill_bars[skill] = level.meter
	skill_column.add_child(HSeparator.new())
	skill_column.add_child(_label(_prep_local("INCAPABLE OF", "YAPAMADIĞI İŞLER", "NIEZDOLNOŚCI"), 13, GOLD))
	var incapable := _label(_prep_local("None", "Yok", "Brak"), 12, MUTED)
	skill_column.add_child(incapable)
	_character_inputs.append({"index": _editing_character_index, "name": name_edit, "first_name": first_name_edit, "last_name": last_name_edit, "age": age, "chronological_age": chronological_age, "favorite_color": favorite_color, "childhood": childhood, "adulthood": adulthood, "childhood_note": childhood_note, "adulthood_note": adulthood_note, "sex": sex, "body_type": body_type, "head_type": head_type, "hair": hair, "hair_color": hair_color, "skin": skin, "traits": trait_fields, "conditions": condition_fields, "skills": skill_fields, "skill_bars": skill_bars, "preview": preview})
	name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	first_name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	last_name_edit.text_changed.connect(func(_text: String): _refresh_character_editor())
	_refresh_character_editor()


func _localized_skill(skill: String) -> String:
	match skill:
		"chop": return _prep_local("Chop", "Odunculuk", "Wycinka")
		"mine": return _prep_local("Mine", "Madencilik", "Górnictwo")
		"harvest": return _prep_local("Harvest", "Hasat", "Zbiory")
		"haul": return _prep_local("Haul", "Taşıma", "Transport")
		"build": return _prep_local("Build", "İnşa", "Budowa")
		"research": return _prep_local("Research", "Araştırma", "Badania")
		"treat": return _prep_local("Treat", "Tedavi", "Leczenie")
		"combat": return _prep_local("Combat", "Savaş", "Walka")
		_: return skill.capitalize()


func _spec_appearance(spec: Dictionary) -> Dictionary:
	var sex := str(spec.get("sex", "female"))
	var gear: Dictionary = spec.get("starting_gear", {})
	var hair_ids := MALE_HAIR_IDS if sex == "male" else FEMALE_HAIR_IDS
	return {"sex": sex, "body_type": clampi(int(spec.get("body_type", 0)), 0, 1),
		"head_type": clampi(int(spec.get("head_type", 0)), 0, 1),
		"hair": hair_ids[clampi(int(spec.get("hair_index", 0)), 0, 3)],
		"hair_color": str(spec.get("hair_color", HAIR_COLOR_OPTIONS[clampi(int(spec.get("hair_color_index", 1)), 0, HAIR_COLOR_OPTIONS.size() - 1)])),
		"skin": str(spec.get("skin_color", SKIN_OPTIONS[clampi(int(spec.get("skin_index", 0)), 0, SKIN_OPTIONS.size() - 1)])),
		"apparel": str(gear.get("apparel", "clothes")),
		"apparel_color": str(gear.get("apparel_color", "#735f50")),
		"shirt": str(gear.get("shirt", "tshirt" if str(gear.get("apparel", "clothes")) != "none" else "none")),
		"pants": str(gear.get("pants", "pants" if str(gear.get("apparel", "clothes")) != "none" else "none")),
		"shirt_color": str(gear.get("shirt_color", OUTFIT_OPTIONS[clampi(int(spec.get("outfit_index", 0)), 0, OUTFIT_OPTIONS.size() - 1)])),
		"pants_color": str(gear.get("pants_color", "#5f6768"))}


func _build_preparation_relationships(body: HBoxContainer) -> void:
	var panel := _preparation_panel(Vector2.ZERO)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(panel)
	var content := _vbox(6)
	panel.add_child(content)
	content.add_child(_label(_prep_local("Parent/Child Relationships", "Ebeveyn ve çocuk ilişkileri", "Relacje rodzinne"), 18, CREAM))
	var graph := FamilyGraph.new()
	graph.name = "PreparationFamilyGraph"
	graph.custom_minimum_size = Vector2(1260, 250)
	content.add_child(graph)
	_build_preparation_family_graph(graph)
	var family_links := PackedStringArray()
	for first_index in range(colonist_count):
		for second_index in range(first_index + 1, colonist_count):
			var relationships: Dictionary = character_specs[first_index].get("starting_relationships", {})
			var relation := str(relationships.get(str(second_index), "none"))
			if relation in ["parent", "child", "sibling"]:
				var first_name := str(character_specs[first_index].get("name", "Colonist"))
				var second_name := str(character_specs[second_index].get("name", "Colonist"))
				var family_word := _prep_local("parent of", "ebeveyni", "rodzic") if relation == "parent" else _prep_local("child of", "çocuğu", "dziecko") if relation == "child" else _prep_local("sibling of", "kardeşi", "rodzeństwo")
				family_links.append("%s  →  %s  %s" % [first_name, family_word, second_name])
	content.add_child(_label("    ·    ".join(family_links) if not family_links.is_empty() else _prep_local("No family ties yet.", "Henüz aile bağı yok.", "Brak więzi rodzinnych."), 12, MUTED))
	content.add_child(HSeparator.new())
	content.add_child(_label(_prep_local("Other Relationships", "Diğer ilişkiler", "Pozostałe relacje"), 18, CREAM))
	if colonist_count < 2:
		content.add_child(_label(_prep_local("A second colonist is needed to create a relationship.", "İlişki kurmak için ikinci bir kolonist gerekir.", "Do utworzenia relacji potrzeba drugiego kolonisty."), 15))
	var pair_grid := GridContainer.new()
	pair_grid.columns = 3 if size.x >= 1360.0 else 2 if size.x >= 1100.0 else 1
	pair_grid.add_theme_constant_override("h_separation", 8)
	pair_grid.add_theme_constant_override("v_separation", 8)
	content.add_child(pair_grid)
	for i in range(colonist_count):
		for j in range(i + 1, colonist_count):
			var first: Dictionary = character_specs[i]
			var second: Dictionary = character_specs[j]
			var row_panel := _preparation_panel(Vector2(0, 64))
			row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			pair_grid.add_child(row_panel)
			var row := _hbox(4)
			row_panel.add_child(row)
			var first_portrait := PawnPortrait.new()
			first_portrait.custom_minimum_size = Vector2(34, 42)
			first_portrait.appearance = _spec_appearance(first)
			row.add_child(first_portrait)
			var pair_label := _label("%s  ↔  %s" % [str(first.get("name", "Colonist")), str(second.get("name", "Colonist"))], 13)
			pair_label.custom_minimum_size = Vector2(106, 0)
			pair_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(pair_label)
			var second_portrait := PawnPortrait.new()
			second_portrait.custom_minimum_size = Vector2(34, 42)
			second_portrait.appearance = _spec_appearance(second)
			row.add_child(second_portrait)
			var relation_ids := ["none", "friend", "rival", "partner", "parent", "child", "sibling"]
			var known: Dictionary = first.get("starting_relationships", {})
			var first_index := i
			var second_index := j
			var relation_picker := OptionButton.new()
			relation_picker.custom_minimum_size = Vector2(125, 30)
			for label_text in [_prep_local("None", "Yok", "Brak"), _prep_local("Friends", "Arkadaş", "Przyjaciele"), _prep_local("Rivals", "Rakip", "Rywale"), _prep_local("Partners", "Partner", "Partnerzy"), _prep_local("Parent of", "Ebeveyni", "Rodzic"), _prep_local("Child of", "Çocuğu", "Dziecko"), _prep_local("Siblings", "Kardeş", "Rodzeństwo")]:
				relation_picker.add_item(label_text)
			relation_picker.select(maxi(0, relation_ids.find(str(known.get(str(j), "none")))))
			relation_picker.item_selected.connect(func(choice_index: int):
				_set_starting_relation(first_index, second_index, relation_ids[choice_index])
				_show_characters())
			row.add_child(relation_picker)
	content.add_child(_label(_prep_local("Each choice applies to both colonists. Parent and child links also appear in the family area above.", "Her seçim iki kolonist için geçerlidir. Ebeveyn ve çocuk bağları yukarıdaki aile alanında da görünür.", "Każdy wybór dotyczy obu postaci. Więzi rodzinne są pokazane powyżej."), 12, MUTED))


func _set_starting_relation(first_index: int, second_index: int, relation_id: String) -> void:
	var spec: Dictionary = character_specs[first_index].duplicate(true)
	var relationships: Dictionary = spec.get("starting_relationships", {})
	if relation_id == "none":
		relationships.erase(str(second_index))
	else:
		relationships[str(second_index)] = relation_id
	spec["starting_relationships"] = relationships
	character_specs[first_index] = spec


func _preparation_family_relation(first_index: int, second_index: int) -> String:
	if first_index == second_index:
		return "none"
	var lower := mini(first_index, second_index)
	var higher := maxi(first_index, second_index)
	var known: Dictionary = character_specs[lower].get("starting_relationships", {})
	var relation := str(known.get(str(higher), "none"))
	if first_index > second_index:
		if relation == "parent":
			return "child"
		if relation == "child":
			return "parent"
	return relation


func _preparation_family_components() -> Array:
	var components: Array = []
	var seen: Dictionary = {}
	for person_index in range(colonist_count):
		if seen.has(person_index):
			continue
		var members: Array = [person_index]
		seen[person_index] = true
		var cursor := 0
		while cursor < members.size():
			var current := int(members[cursor])
			cursor += 1
			for other_index in range(colonist_count):
				if seen.has(other_index):
					continue
				if _preparation_family_relation(current, other_index) in ["parent", "child", "sibling"]:
					seen[other_index] = true
					members.append(other_index)
		components.append(members)
	return components


func _preparation_family_person_card(graph: FamilyGraph, position: Vector2, person_index: int) -> void:
	var spec: Dictionary = character_specs[person_index]
	var card := PanelContainer.new()
	card.position = position
	card.custom_minimum_size = Vector2(110, 94)
	card.size = Vector2(110, 94)
	var style := _style(Color("#343537"), Color("#57595a"), 1)
	style.set_content_margin_all(3)
	card.add_theme_stylebox_override("panel", style)
	graph.add_child(card)
	var content := _vbox(0)
	card.add_child(content)
	var portrait := PawnPortrait.new()
	portrait.custom_minimum_size = Vector2(45, 50)
	portrait.appearance = _spec_appearance(spec)
	content.add_child(portrait)
	var name_label := _label(str(spec.get("name", "Colonist")), 12, CREAM)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(name_label)
	var role := _display_background(str(spec.get("adulthood", "farmer")))
	var role_label := _label(role, 10, MUTED)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(role_label)


func _preparation_family_add_slot(graph: FamilyGraph, position: Vector2, anchor_index: int, slot_role: String) -> void:
	var add := MenuButton.new()
	add.position = position
	add.custom_minimum_size = Vector2(110, 94)
	add.size = Vector2(110, 94)
	add.flat = false
	add.text = "+\n" + (_prep_local("Add parent", "Ebeveyn ekle", "Dodaj rodzica") if slot_role == "parent" else _prep_local("Add bond", "Bağ ekle", "Dodaj więź"))
	add.add_theme_font_size_override("font_size", 12)
	add.add_theme_color_override("font_color", MUTED)
	for state in ["normal", "hover", "pressed"]:
		var style := _style(Color("#2c2d2f") if state == "normal" else Color("#383a3b"), Color("#555759"), 1)
		style.set_content_margin_all(3)
		add.add_theme_stylebox_override(state, style)
	graph.add_child(add)
	var actions: Array = []
	var popup := add.get_popup()
	for other_index in range(colonist_count):
		if other_index == anchor_index or _preparation_family_relation(anchor_index, other_index) in ["parent", "child", "sibling"]:
			continue
		var other_name := str(character_specs[other_index].get("name", "Colonist"))
		var roles := ["parent"] if slot_role == "parent" else ["child", "sibling"]
		for role in roles:
			var relation_from_anchor := "child" if role == "parent" else "parent" if role == "child" else "sibling"
			var relation_label := _prep_local("parent", "ebeveyn", "rodzic") if role == "parent" else _prep_local("child", "çocuk", "dziecko") if role == "child" else _prep_local("sibling", "kardeş", "rodzeństwo")
			popup.add_item(_prep_local("%s as %s", "%s: %s", "%s jako %s") % [other_name, relation_label], actions.size())
			actions.append({"other": other_index, "relation": relation_from_anchor})
	if actions.is_empty():
		popup.add_item(_prep_local("No available colonist", "Uygun kolonist yok", "Brak dostępnej postaci"))
		popup.set_item_disabled(0, true)
	else:
		popup.id_pressed.connect(func(id: int):
			var action: Dictionary = actions[id]
			var other := int(action["other"])
			var relation := str(action["relation"])
			var lower := mini(anchor_index, other)
			var higher := maxi(anchor_index, other)
			if anchor_index > other:
				if relation == "parent": relation = "child"
				elif relation == "child": relation = "parent"
			_set_starting_relation(lower, higher, relation)
			_show_characters())


func _build_preparation_family_graph(graph: FamilyGraph) -> void:
	var components := _preparation_family_components()
	for component_index in range(components.size()):
		var members: Array = components[component_index]
		var cluster_x := float(component_index * 420)
		graph.clusters.append(Rect2(cluster_x, 0, 410, 245))
		var parents: Array = []
		for member in members:
			for other in members:
				if _preparation_family_relation(int(member), int(other)) == "parent" and not parents.has(member):
					parents.append(member)
		var top: Array = []
		var bottom: Array = []
		if parents.is_empty() and members.size() == 1:
			top.append(members[0])
		elif parents.is_empty():
			bottom = members.duplicate()
		else:
			for member in parents:
				if top.size() < 2:
					top.append(member)
			for member in members:
				if not top.has(member):
					bottom.append(member)
			if bottom.is_empty():
				bottom.append(top.pop_back())
		var positions: Dictionary = {}
		for slot in range(mini(2, top.size())):
			var person_index := int(top[slot])
			var position := Vector2(cluster_x + 62.0 + 140.0 * slot, 12)
			positions[person_index] = position
			_preparation_family_person_card(graph, position, person_index)
		for slot in range(mini(2, bottom.size())):
			var person_index := int(bottom[slot])
			var position := Vector2(cluster_x + 62.0 + 140.0 * slot, 142)
			positions[person_index] = position
			_preparation_family_person_card(graph, position, person_index)
		for first in members:
			for second in members:
				if int(first) >= int(second):
					continue
				var relation := _preparation_family_relation(int(first), int(second))
				if relation not in ["parent", "child", "sibling"] or not positions.has(first) or not positions.has(second):
					continue
				if relation == "sibling":
					var a: Vector2 = positions[first]
					var b: Vector2 = positions[second]
					if a.x > b.x:
						var swap := a
						a = b
						b = swap
					graph.edges.append({"start": a + Vector2(110, 47), "finish": b + Vector2(0, 47), "active": true, "kind": "sibling"})
				else:
					var parent_index := int(first) if relation == "parent" else int(second)
					var child_index := int(second) if relation == "parent" else int(first)
					graph.edges.append({"start": (positions[parent_index] as Vector2) + Vector2(55, 94), "finish": (positions[child_index] as Vector2) + Vector2(55, 0), "active": true})
		for slot in range(top.size(), 2):
			var position := Vector2(cluster_x + 62.0 + 140.0 * slot, 12)
			var anchor := int(bottom[0]) if not bottom.is_empty() else int(members[0])
			_preparation_family_add_slot(graph, position, anchor, "parent")
			if not bottom.is_empty():
				graph.edges.append({"start": position + Vector2(55, 94), "finish": (positions[bottom[0]] as Vector2) + Vector2(55, 0), "active": false})
		for slot in range(bottom.size(), 2):
			var position := Vector2(cluster_x + 62.0 + 140.0 * slot, 142)
			var anchor := int(top[0]) if not top.is_empty() else int(members[0])
			_preparation_family_add_slot(graph, position, anchor, "child")
			if not top.is_empty():
				graph.edges.append({"start": (positions[top[0]] as Vector2) + Vector2(55, 94), "finish": position + Vector2(55, 0), "active": false})
	graph.queue_redraw()


func _build_preparation_equipment(body: HBoxContainer) -> void:
	var gear_columns: BoxContainer = _hbox(5)
	gear_columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(gear_columns)
	if starting_cargo.is_empty():
		starting_cargo = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("inventory", {}).duplicate(true)
	var available_panel := _preparation_panel(Vector2(500, 0))
	available_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gear_columns.add_child(available_panel)
	var available := _vbox(4)
	available_panel.add_child(available)
	available.add_child(_label(_prep_local("Equipment catalog", "Ekipman kataloğu", "Katalog wyposażenia"), 18, CREAM))
	var category := OptionButton.new()
	for category_label in [
		_prep_local("All items", "Tüm eşyalar", "Wszystkie przedmioty"),
		_prep_local("Resources", "Kaynaklar", "Surowce"),
		_prep_local("Apparel", "Giysiler", "Odzież"),
		_prep_local("Weapons", "Silahlar", "Broń")
	]: category.add_item(category_label)
	category.custom_minimum_size.y = 29
	available.add_child(category)
	var search := LineEdit.new()
	search.placeholder_text = _prep_local("Search items...", "Eşya ara...", "Szukaj przedmiotów...")
	search.text = _cargo_search_text
	available.add_child(search)
	available.add_child(HSeparator.new())
	var available_rows: Dictionary = {}
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "tshirt", "pants", "jacket"]:
		var chosen_id: String = item_id
		var available_row := _hbox(5)
		available.add_child(available_row)
		if chosen_id in ["tshirt", "pants", "jacket"]:
			var icon := ApparelIconScript.new()
			icon.item_id = chosen_id
			icon.tint = Color("#78928b" if chosen_id == "tshirt" else "#5f6768" if chosen_id == "pants" else "#735f50")
			available_row.add_child(icon)
		var button := _preparation_tab_button("+  %s" % _cargo_label(chosen_id), func(): _adjust_starting_cargo(chosen_id, 1), false)
		button.custom_minimum_size.y = 30
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		available_row.add_child(button)
		available_rows[chosen_id] = available_row
		available_row.visible = _equipment_item_visible(chosen_id, _cargo_search_text, category.selected)
	search.text_changed.connect(func(value: String):
		_cargo_search_text = value
		for id in available_rows.keys():
			(available_rows[id] as Control).visible = _equipment_item_visible(str(id), value, category.selected))
	category.item_selected.connect(func(_index: int):
		for id in available_rows.keys():
			(available_rows[id] as Control).visible = _equipment_item_visible(str(id), search.text, category.selected))
	var selected_panel := _preparation_panel(Vector2(500, 0))
	selected_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gear_columns.add_child(selected_panel)
	var selected := _vbox(2)
	selected_panel.add_child(selected)
	selected.add_child(_label(_prep_local("Start with", "Başlangıç yükü", "Ładunek początkowy"), 18, CREAM))
	selected.add_child(HSeparator.new())
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "tshirt", "pants", "jacket"]:
		var chosen_id: String = item_id
		var row := _hbox(5)
		selected.add_child(row)
		if chosen_id in ["tshirt", "pants", "jacket"]:
			var icon := ApparelIconScript.new()
			icon.item_id = chosen_id
			icon.tint = Color("#78928b" if chosen_id == "tshirt" else "#5f6768" if chosen_id == "pants" else "#735f50")
			row.add_child(icon)
		var item_label := _label(_cargo_label(chosen_id), 13)
		item_label.custom_minimum_size.x = 132 if chosen_id in ["tshirt", "pants", "jacket"] else 180
		row.add_child(item_label)
		var count := SpinBox.new()
		count.min_value = 0
		count.max_value = 999
		count.step = 1
		count.value = int(starting_cargo.get(chosen_id, 0))
		count.custom_minimum_size = Vector2(82, 27)
		count.value_changed.connect(func(value: float): starting_cargo[chosen_id] = int(value))
		row.add_child(count)
		row.add_child(_setup_button("−10", func(): count.value = maxi(0, int(count.value) - 10), false, Vector2(45, 27)))
		row.add_child(_setup_button("+10", func(): count.value = mini(999, int(count.value) + 10), false, Vector2(45, 27)))
	selected.add_child(_spacer())
	var remove_all := _setup_button(_prep_local("Remove all", "Tümünü kaldır", "Usuń wszystko"), _clear_starting_cargo, true, Vector2(150, 32))
	remove_all.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	selected.add_child(remove_all)


func _equipment_item_visible(item_id: String, search_text: String, category: int) -> bool:
	if not search_text.is_empty() and not _cargo_label(item_id).to_lower().contains(search_text.to_lower()):
		return false
	match category:
		1: return item_id in ["wood", "stone", "food", "medicine", "silver"]
		2: return item_id in ["tshirt", "pants", "jacket"]
		3: return item_id == "spear"
		_: return true


func _clear_starting_cargo() -> void:
	for item_id in ["wood", "stone", "food", "medicine", "silver", "spear", "tshirt", "pants", "jacket"]:
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
		"jacket": return _prep_local("Jacket", "Ceket", "Kurtka")
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
		_: return trait_id.replace("_", " ").capitalize()


func _display_background(background_id: String) -> String:
	match background_id:
		"rural_child": return _prep_local("Rural child", "Köy çocuğu", "Dziecko ze wsi")
		"town_child": return _prep_local("Town child", "Kasaba çocuğu", "Dziecko z miasta")
		"apprentice": return _prep_local("Apprentice", "Çırak", "Uczeń")
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
	starting_cargo[item_id] = clampi(int(starting_cargo.get(item_id, 0)) + delta, 0, 999)
	_show_characters()


func _set_starting_gear(slot_id: String, item_id: String) -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var gear: Dictionary = spec.get("starting_gear", {"weapon": "fists", "shirt": "tshirt", "pants": "pants"})
	gear[slot_id] = item_id
	spec["starting_gear"] = gear
	character_specs[_editing_character_index] = spec
	_show_characters()


func _randomize_prepared_colonist() -> void:
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index].duplicate(true)
	var names := ["Robin", "Mara", "Elin", "Soren", "Iris", "Tomas", "Nadia", "Leon"]
	spec["name"] = names[randi() % names.size()]
	spec["first_name"] = spec["name"]
	spec["nickname"] = spec["name"]
	spec["last_name"] = ""
	spec["sex"] = "female" if randi() % 2 == 0 else "male"
	spec["body_type"] = randi() % 2
	spec["head_type"] = randi() % 2
	spec["age"] = randi_range(19, 61)
	spec["chronological_age"] = spec["age"]
	spec["favorite_color"] = OUTFIT_OPTIONS[randi() % OUTFIT_OPTIONS.size()]
	spec["hair_index"] = randi() % 4
	spec["hair_color"] = HAIR_COLOR_OPTIONS[randi() % HAIR_COLOR_OPTIONS.size()]
	spec["skin_color"] = SKIN_OPTIONS[randi() % SKIN_OPTIONS.size()]
	var randomized_gear: Dictionary = spec.get("starting_gear", {}).duplicate(true)
	randomized_gear["shirt_color"] = OUTFIT_OPTIONS[randi() % OUTFIT_OPTIONS.size()]
	spec["starting_gear"] = randomized_gear
	spec["childhood"] = ["rural_child", "town_child", "apprentice"][randi() % 3]
	spec["adulthood"] = ["farmer", "builder", "medic", "scholar"][randi() % 4]
	spec["trait_ids"] = [["hardworking"], ["calm", "curious"], ["quick", "kind"], ["night_owl", "timid"]][randi() % 4].duplicate()
	spec["condition_ids"] = []
	var randomized_skills: Dictionary = {}
	for skill in SKILL_IDS: randomized_skills[skill] = randi_range(2, 5)
	spec["skills"] = randomized_skills
	var randomized_passions: Dictionary = {}
	for skill in SKILL_IDS: randomized_passions[skill] = randi() % 3
	spec["passions"] = randomized_passions
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
	colonist_count = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id).get("colonist_count", 3))
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


func _preparation_choice_chips(parent: Control, ids: Array, names: Array, selected_ids: Array, add_caption: String) -> Array:
	var states: Array = []
	for slot in range(3):
		var selected_id := str(selected_ids[slot]) if slot < selected_ids.size() else ""
		states.append({"index": maxi(0, ids.find(selected_id))})
	var selected_count := 0
	for slot in range(states.size()):
		var choice_index := int(states[slot]["index"])
		if choice_index == 0:
			continue
		selected_count += 1
		var chip_row := _hbox(4)
		parent.add_child(chip_row)
		var chip := _preparation_option([], 180)
		for candidate in range(1, ids.size()):
			if candidate != choice_index and _preparation_index_taken(states, candidate):
				continue
			chip.add_item(str(names[candidate]), candidate)
		for item_index in range(chip.item_count):
			if chip.get_item_id(item_index) == choice_index:
				chip.select(item_index)
				break
		var target_slot := slot
		chip.item_selected.connect(func(item_index: int):
			states[target_slot]["index"] = chip.get_item_id(item_index)
			_save_character_inputs()
			_show_characters())
		chip_row.add_child(chip)
		var remove := _setup_button("×", func():
			states[target_slot]["index"] = 0
			_save_character_inputs()
			_show_characters(), false, Vector2(30, 28))
		remove.tooltip_text = _prep_local("Remove", "Kaldır", "Usuń")
		chip_row.add_child(remove)
	if selected_count < 3:
		var add_choice := _preparation_option(["+  " + add_caption], 180)
		var empty_slot := -1
		for slot in range(states.size()):
			if int(states[slot]["index"]) == 0:
				empty_slot = slot
				break
		for candidate in range(1, ids.size()):
			if not _preparation_index_taken(states, candidate):
				add_choice.add_item(str(names[candidate]), candidate)
		var target_slot := empty_slot
		add_choice.item_selected.connect(func(item_index: int):
			var selected_index := add_choice.get_item_id(item_index)
			if selected_index == 0:
				return
			states[target_slot]["index"] = selected_index
			_save_character_inputs()
			_show_characters())
		parent.add_child(add_choice)
	return states


func _preparation_index_taken(states: Array, candidate: int) -> bool:
	for state in states:
		if int(state["index"]) == candidate:
			return true
	return false


func _preparation_skill_field(parent: Control, title: String, initial_index: int, changed: Callable, initial_passion: int = 0) -> Dictionary:
	var state := {"index": clampi(initial_index, 0, 10), "passion": clampi(initial_passion, 0, 2)}
	var row := _hbox(4)
	parent.add_child(row)
	var caption := _label(title, 12, MUTED)
	caption.custom_minimum_size.x = 69
	row.add_child(caption)
	var passion := Button.new()
	passion.custom_minimum_size = Vector2(34, 25)
	passion.flat = true
	passion.text = "🔥🔥" if int(state["passion"]) == 2 else "🔥" if int(state["passion"]) == 1 else "·"
	passion.tooltip_text = _prep_local("Click to change passion: none, interested, burning", "Tutkuyu değiştirmek için tıkla: yok, ilgili, çok tutkulu", "Kliknij, aby zmienić pasję")
	passion.pressed.connect(func():
		state["passion"] = (int(state["passion"]) + 1) % 3
		passion.text = "🔥🔥" if int(state["passion"]) == 2 else "🔥" if int(state["passion"]) == 1 else "·"
		changed.call())
	row.add_child(passion)
	state["passion_button"] = passion
	var meter := ProgressBar.new()
	meter.min_value = 0
	meter.max_value = 10
	meter.value = int(state["index"])
	meter.show_percentage = false
	meter.custom_minimum_size = Vector2(48, 13)
	meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var meter_background := _style(Color("#17181a"), Color("#3c3d3f"), 1)
	meter_background.set_content_margin_all(0)
	var meter_fill := _style(Color("#91866d"), Color.TRANSPARENT, 0)
	meter_fill.set_content_margin_all(0)
	meter.add_theme_stylebox_override("background", meter_background)
	meter.add_theme_stylebox_override("fill", meter_fill)
	row.add_child(meter)
	var level := SpinBox.new()
	level.min_value = 0
	level.max_value = 10
	level.step = 1
	level.custom_minimum_size = Vector2(50, 25)
	level.value = int(state["index"])
	row.add_child(level)
	level.value_changed.connect(func(value: float):
		state["index"] = int(value)
		meter.value = value
		changed.call())
	state["level"] = level
	state["meter"] = meter
	return state


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
		spec["nickname"] = spec["name"]
		spec["first_name"] = (input.first_name as LineEdit).text.strip_edges()
		spec["last_name"] = (input.last_name as LineEdit).text.strip_edges()
		spec["hair_index"] = int(input.hair["index"])
		spec["body_type"] = int(input.body_type["index"])
		spec["head_type"] = int(input.head_type["index"])
		spec["hair_color"] = "#" + (input.hair_color as ColorPickerButton).color.to_html(false)
		spec["skin_color"] = "#" + (input.skin as ColorPickerButton).color.to_html(false)
		spec["sex"] = ["female", "male"][int(input.sex["index"])]
		spec["age"] = int((input.age as SpinBox).value)
		spec["chronological_age"] = maxi(int((input.chronological_age as SpinBox).value), spec["age"])
		spec["favorite_color"] = "#" + (input.favorite_color as ColorPickerButton).color.to_html(false)
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
		var passions: Dictionary = {}
		for skill in input.skills:
			skills[skill] = int(input.skills[skill]["index"])
			passions[skill] = int(input.skills[skill]["passion"])
		spec["skills"] = skills
		spec["passions"] = passions
		character_specs[int(input.index)] = spec

func _refresh_character_editor() -> void:
	if _character_inputs.is_empty():
		return
	_save_character_inputs()
	var spec: Dictionary = character_specs[_editing_character_index]
	var input: Dictionary = _character_inputs[0]
	(input.preview as Control).call("set_appearance", _spec_appearance(spec))
	(input.childhood_note as Label).text = [
		_prep_local("Grew up among fields and practical work.", "Tarlalar ve günlük işler arasında büyüdü.", "Dorastał pośród pól i codziennej pracy."),
		_prep_local("Learned to adapt to a crowded town.", "Kalabalık bir kasabada uyum sağlamayı öğrendi.", "Nauczył się żyć w zatłoczonym mieście."),
		_prep_local("Spent their early years learning a trade.", "İlk yıllarını bir zanaat öğrenerek geçirdi.", "Młode lata spędził na nauce fachu."),
	][int(input.childhood["index"])]
	(input.adulthood_note as Label).text = [
		_prep_local("Worked the land before this expedition.", "Bu yolculuktan önce toprağı işledi.", "Przed wyprawą pracował na roli."),
		_prep_local("Helped raise and repair settlements.", "Yerleşkeler kurup onarmaya yardım etti.", "Pomagał budować i naprawiać osady."),
		_prep_local("Cared for the injured and sick.", "Yaralılarla ve hastalarla ilgilendi.", "Opiekował się rannymi i chorymi."),
		_prep_local("Studied and pursued new discoveries.", "Çalışıp yeni keşiflerin peşinden gitti.", "Studiował i szukał nowych odkryć."),
	][int(input.adulthood["index"])]
	(input.childhood["row"] as Control).tooltip_text = (input.childhood_note as Label).text
	(input.adulthood["row"] as Control).tooltip_text = (input.adulthood_note as Label).text
	for skill in input.get("skill_bars", {}):
		var selection := int(input.skills[skill]["index"])
		var meter: ProgressBar = input.skill_bars[skill]
		meter.value = selection
	for i in mini(_roster_buttons.size(), character_specs.size()):
		var role_ids := ["farmer", "builder", "medic", "scholar"]
		var role_names := [_prep_local("Farmer", "Çiftçi", "Rolnik"), _prep_local("Builder", "İnşaatçı", "Budowniczy"), _prep_local("Medic", "Sağlıkçı", "Medyk"), _prep_local("Scholar", "Araştırmacı", "Badacz")]
		var role: String = str(role_names[maxi(0, role_ids.find(str(character_specs[i].get("adulthood", "farmer"))))])
		_roster_buttons[i].text = "%s\n%s" % [str(character_specs[i].get("name", "Colonist")), role]
	_refresh_character_points()

func _refresh_character_points() -> void:
	if not is_instance_valid(_character_points) or character_specs.is_empty():
		return
	var spec: Dictionary = character_specs[_editing_character_index]
	var person := {"traits": spec.get("trait_ids", []), "health_conditions": spec.get("condition_ids", []), "skills": spec.get("skills", {}), "starting_gear": spec.get("starting_gear", {})}
	var spent := int(Game.preparation_points(person)) if Game.has_method("preparation_points") else 0
	_character_points.text = _prep_local("Points: %d / 12", "Puan: %d / 12", "Punkty: %d / 12") % spent if point_limit_enabled else _prep_local("Points spent: %d", "Harcanan puan: %d", "Wydane punkty: %d") % spent
	_character_points.add_theme_color_override("font_color", RED if point_limit_enabled and spent > 12 else MUTED)


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
		colonist_count = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, str(lobby.get("scenario_id", "landfall"))).get("colonist_count", 3))
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
			"name": str(spec.get("name", "Colonist")),
			"first_name": str(spec.get("first_name", spec.get("name", "Colonist"))),
			"nickname": str(spec.get("nickname", spec.get("name", "Colonist"))),
			"last_name": str(spec.get("last_name", "")),
			"sex": str(spec.get("sex", "female")),
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
			"appearance": _spec_appearance(spec),
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
		_pawn_detail_content.add_child(_button(_prep_local("Wear jacket", "Ceket giy", "Załóż kurtkę"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"})))
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
	health_row.add_child(_label("%s %d" % [_tr("health.bleeding"), int(health.get("bleeding", 0))], 12, RED if float(health.get("bleeding", 0)) > 0 else MUTED))
	for wound in health.get("wounds", []):
		action_column.add_child(_label(_prep_local("• %s · severity %d", "• %s · şiddet %d", "• %s · nasilenie %d") % [str(wound.get("kind", "Wound")).capitalize(), int(wound.get("severity", 0))], 12))
	var equipment: Dictionary = person.get("equipment", {})
	action_column.add_child(_label(_prep_local("Weapon: %s   Apparel: %s", "Silah: %s   Kıyafet: %s", "Broń: %s   Ubranie: %s") % [_display_item(str(equipment.get("weapon", "none"))), _display_item(str(equipment.get("apparel", "none")))], 12))
	var buttons := _hbox(5)
	action_column.add_child(buttons)
	buttons.add_child(_button(_prep_local("Equip spear", "Mızrak kuşan", "Załóż włócznię"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "spear"}), false, Vector2(114, 27)))
	buttons.add_child(_button(_prep_local("Wear jacket", "Ceket giy", "Załóż kurtkę"), func(): _send_command({"type": "direct", "colonist_id": person_id, "action": "equip", "item": "jacket"}), false, Vector2(86, 27)))
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
