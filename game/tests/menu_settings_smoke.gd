extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	assert(main.get("screen") == "menu")
	main.call("_show_new_game_menu")
	assert(is_instance_valid(main.get("_menu_overlay")))
	var ordinary_key := InputEventKey.new()
	ordinary_key.keycode = KEY_A
	ordinary_key.pressed = true
	main.call("_unhandled_key_input", ordinary_key)
	assert(is_instance_valid(main.get("_menu_overlay")))
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	main.call("_unhandled_key_input", escape)
	assert(main.get("_menu_overlay") == null)
	main.call("_show_new_game_menu")
	var start_button: Button
	for button in (main.get("_menu_overlay") as Control).find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "menu.single_player"):
			start_button = button
			break
	assert(start_button != null)
	start_button.pressed.emit()
	await process_frame
	assert(main.get("session_kind") == "solo")
	assert(main.get("screen") == "setup")
	main.call("_show_menu")
	main.call("_show_settings")
	assert(is_instance_valid(main.get("_settings_overlay")))
	main.call("_unhandled_key_input", ordinary_key)
	assert(is_instance_valid(main.get("_settings_overlay")))
	main.call("_unhandled_key_input", escape)
	assert(main.get("_settings_overlay") == null)
	var options_path := ProjectSettings.globalize_path("user://settings.json")
	var had_options := FileAccess.file_exists(options_path)
	var original_options := FileAccess.get_file_as_string(options_path) if had_options else ""
	main.call("_show_settings")
	var settings_ui: Control = main.get("_settings_overlay")
	var display_button: Button
	for button in settings_ui.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "settings.display"):
			display_button = button
			break
	assert(display_button != null)
	display_button.pressed.emit()
	var selectors := settings_ui.find_children("*", "OptionButton", true, false)
	assert(selectors.size() == 2)
	var mode_selector := selectors[0] as OptionButton
	var resolution_selector := selectors[1] as OptionButton
	mode_selector.select(2)
	mode_selector.item_selected.emit(2)
	var resolution_index := -1
	for index in resolution_selector.item_count:
		if resolution_selector.get_item_text(index).begins_with("1280"):
			resolution_index = index
			break
	assert(resolution_index >= 0)
	resolution_selector.select(resolution_index)
	resolution_selector.item_selected.emit(resolution_index)
	var apply_button: Button
	for button in settings_ui.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "common.apply"):
			apply_button = button
			break
	assert(apply_button != null)
	apply_button.pressed.emit()
	var selected_mode: String = main.preferences.window_mode
	var selected_size: Vector2i = main.preferences.resolution
	if had_options:
		var file := FileAccess.open(options_path, FileAccess.WRITE)
		file.store_string(original_options)
	else:
		DirAccess.remove_absolute(options_path)
	assert(selected_mode == "windowed")
	assert(selected_size == Vector2i(1280, 720))
	print("MENU_SETTINGS_SMOKE_OK")
	quit()
