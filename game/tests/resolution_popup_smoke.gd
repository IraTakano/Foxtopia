extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Run this test with a visible Windows display.")
		quit(1)
		return
	change_scene_to_file("res://scenes/main.tscn")
	await process_frame
	await process_frame
	var main := current_scene
	main.call("_show_settings")
	var overlay: Control = main.get("_settings_overlay")
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == main.call("_tr", "settings.display"):
			button.pressed.emit()
			break
	await process_frame
	await process_frame
	var selectors := overlay.find_children("*", "OptionButton", true, false)
	if selectors.size() != 2:
		push_error("Graphics settings selectors are missing.")
		quit(1)
		return
	var modes := selectors[0] as OptionButton
	var resolutions := selectors[1] as OptionButton
	modes.select(1)
	modes.item_selected.emit(1)
	resolutions.show_popup()
	await process_frame
	await process_frame
	var popup := resolutions.get_popup()
	var bars := popup.find_children("*", "VScrollBar", true, false)
	if popup.size.y > 320 or bars.is_empty():
		push_error("Resolution list exceeds its height limit or has no scrollbar.")
		quit(1)
		return
	var bar := bars[0] as VScrollBar
	if not bar.visible or bar.max_value <= bar.page:
		push_error("Resolution list cannot be scrolled.")
		quit(1)
		return
	popup.scroll_to_item(resolutions.item_count - 1)
	await process_frame
	if bar.value <= 0.0:
		push_error("Last resolution cannot be reached by scrolling.")
		quit(1)
		return
	popup.hide()
	print("RESOLUTION_POPUP_SMOKE_OK")
	quit()
