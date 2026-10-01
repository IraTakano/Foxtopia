extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _apply_button(dialog: Node) -> Button:
	for button in dialog.find_children("*", "Button", true, false):
		if (button as Button).text == "Apply":
			return button as Button
	return null


func _capture(file_name: String) -> void:
	var folder := OS.get_environment("PREPARATION_V019_CAPTURE_DIR")
	if folder.is_empty():
		return
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(file_name)) == OK)


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	var before := int(main.call("_preparation_spent_for_specs", main.get("character_specs")))
	var add := main.find_child("PreparationHealthAdd", true, false) as MenuButton
	assert(add != null)
	add.get_popup().id_pressed.emit(0)
	var dialog := main.find_child("PreparationInjuryDialog", true, false)
	assert(dialog != null)
	var kind := dialog.find_child("PreparationInjury_kind", true, false) as MenuButton
	var part := dialog.find_child("PreparationInjury_body_part", true, false) as MenuButton
	var count := dialog.find_child("PreparationInjury_count", true, false) as MenuButton
	assert(kind != null and part != null and count != null)
	kind.get_popup().id_pressed.emit(2) # deep cut
	part.get_popup().id_pressed.emit(1) # torso
	count.get_popup().id_pressed.emit(1) # two
	var apply := _apply_button(dialog)
	assert(apply != null)
	apply.pressed.emit()
	assert(main.find_child("PreparationInjuryDialog", true, false) != null, "Two deep torso cuts must be rejected")
	assert((main.get("character_specs") as Array)[0].get("health_injuries", []).is_empty())
	count.get_popup().id_pressed.emit(0)
	apply.pressed.emit()
	await process_frame
	var specs: Array = main.get("character_specs")
	assert((specs[0]["health_injuries"] as Array).size() == 1)
	assert(str(specs[0]["health_injuries"][0]["kind"]) == "cut_deep")
	assert(str(specs[0]["health_injuries"][0]["body_part"]) == "torso")
	assert(int(specs[0]["health_injuries"][0]["count"]) == 1)
	assert(main.find_child("PreparationInjuryEntry_0", true, false) != null)
	var after_cut := int(main.call("_preparation_spent_for_specs", specs))
	assert(after_cut < before)
	main.call("_open_preparation_injury_dialog", -1)
	dialog = main.find_child("PreparationInjuryDialog", true, false)
	kind = dialog.find_child("PreparationInjury_kind", true, false) as MenuButton
	part = dialog.find_child("PreparationInjury_body_part", true, false) as MenuButton
	count = dialog.find_child("PreparationInjury_count", true, false) as MenuButton
	kind.get_popup().id_pressed.emit(3) # bruise
	part.get_popup().id_pressed.emit(4) # left leg
	count.get_popup().id_pressed.emit(1) # two
	_apply_button(dialog).pressed.emit()
	await process_frame
	specs = main.get("character_specs")
	assert((specs[0]["health_injuries"] as Array).size() == 2)
	var after_bruise := int(main.call("_preparation_spent_for_specs", specs))
	assert(after_bruise < after_cut and after_bruise > after_cut - (before - after_cut) * 2,
		"Bruises must cost less than deep cuts")
	var faction: Dictionary = main.call("_build_faction_spec")
	assert((faction["colonists"][0]["health_injuries"] as Array).size() == 2)
	var model := GameModel.new()
	root.add_child(model)
	assert(bool(model.validate_setup(main.call("_game_setup_config")).get("ok", false)))
	var net := root.get_node_or_null("/root/Net")
	if net != null:
		var cleaned: Dictionary = net.call("_clean_setup", faction)
		assert((cleaned["colonists"][0]["health_injuries"] as Array).size() == 2)
	if not OS.get_environment("PREPARATION_V019_CAPTURE_DIR").is_empty():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1440, 900))
		root.content_scale_size = Vector2i(1440, 900)
		(main as Control).size = Vector2(1440, 900)
		main.call("_show_characters")
		await _capture("health-v019-1440.png")
		DisplayServer.window_set_size(Vector2i(960, 540))
		root.content_scale_size = Vector2i(960, 540)
		(main as Control).size = Vector2(960, 540)
		main.call("_show_characters")
		await _capture("health-v019-960.png")
	print("PREPARATION_HEALTH_UI_V019_OK")
	quit()
