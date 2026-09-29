extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.preferences.language = "en"
	main.preferences.apply_settings()
	main.call("_show_menu")
	await process_frame
	_assert_english(main, "menu")
	main.call("_begin_session", "solo")
	await process_frame
	_assert_english(main, "scenario")
	main.call("_advance_to_world")
	await process_frame
	_assert_english(main, "world")
	main.call("_show_characters")
	await process_frame
	_assert_english(main, "characters")
	main.call("_advance_to_lobby")
	await process_frame
	_assert_english(main, "game")
	for tab_name in ["İşler", "Günlük plan", "Araştırma", "Dünya"]:
		main.call("_set_tab", tab_name)
		await process_frame
		_assert_english(main, tab_name)
	var person: Dictionary = main.call("_local_colonists", main.call("_snapshot"))[0]
	main.call("_select_colonist", str(person.get("id", "")))
	for pawn_tab in ["Health", "Needs", "Gear"]:
		main.call("_set_pawn_tab", pawn_tab)
		await process_frame
		_assert_english(main, pawn_tab)
	print("ENGLISH_UI_SMOKE_OK")
	quit()


func _assert_english(node: Node, stage: String) -> void:
	if node is Control and not (node as Control).is_visible_in_tree():
		return
	var value := ""
	if node is Button:
		value = (node as Button).text
	elif node is Label:
		value = (node as Label).text
	elif node is LineEdit:
		value = (node as LineEdit).placeholder_text
	if not value.is_empty():
		for character in value:
			if character in "çğıöşüÇĞİÖŞÜ":
				push_error("Turkish UI text in %s: %s" % [stage, value])
				assert(false)
	for child in node.get_children():
		_assert_english(child, stage)
