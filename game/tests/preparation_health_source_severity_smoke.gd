extends SceneTree

const PreparationRules = preload("res://scripts/model/preparation_rules.gd")


func _initialize() -> void:
	call_deferred("_run")


func _apply_button(dialog: Node) -> Button:
	for button in dialog.find_children("*", "Button", true, false):
		if (button as Button).text in ["Apply", "Uygula", "Zastosuj"]:
			return button as Button
	return null


func _select_scratch(dialog: Node) -> void:
	var kind := dialog.find_child("PreparationInjury_kind", true, false) as MenuButton
	var tier := dialog.find_child("PreparationInjury_severity_tier", true, false) as MenuButton
	var cause := dialog.find_child("PreparationInjury_cause", true, false) as MenuButton
	assert(kind != null and tier != null and cause != null)
	kind.get_popup().id_pressed.emit(3) # bruise
	assert(tier.get_popup().item_count == 2)
	assert(tier.text.contains("6"), "New bruises keep the former six-damage default")
	kind.get_popup().id_pressed.emit(5) # scratch
	assert(cause.get_popup().item_count == 2)
	tier.get_popup().id_pressed.emit(3) # extreme
	cause.get_popup().id_pressed.emit(1) # animal claw


func _run() -> void:
	var injury := {"kind": "scratch", "body_part": "right_arm", "count": 1,
		"severity_tier": "extreme", "cause": "animal_claw"}
	assert(PreparationRules.preparation_injury_error({"health_injuries": [injury]}).is_empty())
	var wound: Dictionary = PreparationRules.prepared_injuries({"health_injuries": [injury]})[0]
	assert(is_equal_approx(float(wound["severity"]), 8.0))
	assert(is_equal_approx(float(wound["bleeding"]), 0.20))
	assert(is_equal_approx(PreparationRules.wound_pain(wound), 0.10))
	assert(str(wound["cause"]) == "animal_claw")
	var invalid_cause: Dictionary = injury.duplicate(true)
	invalid_cause["cause"] = "human_fist"
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [invalid_cause]}).is_empty())
	var invalid_tier: Dictionary = injury.duplicate(true)
	invalid_tier["severity_tier"] = "lethal"
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [invalid_tier]}).is_empty())
	assert(not PreparationRules.preparation_injury_error({"health_injuries": [
		{"kind": "cut_deep", "body_part": "head", "count": 1,
			"severity_tier": "extreme", "cause": "knife"}]}).is_empty())
	var scar := {"kind": "scar", "body_part": "left_leg", "count": 1,
		"severity_tier": "severe", "cause": "old_burn"}
	var scar_wound: Dictionary = PreparationRules.prepared_injuries({"health_injuries": [scar]})[0]
	assert(is_equal_approx(float(scar_wound["severity"]), 3.0))
	assert(is_equal_approx(PreparationRules.wound_pain(scar_wound), 0.01875))
	var legacy_wound: Dictionary = PreparationRules.prepared_injuries({"health_injuries": [
		{"kind": "cut_light", "body_part": "left_arm", "count": 1}]})[0]
	assert(is_equal_approx(float(legacy_wound["severity"]), 4.0))
	assert(is_equal_approx(float(legacy_wound["bleeding"]), 0.10))
	assert(PreparationRules.injury_severity_tiers("bruise") == ["minor", "moderate"])
	assert(PreparationRules.injury_default_tier("bruise") == "moderate")
	assert(is_equal_approx(PreparationRules.injury_severity("bruise", "moderate"), 6.0))
	for old_tier in ["severe", "extreme"]:
		assert(PreparationRules.preparation_injury_error({"health_injuries": [{"kind": "bruise",
			"body_part": "left_arm", "count": 1, "severity_tier": old_tier}]}).is_empty(),
			"Existing bruise tier must remain loadable")
	var model := GameModel.new()
	root.add_child(model)
	var minor := {"kind": "cut_light", "body_part": "left_arm", "count": 1,
		"severity_tier": "minor", "cause": "knife"}
	var moderate: Dictionary = minor.duplicate(true)
	moderate["severity_tier"] = "moderate"
	assert(model.preparation_points({"health_injuries": [moderate]}) <
		model.preparation_points({"health_injuries": [minor]}))
	assert(PreparationRules.injury_severity_tiers("cut_light") == ["minor", "moderate"])
	assert(PreparationRules.injury_severity_tiers("cut_deep") == ["severe", "extreme"])
	var person := {"name": "Cause Test", "age": 30, "health_injuries": [injury, scar]}
	var config := {"seed": "health-cause-severity", "scenario_id": "homesteaders",
		"colonists_per_faction": 1, "point_limit_enabled": false,
		"faction_specs": [{"site_id": "site_1", "colonist_count": 1, "colonists": [person]}]}
	assert(bool(model.validate_setup(config).get("ok", false)))
	var net := root.get_node_or_null("/root/Net")
	assert(net != null)
	var cleaned: Dictionary = net.call("_clean_setup", config["faction_specs"][0])
	assert(cleaned["colonists"][0]["health_injuries"][0]["cause"] == "animal_claw")
	assert(cleaned["colonists"][0]["health_injuries"][0]["severity_tier"] == "extreme")
	model.start_new_game(config)
	assert(not model.state.is_empty())
	var health: Dictionary = model.state["colonists"][0]["health"]
	assert(health["wounds"].size() == 2)
	assert(health["wounds"][0]["cause"] == "animal_claw")
	assert(health["wounds"][0]["severity_tier"] == "extreme")
	assert(health["wounds"][1]["cause"] == "old_burn")
	var serialized: Variant = JSON.parse_string(JSON.stringify(model.serialize_game()))
	assert(serialized is Dictionary)
	assert(serialized["colonists"][0]["health"]["wounds"][0]["cause"] == "animal_claw")
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	var capture_language := OS.get_environment("PREPARATION_HEALTH_SOURCE_LANGUAGE")
	if capture_language in ["en", "tr", "pl"]:
		(main.get("preferences") as FoxtopiaSettings).language = capture_language
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	main.call("_open_preparation_injury_dialog", -1)
	var dialog := main.find_child("PreparationInjuryDialog", true, false)
	assert(dialog != null)
	_select_scratch(dialog)
	var capture_dir := OS.get_environment("PREPARATION_HEALTH_SOURCE_CAPTURE_DIR")
	if not capture_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(capture_dir)
		for dimensions in [Vector2i(1440, 900), Vector2i(960, 540)]:
			dialog.queue_free()
			await process_frame
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(dimensions)
			root.content_scale_size = dimensions
			(main as Control).size = Vector2(dimensions)
			main.call("_show_characters")
			await process_frame
			main.call("_open_preparation_injury_dialog", -1)
			dialog = main.find_child("PreparationInjuryDialog", true, false)
			assert(dialog != null)
			_select_scratch(dialog)
			await process_frame
			await RenderingServer.frame_post_draw
			assert(root.get_texture().get_image().save_png(capture_dir.path_join(
				"health-cause-%d.png" % dimensions.x)) == OK)
	var apply := _apply_button(dialog)
	assert(apply != null)
	apply.pressed.emit()
	await process_frame
	var prepared: Dictionary = (main.get("character_specs") as Array)[0]
	assert(prepared["health_injuries"][0]["kind"] == "scratch")
	assert(prepared["health_injuries"][0]["severity_tier"] == "extreme")
	assert(prepared["health_injuries"][0]["cause"] == "animal_claw")
	print("PREPARATION_HEALTH_SOURCE_SEVERITY_OK")
	quit()
