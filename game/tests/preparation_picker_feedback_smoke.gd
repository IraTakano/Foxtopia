extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _filter_index(filters: Array, filter_id: String) -> int:
	for index in filters.size():
		if str(filters[index]["id"]) == filter_id:
			return index
	return -1


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")

	var trait_filters: Array = main.call("_preparation_option_filters", "trait")
	assert(_filter_index(trait_filters, "work_speed_effect") >= 0)
	assert(_filter_index(trait_filters, "social_effect") >= 0)
	assert(_filter_index(trait_filters, "skill_bonus:intellectual") == -1)
	assert(bool(main.call("_preparation_option_matches", "trait", "curious", "work_speed_effect")))
	assert(bool(main.call("_preparation_option_matches", "trait", "kind", "social_effect")))
	assert(not bool(main.call("_preparation_option_matches", "trait", "kind", "movement_effect")))
	assert(bool(main.call("_preparation_option_matches", "trait", "pyromaniac", "work_restriction")))
	assert(bool(main.call("_preparation_option_matches", "trait", "quick", "movement_effect")))

	main.call("_open_preparation_option_dialog", "childhood", ["rural_child", "town_child", "apprentice", "vatgrown_soldier"], ["Rural child", "Town child", "Apprentice", "Vatgrown soldier"], "rural_child", func(_id: String): pass)
	var dialog := main.find_child("PreparationOptionDialog", true, false)
	assert(dialog != null)
	var rows := dialog.find_child("PreparationChoiceRows", true, false)
	var details := dialog.find_child("PreparationChoiceDetails", true, false) as Label
	var filter_menu := dialog.find_child("PreparationChoiceFilter", true, false) as MenuButton
	assert(rows.get_child_count() == 4)
	for row in rows.get_children():
		assert((row as Button).tooltip_text.is_empty())
	(rows.get_child(1) as Button).mouse_entered.emit()
	assert(details.text.begins_with("Town child"))
	var backstory_filters: Array = main.call("_preparation_option_filters", "childhood")
	filter_menu.get_popup().id_pressed.emit(_filter_index(backstory_filters, "skill:shooting"))
	assert(rows.get_child_count() == 1)
	var remove_filter := dialog.find_child("PreparationFilterRemove_skill_shooting", true, false) as Button
	assert(remove_filter != null)
	remove_filter.pressed.emit()
	assert(rows.get_child_count() == 4)
	dialog.queue_free()
	await process_frame

	var trait_entry := main.find_child("PreparationTraitEntry", true, false) as Button
	assert(trait_entry != null)
	assert(trait_entry.get_theme_stylebox("normal") is StyleBoxEmpty)
	trait_entry.mouse_entered.emit()
	var hover := main.get_node_or_null("PreparationEntryHover") as PanelContainer
	assert(hover != null)
	var hover_style := hover.get_theme_stylebox("panel") as StyleBoxFlat
	assert(hover_style != null and hover_style.bg_color.a >= 0.99)
	trait_entry.mouse_exited.emit()
	assert(main.get_node_or_null("PreparationEntryHover") == null)

	var specs: Array = main.get("character_specs")
	specs[0]["condition_ids"] = ["asthma"]
	main.call("_show_characters")
	var health_entry := main.find_child("PreparationHealthEntry", true, false) as Button
	assert(health_entry != null)
	health_entry.mouse_entered.emit()
	assert(main.get_node_or_null("PreparationEntryHover") != null)
	health_entry.mouse_exited.emit()
	assert(main.get_node_or_null("PreparationEntryHover") == null)
	print("PREPARATION_PICKER_FEEDBACK_OK")
	quit()
