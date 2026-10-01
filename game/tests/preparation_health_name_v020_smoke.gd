extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")


func _initialize() -> void:
	call_deferred("_run")


func _capture(path: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(path) == OK)


func _run() -> void:
	var scar_spec := {"health_injuries": [{"kind": "scar", "body_part": "right_arm", "count": 2}]}
	assert(PreparationRules.preparation_injury_error(scar_spec).is_empty())
	var wounds := PreparationRules.prepared_injuries(scar_spec)
	assert(wounds.size() == 2)
	assert(wounds.all(func(entry: Variant): return entry["kind"] == "scar" and entry["body_part"] == "right_arm"))
	assert(is_equal_approx(PreparationRules.health_pain({"wounds": wounds, "conditions": []}), 0.10))
	assert(PreparationRules.prepared_injuries({"health_conditions": ["scar"]}).is_empty(),
		"Old scar conditions must not create an additional wound and double pain")
	assert(is_equal_approx(PreparationRules.health_pain({"wounds": [], "conditions": ["scar"]}), 0.05))

	var model := GameModel.new()
	root.add_child(model)
	var setup := {"seed": "scar-v020", "scenario_id": "homesteaders", "colonists_per_faction": 1,
		"point_limit_enabled": false, "faction_specs": [{"site_id": "site_1", "colonist_count": 1,
			"colonists": [{"name": "Scarred", "first_name": "Scarred", "nickname": "Scarred", "age": 30,
				"health_injuries": scar_spec["health_injuries"]}]}]}
	assert(bool(model.validate_setup(setup).get("ok", false)))
	model.start_new_game(setup)
	var person: Dictionary = model.state["colonists"][0]
	assert(person["health"]["wounds"].size() == 2)
	assert(is_equal_approx(float(person["health"]["hp"]), 100.0))
	assert(is_equal_approx(float(person["health"]["pain"]), 0.10))
	model.tick(1.0)
	assert(person["health"]["wounds"].size() == 2, "A healed scar must not disappear on the next simulation tick")
	assert(str(person["health"]["wounds"][0]["body_part"]) == "right_arm")
	var saved: Variant = JSON.parse_string(JSON.stringify(model.state))
	assert(saved is Dictionary and model.load_game(saved))
	assert((model.state["colonists"][0]["health"]["wounds"] as Array).size() == 2)

	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	assert(main.call("_normalize_prepared_nickname", "NewBramble") == "New Bramble")
	assert(main.call("_normalize_prepared_nickname", "McDonald") == "McDonald")
	var one_word := 0
	for i in range(100):
		var nickname := str(main.call("_pick_prepared_nickname", "Ada", false))
		assert(nickname.length() <= 11)
		assert(nickname.count(" ") <= 1, "Generated pairs need a visible space")
		if not nickname.contains(" "): one_word += 1
	assert(one_word >= 65, "Most generated nicknames should be one word")
	var roster := main.find_child("RosterName", true, false) as Label
	assert(roster != null)
	assert(roster.clip_text and roster.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS)
	main.call("_open_preparation_injury_dialog", -1)
	var dialog := main.find_child("PreparationInjuryDialog", true, false)
	assert(dialog != null)
	(dialog.find_child("PreparationInjury_kind", true, false) as MenuButton).get_popup().id_pressed.emit(0) # scar
	(dialog.find_child("PreparationInjury_body_part", true, false) as MenuButton).get_popup().id_pressed.emit(3) # right arm
	(dialog.find_child("PreparationInjury_count", true, false) as MenuButton).get_popup().id_pressed.emit(1) # two
	var apply: Button
	for button in dialog.find_children("*", "Button", true, false):
		if (button as Button).text == "Apply": apply = button as Button
	assert(apply != null)
	apply.pressed.emit()
	await process_frame
	var spec: Dictionary = (main.get("character_specs") as Array)[0]
	assert(str(spec["health_injuries"][0]["kind"]) == "scar")
	assert(str(spec["health_injuries"][0]["body_part"]) == "right_arm")
	assert(int(spec["health_injuries"][0]["count"]) == 2)
	assert((main.find_child("PreparationInjuryEntry_0", true, false) as Button).text.contains("Right arm"))
	spec = (main.get("character_specs") as Array)[1]
	spec["condition_ids"] = ["scar"]
	(main.get("character_specs") as Array)[1] = spec
	main.call("_preparation_migrate_legacy_injuries", 1)
	spec = (main.get("character_specs") as Array)[1]
	assert(not (spec["condition_ids"] as Array).has("scar"))
	assert(str(spec["health_injuries"][0]["kind"]) == "scar")
	assert(str(spec["health_injuries"][0]["body_part"]) == "torso")
	var capture_dir := OS.get_environment("PREPARATION_V020_CAPTURE_DIR")
	if not capture_dir.is_empty():
		var visible_spec: Dictionary = (main.get("character_specs") as Array)[0]
		visible_spec["nickname"] = "NewBramble"
		(main.get("character_specs") as Array)[0] = visible_spec
		main.get("preferences").language = "tr"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1440, 900))
		root.content_scale_size = Vector2i(1440, 900)
		(main as Control).size = Vector2(1440, 900)
		main.call("_show_characters")
		await _capture(capture_dir.path_join("health-name-v020-1440.png"))
		DisplayServer.window_set_size(Vector2i(960, 540))
		root.content_scale_size = Vector2i(960, 540)
		(main as Control).size = Vector2(960, 540)
		main.call("_show_characters")
		await _capture(capture_dir.path_join("health-name-v020-960.png"))
	print("PREPARATION_HEALTH_NAME_V020_OK")
	quit()
