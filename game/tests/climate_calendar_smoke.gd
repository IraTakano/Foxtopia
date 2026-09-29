extends SceneTree

const Calendar = preload("res://scripts/model/climate_calendar.gd")


func _initialize() -> void:
	assert(Calendar.DAYS_PER_PERIOD == 15)
	assert(Calendar.DAYS_PER_YEAR == 60)
	assert(Calendar.date_from_steps(0)["period_day"] == 1)
	assert(Calendar.date_from_steps(15 * 600)["period_index"] == 1)
	assert(Calendar.date_from_steps(60 * 600)["year"] == 5501)
	assert(Calendar.date_from_steps(60 * 600)["period_day"] == 1)
	var north := Calendar.describe(12.0, 45.0)
	var south := Calendar.describe(12.0, -45.0)
	assert(north["monthly_temperatures"].size() == 4)
	assert(north["monthly_temperatures"][1]["season"] == "summer")
	assert(south["monthly_temperatures"][1]["season"] == "winter")
	assert(north["monthly_temperatures"][1]["average"] > north["monthly_temperatures"][3]["average"])
	assert(south["monthly_temperatures"][1]["average"] < south["monthly_temperatures"][3]["average"])
	assert(north["growing_days"] == south["growing_days"])
	assert(Calendar.describe(-40.0, 80.0)["growing_days"] == 0)
	assert(Calendar.describe(25.0, 0.0)["growing_days"] == 60)
	assert(Calendar.describe(-40.0, 80.0)["season_pattern"] == "permanent_winter")
	assert(Calendar.describe(25.0, 0.0)["season_pattern"] == "permanent_summer")
	var model := GameModel.new()
	root.add_child(model)
	var world := model.preview_world("climate-smoke")
	assert(world["calendar"]["days_per_year"] == 60)
	var site_id := str(world["sites"][0]["id"])
	var site := model.describe_site(world, site_id)
	assert(site["monthly_temperatures"].size() == 4)
	assert(site["temperature_min"] <= site["temperature"])
	assert(site["temperature_max"] >= site["temperature"])
	assert(site["growing_days"] >= 0 and site["growing_days"] <= 60)
	var repeat := model.describe_site(model.preview_world("climate-smoke"), site_id)
	assert(site["monthly_temperatures"] == repeat["monthly_temperatures"])
	var spec := {"id": "faction_1", "name": "Climate colony", "settlement_name": "Climate site",
		"players": [1], "site_id": site_id, "colonists": [{}]}
	var started := model.start_new_game({"seed": "climate-smoke", "mode": "solo",
		"scenario_id": "hard_landing", "faction_specs": [spec], "point_limit_enabled": false})
	assert(started.has("maps"), str(started))
	var map_data: Dictionary = model.state["maps"][site_id]
	map_data["structures"].append({"id": "climate_farm", "kind": "farm", "x": 20, "y": 20})
	map_data["site_info"]["temperature"] = -40.0
	map_data["site_info"]["latitude"] = 80.0
	model.state["time"] = 79
	model.tick(1.0)
	assert(map_data["drops"].is_empty(), "Farm produced food below growing temperature")
	map_data["site_info"]["temperature"] = 25.0
	map_data["site_info"]["latitude"] = 0.0
	model.state["time"] = 159
	model.tick(1.0)
	assert(map_data["drops"].size() == 1, "Farm did not produce in growing season")
	var legacy := model.serialize_game()
	legacy["world"].erase("calendar")
	legacy["maps"][site_id]["site_info"].erase("monthly_temperatures")
	assert(model.load_game(legacy))
	assert(model.state["world"].has("calendar"))
	assert(model.state["maps"][site_id]["site_info"].has("monthly_temperatures"))
	print("CLIMATE_CALENDAR_SMOKE_OK")
	quit()
