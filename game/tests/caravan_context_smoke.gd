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
	main.call("_advance_to_lobby")
	await process_frame
	var overlay: Control = main.get("_naming_overlay")
	var edits := overlay.find_children("*", "LineEdit", true, false)
	assert(edits.size() == 2)
	(edits[0] as LineEdit).text = "Test Colony"
	(edits[1] as LineEdit).text = "Test Settlement"
	for button in overlay.find_children("*", "Button", true, false):
		if button.text == "Name our home":
			button.pressed.emit()
			break
	assert(not main.get("_naming_prompt_open"))
	var person: Dictionary = main.call("_local_colonists", main.call("_snapshot"))[0]
	var pos := Vector2i(int(person["x"]), int(person["y"]))
	var trader_tile := Vector2i(-1, -1)
	for direction in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
		var candidate: Vector2i = pos + direction
		if main.call("_map_tile_passable", candidate):
			trader_tile = candidate
			break
	assert(trader_tile.x >= 0)
	var faction: Dictionary = main.call("_my_faction", main.call("_snapshot"))
	var model: GameModel = root.get_node("Game")
	model.state["caravans"].append({"id": "test_trader", "kind": "npc", "site_id": person["site_id"],
		"faction_id": faction["id"], "trader_name": "Maren", "name": "Test Caravan",
		"x": trader_tile.x, "y": trader_tile.y, "ttl": 50,
		"stock": {"wood": 10, "stone": 0, "food": 10, "medicine": 0, "silver": 100,
		"spear": 0, "tshirt": 1, "pants": 1, "jacket": 0}})
	main.call("_select_colonist", str(person["id"]))
	main.call("_on_map_pressed", trader_tile, "", "", MOUSE_BUTTON_RIGHT)
	var menu: PopupMenu = main.get("_context_menu")
	var trade_label := ""
	for index in range(menu.item_count):
		if menu.get_item_id(index) == 5:
			trade_label = menu.get_item_text(index)
	assert(trade_label == "Trade with Maren", "Expected named trader interaction")
	main.call("_context_selected", 5)
	assert(str(person.get("manual", {}).get("action", "")) == "trade")
	model.tick(1.0)
	assert(int(model.state["caravans"][0].get("trade_ready_until", -1)) >= int(model.state["time"]))
	assert(main.get("_trade_caravan_pending_id") == "")
	var trade_dialogs := main.find_children("*", "PopupPanel", true, false)
	assert(not trade_dialogs.is_empty(), "Trader interaction should open the exchange dialog")
	print("CARAVAN_CONTEXT_SMOKE_OK")
	quit()
