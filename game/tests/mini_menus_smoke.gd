extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.call("_advance_to_lobby")
	await process_frame
	assert(main.screen == "game")
	var tabs: Dictionary = main.get("_tab_buttons")
	assert(not tabs.has("Sağlık"), "Health belongs to the selected colonist")
	assert(not tabs.has("Ticaret"), "Trade belongs to a trader interaction")
	var person: Dictionary = main.call("_local_colonists", main.call("_snapshot"))[0]
	var person_id := str(person.get("id", ""))
	main.call("_select_colonist", person_id)
	main.call("_set_tab", "Sağlık")
	assert(main.pawn_tab == "Health")
	assert(main.current_tab.is_empty())
	main.call("_set_tab", "Sağlık")
	assert(main.pawn_tab.is_empty())
	main.call("_arm_direct_action", "move")
	var strip: HBoxContainer = main.get("_command_strip")
	assert(str(strip.get_meta("pending_direct_action", "")) == "move")
	var start: Vector2i = Vector2i(int(person.get("x", 0)), int(person.get("y", 0)))
	var destination: Vector2i = start
	for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		var candidate: Vector2i = start + direction
		if main.call("_map_tile_passable", candidate):
			destination = candidate
			break
	assert(destination != start, "Test pawn needs a passable neighbor")
	main.call("_on_map_pressed", destination, "", "", MOUSE_BUTTON_LEFT)
	assert(str(strip.get_meta("pending_direct_action", "")) == "")
	var updated: Dictionary = main.call("_local_colonists", main.call("_snapshot"))[0]
	assert(str(updated.get("manual", {}).get("action", "")) == "move")
	main.call("_arm_direct_action", "attack")
	main.call("_on_map_pressed", destination, "", "", MOUSE_BUTTON_LEFT)
	assert(str(strip.get_meta("pending_direct_action", "")) == "attack", "An invalid target keeps the tool armed")
	main.call("_on_map_pressed", destination, "", "", MOUSE_BUTTON_RIGHT)
	assert(str(strip.get_meta("pending_direct_action", "")) == "")
	main.call("_set_tab", "Emirler")
	assert(main.current_tab == "Emirler")
	assert(main.get("_tool_panel").offset_top == -185)
	main.call("_on_map_pressed", destination, "", "", MOUSE_BUTTON_LEFT)
	assert(main.current_tab.is_empty())
	print("MINI_MENUS_SMOKE_OK")
	quit()
