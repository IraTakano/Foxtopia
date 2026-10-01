extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")


func _initialize() -> void:
	call_deferred("_run")


func _capture(name: String) -> void:
	var folder := OS.get_environment("PREPARATION_BRUISE_CAPTURE_DIR")
	if folder.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(folder)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(folder.path_join(name + ".png")) == OK)


func _open_bruise(main: Node) -> void:
	main.call("_open_preparation_injury_dialog", -1)
	var dialog := main.find_child("PreparationInjuryDialog", true, false)
	assert(dialog != null)
	var kind := dialog.find_child("PreparationInjury_kind", true, false) as MenuButton
	var tier := dialog.find_child("PreparationInjury_severity_tier", true, false) as MenuButton
	assert(kind != null and tier != null)
	kind.get_popup().id_pressed.emit(3)
	assert(tier.get_popup().item_count == 2)
	assert(tier.get_popup().get_item_text(0).contains("2"))
	assert(tier.get_popup().get_item_text(1).contains("6"))
	assert(tier.text == tier.get_popup().get_item_text(1))


func _run() -> void:
	assert(PreparationRules.injury_severity_tiers("bruise") == ["minor", "moderate"])
	for tier in ["severe", "extreme"]:
		assert(PreparationRules.preparation_injury_error({"health_injuries": [{"kind": "bruise",
			"body_part": "left_arm", "count": 1, "severity_tier": tier}]}).is_empty())
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	(main.get("preferences") as FoxtopiaSettings).language = "tr"
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	for dimensions in [Vector2i(1440, 900), Vector2i(960, 540)]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(dimensions)
		root.content_scale_size = dimensions
		(main as Control).size = Vector2(dimensions)
		main.call("_show_characters")
		_open_bruise(main)
		await _capture("bruise-%d" % dimensions.x)
		main.find_child("PreparationInjuryDialog", true, false).queue_free()
		await process_frame
	print("PREPARATION_BRUISE_V024_OK")
	quit()
