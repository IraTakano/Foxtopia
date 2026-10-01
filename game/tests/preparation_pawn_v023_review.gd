extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _capture(name: String) -> void:
	var folder := OS.get_environment("PREPARATION_PAWN_CAPTURE_DIR")
	if folder.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(folder)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(name + ".png")) == OK)


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1440, 900))
	root.content_scale_size = Vector2i(1440, 900)
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.set("_editing_character_index", 0)
	var spec: Dictionary = (main.get("character_specs") as Array)[0]
	spec["sex"] = "female"
	spec["hair_style"] = "short"
	spec["hair_index"] = 1
	spec["starting_gear"] = {"weapon": "fists", "shirt": "tshirt", "pants": "none", "apparel": "none", "shirt_color": "#527a81"}
	main.set("_preparation_appearance_category", 1)
	main.call("_show_characters")
	await _capture("female-pixie-shirt-only-1440")
	var appearance: Dictionary = main.call("_spec_appearance", spec)
	assert(str(appearance["shirt"]) == "tshirt" and str(appearance["pants"]) == "none")
	spec = (main.get("character_specs") as Array)[0]
	spec["starting_gear"] = {"weapon": "fists", "shirt": "none", "pants": "none", "apparel": "none"}
	main.call("_show_characters")
	appearance = main.call("_spec_appearance", (main.get("character_specs") as Array)[0])
	assert(str(appearance["shirt"]) == "none" and str(appearance["pants"]) == "none")
	await _capture("female-pixie-naked-1440")
	spec = (main.get("character_specs") as Array)[0]
	spec["sex"] = "male"
	spec["first_name"] = "Aras"
	spec["nickname"] = "Aras"
	spec["last_name"] = "Demir"
	spec["name"] = "Aras"
	spec["hair_style"] = "long"
	spec["hair_index"] = 6
	spec["starting_gear"] = {"weapon": "fists", "shirt": "tshirt", "pants": "pants", "apparel": "none"}
	main.call("_show_characters")
	appearance = main.call("_spec_appearance", (main.get("character_specs") as Array)[0])
	assert(str(appearance["sex"]) == "male" and str(appearance["hair"]) == "long")
	var preview: Control = (main.get("_character_inputs") as Array)[0]["preview"]
	var visible_appearance: Dictionary = preview.get("appearance")
	assert(str(visible_appearance["sex"]) == "male" and str(visible_appearance["hair"]) == "long")
	await _capture("male-tied-long-1440")
	spec = (main.get("character_specs") as Array)[0]
	spec["hair_style"] = "medium"
	spec["hair_index"] = 5
	main.call("_show_characters")
	appearance = main.call("_spec_appearance", (main.get("character_specs") as Array)[0])
	assert(str(appearance["sex"]) == "male" and str(appearance["hair"]) == "medium")
	await _capture("male-ear-length-1440")
	DisplayServer.window_set_size(Vector2i(960, 540))
	root.content_scale_size = Vector2i(960, 540)
	(main as Control).size = Vector2(960, 540)
	main.call("_show_characters")
	await _capture("male-ear-length-960")
	spec = (main.get("character_specs") as Array)[0]
	spec["hair_style"] = "long"
	spec["hair_index"] = 6
	main.call("_show_characters")
	await _capture("male-tied-long-960")
	spec = (main.get("character_specs") as Array)[0]
	spec["sex"] = "female"
	spec["hair_style"] = "short"
	spec["hair_index"] = 1
	spec["starting_gear"] = {"weapon": "fists", "shirt": "tshirt", "pants": "none", "apparel": "none", "shirt_color": "#527a81"}
	main.call("_show_characters")
	await _capture("female-pixie-shirt-only-960")
	print("PREPARATION_PAWN_V023_REVIEW_OK")
	quit()
