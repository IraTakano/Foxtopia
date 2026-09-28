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
	assert(main.get("screen") == "characters")
	main.call("_switch_preparation_tab", "relationships")
	main.call("_switch_preparation_tab", "equipment")
	main.call("_switch_preparation_tab", "characters")
	main.call("_advance_to_lobby")
	await process_frame
	assert(main.get("screen") == "game")
	var snapshot: Dictionary = main.call("_snapshot")
	assert((snapshot.get("colonists", []) as Array).size() == 3)
	for tab_name in ["Emirler", "İşler", "Araştırma", "Dünya"]:
		main.call("_set_tab", tab_name)
		assert(main.get("current_tab") == tab_name)
	main.call("_set_tab", "Dünya")
	assert(main.get("current_tab") == "")
	print("UI_SMOKE_OK")
	quit()
