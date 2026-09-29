extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(change_scene_to_file("res://scenes/main.tscn") == OK)
	await process_frame
	await process_frame
	var main := current_scene
	var model := root.get_node("Game")
	var world: Dictionary = model.call("preview_world", "portrait-input-probe")
	var site_id := ""
	for site in world.get("sites", []):
		if str(site.get("kind", "")) == "vacant":
			site_id = str(site.get("id", ""))
			break
	assert(not site_id.is_empty())
	model.call("start_new_game", {"seed": "portrait-input-probe", "mode": "solo", "scenario_id": "landfall", "point_limit_enabled": false,
		"faction_specs": [{"site_id": site_id, "name": "Test Colony", "settlement_name": "Test Settlement", "players": [1]}]})
	main.selected_site_id = site_id
	main.call("_show_game")
	await process_frame
	var strip: HBoxContainer = main.get("_portrait_strip")
	var people: Array = main.call("_local_colonists", main.call("_snapshot"))
	assert(people.size() >= 2)
	assert(strip.get_child_count() == people.size())
	var first_button := strip.get_child(0) as Button
	first_button.pressed.emit()
	assert((main.get("selected_ids") as Array)[0] == str(people[0]["id"]))
	assert(strip.get_child_count() == people.size(), "Portrait selection must not leave queued old buttons in the layout")
	for index in strip.get_child_count():
		var button := strip.get_child(index) as Button
		var portrait := button.get_child(0) as Control
		assert(bool(portrait.get("is_selected")) == (index == 0), "Only the clicked portrait should be highlighted")
	var architect := (main.get("_tab_buttons") as Dictionary)["Emirler"] as Button
	architect.grab_focus()
	var pause := InputEventKey.new()
	pause.keycode = int(main.preferences.keybinds["pause"])
	pause.pressed = true
	Input.parse_input_event(pause)
	await process_frame
	assert(main.game_paused, "Space should pause when an Architect button has keyboard focus")
	assert(main.current_tab.is_empty(), "Space must not activate the focused Architect button")
	print("PORTRAIT_INPUT_REGRESSION_OK")
	quit()
