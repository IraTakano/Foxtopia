extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var test_dir := "foxtopia_ui_test_saves_%d" % Time.get_ticks_usec()
	var game := root.get_node("Game")
	game.set("_save_directory_name", test_dir)
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.call("_advance_to_lobby")
	await process_frame
	assert(main.get("screen") == "game")
	assert(game.has_unsaved_changes())
	# The initial colony naming overlay is handled by the naming flow test.
	main.set("_naming_prompt_open", false)
	main.call("_request_exit", true)
	var warning_button: Button
	for button in main.find_children("*", "Button", true, false):
		if button.text == main.call("_prep_local", "Save and return to menu", "Kaydet ve ana menüye dön", "Zapisz i wróć do menu"):
			warning_button = button
			break
	assert(warning_button != null)
	warning_button.pressed.emit()
	await process_frame
	assert(main.get("screen") == "menu")
	assert(game.list_saved_games().size() == 1)
	main.call("_open_save_picker", false)
	var delete_button: Button
	for button in main.find_children("*", "Button", true, false):
		if button.text == main.call("_prep_local", "Delete", "Sil", "Usuń"):
			delete_button = button
			break
	assert(delete_button != null)
	delete_button.pressed.emit()
	var confirmation: ConfirmationDialog
	for dialog in main.find_children("*", "ConfirmationDialog", true, false):
		confirmation = dialog
		break
	assert(confirmation != null)
	confirmation.confirmed.emit()
	confirmation.hide()
	await process_frame
	assert(game.list_saved_games().is_empty())
	var directory := "user://%s" % test_dir
	assert(DirAccess.remove_absolute(ProjectSettings.globalize_path(directory)) == OK)
	print("SAVE_UI_SMOKE_OK")
	quit()
