extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var settings_path := ProjectSettings.globalize_path("user://settings.json")
	var had_settings := FileAccess.file_exists(settings_path)
	var original_settings := FileAccess.get_file_as_string(settings_path) if had_settings else ""
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_show_settings")
	var overlay: Control = main.get("_settings_overlay")
	var controls_button: Button
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "settings.controls"):
			controls_button = button
			break
	assert(controls_button != null)
	controls_button.pressed.emit()
	await process_frame
	var scrolls := overlay.find_children("*", "ScrollContainer", true, false)
	assert(not scrolls.is_empty())
	var key_scroll := scrolls[0] as ScrollContainer
	assert(key_scroll.get_v_scroll_bar().visible)
	assert(key_scroll.get_v_scroll_bar().max_value > key_scroll.size.y)
	var previous_pause := int(main.preferences.keybinds["pause"])
	var replacement_pause := KEY_P if previous_pause != KEY_P else KEY_O
	var pause_button: Button
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == OS.get_keycode_string(previous_pause):
			pause_button = button
			break
	assert(pause_button != null)
	pause_button.pressed.emit()
	var rebind := InputEventKey.new()
	rebind.keycode = replacement_pause
	rebind.pressed = true
	main.call("_input", rebind)
	assert(int((main.get("_settings_draft") as Dictionary)["keybinds"]["pause"]) == replacement_pause)
	var apply_button: Button
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "common.apply"):
			apply_button = button
			break
	assert(apply_button != null)
	apply_button.pressed.emit()
	assert(int(main.preferences.keybinds["pause"]) == replacement_pause)
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.call("_advance_to_lobby")
	await process_frame
	assert(main.get("screen") == "game")
	main.call("_unhandled_key_input", rebind)
	assert(main.get("game_paused"))
	main.call("_unhandled_key_input", rebind)
	assert(not main.get("game_paused"))
	for speed_index in [1, 2, 3]:
		var speed_key := InputEventKey.new()
		speed_key.keycode = KEY_1 + speed_index - 1
		speed_key.pressed = true
		main.call("_unhandled_key_input", speed_key)
		assert(is_equal_approx(float(main.get("speed")), float([1, 3, 6][speed_index - 1])))
		assert(not main.get("game_paused"))
	var tab_key := InputEventKey.new()
	tab_key.keycode = KEY_TAB
	tab_key.pressed = true
	main.call("_input", tab_key)
	assert(main.get("current_tab") == "Emirler")
	main.call("_input", tab_key)
	assert(main.get("current_tab") == "")
	var work_key := InputEventKey.new()
	work_key.keycode = KEY_F1
	work_key.pressed = true
	main.call("_input", work_key)
	assert(main.get("current_tab") == "İşler")
	main.call("_input", work_key)
	var map_view: Control = main.get("_map_view")
	var zoom_before: float = map_view.get("zoom")
	var zoom_key := InputEventKey.new()
	zoom_key.keycode = KEY_PAGEDOWN
	zoom_key.pressed = true
	main.call("_unhandled_key_input", zoom_key)
	assert(float(map_view.get("zoom")) > zoom_before)
	var pan_before: Vector2 = map_view.get("camera_offset")
	var pan_key := InputEventKey.new()
	pan_key.keycode = KEY_W
	pan_key.pressed = true
	Input.parse_input_event(pan_key)
	await process_frame
	main.call("_pan_camera_from_keys", 0.25)
	assert((map_view.get("camera_offset") as Vector2).y > pan_before.y)
	pan_key.pressed = false
	Input.parse_input_event(pan_key)
	var next_key := InputEventKey.new()
	next_key.keycode = KEY_PERIOD
	next_key.pressed = true
	main.call("_unhandled_key_input", next_key)
	assert((main.get("selected_ids") as Array).size() == 1)
	var selected_person_id := str((main.get("selected_ids") as Array)[0])
	var draft_key := InputEventKey.new()
	draft_key.keycode = KEY_R
	draft_key.pressed = true
	main.call("_unhandled_key_input", draft_key)
	for person in (main.call("_snapshot") as Dictionary).get("colonists", []):
		assert(bool(person.get("drafted", false)) == (str(person["id"]) == selected_person_id))
	main.set("selected_ids", [] as Array[String])
	main.call("_unhandled_key_input", draft_key)
	for person in (main.call("_snapshot") as Dictionary).get("colonists", []):
		assert(bool(person.get("drafted", false)))
	main.call("_unhandled_key_input", draft_key)
	for person in (main.call("_snapshot") as Dictionary).get("colonists", []):
		assert(not bool(person.get("drafted", false)))
	var first: Dictionary = (main.call("_snapshot") as Dictionary)["colonists"][0]
	var person_id := str(first["id"])
	main.call("_select_colonist", person_id)
	assert(main.call("_send_command", {"type": "direct", "colonist_id": person_id, "action": "move", "x": int(first["x"]), "y": int(first["y"])}))
	var clear_key := InputEventKey.new()
	clear_key.keycode = KEY_C
	clear_key.pressed = true
	main.call("_unhandled_key_input", clear_key)
	for person in (main.call("_snapshot") as Dictionary).get("colonists", []):
		if str(person["id"]) == person_id:
			assert((person.get("manual", {}) as Dictionary).is_empty())
	if had_settings:
		var file := FileAccess.open(settings_path, FileAccess.WRITE)
		file.store_string(original_settings)
	else:
		DirAccess.remove_absolute(settings_path)
	print("KEYBOARD_CONTROLS_SMOKE_OK")
	quit()
