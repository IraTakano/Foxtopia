extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(change_scene_to_file("res://scenes/main.tscn") == OK)
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.scenario_id = "hard_landing"
	main.colonist_count = 1
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.call("_advance_to_lobby")
	assert(main.screen == "game", "Naming must not block starting the colony")
	var game := root.get_node("Game")
	var faction: Dictionary = game.state["factions"][0]
	assert(str(faction["name"]).begins_with("Unnamed"))
	await process_frame
	assert(main.get("_naming_prompt_open"), "An unnamed colony must receive the naming dialog immediately")
	assert(main.game_paused, "Solo naming event should pause the clock")
	var naming_popup: Control = main.get("_naming_overlay")
	assert(is_instance_valid(naming_popup))
	var old_time := int(game.state["time"])
	main.call("_process", 10.0)
	assert(int(game.state["time"]) == old_time)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	main.call("_input", escape)
	assert(main.get("_naming_prompt_open"), "Escape must not dismiss the required name dialog")
	var edits := naming_popup.find_children("*", "LineEdit", true, false)
	assert(edits.size() == 2)
	var name_button: Button
	for button in naming_popup.find_children("*", "Button", true, false):
		if button.text == main.call("_prep_local", "Name our home", "Yurdumuzu adlandır", "Nazwij nasz dom"):
			name_button = button
			break
	assert(name_button != null)
	name_button.pressed.emit()
	assert(main.get("_naming_prompt_open"), "Empty names must not dismiss the dialog")
	(edits[0] as LineEdit).text = "Foxbound"
	(edits[1] as LineEdit).text = "Hearth"
	name_button.pressed.emit()
	await process_frame
	assert(str(game.state["factions"][0]["name"]) == "Foxbound")
	assert(str(game.state["factions"][0]["settlement_name"]) == "Hearth")
	assert(not main.game_paused)
	print("NAMING_FLOW_SMOKE_OK")
	quit()
