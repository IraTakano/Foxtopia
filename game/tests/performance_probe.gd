extends Node

const MainScript = preload("res://scripts/ui/main.gd")


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MainScript.new()
	get_tree().root.add_child(main)
	await get_tree().process_frame
	var model: GameModel = get_node("/root/Game")
	var world: Dictionary = model.preview_world("fps-probe-2026")
	var site_id := ""
	for site in world.get("sites", []):
		if str(site.get("kind", "")) == "vacant":
			site_id = str(site.get("id", ""))
			break
	assert(not site_id.is_empty())
	var result: Dictionary = model.start_new_game({"seed": "fps-probe-2026", "mode": "solo", "scenario_id": "landfall", "point_limit_enabled": false,
		"faction_specs": [{"site_id": site_id, "name": "Probe", "settlement_name": "Probe Town", "players": [1]}]})
	assert(not result.is_empty() and not model.state.is_empty())
	main.selected_site_id = site_id
	main.selected_ids = [str(model.state["colonists"][0]["id"])]
	main._show_game()
	await get_tree().process_frame
	var samples: Array[float] = []
	for step in 60:
		var start := Time.get_ticks_usec()
		model.tick(1.0)
		samples.append(float(Time.get_ticks_usec() - start) / 1000.0)
		await get_tree().process_frame
	samples.sort()
	var total := 0.0
	for sample in samples: total += sample
	print("PERF tick+UI avg=%.2fms median=%.2fms p95=%.2fms max=%.2fms" % [total / samples.size(), samples[30], samples[57], samples[59]])
	get_tree().quit()
