extends Node

## Music and feedback for the whole game. Sounds are original PCM assets generated
## by generate_audio.py; keeping the players here lets rebuilt UI screens use them.

const SettingsScript = preload("res://scripts/ui/settings.gd")
const MENU_THEME = preload("res://assets/audio/menu_theme.wav")
const COLONY_THEME = preload("res://assets/audio/colony_theme.wav")
const EFFECT_STREAMS := {
	"ui_click": preload("res://assets/audio/ui_click.wav"),
	"ui_select": preload("res://assets/audio/ui_select.wav"),
	"order": preload("res://assets/audio/order.wav"),
	"build": preload("res://assets/audio/build.wav"),
	"research": preload("res://assets/audio/research.wav"),
	"alert": preload("res://assets/audio/alert.wav"),
	"reject": preload("res://assets/audio/reject.wav"),
	"trade": preload("res://assets/audio/trade.wav"),
}

const EFFECT_VOICES := 8
const MUSIC_FADE_SPEED := 0.85

var music_mode := "menu"
var _main: Node
var _menu_player: AudioStreamPlayer
var _colony_player: AudioStreamPlayer
var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _menu_gain := 1.0
var _colony_gain := 0.0
var _last_ui_sound_ms := 0
var _last_slider_sound_ms := 0
var _last_reject_sound_ms := 0
var _last_event_sound_ms: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music")
	_ensure_bus("Effects")
	restore_volumes(SettingsScript.load_settings())
	var menu_stream: AudioStreamWAV = MENU_THEME.duplicate()
	var colony_stream: AudioStreamWAV = COLONY_THEME.duplicate()
	menu_stream.loop_end = roundi(menu_stream.get_length() * menu_stream.mix_rate)
	colony_stream.loop_end = roundi(colony_stream.get_length() * colony_stream.mix_rate)
	menu_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	colony_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_menu_player = _make_music_player(menu_stream, "MenuMusic", 1.0)
	_colony_player = _make_music_player(colony_stream, "ColonyMusic", 0.0)
	for i in EFFECT_VOICES:
		var voice := AudioStreamPlayer.new()
		voice.name = "Effect%d" % i
		voice.bus = &"Effects"
		add_child(voice)
		_voices.append(voice)
	get_tree().node_added.connect(_on_node_added)
	Game.event_emitted.connect(_on_game_event)
	call_deferred("_start_music")


func _exit_tree() -> void:
	set_process(false)
	for voice in _voices:
		voice.stop()
		voice.stream = null
	if is_instance_valid(_menu_player):
		_menu_player.stop()
		_menu_player.stream = null
	if is_instance_valid(_colony_player):
		_colony_player.stop()
		_colony_player.stream = null


