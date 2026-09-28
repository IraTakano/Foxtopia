extends Node

func _ready() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene = load("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	await get_tree().process_frame
	scene._begin_session("solo")
	await get_tree().process_frame
	scene._advance_to_world()
	await get_tree().process_frame
	scene._show_characters()
	await get_tree().process_frame
	if OS.get_environment("FOXTOPIA_SCREENSHOT_STAGE") == "characters":
		await RenderingServer.frame_post_draw
		print("LAYOUT_SCENE:", scene.size)
		for child in scene.get_children():
			if child is Control:
				print("LAYOUT_CHILD:", child.name, ":", child.size, ":", child.position)
				for grandchild in child.get_children():
					if grandchild is Control:
						print("LAYOUT_GRAND:", grandchild.name, ":", grandchild.size, ":", grandchild.position)
						for c3 in grandchild.get_children():
							if c3 is Control:
								print("LAYOUT_L3:", c3.get_class(), ":", c3.size, ":", c3.position, ":", c3.get_combined_minimum_size())
		var preview_path := OS.get_environment("FOXTOPIA_SCREENSHOT")
		print("SCREENSHOT_SAVED:", get_viewport().get_texture().get_image().save_png(preview_path), ":", preview_path)
		get_tree().quit()
		return
	scene._advance_to_lobby()
	await get_tree().process_frame
	scene._start_prepared_game()
	await get_tree().process_frame
	assert(scene.screen == "game")
	assert(not Game.state.is_empty())
	assert((Game.state.get("colonists", []) as Array).size() == 3)
	for tab_name in ["İşler", "Araştırma", "Sağlık", "Ticaret", "Dünya"]:
		scene._set_tab(tab_name)
	if OS.has_environment("FOXTOPIA_SCREENSHOT"):
		await RenderingServer.frame_post_draw
		var path := OS.get_environment("FOXTOPIA_SCREENSHOT")
		var image := get_viewport().get_texture().get_image()
		print("SCREENSHOT_SAVED:", image.save_png(path), ":", path)
	print("UI_SMOKE_OK")
	get_tree().quit()
