extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(change_scene_to_file("res://scenes/main.tscn") == OK)
	await process_frame
	await process_frame
	var director: Node = root.get_node("AudioDirector")
	var main := current_scene
	assert(director != null)
	assert(director.get("music_mode") == "menu")
	for bus_name in ["Master", "Music", "Effects"]:
		assert(AudioServer.get_bus_index(StringName(bus_name)) >= 0)
	for setting_key in ["master_volume", "music_volume", "effects_volume"]:
		director.call("preview_volume", setting_key, 1.0)
	var menu_player: AudioStreamPlayer = director.get("_menu_player")
	var colony_player: AudioStreamPlayer = director.get("_colony_player")
	for attempt in 12:
		if menu_player.playing and colony_player.playing:
			break
		await process_frame
	assert(menu_player.playing and colony_player.playing)
	assert(menu_player.bus == &"Music" and colony_player.bus == &"Music")
	assert(menu_player.stream is AudioStreamWAV)
	assert((menu_player.stream as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_FORWARD)
	assert((menu_player.stream as AudioStreamWAV).loop_end > 0)
	assert((menu_player.stream as AudioStreamWAV).format == AudioStreamWAV.FORMAT_16_BITS)
	assert(menu_player.stream.get_length() >= 20.0)
	assert(colony_player.stream.get_length() >= 20.0)
	await create_timer(0.25).timeout
	var music_peak_db := AudioServer.get_bus_peak_volume_left_db(AudioServer.get_bus_index(&"Music"), 0)
	assert(menu_player.get_playback_position() > 0.02)
	assert(music_peak_db > -60.0)
	menu_player.seek(23.9)
	await create_timer(0.25).timeout
	assert(menu_player.playing)
	assert(menu_player.get_playback_position() < 1.0)
	var test_button := Button.new()
	main.add_child(test_button)
	director.set("_last_ui_sound_ms", -1000)
	test_button.pressed.emit()
	var heard_ui := false
	for voice in director.get("_voices"):
		if voice.playing and voice.bus == &"Effects" and voice.stream.resource_path.ends_with("ui_click.wav"):
			heard_ui = true
	assert(heard_ui)
	root.get_node("Game").emit_signal("event_emitted", {"kind": "research"})
	var heard_research := false
	for voice in director.get("_voices"):
		if voice.playing and voice.stream.resource_path.ends_with("research.wav"):
			heard_research = true
	assert(heard_research)
	director.call("play_rejection")
	var heard_rejection := false
	for voice in director.get("_voices"):
		if voice.playing and voice.stream.resource_path.ends_with("reject.wav"):
			heard_rejection = true
	assert(heard_rejection)
	main.call("_show_settings")
	var settings_overlay: Control = main.get("_settings_overlay")
	var audio_button: Button
	for button in settings_overlay.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "settings.audio"):
			audio_button = button
			break
	assert(audio_button != null)
	audio_button.pressed.emit()
	var sliders := settings_overlay.find_children("*", "HSlider", true, false)
	assert(sliders.size() == 3)
	var music_bus := AudioServer.get_bus_index(&"Music")
	var effects_bus := AudioServer.get_bus_index(&"Effects")
	(sliders[1] as HSlider).value = 0.0
	assert(AudioServer.is_bus_mute(music_bus))
	(sliders[2] as HSlider).value = 0.0
	assert(AudioServer.is_bus_mute(effects_bus))
	(sliders[2] as HSlider).value = 0.37
	assert(not AudioServer.is_bus_mute(effects_bus))
	assert(is_equal_approx(AudioServer.get_bus_volume_linear(effects_bus), 0.37))
	main.call("_close_settings")
	assert(AudioServer.is_bus_mute(music_bus) == (main.preferences.music_volume <= 0.0))
	assert(AudioServer.is_bus_mute(effects_bus) == (main.preferences.effects_volume <= 0.0))
	if main.preferences.effects_volume > 0.0:
		assert(is_equal_approx(AudioServer.get_bus_volume_linear(effects_bus), main.preferences.effects_volume))
	main.set_process(false)
	main.set("screen", "game")
	await process_frame
	await process_frame
	assert(director.get("music_mode") == "game")
	main.set("screen", "menu")
	await process_frame
	await process_frame
	assert(director.get("music_mode") == "menu")
	director.call("restore_volumes", main.preferences)
	director.queue_free()
	await process_frame
	await create_timer(0.15).timeout
	print("AUDIO_SMOKE_OK")
	quit()