func _make_music_player(stream: AudioStream, player_name: String, gain: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.stream = stream
	player.bus = &"Music"
	player.volume_db = linear_to_db(maxf(gain, 0.0001))
	add_child(player)
	return player


func _start_music() -> void:
	_menu_player.play()
	_colony_player.play()


func _process(delta: float) -> void:
	# WASAPI can finish initializing after an autoload's ready/deferred calls.
	# Retry until the streams actually enter playback on the live audio driver.
	if not _menu_player.playing:
		_menu_player.play()
	if not _colony_player.playing:
		_colony_player.play()
	if not is_instance_valid(_main):
		var scene := get_tree().current_scene
		if scene != null and scene.get("screen") is String:
			_main = scene
	var wanted := "game" if is_instance_valid(_main) and _main.get("screen") == "game" else "menu"
	if music_mode != wanted:
		music_mode = wanted
	_menu_gain = move_toward(_menu_gain, 0.0 if wanted == "game" else 1.0, delta * MUSIC_FADE_SPEED)
	_colony_gain = move_toward(_colony_gain, 1.0 if wanted == "game" else 0.0, delta * MUSIC_FADE_SPEED)
	_menu_player.volume_db = linear_to_db(maxf(_menu_gain, 0.0001))
	_colony_player.volume_db = linear_to_db(maxf(_colony_gain, 0.0001))


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		(node as BaseButton).pressed.connect(_on_button_pressed.bind(node))
	if node is HSlider or node is VSlider:
		(node as Range).value_changed.connect(_on_slider_changed)
	if node is OptionButton:
		(node as OptionButton).item_selected.connect(_on_option_selected)
	if node is PopupMenu and not (node.get_parent() is OptionButton):
		(node as PopupMenu).id_pressed.connect(_on_popup_item)
	if node.has_signal("map_pressed"):
		node.connect("map_pressed", _on_map_pressed)
	if node is Control and node.has_method("_show_game") and node.has_method("_show_menu"):
		_main = node


func _on_button_pressed(button: BaseButton) -> void:
	if not is_instance_valid(button):
		return
	var now := Time.get_ticks_msec()
	if now - _last_ui_sound_ms < 35:
		return
	_last_ui_sound_ms = now
	play_effect("ui_select" if button is CheckButton or button is CheckBox else "ui_click")


func _on_slider_changed(_level: float) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_slider_sound_ms < 130:
		return
	_last_slider_sound_ms = now
	# Settings sliders update the bus on the same signal; play after that update.
	call_deferred("play_effect", "ui_select")


func _on_option_selected(_index: int) -> void:
	play_effect("ui_select")


func _on_popup_item(_id: int) -> void:
	play_effect("ui_select")


func _on_map_pressed(_tile: Vector2i, colonist_id: String, enemy_id: String, mouse_button: int) -> void:
	if mouse_button == MOUSE_BUTTON_RIGHT:
		play_effect("order")
	elif not colonist_id.is_empty() or not enemy_id.is_empty():
		play_effect("ui_select")


func _on_game_event(event: Dictionary) -> void:
	var kind := str(event.get("kind", ""))
	var effect_name := ""
	match kind:
		"build": effect_name = "build"
		"research": effect_name = "research"
		"raid", "raid_warning", "raid_attack", "death": effect_name = "alert"
		"npc_trade", "trade_accept", "trade_complete": effect_name = "trade"
		"caravan", "player_joined", "naming_prompt": effect_name = "ui_select"
	if effect_name.is_empty():
		return
	var now := Time.get_ticks_msec()
	if now - int(_last_event_sound_ms.get(kind, -1000)) < 450:
		return
	_last_event_sound_ms[kind] = now
	play_effect(effect_name)


func play_effect(effect_name: String) -> void:
	if not EFFECT_STREAMS.has(effect_name):
		return
	var voice: AudioStreamPlayer
	for candidate in _voices:
		if not candidate.playing:
			voice = candidate
			break
	if voice == null:
		voice = _voices[_next_voice]
		_next_voice = (_next_voice + 1) % _voices.size()
		voice.stop()
	voice.stream = EFFECT_STREAMS[effect_name]
	voice.play()


func play_rejection() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_reject_sound_ms < 280:
		return
	_last_reject_sound_ms = now
	play_effect("reject")


func preview_volume(setting_key: String, level: float) -> void:
	var bus_name: String = {
		"master_volume": "Master",
		"music_volume": "Music",
		"effects_volume": "Effects",
	}.get(setting_key, "")
	if bus_name.is_empty():
		return
	var index := _ensure_bus(bus_name)
	var safe_level := clampf(level, 0.0, 1.0)
	AudioServer.set_bus_volume_linear(index, maxf(safe_level, 0.0001))
	AudioServer.set_bus_mute(index, safe_level <= 0.0)


func restore_volumes(settings: RefCounted) -> void:
	preview_volume("master_volume", float(settings.get("master_volume")))
	preview_volume("music_volume", float(settings.get("music_volume")))
	preview_volume("effects_volume", float(settings.get("effects_volume")))


func _ensure_bus(bus_name: String) -> int:
	var index := AudioServer.get_bus_index(StringName(bus_name))
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, &"Master")
	return index
