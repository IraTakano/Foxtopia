extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(change_scene_to_file("res://scenes/main.tscn") == OK)
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	assert(main.screen == "scenario")
	var model := root.get_node("Game")
	var world: Dictionary = model.call("preview_world", "time-pause-probe")
	var site_id := ""
	for site in world.get("sites", []):
		if str(site.get("kind", "")) == "vacant":
			site_id = str(site.get("id", ""))
			break
	assert(not site_id.is_empty())
	model.call("start_new_game", {"seed": "time-pause-probe", "mode": "solo", "scenario_id": "landfall", "point_limit_enabled": false,
		"faction_specs": [{"site_id": site_id, "name": "Time Colony", "settlement_name": "Clock Town", "players": [1]}]})
	main.selected_site_id = site_id
	main.call("_show_game")
	assert((main.get("_active_alerts") as Array).has("research_bench"))
	var heard_alert := false
	for voice in root.get_node("AudioDirector").get("_voices"):
		if voice.playing and voice.stream.resource_path.ends_with("alert.wav"):
			heard_alert = true
	assert(heard_alert, "A new top-right warning should play its alert sound")
	main.call("_set_speed", 3.0)
	main.call("_process", 10.0)
	assert(int(model.state["time"]) == 45, "3x must advance 45 model steps in 10 real seconds")
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	main.call("_input", escape)
	assert(main.game_paused and main.get("_pause_menu_open"))
	main.call("_process", 10.0)
	assert(int(model.state["time"]) == 45, "Esc menu did not stop simulation")
	for child in main.get_children():
		if child is PopupPanel and child.visible:
			child.hide()
			break
	assert(not main.game_paused and is_equal_approx(main.speed, 3.0), "Closing Esc menu must restore speed")
	main.call("_show_pause_menu")
	var load_button: Button
	for button in main.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "game.load_game"):
			load_button = button
			break
	assert(load_button != null)
	load_button.pressed.emit()
	await process_frame
	assert(main.get("_save_picker_open") and main.game_paused, "Load picker must hold the solo pause")
	main.call("_process", 10.0)
	assert(int(model.state["time"]) == 45)
	for child in main.get_children():
		if child is PopupPanel and child.visible:
			child.hide()
			break
	assert(not main.game_paused and is_equal_approx(main.speed, 3.0), "Closing load picker must restore speed")
	print("TIME_PAUSE_SMOKE_OK")
	quit()
