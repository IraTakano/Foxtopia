extends SceneTree

const Store = preload("res://scripts/ui/preparation_preset_store.gd")


func _initialize() -> void:
	call_deferred("_run")


func _button_in(node: Node, caption: String) -> Button:
	for button in node.find_children("*", "Button", true, false):
		if (button as Button).text.begins_with(caption):
			return button as Button
	return null


func _run() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_begin_session", "solo")
	main.call("_advance_to_world")
	main.call("_show_characters")
	for saved in Store.list_slots("character"):
		assert(str(saved["id"]) != "old_character", "Generated legacy placeholder must stay out of the library")
	for saved in Store.list_slots("crew"):
		assert(str(saved["id"]) != "old_crew", "Generated legacy placeholder must stay out of the library")
	var original_name := str((main.get("character_specs") as Array)[0]["name"])
	var slot_name := "Character UI %d" % Time.get_ticks_usec()
	main.call("_save_character_preset")
	var panels := main.find_children("*", "PopupPanel", true, false)
	assert(not panels.is_empty())
	var save_popup: PopupPanel = panels.back()
	var name_inputs := save_popup.find_children("*", "LineEdit", true, false)
	assert(name_inputs.size() == 1)
	(name_inputs[0] as LineEdit).text = slot_name
	var create := _button_in(save_popup, main.call("_prep_local", "Create new save", "Yeni kayıt oluştur", "Utwórz nowy zapis"))
	assert(create != null)
	create.pressed.emit()
	var slot_id := Store.safe_id(slot_name)
	assert(not Store.load_slot("character", slot_id).is_empty())
	var changed_specs: Array = main.get("character_specs")
	(changed_specs[0] as Dictionary)["name"] = "Changed after save"
	main.set("character_specs", changed_specs)
	main.call("_load_character_preset")
	panels = main.find_children("*", "PopupPanel", true, false)
	assert(not panels.is_empty())
	var load_popup: PopupPanel = panels.back()
	var load_button := _button_in(load_popup, main.call("_prep_local", "Load", "Yükle", "Wczytaj") + "  " + slot_name)
	assert(load_button != null)
	load_button.pressed.emit()
	assert(str((main.get("character_specs") as Array)[0]["name"]) == original_name)
	assert(Store.delete_slot("character", slot_id))
	print("PREPARATION_LIBRARY_UI_SMOKE_OK")
	quit()
