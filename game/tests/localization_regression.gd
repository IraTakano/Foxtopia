extends SceneTree

const I18n = preload("res://scripts/ui/i18n.gd")


func _initialize() -> void:
	var event := {"kind": "trade_offer", "message": "Kızıltepe ticaret teklifi gönderdi.",
		"message_key": "event.trade_offer", "message_args": {"faction_name": "Kızıltepe"}}
	assert(I18n.localize_model_event(event, "en") == "Kızıltepe sent a trade offer.")
	assert(I18n.localize_model_event(event, "tr") == "Kızıltepe ticaret teklifi gönderdi.")
	assert(I18n.localize_model_event(event, "pl") == "Kızıltepe przesłała ofertę handlową.")
	var research := {"kind": "research", "message": "Taş İşçiliği araştırması tamamlandı.",
		"message_key": "event.research", "message_args": {"project_id": "stonework"}}
	assert(I18n.localize_model_event(research, "en") == "Research completed: Stonework.")
	assert(I18n.localize_model_event(research, "tr") == "Taş İşçiliği araştırması tamamlandı.")
	var build := {"kind": "build", "message": "Ahşap duvar tamamlandı.",
		"message_key": "event.build", "message_args": {"building_kind": "build_wall"}}
	assert(I18n.localize_model_event(build, "en") == "Wood wall was completed.")
	assert(I18n.localize_model_event(build, "tr") == "Ahşap duvar tamamlandı.")
	var caravan := {"kind": "caravan", "message": "Kızıltepe Ticaret Kervanı geldi.",
		"message_key": "event.caravan_arrived", "message_args": {"source_name": "Kızıltepe"}}
	assert(I18n.localize_model_event(caravan, "en") == "Red Hill trade caravan has arrived.")
	assert(I18n.localize_site_name("Kızıltepe 2", "en") == "Red Hill 2")
	assert(I18n.localize_model_text("Bu hücreye gidilemez.", "en") == "This tile cannot be reached.")
	assert(I18n.localize_model_event({"kind": "death", "message": "Ada hayatını kaybetti."}, "en") == "Ada has died.")
	var model := GameModel.new()
	root.add_child(model)
	model.start_new_game({"seed": "locale-event-save", "mode": "solo", "scenario_id": "hard_landing"})
	model._event("trade_offer", "Kızıltepe ticaret teklifi gönderdi.", "", "event.trade_offer",
		{"faction_name": "Kızıltepe"})
	var restored := GameModel.new()
	root.add_child(restored)
	assert(restored.load_game(model.serialize_game()))
	var saved_event: Dictionary = (restored.state["events"] as Array).back()
	assert(I18n.localize_model_event(saved_event, "en") == "Kızıltepe sent a trade offer.")
	assert(I18n.localize_model_event(saved_event, "tr") == "Kızıltepe ticaret teklifi gönderdi.")
	print("LOCALIZATION_REGRESSION_OK")
	quit()
