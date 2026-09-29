extends Node
class_name GameModel

const SetupCatalog = preload("res://scripts/model/setup_catalog.gd")
const ClimateCalendar = preload("res://scripts/model/climate_calendar.gd")
const AUTOSAVE_PREFIX := "autosave_"
const AUTOSAVE_LIMIT := 20

## Authoritative, transport-independent game simulation. All values in state are
## JSON-compatible so the server can send snapshots and save the same data.
signal state_changed(snapshot: Dictionary)
signal event_emitted(event: Dictionary)

const LOCAL_SIZE := 50
const WORLD_WIDTH := 96
const WORLD_HEIGHT := 60
const WORK_TYPES := ["chop", "mine", "harvest", "haul", "build", "research", "treat"]
const RESOURCE_KINDS := {"chop": "tree", "mine": "stone", "harvest": "berry"}
const OUTPUT_KINDS := {"chop": "wood", "mine": "stone", "harvest": "food"}
const BUILD_COSTS := {
	"build_wall": {"wood": 3},
	"build_bed": {"wood": 5},
	"build_research_bench": {"wood": 7, "stone": 3},
	"build_styling_table": {"wood": 6, "stone": 2},
	"build_stone_wall": {"stone": 4},
	"build_barrier": {"wood": 4, "stone": 2},
}
const RESEARCH_PROJECTS := {
	"farming": {"name": "Tarım", "cost": 25, "requires": []},
	"first_aid": {"name": "İlk Yardım", "cost": 30, "requires": []},
	"stonework": {"name": "Taş İşçiliği", "cost": 35, "requires": []},
	"barriers": {"name": "Barikat", "cost": 40, "requires": ["stonework"]},
}
const ITEM_PRICES := {"wood": 2, "stone": 3, "food": 4, "medicine": 12, "spear": 18, "jacket": 11}
const TRAIT_COSTS := {"hardworking": 6, "calm": 4, "quick": 4, "curious": 3,
	"kind": 3, "night_owl": 2, "timid": -4, "abrasive": -4, "lazy": -6}
const HEALTH_CONDITION_COSTS := {"asthma": -4, "bad_back": -5, "scar": -2}
const CHILDHOOD_SKILL_BONUSES := {"rural_child": "harvest", "town_child": "haul", "apprentice": "build"}
const ADULTHOOD_SKILL_BONUSES := {"farmer": "harvest", "builder": "build", "medic": "treat", "scholar": "research"}
const STARTING_GEAR_COSTS := {"fists": 0, "spear": 3, "clothes": 0, "jacket": 2}
const STARTING_RELATIONSHIP_OPINIONS := {"friend": 35, "rival": -35, "partner": 65,
	"parent": 45, "child": 45, "sibling": 40}
const PREPARATION_POINT_LIMIT := 12
const FIRST_NAMES := ["Ada", "Deniz", "Efe", "Elif", "Emir", "Maya", "Mert", "Nil", "Selin", "Tuna", "Zeynep", "Arda"]
const SITE_NAMES := ["Çınar", "Kavak", "Akkaya", "Yeşilova", "Güneydere", "Kuzeyyaka", "Taşlık", "Yelbayır", "Söğüt", "Gökova", "Kızıltepe", "Ilıca", "Umut", "Serin", "Akpınar", "Günyeli"]

var state: Dictionary = {}
var active_colony_id: String = ""
var _tick_remainder: float = 0.0
var _autosave_elapsed: float = 0.0
var _next_autosave_slot: int = 0
var _has_unsaved_changes: bool = false
var _last_saved_slot: String = ""
var _save_directory_name: String = "saves"
var _route_cache: Dictionary = {}

var world: Dictionary:
	get:
		return state.get("world", {})

var colonies: Array:
	get:
		return state.get("factions", [])


func preview_world(seed_text: String, options: Dictionary = {}) -> Dictionary:
	var seed_value := seed_text.strip_edges()
	if seed_value.is_empty():
		seed_value = "Foxtopia-%d" % Time.get_unix_time_from_system()
	var world_options := {
		"coverage": clampf(float(options.get("coverage", 0.50)), 0.25, 0.75),
		"rainfall": clampf(float(options.get("rainfall", 0.50)), 0.0, 1.0),
		"temperature": clampf(float(options.get("temperature", 0.50)), 0.0, 1.0),
		"population": clampf(float(options.get("population", 0.50)), 0.0, 1.0),
	}
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number(seed_value)
	var continent := FastNoiseLite.new()
	continent.seed = int(rng.randi())
	continent.frequency = 0.065
	continent.fractal_octaves = 4
	continent.fractal_gain = 0.48
	var details := FastNoiseLite.new()
	details.seed = int(rng.randi())
	details.frequency = 0.16
	details.fractal_octaves = 3
	var climate := FastNoiseLite.new()
	climate.seed = int(rng.randi())
	climate.frequency = 0.09
	climate.fractal_octaves = 3
	# Several seeded continental plates leave broad, navigable seas between them.
	var land_masses := [
		{"center": Vector2(0.29 + rng.randf_range(-0.075, 0.075), 0.31 + rng.randf_range(-0.08, 0.08)), "radius": Vector2(rng.randf_range(0.17, 0.20), rng.randf_range(0.19, 0.25))},
		{"center": Vector2(0.70 + rng.randf_range(-0.075, 0.075), 0.37 + rng.randf_range(-0.08, 0.08)), "radius": Vector2(rng.randf_range(0.17, 0.20), rng.randf_range(0.19, 0.24))},
		{"center": Vector2(0.55 + rng.randf_range(-0.10, 0.10), 0.76 + rng.randf_range(-0.07, 0.07)), "radius": Vector2(rng.randf_range(0.18, 0.22), rng.randf_range(0.17, 0.22))},
		{"center": Vector2(0.17 + rng.randf_range(-0.07, 0.07), 0.72 + rng.randf_range(-0.08, 0.08)), "radius": Vector2(rng.randf_range(0.085, 0.12), rng.randf_range(0.09, 0.14))},
	]
	var tiles: Array = []
	var elevations: Array = []
	var rainfalls: Array = []
	var temperatures: Array = []
	var coverage_scale := sqrt(float(world_options["coverage"]) / 0.50)
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var position := Vector2((float(x) + 0.5) / float(WORLD_WIDTH), (float(y) + 0.5) / float(WORLD_HEIGHT))
			var height := -1.0
			for mass in land_masses:
				var offset: Vector2 = (position - mass["center"]) / (mass["radius"] * coverage_scale)
				height = maxf(height, 1.0 - offset.length())
			height += continent.get_noise_2d(float(x), float(y)) * 0.35
			height += details.get_noise_2d(float(x), float(y)) * 0.075
			var moisture := climate.get_noise_2d(float(x), float(y))
			var ruggedness := details.get_noise_2d(float(x) + 91.0, float(y) - 57.0)
			var latitude := absf(position.y - 0.5) * 2.0
			var temperature := 29.0 - latitude * 32.0 + (float(world_options["temperature"]) - 0.5) * 24.0 + climate.get_noise_2d(float(x) + 231.0, float(y)) * 8.0 - maxf(height - 0.35, 0.0) * 17.0
			var rainfall := clampf(620.0 + moisture * 880.0 + (float(world_options["rainfall"]) - 0.5) * 1050.0 - latitude * 170.0, 80.0, 2000.0)
			var elevation := maxf(0.0, (height - 0.10) * 2400.0 + ruggedness * 250.0)
			var biome := "plains"
			if height < 0.145:
				biome = "water"
			elif height > 0.48 and ruggedness > 0.07:
				biome = "rocky"
			elif temperature < 0.0:
				biome = "tundra"
			elif rainfall < 410.0:
				biome = "arid"
			elif rainfall > 720.0:
				biome = "forest"
			tiles.append(biome)
			elevations.append(snappedf(elevation, 1.0))
			rainfalls.append(snappedf(rainfall, 1.0))
			temperatures.append(snappedf(temperature, 0.1))
	var sites: Array = []
	var population_count := clampi(roundi(22.0 + float(world_options["population"]) * 54.0), 22, 76)
	for i in range(population_count):
		var pos := _find_site_position(rng, sites, tiles)
		var kind := "vacant"
		if i >= population_count / 2 and i < population_count * 3 / 4:
			kind = "friendly"
		elif i >= population_count * 3 / 4:
			kind = "hostile"
		var site_name: String = SITE_NAMES[i % SITE_NAMES.size()]
		sites.append({
			"id": "site_%d" % (i + 1), "x": pos.x, "y": pos.y,
			"biome": tiles[pos.y * WORLD_WIDTH + pos.x],
			"kind": kind, "name": site_name if i < SITE_NAMES.size() else "%s %d" % [site_name, i / SITE_NAMES.size() + 1],
		})
	return {"seed": seed_value, "width": WORLD_WIDTH, "height": WORLD_HEIGHT,
		"tiles": tiles, "elevation": elevations, "rainfall_map": rainfalls,
		"temperature_map": temperatures, "options": world_options, "sites": sites,
		"calendar": ClimateCalendar.world_calendar()}


func describe_site(world_data: Dictionary, site_id: String) -> Dictionary:
	var site: Dictionary = _site_by_id(world_data, site_id)
	var x := int(site.get("x", -1))
	var y := int(site.get("y", -1))
	if site_id.begins_with("tile_"):
		var parts := site_id.trim_prefix("tile_").split("_")
		if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
			x = int(parts[0])
			y = int(parts[1])
	var width := int(world_data.get("width", 0))
	var height := int(world_data.get("height", 0))
	var tiles: Array = world_data.get("tiles", [])
	if x < 0 or y < 0 or x >= width or y >= height or y * width + x >= tiles.size():
		return {}
	var index := y * width + x
	var biome := str(tiles[index])
	if biome == "water":
		return {}
	var elevation_data: Array = world_data.get("elevation", [])
	var rainfall_data: Array = world_data.get("rainfall_map", [])
	var temperature_data: Array = world_data.get("temperature_map", [])
	var elevation := int(elevation_data[index]) if index < elevation_data.size() else 200
	var rainfall := int(rainfall_data[index]) if index < rainfall_data.size() else 700
	var temperature := float(temperature_data[index]) if index < temperature_data.size() else 18.0
	var site_latitude := snappedf((0.5 - (float(y) + 0.5) / float(height)) * 180.0, 0.1)
	var climate_profile: Dictionary = ClimateCalendar.describe(temperature, site_latitude)
	var terrain := "Mountainous" if biome == "rocky" and elevation > 700 else "Hilly" if elevation > 450 or biome == "rocky" else "Flat"
	var coast_direction := ""
	var nearest_water := 99
	for direction in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
		var step: Vector2i = direction
		for distance in range(1, 5):
			var neighbor_x: int = posmod(x + step.x * distance, width)
			var neighbor_y: int = y + step.y * distance
			if neighbor_y < 0 or neighbor_y >= height:
				break
			if str(tiles[neighbor_y * width + neighbor_x]) == "water":
				if distance < nearest_water:
					nearest_water = distance
					coast_direction = "west" if step.x < 0 else "east" if step.x > 0 else "north" if step.y < 0 else "south"
				break
	var hash_value := _seed_number("%s/%d/%d/stone" % [str(world_data.get("seed", "")), x, y])
	return {
		"id": site_id, "name": str(site.get("name", "Unsettled land")), "x": x, "y": y,
		"kind": str(site.get("kind", "vacant")), "biome": biome,
		"terrain": terrain, "elevation": elevation, "rainfall": rainfall,
		"temperature": temperature, "temperature_min": climate_profile["temperature_min"],
		"temperature_max": climate_profile["temperature_max"],
		"monthly_temperatures": climate_profile["monthly_temperatures"],
		"season_pattern": climate_profile["season_pattern"],
		"growing_days": climate_profile["growing_days"],
		"growing_periods": climate_profile["growing_periods"],
		"coastal": nearest_water <= 3, "coast_direction": coast_direction if nearest_water <= 3 else "",
		"stone_types": ["granite", "slate"] if hash_value % 2 == 0 else ["limestone", "sandstone"],
		"latitude": site_latitude,
		"longitude": snappedf(((float(x) + 0.5) / float(width) - 0.5) * 360.0, 0.1),
	}


func preview_local_map(world_data: Dictionary, site_id: String) -> Dictionary:
	var site_info := describe_site(world_data, site_id)
	if site_info.is_empty():
		return {}
	return _generate_local_map(str(world_data.get("seed", "")), site_id, str(site_info["biome"]), site_info)


func _starting_inventory(spec: Dictionary, scenario_id: String) -> Dictionary:
	var scenario: Dictionary = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, scenario_id)
	var defaults: Dictionary = scenario.get("inventory", {})
	var inventory: Dictionary = defaults.duplicate(true)
	var chosen: Variant = spec.get("starting_cargo", {})
	if chosen is Dictionary and not chosen.is_empty():
		for item in defaults.keys():
			inventory[item] = clampi(int(chosen.get(item, 0)), 0, 999)
	return inventory


func start_new_game(config: Dictionary) -> Dictionary:
	var seed_text: String = str(config.get("seed", "")).strip_edges()
	if seed_text.is_empty(): seed_text = "Foxtopia-%d" % Time.get_unix_time_from_system()
	var mode: String = str(config.get("mode", "solo"))
	if not mode in ["solo", "coop", "competitive"]:
		mode = "solo"
	var selected_scenario := str(config.get("scenario_id", "landfall"))
	var count: int = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, selected_scenario).get("colonist_count", 3))
	var selected_storyteller := str(config.get("storyteller_id", "steady"))
	var selected_difficulty := str(config.get("difficulty_id", "frontier"))
	var generated_world := preview_world(seed_text, config.get("world_options", {}))
	var specs: Array = config.get("faction_specs", [])
	if specs.is_empty():
		specs = _default_specs(config, mode, generated_world, count)
	var normalized := config.duplicate(true)
	normalized["seed"] = seed_text
	normalized["faction_specs"] = specs
	var validation := validate_setup(normalized)
	if not bool(validation.get("ok", false)): return validation
	var factions: Array = []
	var players: Dictionary = {}
	var colonists: Array = []
	var maps: Dictionary = {}
	var used_sites: Array = []
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var faction_id := str(spec.get("id", "faction_%d" % (i + 1)))
		var site_id := _resolve_start_site(generated_world, str(spec.get("site_id", "site_%d" % (i + 1))), used_sites)
		used_sites.append(site_id)
		var faction_name := str(spec.get("name", "Unnamed colony")).strip_edges()
		var settlement_name := str(spec.get("settlement_name", "Unnamed settlement")).strip_edges()
		if faction_name.is_empty(): faction_name = "Unnamed colony"
		if settlement_name.is_empty(): settlement_name = "Unnamed settlement"
		var peer_ids: Array = spec.get("players", [i + 1])
		if peer_ids.is_empty(): peer_ids = [i + 1]
		var faction := {
			"id": faction_id, "name": faction_name,
			"settlement_name": settlement_name, "site_id": site_id,
			"players": peer_ids.duplicate(),
			"inventory": _starting_inventory(spec, selected_scenario),
			"research": {"project": "", "progress": 0.0, "unlocked": []},
			"relations": {}, "name_prompted": false,
		}
		factions.append(faction)
		for peer_id in peer_ids:
			players[str(peer_id)] = faction_id
		var site := _site_by_id(generated_world, site_id)
		site["kind"] = "player"
		site["faction_id"] = faction_id
		site["name"] = settlement_name
		maps[site_id] = preview_local_map(generated_world, site_id)
		var prepared: Array = spec.get("colonists", [])
		for j in range(count):
			var prepared_one: Dictionary = prepared[j] if j < prepared.size() else {}
			colonists.append(_make_colonist(generated_world["seed"], faction_id, site_id, i, j, prepared_one))
		_apply_starting_relationships(colonists, prepared, colonists.size() - count, count)
	active_colony_id = str(factions[0]["id"]) if not factions.is_empty() else ""
	state = {
		"schema": 1, "mode": mode, "seed": generated_world["seed"],
		"time": 0, "day_length": 600, "raid_clock": 0, "caravan_clock": 0, "next_id": 1,
		"scenario_id": selected_scenario, "storyteller_id": selected_storyteller,
		"difficulty_id": selected_difficulty, "raid_cycle": 0, "caravan_cycle": 0,
		"colonists_per_faction": count,
		"world": generated_world, "factions": factions, "players": players,
		"maps": maps, "colonists": colonists, "orders": [], "raiders": [],
		"caravans": [], "trade_offers": [], "events": [],
		"point_limit_enabled": bool(config.get("point_limit_enabled", true)),
		"research_projects": RESEARCH_PROJECTS.duplicate(true),
	}
	_route_cache.clear()
	_tick_remainder = 0.0
	_autosave_elapsed = 0.0
	_next_autosave_slot = 0
	_last_saved_slot = ""
	_emit_change()
	return get_snapshot(1)


func add_late_player(peer_id: int, spec: Dictionary = {}) -> Dictionary:
	if state.is_empty(): return _error("Game has not started.")
	if peer_id < 2 or state["players"].has(str(peer_id)): return _error("Player is already assigned.")
	if str(state.get("mode", "")) == "coop":
		var shared: Dictionary = state["factions"][0]
		shared["players"].append(peer_id)
		state["players"][str(peer_id)] = shared["id"]
		_emit_change()
		return _ok({"faction_id": shared["id"]})
	if str(state.get("mode", "")) != "competitive": return _error("Late joining is unavailable in this mode.")
	var validation := validate_setup({"seed": state["seed"], "world_options": state["world"].get("options", {}), "faction_specs": [spec],
		"colonists_per_faction": state.get("colonists_per_faction", 3),
		"scenario_id": state.get("scenario_id", "landfall"),
		"point_limit_enabled": state.get("point_limit_enabled", true)})
	if not bool(validation.get("ok", false)): return validation
	var site_id := str(spec.get("site_id", ""))
	if site_id.is_empty(): return _error("Choose a free start tile.")
	var existing := _site_by_id(state["world"], site_id)
	if not existing.is_empty() and str(existing.get("kind", "")) != "vacant":
		return _error("This settlement is occupied.")
	var used: Array = []
	for faction in state["factions"]: used.append(str(faction["site_id"]))
	if used.has(site_id): return _error("This settlement is occupied.")
	site_id = _resolve_start_site(state["world"], site_id, used)
	var index: int = state["factions"].size()
	var faction_id := "faction_%d" % (index + 1)
	var faction_name := str(spec.get("name", "Unnamed colony")).strip_edges()
	var settlement_name := str(spec.get("settlement_name", "Unnamed settlement")).strip_edges()
	if faction_name.is_empty(): faction_name = "Unnamed colony"
	if settlement_name.is_empty(): settlement_name = "Unnamed settlement"
	var faction := {"id": faction_id, "name": faction_name, "settlement_name": settlement_name,
		"site_id": site_id, "players": [peer_id],
		"inventory": _starting_inventory(spec, str(state.get("scenario_id", "landfall"))),
		"research": {"project": "", "progress": 0.0, "unlocked": []},
		"relations": {}, "name_prompted": false}
	state["factions"].append(faction)
	state["players"][str(peer_id)] = faction_id
	var site := _site_by_id(state["world"], site_id)
	site["kind"] = "player"
	site["faction_id"] = faction_id
	site["name"] = settlement_name
	state["maps"][site_id] = preview_local_map(state["world"], site_id)
	var prepared: Array = spec.get("colonists", [])
	var first_colonist_index: int = state["colonists"].size()
	for j in range(int(state.get("colonists_per_faction", 3))):
		var person: Dictionary = prepared[j] if j < prepared.size() else {}
		state["colonists"].append(_make_colonist(str(state["seed"]), faction_id, site_id, index, j, person))
	_apply_starting_relationships(state["colonists"], prepared, first_colonist_index,
		int(state.get("colonists_per_faction", 3)))
	_event("player_joined", "%s established a new colony." % faction_name, site_id,
		"event.player_joined", {"faction_name": faction_name})
	_emit_change()
	return _ok({"faction_id": faction_id, "site_id": site_id})


func remove_player(peer_id: int) -> void:
	if state.is_empty() or not state["players"].has(str(peer_id)): return
	var faction_id := str(state["players"][str(peer_id)])
	state["players"].erase(str(peer_id))
	var faction := _faction_by_id(faction_id)
	if not faction.is_empty(): faction["players"].erase(peer_id)
	_emit_change()


func validate_setup(config: Dictionary) -> Dictionary:
	for selection in [
		[SetupCatalog.SCENARIOS, str(config.get("scenario_id", "landfall"))],
		[SetupCatalog.STORYTELLERS, str(config.get("storyteller_id", "steady"))],
		[SetupCatalog.DIFFICULTIES, str(config.get("difficulty_id", "frontier"))],
	]:
		if str(SetupCatalog.find_by_id(selection[0], selection[1]).get("id", "")) != selection[1]:
			return _error("Invalid game setup choice.")
	var preview := preview_world(str(config.get("seed", "")), config.get("world_options", {}))
	var selected: Dictionary = {}
	var scenario_count: int = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, str(config.get("scenario_id", "landfall"))).get("colonist_count", 3))
	if int(config.get("colonists_per_faction", config.get("colonist_count", scenario_count))) != scenario_count:
		return _error("Starting crew size must match the selected scenario.")
	var count: int = scenario_count
	for raw_spec in config.get("faction_specs", []):
		if not raw_spec is Dictionary: return _error("Invalid faction setup.")
		var spec: Dictionary = raw_spec
		if spec.has("starting_cargo"):
			var cargo: Variant = spec["starting_cargo"]
			if not cargo is Dictionary: return _error("Invalid starting cargo.")
			for item in cargo.keys():
				if str(item) not in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
					return _error("Invalid starting cargo item.")
				if int(cargo[item]) < 0 or int(cargo[item]) > 999:
					return _error("Starting cargo quantity must be between 0 and 999.")
		var site_id := str(spec.get("site_id", ""))
		if selected.has(site_id): return _error("Each colony needs a separate start tile.")
		selected[site_id] = true
		if site_id.begins_with("tile_"):
			var coords := site_id.trim_prefix("tile_").split("_")
			if coords.size() != 2 or not coords[0].is_valid_int() or not coords[1].is_valid_int():
				return _error("Invalid start tile.")
			var x := int(coords[0])
			var y := int(coords[1])
			if x < 0 or x >= WORLD_WIDTH or y < 0 or y >= WORLD_HEIGHT or preview["tiles"][y * WORLD_WIDTH + x] == "water":
				return _error("Colonies must start on land.")
			for site in preview["sites"]:
				if int(site["x"]) == x and int(site["y"]) == y:
					return _error("This tile already has a settlement.")
		elif not site_id.is_empty():
			var site := _site_by_id(preview, site_id)
			if site.is_empty() or str(site.get("kind", "")) != "vacant":
				return _error("Choose a free settlement tile.")
		else:
			return _error("Choose a start tile.")
		var prepared: Variant = spec.get("colonists", [])
		if not prepared is Array or prepared.size() > count:
			return _error("Invalid colonist count.")
		var declared_relationships: Dictionary = {}
		for person_index in range(prepared.size()):
			var raw_colonist: Variant = prepared[person_index]
			if not raw_colonist is Dictionary: return _error("Invalid colonist setup.")
			var person: Dictionary = raw_colonist
			var age: Variant = person.get("age", 24)
			if not (age is int or age is float) or float(age) != float(int(age)) or int(age) < 18 or int(age) > 80:
				return _error("Colonist age must be between 18 and 80.")
			if not CHILDHOOD_SKILL_BONUSES.has(str(person.get("childhood", "rural_child"))):
				return _error("Invalid childhood background.")
			if not ADULTHOOD_SKILL_BONUSES.has(str(person.get("adulthood", "farmer"))):
				return _error("Invalid adulthood background.")
			var gear: Variant = person.get("starting_gear", {})
			if not gear is Dictionary: return _error("Invalid starting gear.")
			if str(gear.get("weapon", "fists")) not in ["fists", "spear"]:
				return _error("Invalid starting weapon.")
			if str(gear.get("apparel", "clothes")) not in ["clothes", "jacket"]:
				return _error("Invalid starting apparel.")
			var relationships: Variant = person.get("starting_relationships", {})
			if not relationships is Dictionary: return _error("Invalid starting relationships.")
			for raw_other in relationships.keys():
				var other_text := str(raw_other)
				if not other_text.is_valid_int(): return _error("Invalid starting relationship target.")
				var other_index := int(other_text)
				if other_index < 0 or other_index >= count or other_index == person_index:
					return _error("Invalid starting relationship target.")
				var relation_type := str(relationships[raw_other])
				if not STARTING_RELATIONSHIP_OPINIONS.has(relation_type):
					return _error("Invalid starting relationship.")
				var pair_key := "%d_%d" % [mini(person_index, other_index), maxi(person_index, other_index)]
				var normalized_relation := relation_type
				if person_index > other_index:
					if relation_type == "parent": normalized_relation = "child"
					elif relation_type == "child": normalized_relation = "parent"
				if declared_relationships.has(pair_key) and declared_relationships[pair_key] != normalized_relation:
					return _error("Conflicting starting relationships.")
				declared_relationships[pair_key] = normalized_relation
			var traits: Array = person.get("traits", [])
			if traits.size() > 3: return _error("A colonist can have at most three traits.")
			var trait_unique: Dictionary = {}
			for raw_trait in traits:
				var trait_id := str(raw_trait)
				if not TRAIT_COSTS.has(trait_id) or trait_unique.has(trait_id): return _error("Invalid or repeated trait.")
				trait_unique[trait_id] = true
			var condition_unique: Dictionary = {}
			for raw_condition in person.get("health_conditions", []):
				var condition_id := str(raw_condition)
				if not HEALTH_CONDITION_COSTS.has(condition_id) or condition_unique.has(condition_id):
					return _error("Invalid or repeated health condition.")
				condition_unique[condition_id] = true
			for skill in person.get("skills", {}).keys():
				if not WORK_TYPES.has(str(skill)) and str(skill) != "combat": return _error("Invalid skill.")
				if int(person["skills"][skill]) < 0 or int(person["skills"][skill]) > 10:
					return _error("Skill level must be between 0 and 10.")
			var points := preparation_points(person)
			if bool(config.get("point_limit_enabled", true)) and points > PREPARATION_POINT_LIMIT:
				return _error("Colonist preparation exceeds the point limit.")
			if str(person.get("sex", "female")) not in ["female", "male"]:
				return _error("Invalid sex selection.")
			if str(person.get("gender", "woman")) not in ["woman", "man", "nonbinary"]:
				return _error("Invalid gender selection.")
	return _ok()


func preparation_points(person: Dictionary) -> int:
	var points := 0
	for raw_trait in person.get("traits", []): points += int(TRAIT_COSTS.get(str(raw_trait), 0))
	for condition in person.get("health_conditions", []):
		points += int(HEALTH_CONDITION_COSTS.get(str(condition), 0))
	for skill in person.get("skills", {}).keys():
		if WORK_TYPES.has(str(skill)) or str(skill) == "combat":
			points += maxi(0, int(person["skills"][skill]) - 5)
	var gear: Variant = person.get("starting_gear", {})
	if gear is Dictionary:
		points += int(STARTING_GEAR_COSTS.get(str(gear.get("weapon", "fists")), 0))
		points += int(STARTING_GEAR_COSTS.get(str(gear.get("apparel", "clothes")), 0))
	return points


func issue_command(peer_id: int, command: Dictionary) -> Dictionary:
	if state.is_empty(): return _error("Oyun başlamadı.")
	var faction_id: String = str(state["players"].get(str(peer_id), ""))
	if faction_id.is_empty(): return _error("Oyuncu bir koloniye bağlı değil.")
	var command_type: String = str(command.get("type", ""))
	var result: Dictionary = {}
	match command_type:
		"designate": result = _command_designate(faction_id, command)
		"set_work_priority": result = _command_work_priority(faction_id, command)
		"set_schedule": result = _command_schedule(faction_id, command)
		"set_order_priority": result = _command_order_priority(faction_id, command)
		"direct": result = _command_direct(faction_id, command)
		"set_draft": result = _command_draft(faction_id, command)
		"set_research": result = _command_research(faction_id, command)
		"customize_colonist": result = _command_customize(faction_id, command)
		"trade_offer": result = _command_trade_offer(faction_id, command)
		"trade_accept": result = _command_trade_accept(faction_id, command)
		"trade_decline": result = _command_trade_decline(faction_id, command)
		"npc_trade": result = _command_npc_trade(faction_id, command)
		"rename": result = _command_rename(faction_id, command)
		"cancel_order": result = _command_cancel_order(faction_id, command)
		"create_zone": result = _command_create_zone(faction_id, command)
		"set_zone_filter": result = _command_zone_filter(faction_id, command)
		"delete_zone": result = _command_delete_zone(faction_id, command)
		_: result = _error("Bilinmeyen komut: %s" % command_type)
	if result.get("ok", false):
		_emit_change()
	return result


func tick(delta: float = 1.0) -> void:
	if state.is_empty() or delta <= 0.0: return
	_tick_remainder += minf(delta, 30.0)
	var steps := 0
	while _tick_remainder >= 1.0 and steps < 30:
		_tick_remainder -= 1.0
		_tick_one_second()
		steps += 1
	if steps > 0: _emit_change()


func get_snapshot(peer_id: int = 0) -> Dictionary:
	if state.is_empty(): return {}
	var copy: Dictionary = state.duplicate(true)
	if peer_id == 0 or str(state.get("mode", "")) != "competitive": return copy
	var faction_id: String = str(state["players"].get(str(peer_id), ""))
	if faction_id.is_empty(): return {}
	var own: Dictionary = _faction_by_id(faction_id)
	var site_id: String = str(own.get("site_id", ""))
	var visible_maps: Dictionary = {}
	if copy["maps"].has(site_id): visible_maps[site_id] = copy["maps"][site_id]
	copy["maps"] = visible_maps
	copy["colonists"] = copy["colonists"].filter(func(c): return c["faction_id"] == faction_id)
	copy["orders"] = copy["orders"].filter(func(o): return o["faction_id"] == faction_id)
	copy["raiders"] = copy["raiders"].filter(func(r): return r["site_id"] == site_id)
	copy["caravans"] = copy["caravans"].filter(func(c): return c.get("faction_id", "") == faction_id or c.get("from_faction", "") == faction_id or c.get("to_faction", "") == faction_id)
	copy["trade_offers"] = copy["trade_offers"].filter(func(o): return o["from_faction"] == faction_id or o["to_faction"] == faction_id)
	for f in copy["factions"]:
		if f["id"] != faction_id:
			f.erase("inventory")
			f.erase("research")
	return copy


func serialize_game() -> Dictionary:
	return state.duplicate(true)


func save_game(slot_id: String = "") -> bool:
	if state.is_empty() or not _valid_save_slot(_save_directory_name): return false
	var generated := slot_id.is_empty()
	if generated: slot_id = "save_%d" % Time.get_unix_time_from_system()
	if not _valid_save_slot(slot_id) or slot_id.begins_with(AUTOSAVE_PREFIX): return false
	if generated:
		var base_slot := slot_id
		var suffix := 2
		while FileAccess.file_exists(_save_path(slot_id)):
			slot_id = "%s_%d" % [base_slot, suffix]
			suffix += 1
	if not _write_save_file(slot_id): return false
	_last_saved_slot = slot_id
	_has_unsaved_changes = false
	_autosave_elapsed = 0.0
	return true


func save_autosave(max_count: int = 3) -> bool:
	if state.is_empty() or max_count <= 0 or not _valid_save_slot(_save_directory_name): return false
	var count := clampi(max_count, 1, AUTOSAVE_LIMIT)
	if _next_autosave_slot < 1 or _next_autosave_slot > count:
		_next_autosave_slot = _select_autosave_slot(count)
	var slot_id := "%s%02d" % [AUTOSAVE_PREFIX, _next_autosave_slot]
	if not _write_save_file(slot_id): return false
	_next_autosave_slot = _next_autosave_slot % count + 1
	_prune_autosaves(count)
	_last_saved_slot = slot_id
	_has_unsaved_changes = false
	_autosave_elapsed = 0.0
	return true


func advance_autosave(real_delta_seconds: float, interval_minutes: float, max_count: int) -> bool:
	if state.is_empty() or interval_minutes <= 0.0 or max_count <= 0:
		_autosave_elapsed = 0.0
		return false
	_autosave_elapsed += maxf(real_delta_seconds, 0.0)
	if _autosave_elapsed < interval_minutes * 60.0: return false
	_autosave_elapsed = 0.0
	if not _has_unsaved_changes: return false
	return save_autosave(max_count)


func has_unsaved_changes() -> bool:
	return _has_unsaved_changes and not state.is_empty()


func delete_saved_game(slot_id: String) -> bool:
	if not _valid_save_slot(slot_id) or not _valid_save_slot(_save_directory_name): return false
	var path := _save_path(slot_id)
	if not FileAccess.file_exists(path): return false
	var removed := DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK
	if removed and slot_id == _last_saved_slot:
		_has_unsaved_changes = not state.is_empty()
		_last_saved_slot = ""
	return removed


func _save_path(slot_id: String) -> String:
	return "%s/%s.json" % [_save_dir(), slot_id]


func _save_dir() -> String:
	return "user://%s" % _save_directory_name


func _write_save_file(slot_id: String) -> bool:
	if not _valid_save_slot(_save_directory_name): return false
	var save_dir := _save_dir()
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_dir)) != OK: return false
	var path := _save_path(slot_id)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(state))
	file.flush()
	var wrote := file.get_error() == OK
	file.close()
	return wrote


func _prune_autosaves(max_count: int) -> void:
	var dir := DirAccess.open(_save_dir())
	if dir == null: return
	for filename in dir.get_files():
		if not filename.ends_with(".json"): continue
		var slot_id := filename.trim_suffix(".json")
		if _autosave_slot_number(slot_id) > max_count:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_save_path(slot_id)))


func _select_autosave_slot(max_count: int) -> int:
	var oldest_slot := 1
	var oldest_time := 9223372036854775807
	for number in range(1, max_count + 1):
		var path := _save_path("%s%02d" % [AUTOSAVE_PREFIX, number])
		if not FileAccess.file_exists(path): return number
		var modified := FileAccess.get_modified_time(path)
		if modified < oldest_time:
			oldest_time = modified
			oldest_slot = number
	return oldest_slot


func _autosave_slot_number(slot_id: String) -> int:
	if not slot_id.begins_with(AUTOSAVE_PREFIX): return -1
	var number := slot_id.trim_prefix(AUTOSAVE_PREFIX)
	if number.length() != 2 or not number.is_valid_int(): return -1
	return int(number)


func list_saved_games() -> Array:
	var saves: Array = []
	if not _valid_save_slot(_save_directory_name): return saves
	var dir := DirAccess.open(_save_dir())
	if dir == null: return saves
	for filename in dir.get_files():
		if not filename.ends_with(".json"): continue
		var slot_id := filename.trim_suffix(".json")
		if not _valid_save_slot(slot_id): continue
		var path := _save_path(slot_id)
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null: continue
		var data: Variant = JSON.parse_string(file.get_as_text())
		if not data is Dictionary or int(data.get("schema", -1)) != 1: continue
		if not data.get("factions", []) is Array: continue
		var names: Array = []
		for faction in data.get("factions", []): names.append(str(faction.get("name", "Colony")))
		saves.append({"id": slot_id, "is_autosave": _autosave_slot_number(slot_id) > 0,
			"saved_at": FileAccess.get_modified_time(path),
			"seed": str(data.get("seed", "")), "time": int(data.get("time", 0)),
			"mode": str(data.get("mode", "solo")), "colonies": names})
	saves.sort_custom(func(a, b): return int(a["saved_at"]) > int(b["saved_at"]))
	return saves


func _valid_save_slot(slot_id: String) -> bool:
	if slot_id.is_empty() or slot_id.length() > 48: return false
	for ch in slot_id:
		if not (ch >= "a" and ch <= "z" or ch >= "A" and ch <= "Z" or ch >= "0" and ch <= "9" or ch in ["_", "-"]):
			return false
	return true


func load_game(data: Variant = {}) -> bool:
	var loaded: Variant = data
	var loaded_slot_id := ""
	if not (loaded is Dictionary) or loaded.is_empty():
		if not _valid_save_slot(_save_directory_name): return false
		var slot_id := str(loaded) if loaded is String else ""
		if slot_id.is_empty():
			var saves := list_saved_games()
			if not saves.is_empty(): slot_id = str(saves[0]["id"])
		var path := "user://foxtopia_save.json"
		if not slot_id.is_empty():
			if not _valid_save_slot(slot_id): return false
			path = _save_path(slot_id)
		loaded_slot_id = slot_id
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null: return false
		loaded = JSON.parse_string(file.get_as_text())
	if not (loaded is Dictionary): return false
	if int(loaded.get("schema", -1)) != 1: return false
	if not loaded.has("world") or not loaded.has("factions") or not loaded.has("maps"): return false
	state = loaded.duplicate(true)
	_route_cache.clear()
	_migrate_loaded_state()
	active_colony_id = str(state["factions"][0]["id"]) if not state["factions"].is_empty() else ""
	_tick_remainder = 0.0
	_autosave_elapsed = 0.0
	_next_autosave_slot = 0
	_last_saved_slot = loaded_slot_id
	_emit_change(false)
	return true


func _migrate_loaded_state() -> void:
	if not state.has("day_length"): state["day_length"] = 600
	var saved_world: Dictionary = state.get("world", {})
	if not saved_world.has("calendar"):
		saved_world["calendar"] = ClimateCalendar.world_calendar()
	if not state.has("colonists_per_faction"): state["colonists_per_faction"] = 3
	if not state.has("point_limit_enabled"): state["point_limit_enabled"] = true
	if not state.has("scenario_id"): state["scenario_id"] = "landfall"
	if not state.has("storyteller_id"): state["storyteller_id"] = "steady"
	if not state.has("difficulty_id"): state["difficulty_id"] = "frontier"
	if not state.has("raid_cycle"): state["raid_cycle"] = 0
	if not state.has("caravan_cycle"): state["caravan_cycle"] = 0
	for faction in state.get("factions", []):
		if not faction.has("name_prompted"):
			faction["name_prompted"] = not str(faction.get("name", "")).begins_with("Unnamed")
	for site_id in state.get("maps", {}).keys():
		var map_data: Dictionary = state["maps"][site_id]
		var previous_info: Dictionary = map_data.get("site_info", {})
		if not previous_info.has("monthly_temperatures"):
			var refreshed_info := describe_site(saved_world, str(site_id))
			if not refreshed_info.is_empty():
				previous_info.merge(refreshed_info, true)
				map_data["site_info"] = previous_info
		if not map_data.has("zones"):
			map_data["zones"] = [{"id": "zone_1", "kind": "stockpile", "x": 24, "y": 26,
				"width": 3, "height": 2, "accepts": ITEM_PRICES.keys()}]
	for colonist in state.get("colonists", []):
		if not colonist.has("age"): colonist["age"] = 24
		if not colonist.has("childhood"): colonist["childhood"] = "rural_child"
		if not colonist.has("adulthood"): colonist["adulthood"] = "farmer"
		if not colonist.has("relationship_types"): colonist["relationship_types"] = {}
		if not colonist.has("previous_x"): colonist["previous_x"] = int(colonist["x"])
		if not colonist.has("previous_y"): colonist["previous_y"] = int(colonist["y"])
		if not colonist.has("carrying"): colonist["carrying"] = {}
		if not colonist.has("idle_target"): colonist["idle_target"] = {}
		if not colonist.has("idle_until"): colonist["idle_until"] = int(state.get("time", 0))
		if not colonist.has("styling_ready_until"): colonist["styling_ready_until"] = -1
		if not colonist.has("relationships"): colonist["relationships"] = {}
		if not colonist.has("schedule") or not colonist["schedule"] is Array or colonist["schedule"].size() != 24:
			colonist["schedule"] = _default_schedule()
		if not colonist["needs"].has("thoughts"): colonist["needs"]["thoughts"] = []
		if not colonist["health"].has("conditions"): colonist["health"]["conditions"] = []
		if not colonist["health"].has("wound_summary"): _update_health_summary(colonist["health"])
	for raider in state.get("raiders", []):
		if not raider.has("previous_x"): raider["previous_x"] = int(raider["x"])
		if not raider.has("previous_y"): raider["previous_y"] = int(raider["y"])
		if not raider.has("phase"): raider["phase"] = "attacking"


func load_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.is_empty() or not snapshot.has("world") or not snapshot.has("factions"):
		return false
	state = snapshot.duplicate(true)
	_route_cache.clear()
	active_colony_id = str(state["factions"][0]["id"]) if not state["factions"].is_empty() else ""
	_emit_change(false)
	return true


func _default_specs(config: Dictionary, mode: String, generated_world: Dictionary, count: int) -> Array:
	var specs: Array = []
	var player_count: int = clampi(int(config.get("player_count", 1)), 1, 8)
	var faction_count := player_count if mode == "competitive" else 1
	for i in range(faction_count):
		var peer_ids: Array = [i + 1] if mode == "competitive" else range(1, player_count + 1)
		specs.append({"id": "faction_%d" % (i + 1),
			"name": str(config.get("colony_name", "Unnamed colony")),
			"settlement_name": str(config.get("settlement_name", "Unnamed settlement")),
			"site_id": "site_%d" % (i + 1), "players": peer_ids,
			"colonists": config.get("colonists", []) if i == 0 else []})
	return specs


func _make_colonist(seed_text: String, faction_id: String, site_id: String, faction_index: int, index: int, prepared: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number("%s/%s/%d" % [seed_text, faction_id, index])
	var childhood := str(prepared.get("childhood", ["rural_child", "town_child", "apprentice"][index % 3]))
	var adulthood := str(prepared.get("adulthood", ["farmer", "builder", "medic", "scholar"][index % 4]))
	var traits: Array = prepared.get("traits", [])
	if not prepared.has("traits"):
		traits = [["hardworking", "calm"], ["quick", "curious"], ["kind", "quick"]][index % 3].duplicate()
	var skills: Dictionary = {"chop": rng.randi_range(2, 6), "mine": rng.randi_range(2, 6),
		"harvest": rng.randi_range(2, 6), "haul": rng.randi_range(2, 6),
		"build": rng.randi_range(2, 6), "research": rng.randi_range(2, 6),
		"treat": rng.randi_range(2, 6), "combat": rng.randi_range(2, 6)}
	var childhood_skill: String = str(CHILDHOOD_SKILL_BONUSES.get(childhood, ""))
	if skills.has(childhood_skill): skills[childhood_skill] = mini(10, int(skills[childhood_skill]) + 1)
	var adulthood_skill: String = str(ADULTHOOD_SKILL_BONUSES.get(adulthood, ""))
	if skills.has(adulthood_skill): skills[adulthood_skill] = mini(10, int(skills[adulthood_skill]) + 2)
	for key in prepared.get("skills", {}).keys():
		if skills.has(key): skills[key] = clampi(int(prepared["skills"][key]), 0, 10)
	var priorities: Dictionary = {}
	for work in WORK_TYPES: priorities[work] = 5
	for key in prepared.get("work_priorities", {}).keys():
		if priorities.has(key): priorities[key] = clampi(int(prepared["work_priorities"][key]), 0, 9)
	var appearance: Dictionary = prepared.get("appearance", {})
	var conditions: Array = []
	for raw_condition in prepared.get("health_conditions", []):
		var condition := str(raw_condition)
		if HEALTH_CONDITION_COSTS.has(condition) and not conditions.has(condition): conditions.append(condition)
	var starting_hp := 92.0 if conditions.has("bad_back") else 100.0
	var starting_gear: Dictionary = prepared.get("starting_gear", {})
	return {"id": "colonist_%d_%d" % [faction_index + 1, index + 1],
		"faction_id": faction_id, "site_id": site_id,
		"name": str(prepared.get("name", FIRST_NAMES[(faction_index * 3 + index) % FIRST_NAMES.size()])),
		"age": clampi(int(prepared.get("age", 24 + index * 3)), 18, 80),
		"childhood": childhood, "adulthood": adulthood,
		"sex": str(prepared.get("sex", "female" if index % 2 == 0 else "male")),
		"gender": str(prepared.get("gender", "woman" if index % 2 == 0 else "man")),
		"x": 23 + index, "y": 25, "previous_x": 23 + index, "previous_y": 25,
		"facing": "down",
		"appearance": {"hair": str(appearance.get("hair", "short")),
			"hair_color": str(appearance.get("hair_color", "#4e3d32")),
			"skin": str(appearance.get("skin", "medium")),
			"outfit": str(appearance.get("outfit", "blue"))},
		"traits": traits.duplicate(), "skills": skills, "work_priorities": priorities,
		"schedule": _default_schedule(),
		"relationships": {}, "relationship_types": {},
		"needs": {"hunger": 100.0, "rest": 100.0, "mood": 75.0, "thoughts": []},
		"health": {"hp": starting_hp, "max_hp": 100.0, "bleeding": 0.0,
			"wounds": [], "conditions": conditions},
		"equipment": {"weapon": str(starting_gear.get("weapon", "fists")),
			"apparel": str(starting_gear.get("apparel", "clothes"))},
		"drafted": false, "manual": {}, "current_order": "", "work_left": 0.0,
		"resting": false, "carrying": {}, "idle_target": {}, "idle_until": 0,
		"styling_ready_until": -1,
		"attack_cooldown": 0,
		"alive": true}


func _apply_starting_relationships(colonists: Array, prepared: Array, offset: int, count: int) -> void:
	for source_index in range(mini(prepared.size(), count)):
		if not prepared[source_index] is Dictionary: continue
		var source: Dictionary = colonists[offset + source_index]
		var relationships: Variant = prepared[source_index].get("starting_relationships", {})
		if not relationships is Dictionary: continue
		for raw_other in relationships.keys():
			var other_text := str(raw_other)
			if not other_text.is_valid_int(): continue
			var other_index := int(other_text)
			if other_index < 0 or other_index >= count or other_index == source_index: continue
			var relation_type := str(relationships[raw_other])
			if not STARTING_RELATIONSHIP_OPINIONS.has(relation_type): continue
			var other: Dictionary = colonists[offset + other_index]
			source["relationships"][str(other["id"])] = STARTING_RELATIONSHIP_OPINIONS[relation_type]
			other["relationships"][str(source["id"])] = STARTING_RELATIONSHIP_OPINIONS[relation_type]
			source["relationship_types"][str(other["id"])] = relation_type
			var reverse_type := "child" if relation_type == "parent" else "parent" if relation_type == "child" else relation_type
			other["relationship_types"][str(source["id"])] = reverse_type


func _generate_local_map(seed_text: String, site_id: String, biome: String, site_info: Dictionary = {}) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number("%s/%s/map" % [seed_text, site_id])
	var terrain_noise := FastNoiseLite.new()
	terrain_noise.seed = int(rng.randi())
	terrain_noise.frequency = 0.052
	terrain_noise.fractal_octaves = 4
	var detail_noise := FastNoiseLite.new()
	detail_noise.seed = int(rng.randi())
	detail_noise.frequency = 0.105
	var foliage_noise := FastNoiseLite.new()
	foliage_noise.seed = int(rng.randi())
	foliage_noise.frequency = 0.075
	var coast_direction := str(site_info.get("coast_direction", ""))
	var hilly := str(site_info.get("terrain", "Flat")) != "Flat"
	var mountainous := str(site_info.get("terrain", "Flat")) == "Mountainous"
	var rainfall := int(site_info.get("rainfall", 700))
	var has_lake := coast_direction.is_empty() and rainfall > 900 and rng.randf() < 0.65
	var lake_center := Vector2(10 if rng.randi() % 2 == 0 else 40, 11 if rng.randi() % 2 == 0 else 39)
	var lake_radius := rng.randf_range(6.0, 9.0)
	var ridge_side := rng.randi_range(0, 3)
	var terrain: Array = []
	var resources: Array = []
	for y in range(LOCAL_SIZE):
		for x in range(LOCAL_SIZE):
			var broad := terrain_noise.get_noise_2d(float(x), float(y))
			var detail := detail_noise.get_noise_2d(float(x), float(y))
			var center_distance := Vector2(float(x - 25), float(y - 25)).length()
			var clearing := maxf(0.0, 1.0 - center_distance / 12.0)
			var protected_center := center_distance < 9.0
			var tile := "grass"
			var shore_position := 8.0 + broad * 11.0 + detail * 2.0
			var shoreline := (coast_direction == "west" and float(x) < shore_position) or (coast_direction == "east" and float(LOCAL_SIZE - 1 - x) < shore_position) or (coast_direction == "north" and float(y) < shore_position) or (coast_direction == "south" and float(LOCAL_SIZE - 1 - y) < shore_position)
			var lake_distance := Vector2(float(x), float(y)).distance_to(lake_center)
			var lake := has_lake and lake_distance < lake_radius + broad * 4.0 + detail * 1.5
			var ridge_distance := float(x) if ridge_side == 0 else float(LOCAL_SIZE - 1 - x) if ridge_side == 1 else float(y) if ridge_side == 2 else float(LOCAL_SIZE - 1 - y)
			var ridge := hilly and ridge_distance < (10.0 if mountainous else 4.0) + broad * 12.0
			if not protected_center and (shoreline or lake):
				tile = "water"
			elif not protected_center and (ridge or (biome == "rocky" and broad > 0.18)):
				tile = "rock_ground"
			elif (biome == "arid" and detail > -0.25) or detail > 0.21 or clearing > 0.55:
				tile = "dirt"
			terrain.append(tile)
			if x >= 21 and x <= 29 and y >= 21 and y <= 29: continue
			if tile == "water": continue
			var r := rng.randf()
			var foliage := foliage_noise.get_noise_2d(float(x), float(y))
			var tree_chance := 0.24 if biome == "forest" else 0.10 if biome == "plains" else 0.04 if biome == "tundra" else 0.025
			if tile != "rock_ground" and foliage > (-0.12 if biome == "forest" else 0.08) and r < tree_chance:
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "tree", "amount": 1})
			elif (tile == "rock_ground" and r < 0.22) or r < 0.018:
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "stone", "amount": 1})
			elif tile == "grass" and biome in ["forest", "plains"] and foliage > 0.10 and r < 0.12:
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "berry", "amount": 1})
	return {"width": LOCAL_SIZE, "height": LOCAL_SIZE, "terrain": terrain,
		"site_id": site_id, "biome": biome, "site_info": site_info,
		"resources": resources, "drops": [],
		"structures": [{"id": "stockpile", "kind": "stockpile", "x": 25, "y": 26}],
		"zones": [{"id": "zone_1", "kind": "stockpile", "x": 24, "y": 26, "width": 3, "height": 2,
			"accepts": ["wood", "stone", "food", "medicine", "spear", "jacket"]}]}


func _resolve_start_site(generated_world: Dictionary, requested_id: String, used: Array) -> String:
	if requested_id.begins_with("tile_"):
		var coords := requested_id.trim_prefix("tile_").split("_")
		if coords.size() == 2 and coords[0].is_valid_int() and coords[1].is_valid_int():
			var x := int(coords[0])
			var y := int(coords[1])
			if x >= 0 and x < WORLD_WIDTH and y >= 0 and y < WORLD_HEIGHT and generated_world["tiles"][y * WORLD_WIDTH + x] != "water":
				var occupied := false
				for existing in generated_world["sites"]:
					if int(existing["x"]) == x and int(existing["y"]) == y:
						occupied = true
						break
				if not occupied and not used.has(requested_id):
					generated_world["sites"].append({"id": requested_id, "x": x, "y": y,
						"biome": generated_world["tiles"][y * WORLD_WIDTH + x], "kind": "vacant",
						"name": "New settlement"})
					return requested_id
	var site := _site_by_id(generated_world, requested_id)
	if not used.has(requested_id) and not site.is_empty() and str(site.get("kind", "")) == "vacant":
		return requested_id
	return _first_free_site(generated_world, used)


func _find_site_position(rng: RandomNumberGenerator, sites: Array, tiles: Array) -> Vector2i:
	for min_distance in [10, 7, 4, 1]:
		for _attempt in range(500):
			var p := Vector2i(rng.randi_range(3, WORLD_WIDTH - 4), rng.randi_range(3, WORLD_HEIGHT - 4))
			if tiles[p.y * WORLD_WIDTH + p.x] == "water": continue
			var okay := true
			for s in sites:
				if abs(int(s["x"]) - p.x) + abs(int(s["y"]) - p.y) < min_distance:
					okay = false
					break
			if okay: return p
	for y in range(3, WORLD_HEIGHT - 3):
		for x in range(3, WORLD_WIDTH - 3):
			if tiles[y * WORLD_WIDTH + x] == "water": continue
			var occupied := false
			for s in sites:
				if int(s["x"]) == x and int(s["y"]) == y:
					occupied = true
					break
			if not occupied: return Vector2i(x, y)
	return Vector2i(WORLD_WIDTH / 2, WORLD_HEIGHT / 2)


func _seed_number(value: String) -> int:
	var result: int = 2166136261
	for i in range(value.length()):
		result = ((result ^ value.unicode_at(i)) * 16777619) & 0x7fffffff
	return maxi(result, 1)


func _first_free_site(generated_world: Dictionary, used: Array) -> String:
	for site in generated_world["sites"]:
		if site["kind"] == "vacant" and not used.has(site["id"]): return str(site["id"])
	return "site_1"


func _site_by_id(world_data: Dictionary, site_id: String) -> Dictionary:
	for site in world_data.get("sites", []):
		if site["id"] == site_id: return site
	return {}


func _faction_by_id(faction_id: String) -> Dictionary:
	for faction in state.get("factions", []):
		if faction["id"] == faction_id: return faction
	return {}


func _colonist_by_id(colonist_id: String) -> Dictionary:
	for colonist in state.get("colonists", []):
		if colonist["id"] == colonist_id: return colonist
	return {}


func _order_by_id(order_id: String) -> Dictionary:
	for order in state.get("orders", []):
		if order["id"] == order_id: return order
	return {}


func _raider_by_id(raider_id: String) -> Dictionary:
	for raider in state.get("raiders", []):
		if raider["id"] == raider_id: return raider
	return {}


func _owned_colonist(faction_id: String, colonist_id: String) -> Dictionary:
	var colonist := _colonist_by_id(colonist_id)
	if colonist.is_empty() or colonist["faction_id"] != faction_id: return {}
	return colonist


func _error(message: String) -> Dictionary:
	return {"ok": false, "error": message}


func _ok(extra: Dictionary = {}) -> Dictionary:
	var answer := {"ok": true}
	answer.merge(extra)
	return answer


func _new_id(prefix: String) -> String:
	var id := "%s_%d" % [prefix, int(state["next_id"])]
	state["next_id"] = int(state["next_id"]) + 1
	return id


func _emit_change(mark_unsaved: bool = true) -> void:
	_has_unsaved_changes = mark_unsaved
	# Local listeners use this as a read-only view. Network transport and saves
	# still take their own copies at the boundary where ownership changes.
	state_changed.emit(state)


func _event(kind: String, message: String, site_id: String = "", message_key: String = "",
		message_args: Dictionary = {}, subject_ids: Array = []) -> void:
	var item := {"time": int(state["time"]), "kind": kind, "message": message,
		"site_id": site_id, "message_key": message_key,
		"message_args": message_args.duplicate(true), "subject_ids": subject_ids.duplicate()}
	state["events"].append(item)
	if state["events"].size() > 40: state["events"].pop_front()
	event_emitted.emit(item.duplicate(true))


func _command_designate(faction_id: String, command: Dictionary) -> Dictionary:
	var faction := _faction_by_id(faction_id)
	var site_id: String = str(command.get("site_id", faction.get("site_id", "")))
	if site_id != str(faction.get("site_id", "")): return _error("Bu yerleşkede emir veremezsiniz.")
	var x: int = int(command.get("x", -1))
	var y: int = int(command.get("y", -1))
	if x < 0 or y < 0 or x >= LOCAL_SIZE or y >= LOCAL_SIZE: return _error("Harita dışında.")
	var kind: String = str(command.get("kind", ""))
	if not kind in ["chop", "mine", "harvest", "haul", "build_wall", "build_bed", "build_research_bench", "build_styling_table", "build_stone_wall", "build_barrier", "build_farm"]:
		return _error("Geçersiz iş türü.")
	var map_data: Dictionary = state["maps"].get(site_id, {})
	if map_data.is_empty(): return _error("Yerleşke haritası bulunamadı.")
	if map_data["terrain"][y * LOCAL_SIZE + x] == "water": return _error("Su üzerine işaretleme yapılamaz.")
	if RESOURCE_KINDS.has(kind):
		var resource := _resource_at(map_data, x, y)
		if resource.is_empty() or resource["kind"] != RESOURCE_KINDS[kind]: return _error("Burada uygun kaynak yok.")
	elif kind == "haul":
		if _drop_at(map_data, x, y).is_empty(): return _error("Burada taşınacak malzeme yok.")
	else:
		if not _structure_at(map_data, x, y).is_empty(): return _error("Burada zaten bir yapı var.")
		if kind == "build_stone_wall" and not faction["research"]["unlocked"].has("stonework"):
			return _error("Önce Taş İşçiliği araştırılmalı.")
		if kind == "build_barrier" and not faction["research"]["unlocked"].has("barriers"):
			return _error("Önce Barikat araştırılmalı.")
		if kind == "build_farm" and not faction["research"]["unlocked"].has("farming"):
			return _error("Önce Tarım araştırılmalı.")
	for other in state["orders"]:
		if other["site_id"] == site_id and int(other["x"]) == x and int(other["y"]) == y and other["kind"] == kind and other["status"] != "done" and other["status"] != "cancelled":
			return _error("Bu iş zaten işaretlenmiş.")
	var priority: int = clampi(int(command.get("priority", 5)), 1, 9)
	var order_id := _new_id("order")
	state["orders"].append({"id": order_id, "faction_id": faction_id, "site_id": site_id,
		"kind": kind, "x": x, "y": y, "priority": priority, "status": "queued",
		"claimed_by": "", "progress": 0.0, "created_at": int(state["time"])})
	return _ok({"order_id": order_id})


func _command_work_priority(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty(): return _error("Kolonist bulunamadı veya size ait değil.")
	var work: String = str(command.get("work", ""))
	if not WORK_TYPES.has(work): return _error("Geçersiz iş türü.")
	var priority: int = int(command.get("priority", -1))
	if priority < 0 or priority > 9: return _error("İş önceliği Kapalı (0) veya 1-9 olmalı.")
	colonist["work_priorities"][work] = priority
	return _ok()


func _default_schedule() -> Array:
	var hours: Array = []
	for hour in 24:
		hours.append("sleep" if hour < 6 or hour >= 22 else "recreation" if hour >= 19 else "work" if hour >= 8 else "anything")
	return hours


func _command_schedule(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty(): return _error("Kolonist bulunamadı veya size ait değil.")
	var hour := int(command.get("hour", -1))
	var activity := str(command.get("activity", ""))
	if hour < 0 or hour >= 24 or activity not in ["anything", "work", "recreation", "sleep"]:
		return _error("Geçersiz günlük plan hücresi.")
	colonist["schedule"][hour] = activity
	return _ok()


func _command_order_priority(faction_id: String, command: Dictionary) -> Dictionary:
	var order := _order_by_id(str(command.get("order_id", "")))
	if order.is_empty() or order["faction_id"] != faction_id: return _error("İş emri bulunamadı.")
	var priority: int = int(command.get("priority", -1))
	if priority < 1 or priority > 9: return _error("Emir önceliği 1-9 olmalı.")
	order["priority"] = priority
	return _ok()


func _command_cancel_order(faction_id: String, command: Dictionary) -> Dictionary:
	var order := _order_by_id(str(command.get("order_id", "")))
	if order.is_empty() or order["faction_id"] != faction_id: return _error("İş emri bulunamadı.")
	if order["status"] == "done": return _error("Tamamlanmış iş iptal edilemez.")
	order["status"] = "cancelled"
	order["claimed_by"] = ""
	for colonist in state["colonists"]:
		if colonist["current_order"] == order["id"]: colonist["current_order"] = ""
	return _ok()


func _command_create_zone(faction_id: String, command: Dictionary) -> Dictionary:
	var site_id := str(_faction_by_id(faction_id).get("site_id", ""))
	var map_data: Dictionary = state["maps"].get(site_id, {})
	var x := int(command.get("x", -1))
	var y := int(command.get("y", -1))
	var width := int(command.get("width", 1))
	var height := int(command.get("height", 1))
	if x < 0 or y < 0 or width < 1 or height < 1 or width > 15 or height > 15 or x + width > LOCAL_SIZE or y + height > LOCAL_SIZE:
		return _error("Invalid stockpile area.")
	var accepts := _validated_zone_filter(command.get("accepts", ITEM_PRICES.keys()))
	if accepts.is_empty(): return _error("Stockpile needs at least one accepted item.")
	for zy in range(y, y + height):
		for zx in range(x, x + width):
			if not _passable(map_data, zx, zy) or not _zone_at(map_data, zx, zy).is_empty():
				return _error("Stockpile overlaps blocked land or another zone.")
	var zone_id := _new_id("zone")
	map_data["zones"].append({"id": zone_id, "kind": "stockpile", "x": x, "y": y,
		"width": width, "height": height, "accepts": accepts})
	return _ok({"zone_id": zone_id})


func _command_zone_filter(faction_id: String, command: Dictionary) -> Dictionary:
	var map_data: Dictionary = state["maps"].get(str(_faction_by_id(faction_id).get("site_id", "")), {})
	var zone := _zone_by_id(map_data, str(command.get("zone_id", "")))
	if zone.is_empty(): return _error("Stockpile not found.")
	var accepts := _validated_zone_filter(command.get("accepts", []))
	if accepts.is_empty(): return _error("Stockpile needs at least one accepted item.")
	zone["accepts"] = accepts
	return _ok()


func _command_delete_zone(faction_id: String, command: Dictionary) -> Dictionary:
	var map_data: Dictionary = state["maps"].get(str(_faction_by_id(faction_id).get("site_id", "")), {})
	var zone := _zone_by_id(map_data, str(command.get("zone_id", "")))
	if zone.is_empty(): return _error("Stockpile not found.")
	map_data["zones"].erase(zone)
	return _ok()


func _validated_zone_filter(raw_filter: Variant) -> Array:
	var accepts: Array = []
	if not raw_filter is Array: return accepts
	for raw_item in raw_filter:
		var item := str(raw_item)
		if ITEM_PRICES.has(item) and not accepts.has(item): accepts.append(item)
	return accepts


func _zone_by_id(map_data: Dictionary, zone_id: String) -> Dictionary:
	for zone in map_data.get("zones", []):
		if str(zone.get("id", "")) == zone_id: return zone
	return {}


func _zone_at(map_data: Dictionary, x: int, y: int) -> Dictionary:
	for zone in map_data.get("zones", []):
		if x >= int(zone["x"]) and x < int(zone["x"]) + int(zone["width"]) and y >= int(zone["y"]) and y < int(zone["y"]) + int(zone["height"]):
			return zone
	return {}


func _stockpile_for(map_data: Dictionary, x: int, y: int, item: String, reachable_only: bool = false) -> Dictionary:
	var nearest: Dictionary = {}
	var best := 99999
	var walking_distances := _walking_distances(map_data, Vector2i(x, y)) if reachable_only else PackedInt32Array()
	for zone in map_data.get("zones", []):
		if not (zone.get("accepts", []) as Array).has(item): continue
		for zy in range(int(zone["y"]), int(zone["y"]) + int(zone["height"])):
			for zx in range(int(zone["x"]), int(zone["x"]) + int(zone["width"])):
				if not _passable(map_data, zx, zy): continue
				var distance: int = int(walking_distances[zy * LOCAL_SIZE + zx]) if reachable_only else abs(zx - x) + abs(zy - y)
				if distance < 0: continue
				if distance < best:
					best = distance
					nearest = {"zone_id": zone["id"], "x": zx, "y": zy}
	return nearest


func _walking_distances(map_data: Dictionary, origin: Vector2i) -> PackedInt32Array:
	var distances := PackedInt32Array()
	distances.resize(LOCAL_SIZE * LOCAL_SIZE)
	distances.fill(-1)
	if map_data.is_empty() or origin.x < 0 or origin.x >= LOCAL_SIZE or origin.y < 0 or origin.y >= LOCAL_SIZE:
		return distances
	var start_index := origin.y * LOCAL_SIZE + origin.x
	distances[start_index] = 0
	var queue := PackedInt32Array([start_index])
	var head := 0
	var directions: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	while head < queue.size():
		var index: int = queue[head]
		head += 1
		var cell := Vector2i(index % LOCAL_SIZE, index / LOCAL_SIZE)
		for direction in directions:
			var next: Vector2i = cell + direction
			if not _passable(map_data, next.x, next.y): continue
			var next_index := next.y * LOCAL_SIZE + next.x
			if distances[next_index] >= 0: continue
			distances[next_index] = distances[index] + 1
			queue.append(next_index)
	return distances


func _command_direct(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty() or not colonist["alive"]: return _error("Kolonist bulunamadı.")
	var colonist_map: Dictionary = state["maps"].get(colonist["site_id"], {})
	var action: String = str(command.get("action", ""))
	if not action in ["move", "work", "haul", "equip", "attack", "trade", "style", "clear"]:
		return _error("Geçersiz doğrudan emir.")
	if action == "clear":
		colonist["manual"] = {}
		return _ok()
	if action in ["move", "work", "haul", "trade", "style"]:
		var x: int = int(command.get("x", -1))
		var y: int = int(command.get("y", -1))
		if action == "work":
			var order := _order_by_id(str(command.get("target_id", command.get("order_id", ""))))
			if order.is_empty():
				for candidate in state["orders"]:
					if candidate["site_id"] == colonist["site_id"] and int(candidate["x"]) == x and int(candidate["y"]) == y and candidate["status"] not in ["done", "cancelled"]:
						order = candidate
						break
			if order.is_empty() or order["faction_id"] != faction_id or order["status"] in ["done", "cancelled"]:
				return _error("İş emri bulunamadı.")
			x = int(order["x"])
			y = int(order["y"])
			if not _can_reach(colonist_map, colonist, x, y): return _error("No walkable route to this job.")
			colonist["manual"] = {"action": "work", "order_id": order["id"]}
			return _ok()
		if action == "haul":
			var map_data: Dictionary = state["maps"].get(colonist["site_id"], {})
			var drop := _drop_by_id(map_data, str(command.get("target_id", "")))
			if drop.is_empty(): drop = _drop_at(map_data, x, y)
			if drop.is_empty(): return _error("Taşınacak malzeme bulunamadı.")
			if _stockpile_for(map_data, int(drop["x"]), int(drop["y"]), str(drop["kind"])).is_empty():
				return _error("Bu malzemeyi kabul eden bir depolama alanı yok.")
			x = int(drop["x"])
			y = int(drop["y"])
			if not _can_reach(colonist_map, colonist, x, y): return _error("No walkable route to these supplies.")
			if _stockpile_for(map_data, x, y, str(drop["kind"]), true).is_empty():
				return _error("No walkable route from these supplies to a stockpile.")
			colonist["manual"] = {"action": "haul", "drop_id": drop["id"]}
			return _ok()
		if action == "trade":
			var caravan := _caravan_by_id(str(command.get("target_id", "")))
			if caravan.is_empty():
				for candidate in state["caravans"]:
					if candidate.get("kind", "") == "npc" and candidate.get("site_id", "") == colonist["site_id"] and int(candidate.get("x", -1)) == x and int(candidate.get("y", -1)) == y:
						caravan = candidate
						break
			if caravan.is_empty() or caravan.get("kind", "") != "npc" or caravan.get("faction_id", "") != faction_id:
				return _error("Tüccar kervanı bulunamadı.")
			x = int(caravan.get("x", 25))
			y = int(caravan.get("y", 25))
			if not _can_reach(colonist_map, colonist, x, y, 1): return _error("No walkable route to the trader.")
			colonist["manual"] = {"action": "trade", "caravan_id": caravan["id"], "x": x, "y": y}
			return _ok()
		if action == "style":
			var style_table: Dictionary = {}
			for structure in state["maps"][colonist["site_id"]]["structures"]:
				if structure.get("kind", "") != "styling_table": continue
				if str(structure.get("id", "")) == str(command.get("target_id", "")) or int(structure["x"]) == x and int(structure["y"]) == y:
					style_table = structure
					break
			if style_table.is_empty(): return _error("Styling table not found.")
			if not _can_reach(colonist_map, colonist, int(style_table["x"]), int(style_table["y"]), 1):
				return _error("No walkable route to the styling table.")
			colonist["manual"] = {"action": "style", "x": int(style_table["x"]), "y": int(style_table["y"])}
			return _ok()
		if x < 0 or y < 0 or x >= LOCAL_SIZE or y >= LOCAL_SIZE: return _error("Harita dışında.")
		if not _passable(state["maps"][colonist["site_id"]], x, y): return _error("Bu hücreye gidilemez.")
		if not _can_reach(colonist_map, colonist, x, y): return _error("No walkable route to this tile.")
		colonist["manual"] = {"action": "move", "x": x, "y": y}
		return _ok()
	if action == "equip":
		var item: String = str(command.get("item", ""))
		if not item in ["spear", "jacket"]: return _error("Bu eşya kuşanılamaz.")
		var inventory: Dictionary = _faction_by_id(faction_id)["inventory"]
		if int(inventory.get(item, 0)) < 1: return _error("Depoda eşya yok.")
		var stockpile := _stockpile_for(colonist_map, int(colonist["x"]), int(colonist["y"]), item, true)
		if stockpile.is_empty(): return _error("This item has no accessible stockpile.")
		colonist["manual"] = {"action": "equip", "item": item, "x": stockpile["x"], "y": stockpile["y"]}
		return _ok()
	if action == "attack":
		var raider := _raider_by_id(str(command.get("target_id", "")))
		if raider.is_empty():
			var x: int = int(command.get("x", -1))
			var y: int = int(command.get("y", -1))
			for candidate in state["raiders"]:
				if candidate["site_id"] == colonist["site_id"] and int(candidate["x"]) == x and int(candidate["y"]) == y:
					raider = candidate
					break
		if raider.is_empty() or raider["site_id"] != colonist["site_id"]: return _error("Düşman bulunamadı.")
		if not _can_reach(colonist_map, colonist, int(raider["x"]), int(raider["y"]), 1):
			return _error("No walkable route to this enemy.")
		colonist["drafted"] = true
		colonist["manual"] = {"action": "attack", "target_id": raider["id"]}
		return _ok()
	return _error("Emir uygulanamadı.")


func _command_draft(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty(): return _error("Kolonist bulunamadı.")
	colonist["drafted"] = bool(command.get("drafted", false))
	if not colonist["drafted"] and colonist["manual"].get("action", "") == "attack":
		colonist["manual"] = {}
	return _ok()


func _command_research(faction_id: String, command: Dictionary) -> Dictionary:
	var project: String = str(command.get("project", ""))
	var faction := _faction_by_id(faction_id)
	if project.is_empty():
		faction["research"]["project"] = ""
		return _ok()
	if not RESEARCH_PROJECTS.has(project): return _error("Araştırma bulunamadı.")
	var has_bench := false
	for structure in state["maps"][faction["site_id"]]["structures"]:
		if structure.get("kind", "") == "research_bench": has_bench = true; break
	if not has_bench: return _error("Build a research bench first.")
	if faction["research"]["unlocked"].has(project): return _error("Bu araştırma tamamlandı.")
	for required in RESEARCH_PROJECTS[project]["requires"]:
		if not faction["research"]["unlocked"].has(required): return _error("Ön koşul tamamlanmadı.")
	faction["research"]["project"] = project
	faction["research"]["progress"] = 0.0
	return _ok()


func _command_customize(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty(): return _error("Kolonist bulunamadı.")
	if int(colonist.get("styling_ready_until", -1)) < int(state["time"]):
		return _error("Use a styling table before changing appearance.")
	var changes: Dictionary = command.get("appearance", {})
	if changes.is_empty(): return _error("Görünüş seçimi boş.")
	var changed := false
	for key in ["hair", "hair_color", "skin", "outfit"]:
		if not changes.has(key): continue
		var value: String = str(changes[key]).strip_edges()
		if value.is_empty() or value.length() > 24: return _error("Geçersiz görünüş değeri.")
		colonist["appearance"][key] = value
		changed = true
	if not changed: return _error("Görünüş seçimi boş.")
	colonist["styling_ready_until"] = -1
	return _ok()


func _command_trade_offer(faction_id: String, command: Dictionary) -> Dictionary:
	var to_faction: String = str(command.get("to_faction", ""))
	if to_faction == faction_id or _faction_by_id(to_faction).is_empty(): return _error("Hedef koloni bulunamadı.")
	var give: Dictionary = command.get("give", {})
	var receive: Dictionary = command.get("receive", {})
	if give.is_empty() or receive.is_empty(): return _error("Takasın iki tarafı da doldurulmalı.")
	if not _valid_cargo(give) or not _valid_cargo(receive): return _error("Geçersiz ticaret miktarı.")
	if not _has_cargo(_faction_by_id(faction_id)["inventory"], give): return _error("Teklif için kaynak yetersiz.")
	var offer_id := _new_id("trade")
	state["trade_offers"].append({"id": offer_id, "from_faction": faction_id,
		"to_faction": to_faction, "give": give.duplicate(true), "receive": receive.duplicate(true),
		"status": "pending", "created_at": int(state["time"])})
	var offer_faction_name := str(_faction_by_id(faction_id)["name"])
	_event("trade_offer", "%s ticaret teklifi gönderdi." % offer_faction_name, "",
		"event.trade_offer", {"faction_name": offer_faction_name})
	return _ok({"offer_id": offer_id})


func _command_trade_accept(faction_id: String, command: Dictionary) -> Dictionary:
	var offer := _trade_offer_by_id(str(command.get("offer_id", "")))
	if offer.is_empty() or offer["to_faction"] != faction_id or offer["status"] != "pending":
		return _error("Bekleyen teklif bulunamadı.")
	var source := _faction_by_id(str(offer["from_faction"]))
	var target := _faction_by_id(faction_id)
	if not _has_cargo(source["inventory"], offer["give"]) or not _has_cargo(target["inventory"], offer["receive"]):
		return _error("Takas için kaynak yetersiz.")
	_change_cargo(source["inventory"], offer["give"], -1)
	_change_cargo(target["inventory"], offer["receive"], -1)
	var origin := _site_by_id(state["world"], str(source["site_id"]))
	var destination := _site_by_id(state["world"], str(target["site_id"]))
	var distance: int = abs(int(origin["x"]) - int(destination["x"])) + abs(int(origin["y"]) - int(destination["y"]))
	var eta: int = maxi(12, distance * 2)
	state["caravans"].append({"id": _new_id("caravan"), "kind": "player_trade",
		"from_faction": source["id"], "to_faction": target["id"],
		"from_site": source["site_id"], "to_site": target["site_id"],
		"eta": eta, "cargo_to_target": offer["give"].duplicate(true),
		"cargo_to_source": offer["receive"].duplicate(true), "offer_id": offer["id"]})
	offer["status"] = "in_transit"
	_event("trade_accept", "Ticaret kabul edildi; kervan yola çıktı.", "", "event.trade_accept")
	return _ok({"eta": eta})


func _command_trade_decline(faction_id: String, command: Dictionary) -> Dictionary:
	var offer := _trade_offer_by_id(str(command.get("offer_id", "")))
	if offer.is_empty() or not faction_id in [offer["from_faction"], offer["to_faction"]] or offer["status"] != "pending":
		return _error("Bekleyen teklif bulunamadı.")
	offer["status"] = "declined"
	return _ok()


func _command_npc_trade(faction_id: String, command: Dictionary) -> Dictionary:
	var caravan := _caravan_by_id(str(command.get("caravan_id", "")))
	if caravan.is_empty() or caravan.get("kind", "") != "npc" or caravan.get("faction_id", "") != faction_id:
		return _error("Tüccar kervanı bulunamadı.")
	if int(caravan.get("trade_ready_until", -1)) < int(state["time"]):
		return _error("Speak to a caravan trader first.")
	var buy: Dictionary = command.get("buy", {})
	var sell: Dictionary = command.get("sell", {})
	if buy.is_empty() and sell.is_empty(): return _error("Alınacak veya satılacak eşya seçin.")
	if not _valid_cargo(buy, false) or not _valid_cargo(sell, false): return _error("Geçersiz ticaret miktarı.")
	var faction_inventory: Dictionary = _faction_by_id(faction_id)["inventory"]
	var stock: Dictionary = caravan["stock"]
	if not _has_cargo(stock, buy) or not _has_cargo(faction_inventory, sell): return _error("Eşya stoğu yetersiz.")
	var balance := 0
	for item in buy.keys(): balance -= int(ITEM_PRICES[item]) * int(buy[item])
	for item in sell.keys(): balance += int(ITEM_PRICES[item]) * int(sell[item])
	if int(faction_inventory.get("silver", 0)) + balance < 0: return _error("Gümüş yetersiz.")
	if int(stock.get("silver", 0)) - balance < 0: return _error("Tüccarın gümüşü yetersiz.")
	_change_cargo(faction_inventory, buy, 1)
	_change_cargo(stock, buy, -1)
	_change_cargo(faction_inventory, sell, -1)
	_change_cargo(stock, sell, 1)
	faction_inventory["silver"] = int(faction_inventory.get("silver", 0)) + balance
	stock["silver"] = int(stock.get("silver", 0)) - balance
	_event("npc_trade", "Tüccarla alışveriş tamamlandı.", str(caravan["site_id"]), "event.npc_trade")
	return _ok({"silver_change": balance})


func _command_rename(faction_id: String, command: Dictionary) -> Dictionary:
	var name: String = str(command.get("name", "")).strip_edges()
	if name.is_empty() or name.length() > 32: return _error("Ad 1-32 karakter olmalı.")
	var faction := _faction_by_id(faction_id)
	var target: String = str(command.get("target", ""))
	if target == "faction": faction["name"] = name
	elif target == "settlement":
		faction["settlement_name"] = name
		_site_by_id(state["world"], str(faction["site_id"]))["name"] = name
	else: return _error("Geçersiz adlandırma hedefi.")
	return _ok()


func _resource_at(map_data: Dictionary, x: int, y: int) -> Dictionary:
	for resource in map_data.get("resources", []):
		if int(resource["x"]) == x and int(resource["y"]) == y and int(resource["amount"]) > 0:
			return resource
	return {}


func _structure_at(map_data: Dictionary, x: int, y: int) -> Dictionary:
	for structure in map_data.get("structures", []):
		if int(structure["x"]) == x and int(structure["y"]) == y:
			return structure
	return {}


func _drop_at(map_data: Dictionary, x: int, y: int) -> Dictionary:
	for drop in map_data.get("drops", []):
		if int(drop["x"]) == x and int(drop["y"]) == y:
			return drop
	return {}


func _drop_by_id(map_data: Dictionary, drop_id: String) -> Dictionary:
	for drop in map_data.get("drops", []):
		if drop["id"] == drop_id: return drop
	return {}


func _caravan_by_id(caravan_id: String) -> Dictionary:
	for caravan in state.get("caravans", []):
		if caravan["id"] == caravan_id: return caravan
	return {}


func _trade_offer_by_id(offer_id: String) -> Dictionary:
	for offer in state.get("trade_offers", []):
		if offer["id"] == offer_id: return offer
	return {}


func _valid_cargo(cargo: Dictionary, allow_silver: bool = true) -> bool:
	for item in cargo.keys():
		if not ITEM_PRICES.has(item) and (not allow_silver or item != "silver"): return false
		if int(cargo[item]) <= 0 or int(cargo[item]) > 9999: return false
	return true


func _has_cargo(inventory: Dictionary, cargo: Dictionary) -> bool:
	for item in cargo.keys():
		if int(inventory.get(item, 0)) < int(cargo[item]): return false
	return true


func _change_cargo(inventory: Dictionary, cargo: Dictionary, sign_value: int) -> void:
	for item in cargo.keys():
		inventory[item] = int(inventory.get(item, 0)) + sign_value * int(cargo[item])


func _tick_one_second() -> void:
	state["time"] = int(state["time"]) + 1
	for actor in state["colonists"]:
		actor["previous_x"] = int(actor["x"])
		actor["previous_y"] = int(actor["y"])
	for actor in state["raiders"]:
		actor["previous_x"] = int(actor["x"])
		actor["previous_y"] = int(actor["y"])
	for colonist in state["colonists"]:
		_tick_colonist(colonist)
	_tick_social()
	_tick_raiders()
	_tick_caravans()
	_tick_farms()
	state["raid_clock"] = int(state["raid_clock"]) + 1
	state["caravan_clock"] = int(state["caravan_clock"]) + 1
	var difficulty: Dictionary = SetupCatalog.find_by_id(SetupCatalog.DIFFICULTIES, str(state.get("difficulty_id", "frontier")))
	if float(difficulty.get("raid_scale", 1.0)) > 0.0:
		var raid_period := _event_period("raid")
		if int(state["raid_clock"]) == raid_period - 20:
			for faction in state["factions"]:
				_event("raid_warning", "%s yakınlarında düşman izleri görüldü." % faction["settlement_name"],
					str(faction["site_id"]), "event.raid_warning", {"settlement_name": str(faction["settlement_name"])})
		if int(state["raid_clock"]) >= raid_period:
			state["raid_clock"] = -40
			state["raid_cycle"] = int(state.get("raid_cycle", 0)) + 1
			_spawn_raids()
	if int(state["caravan_clock"]) >= _event_period("caravan"):
		state["caravan_clock"] = -35
		state["caravan_cycle"] = int(state.get("caravan_cycle", 0)) + 1
		_spawn_npc_caravans()


func _event_period(kind: String) -> int:
	var storyteller: Dictionary = SetupCatalog.find_by_id(SetupCatalog.STORYTELLERS, str(state.get("storyteller_id", "steady")))
	var factor := float(storyteller.get("raid_factor", 1.0)) if kind == "raid" else float(storyteller.get("caravan_factor", 1.0))
	if kind == "raid":
		var difficulty: Dictionary = SetupCatalog.find_by_id(SetupCatalog.DIFFICULTIES, str(state.get("difficulty_id", "frontier")))
		factor /= maxf(0.1, float(difficulty.get("raid_scale", 1.0)))
	var variance := float(storyteller.get("variance", 0.0))
	if variance > 0.0:
		var rng := RandomNumberGenerator.new()
		rng.seed = _seed_number("%s/%s/%d" % [str(state.get("seed", "")), kind, int(state.get(kind + "_cycle", 0))])
		factor *= 1.0 + rng.randf_range(-variance, variance)
	return maxi(35, roundi((150.0 if kind == "raid" else 100.0) * factor))


func _tick_colonist(colonist: Dictionary) -> void:
	if not bool(colonist["alive"]): return
	var faction := _faction_by_id(str(colonist["faction_id"]))
	var needs: Dictionary = colonist["needs"]
	var health: Dictionary = colonist["health"]
	needs["hunger"] = maxf(0.0, float(needs["hunger"]) - 0.18)
	needs["rest"] = maxf(0.0, float(needs["rest"]) - 0.11)
	if float(health["bleeding"]) > 0.0:
		health["hp"] = maxf(0.0, float(health["hp"]) - float(health["bleeding"]) * 0.10)
	if float(needs["hunger"]) <= 0.0:
		health["hp"] = maxf(0.0, float(health["hp"]) - 0.2)
	if float(health["hp"]) <= 0.0:
		colonist["alive"] = false
		colonist["current_order"] = ""
		colonist["manual"] = {}
		_event("death", "%s hayatını kaybetti." % colonist["name"], str(colonist["site_id"]),
			"event.death", {"colonist_name": str(colonist["name"])}, [str(colonist["id"])])
		return
	if float(health["bleeding"]) <= 0.0 and float(health["hp"]) < 100.0:
		health["hp"] = minf(100.0, float(health["hp"]) + 0.025)
	_update_health_summary(health)
	var day_length := maxi(1, int(state.get("day_length", 600)))
	var hour := (8 + floori(float(posmod(int(state["time"]), day_length)) * 24.0 / float(day_length))) % 24
	var plan: Array = colonist.get("schedule", _default_schedule())
	var activity := str(plan[hour]) if hour < plan.size() else "anything"
	if float(needs["hunger"]) < 42.0 and int(faction["inventory"].get("food", 0)) > 0:
		faction["inventory"]["food"] = int(faction["inventory"]["food"]) - 1
		needs["hunger"] = minf(100.0, float(needs["hunger"]) + 42.0)
	_update_mood(colonist)
	var has_manual_order := not (colonist.get("manual", {}) as Dictionary).is_empty()
	if has_manual_order: colonist["resting"] = false
	if (float(needs["rest"]) < 20.0 or activity == "sleep") and not bool(colonist["drafted"]) and not has_manual_order:
		colonist["resting"] = true
	if bool(colonist.get("resting", false)) and not bool(colonist["drafted"]):
		var rest_gain := 0.9
		for structure in state["maps"][colonist["site_id"]]["structures"]:
			if structure["kind"] == "bed": rest_gain = 1.7; break
		needs["rest"] = minf(100.0, float(needs["rest"]) + rest_gain)
		if float(needs["rest"]) >= 80.0 and activity != "sleep": colonist["resting"] = false
		return
	if int(colonist.get("attack_cooldown", 0)) > 0:
		colonist["attack_cooldown"] = int(colonist["attack_cooldown"]) - 1
	if not (colonist.get("carrying", {}) as Dictionary).is_empty() and (colonist.get("manual", {}) as Dictionary).get("action", "") != "haul":
		_tick_carry_to_stockpile(colonist)
		return
	if not colonist["manual"].is_empty():
		if _tick_manual(colonist): return
	if bool(colonist["drafted"]):
		_tick_drafted(colonist)
		return
	if _tick_treat(colonist): return
	if activity == "recreation":
		needs["mood"] = minf(100.0, float(needs.get("mood", 75.0)) + 0.05)
		_tick_idle(colonist)
		return
	var current := _order_by_id(str(colonist["current_order"]))
	if not current.is_empty() and current["status"] == "claimed" and current["claimed_by"] == colonist["id"]:
		_tick_order(colonist, current)
		return
	colonist["current_order"] = ""
	var next_order := _choose_order(colonist)
	if not next_order.is_empty():
		_claim_order(colonist, next_order)
		_tick_order(colonist, next_order)
		return
	if _tick_research(colonist): return
	_tick_idle(colonist)


func _tick_idle(colonist: Dictionary) -> void:
	var target: Dictionary = colonist.get("idle_target", {})
	if not target.is_empty():
		if int(state["time"]) >= int(colonist.get("idle_until", 0)):
			colonist["idle_target"] = {}
			return
		if _move_towards(colonist, int(target["x"]), int(target["y"])):
			colonist["idle_target"] = {}
			colonist["idle_until"] = int(state["time"]) + 8
		return
	if int(state["time"]) < int(colonist.get("idle_until", 0)): return
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number("%s/%d/idle" % [colonist["id"], int(state["time"] / 8)])
	var map_data: Dictionary = state["maps"][colonist["site_id"]]
	for attempt in range(10):
		var x := clampi(int(colonist["x"]) + rng.randi_range(-5, 5), 1, LOCAL_SIZE - 2)
		var y := clampi(int(colonist["y"]) + rng.randi_range(-5, 5), 1, LOCAL_SIZE - 2)
		if abs(x - 25) + abs(y - 25) > 17 or not _passable(map_data, x, y): continue
		colonist["idle_target"] = {"x": x, "y": y}
		colonist["idle_until"] = int(state["time"]) + 18
		return
	colonist["idle_until"] = int(state["time"]) + 10


func _update_mood(colonist: Dictionary) -> void:
	var needs: Dictionary = colonist["needs"]
	var active: Array = []
	var thought_score := 0.0
	for thought in needs.get("thoughts", []):
		if int(thought.get("expires_at", 0)) <= int(state["time"]) or str(thought.get("kind", "")) == "status": continue
		active.append(thought)
		thought_score += float(thought.get("value", 0))
	var status: Array = []
	if float(needs["hunger"]) < 35.0: status.append({"label": "Hungry", "value": -15})
	elif float(needs["hunger"]) > 70.0: status.append({"label": "Fed", "value": 3})
	if float(needs["rest"]) < 30.0: status.append({"label": "Tired", "value": -13})
	elif float(needs["rest"]) > 75.0: status.append({"label": "Well rested", "value": 3})
	if float(colonist["health"]["hp"]) < 65.0: status.append({"label": "In pain", "value": -10})
	if colonist["traits"].has("night_owl"):
		var night := posmod(int(state["time"]), 600) >= 360
		status.append({"label": "Night owl at night" if night else "Night owl in daylight", "value": 4 if night else -3})
	for entry in status:
		active.append({"kind": "status", "label": entry["label"], "value": entry["value"],
			"expires_at": int(state["time"]) + 2})
		thought_score += float(entry["value"])
	needs["thoughts"] = active
	var target := 65.0 + thought_score
	if colonist["traits"].has("calm"): target += 8.0
	if colonist["traits"].has("abrasive"): target -= 5.0
	needs["mood"] = move_toward(float(needs["mood"]), clampf(target, 0.0, 100.0), 0.12)


func _update_health_summary(health: Dictionary) -> void:
	var grouped: Dictionary = {}
	for wound in health.get("wounds", []):
		var kind := str(wound.get("kind", "injury"))
		if not grouped.has(kind): grouped[kind] = {"kind": kind, "count": 0, "max_severity": 0.0}
		grouped[kind]["count"] = int(grouped[kind]["count"]) + 1
		grouped[kind]["max_severity"] = maxf(float(grouped[kind]["max_severity"]), float(wound.get("severity", 0.0)))
	var summary: Array = []
	for entry in grouped.values():
		var severity: float = float(entry["max_severity"])
		entry["severity_label"] = "minor" if severity < 5.0 else "moderate" if severity < 10.0 else "severe" if severity < 17.0 else "critical"
		summary.append(entry)
	health["wound_summary"] = summary


func _tick_social() -> void:
	if int(state["time"]) % 30 != 0: return
	for faction in state["factions"]:
		var people: Array = []
		for person in state["colonists"]:
			if person["faction_id"] == faction["id"] and bool(person["alive"]): people.append(person)
		if people.size() < 2:
			# A lone survivor can name the place after settling in; crews decide
			# together when they first have a nearby social interaction.
			if not people.is_empty() and int(state["time"]) >= 60:
				_prompt_colony_naming(faction)
			continue
		var first: Dictionary = people[0]
		var second: Dictionary = people[1]
		if abs(int(first["x"]) - int(second["x"])) + abs(int(first["y"]) - int(second["y"])) > 5: continue
		var relation_type := str(first.get("relationship_types", {}).get(str(second["id"]), ""))
		var conflict: bool = relation_type == "rival" or first["traits"].has("abrasive") or second["traits"].has("abrasive")
		var value := -5 if relation_type == "rival" else -3 if conflict else 5 if relation_type == "partner" else 4 if relation_type == "friend" else 3
		var label := "Argument with %s" if conflict else "Pleasant conversation with %s"
		for pair in [[first, second], [second, first]]:
			var speaker: Dictionary = pair[0]
			var other: Dictionary = pair[1]
			var thoughts: Array = speaker["needs"]["thoughts"]
			thoughts.append({"kind": "social", "label": label % other["name"], "value": value,
				"expires_at": int(state["time"]) + 120})
			if thoughts.size() > 10: thoughts.pop_front()
			var old: int = int(speaker["relationships"].get(str(other["id"]), 0))
			speaker["relationships"][str(other["id"])] = clampi(old + value, -100, 100)
		_event("social", "%s and %s %s." % [first["name"], second["name"], "argued" if conflict else "talked"],
			str(faction["site_id"]), "event.social_argument" if conflict else "event.social_talk",
			{"first_name": str(first["name"]), "second_name": str(second["name"])},
			[str(first["id"]), str(second["id"])])
		if int(state["time"]) >= 60:
			_prompt_colony_naming(faction)


func _prompt_colony_naming(faction: Dictionary) -> void:
	if bool(faction.get("name_prompted", false)):
		return
	faction["name_prompted"] = true
	if str(faction.get("name", "")).begins_with("Unnamed") or str(faction.get("settlement_name", "")).begins_with("Unnamed"):
		_event("naming_prompt", "Name your colony and settlement.", str(faction["site_id"]), "event.naming_prompt")


func _tick_manual(colonist: Dictionary) -> bool:
	var manual: Dictionary = colonist["manual"]
	var action: String = str(manual.get("action", ""))
	if action == "move":
		if _move_towards(colonist, int(manual["x"]), int(manual["y"])):
			colonist["manual"] = {}
		elif _route_failed(colonist):
			_cancel_unreachable_manual(colonist)
		return true
	if action == "work":
		var order := _order_by_id(str(manual.get("order_id", "")))
		if order.is_empty() or order["status"] in ["done", "cancelled"]:
			colonist["manual"] = {}
			return false
		if int(order.get("retry_at", 0)) > int(state["time"]):
			colonist["manual"] = {}
			return false
		if not _order_can_start(order): return true
		if order["claimed_by"] != colonist["id"]: _claim_order(colonist, order)
		_tick_order(colonist, order)
		if order["status"] == "done": colonist["manual"] = {}
		return true
	if action == "haul":
		var map_data: Dictionary = state["maps"].get(colonist["site_id"], {})
		if (colonist.get("carrying", {}) as Dictionary).is_empty():
			var drop := _drop_by_id(map_data, str(manual.get("drop_id", "")))
			if drop.is_empty():
				colonist["manual"] = {}
				return false
			if _move_towards(colonist, int(drop["x"]), int(drop["y"])):
				_pickup_drop(colonist, drop)
			elif _route_failed(colonist):
				_cancel_unreachable_manual(colonist)
		else:
			if _tick_carry_to_stockpile(colonist): colonist["manual"] = {}
		return true
	if action == "equip":
		if not _move_towards(colonist, int(manual["x"]), int(manual["y"])):
			if _route_failed(colonist): _cancel_unreachable_manual(colonist)
			return true
		var item := str(manual["item"])
		var inventory: Dictionary = _faction_by_id(str(colonist["faction_id"]))["inventory"]
		if int(inventory.get(item, 0)) > 0:
			var slot := "weapon" if item == "spear" else "apparel"
			var previous: String = str(colonist["equipment"][slot])
			inventory[item] = int(inventory[item]) - 1
			if previous in ["spear", "jacket"]: inventory[previous] = int(inventory.get(previous, 0)) + 1
			colonist["equipment"][slot] = item
		colonist["manual"] = {}
		return true
	if action == "trade":
		var caravan := _caravan_by_id(str(manual.get("caravan_id", "")))
		if caravan.is_empty():
			colonist["manual"] = {}
			return false
		if _move_towards(colonist, int(manual["x"]), int(manual["y"]), 1):
			caravan["trade_ready_until"] = int(state["time"]) + 30
			caravan["trade_ready_colonist_id"] = colonist["id"]
			_event("trade_ready", "%s tüccarla görüşmeye hazır." % colonist["name"],
				str(colonist["site_id"]), "event.trade_ready", {"colonist_name": str(colonist["name"])}, [str(colonist["id"])])
			colonist["manual"] = {}
		elif _route_failed(colonist):
			_cancel_unreachable_manual(colonist)
		return true
	if action == "style":
		if _move_towards(colonist, int(manual["x"]), int(manual["y"]), 1):
			colonist["styling_ready_until"] = int(state["time"]) + 30
			_event("styling_ready", "%s is ready to change appearance." % colonist["name"],
				str(colonist["site_id"]), "event.styling_ready", {"colonist_name": str(colonist["name"])}, [str(colonist["id"])])
			colonist["manual"] = {}
		elif _route_failed(colonist):
			_cancel_unreachable_manual(colonist)
		return true
	if action == "attack":
		var raider := _raider_by_id(str(manual.get("target_id", "")))
		if raider.is_empty() or float(raider["hp"]) <= 0.0:
			colonist["manual"] = {}
			return false
		_attack_raider(colonist, raider)
		return true
	colonist["manual"] = {}
	return false


func _cancel_unreachable_manual(colonist: Dictionary) -> void:
	colonist["manual"] = {}
	_event("unreachable_manual", "%s cannot reach the ordered destination." % colonist["name"],
		str(colonist["site_id"]), "event.unreachable_manual", {"colonist_name": str(colonist["name"])}, [str(colonist["id"])])


func _tick_drafted(colonist: Dictionary) -> void:
	var nearest: Dictionary = {}
	var best_distance := 9999
	for raider in state["raiders"]:
		if raider["site_id"] != colonist["site_id"] or float(raider["hp"]) <= 0.0: continue
		var distance: int = abs(int(raider["x"]) - int(colonist["x"])) + abs(int(raider["y"]) - int(colonist["y"]))
		if distance < best_distance:
			best_distance = distance
			nearest = raider
	if not nearest.is_empty() and best_distance <= 4: _attack_raider(colonist, nearest)


func _tick_treat(colonist: Dictionary) -> bool:
	if int(colonist["work_priorities"].get("treat", 0)) == 0: return false
	var target: Dictionary = {}
	for other in state["colonists"]:
		if other["faction_id"] == colonist["faction_id"] and other["alive"] and (float(other["health"]["bleeding"]) > 0.0 or float(other["health"]["hp"]) < 65.0):
			target = other
			break
	if target.is_empty(): return false
	if not _move_towards(colonist, int(target["x"]), int(target["y"]), 1): return not _route_failed(colonist)
	var inventory: Dictionary = _faction_by_id(str(colonist["faction_id"]))["inventory"]
	var advanced_aid: bool = _faction_by_id(str(colonist["faction_id"]))["research"]["unlocked"].has("first_aid")
	var caring_bonus := 5.0 if colonist["traits"].has("kind") else 0.0
	if int(inventory.get("medicine", 0)) > 0:
		inventory["medicine"] = int(inventory["medicine"]) - 1
		target["health"]["bleeding"] = 0.0
		target["health"]["hp"] = minf(100.0, float(target["health"]["hp"]) + (30.0 if advanced_aid else 20.0) + caring_bonus)
		if not target["health"]["wounds"].is_empty(): target["health"]["wounds"].pop_front()
	else:
		target["health"]["bleeding"] = maxf(0.0, float(target["health"]["bleeding"]) - (0.25 if advanced_aid else 0.12))
		target["health"]["hp"] = minf(100.0, float(target["health"]["hp"]) + (4.0 if advanced_aid else 2.0) + caring_bonus * 0.2)
	return true


func _choose_order(colonist: Dictionary) -> Dictionary:
	var candidates: Array = []
	for order in state["orders"]:
		if order["faction_id"] != colonist["faction_id"] or order["site_id"] != colonist["site_id"]: continue
		if order["status"] != "queued" or int(order.get("retry_at", 0)) > int(state["time"]) or not _order_can_start(order): continue
		var work_type := _work_for_order(str(order["kind"]))
		var work_priority: int = int(colonist["work_priorities"].get(work_type, 0))
		if work_priority == 0: continue
		candidates.append({"order": order, "work_priority": work_priority})
	if candidates.is_empty(): return {}
	candidates.sort_custom(func(a, b):
		if int(a["work_priority"]) != int(b["work_priority"]):
			return int(a["work_priority"]) < int(b["work_priority"])
		if int(a["order"]["priority"]) != int(b["order"]["priority"]):
			return int(a["order"]["priority"]) < int(b["order"]["priority"])
		return int(a["order"]["created_at"]) < int(b["order"]["created_at"])
	)
	return candidates[0]["order"]


func _work_for_order(kind: String) -> String:
	if kind.begins_with("build_"): return "build"
	return kind


func _order_can_start(order: Dictionary) -> bool:
	if order["status"] in ["done", "cancelled"]: return false
	var kind: String = str(order["kind"])
	if BUILD_COSTS.has(kind):
		var faction := _faction_by_id(str(order["faction_id"]))
		return _has_cargo(faction["inventory"], BUILD_COSTS[kind])
	if RESOURCE_KINDS.has(kind):
		var map_data: Dictionary = state["maps"][order["site_id"]]
		var resource := _resource_at(map_data, int(order["x"]), int(order["y"]))
		return not resource.is_empty() and resource["kind"] == RESOURCE_KINDS[kind]
	if kind == "haul":
		var map_data: Dictionary = state["maps"][order["site_id"]]
		var drop := _drop_at(map_data, int(order["x"]), int(order["y"]))
		return not drop.is_empty() and not _stockpile_for(map_data, int(drop["x"]), int(drop["y"]), str(drop["kind"])).is_empty()
	return true


func _claim_order(colonist: Dictionary, order: Dictionary) -> void:
	var previous := _order_by_id(str(colonist["current_order"]))
	if not previous.is_empty() and previous["claimed_by"] == colonist["id"] and previous["id"] != order["id"]:
		previous["status"] = "queued"
		previous["claimed_by"] = ""
	if not str(order["claimed_by"]).is_empty() and order["claimed_by"] != colonist["id"]:
		var other := _colonist_by_id(str(order["claimed_by"]))
		if not other.is_empty(): other["current_order"] = ""
	order["status"] = "claimed"
	order["claimed_by"] = colonist["id"]
	colonist["current_order"] = order["id"]


func _tick_order(colonist: Dictionary, order: Dictionary) -> void:
	if str(order["kind"]) == "haul":
		var carried: Dictionary = colonist.get("carrying", {})
		if not carried.is_empty():
			if _tick_carry_to_stockpile(colonist):
				order["status"] = "done"
				order["claimed_by"] = ""
				colonist["current_order"] = ""
			elif (colonist.get("carrying", {}) as Dictionary).is_empty():
				order["retry_at"] = int(state["time"]) + 30
				order["status"] = "queued"
				order["claimed_by"] = ""
				colonist["current_order"] = ""
			return
		var map_data: Dictionary = state["maps"][order["site_id"]]
		var drop := _drop_at(map_data, int(order["x"]), int(order["y"]))
		if drop.is_empty() or _stockpile_for(map_data, int(drop["x"]), int(drop["y"]), str(drop["kind"])).is_empty():
			order["status"] = "queued"
			order["claimed_by"] = ""
			colonist["current_order"] = ""
			return
		var before := Vector2i(int(colonist["x"]), int(colonist["y"]))
		if _move_towards(colonist, int(drop["x"]), int(drop["y"])):
			_pickup_drop(colonist, drop)
		else:
			_check_order_stuck(colonist, order, before)
		return
	if not _order_can_start(order):
		order["status"] = "queued"
		order["claimed_by"] = ""
		colonist["current_order"] = ""
		return
	var before := Vector2i(int(colonist["x"]), int(colonist["y"]))
	if not _move_towards(colonist, int(order["x"]), int(order["y"])):
		_check_order_stuck(colonist, order, before)
		return
	order["stuck_ticks"] = 0
	var work_type := _work_for_order(str(order["kind"]))
	var skill: int = int(colonist["skills"].get(work_type, 2))
	var rate := 0.14 + float(skill) * 0.018
	if colonist["traits"].has("hardworking"): rate *= 1.25
	if colonist["traits"].has("timid") and work_type == "build": rate *= 0.9
	if colonist["traits"].has("lazy"): rate *= 0.78
	if (colonist["health"].get("conditions", []) as Array).has("bad_back") and work_type in ["mine", "haul", "build"]: rate *= 0.76
	if (colonist["health"].get("conditions", []) as Array).has("asthma"): rate *= 0.87
	order["progress"] = minf(1.0, float(order["progress"]) + rate)
	if float(order["progress"]) >= 1.0:
		_complete_order(colonist, order)


func _check_order_stuck(colonist: Dictionary, order: Dictionary, before: Vector2i) -> void:
	if Vector2i(int(colonist["x"]), int(colonist["y"])) != before:
		order["stuck_ticks"] = 0
		return
	order["stuck_ticks"] = int(order.get("stuck_ticks", 0)) + 1
	if int(order["stuck_ticks"]) < 6: return
	order["stuck_ticks"] = 0
	order["retry_at"] = int(state["time"]) + 30
	order["status"] = "queued"
	order["claimed_by"] = ""
	colonist["current_order"] = ""
	if str((colonist.get("manual", {}) as Dictionary).get("order_id", "")) == str(order["id"]):
		colonist["manual"] = {}
	_event("unreachable_order", "A colonist cannot reach a designated job.",
		str(order["site_id"]), "event.unreachable_order", {}, [str(colonist["id"])])


func _complete_order(colonist: Dictionary, order: Dictionary) -> void:
	var map_data: Dictionary = state["maps"][order["site_id"]]
	var kind: String = str(order["kind"])
	if RESOURCE_KINDS.has(kind):
		var resource := _resource_at(map_data, int(order["x"]), int(order["y"]))
		if not resource.is_empty():
			map_data["resources"].erase(resource)
			var amount := 4 if kind != "harvest" else 3
			var drop := {"id": _new_id("drop"), "x": int(order["x"]), "y": int(order["y"]),
				"kind": OUTPUT_KINDS[kind], "amount": amount}
			map_data["drops"].append(drop)
			state["orders"].append({"id": _new_id("order"), "faction_id": order["faction_id"],
				"site_id": order["site_id"], "kind": "haul", "x": int(order["x"]), "y": int(order["y"]),
				"priority": int(order["priority"]), "status": "queued", "claimed_by": "",
				"progress": 0.0, "created_at": int(state["time"])})
	elif kind.begins_with("build_"):
		if BUILD_COSTS.has(kind):
			_change_cargo(_faction_by_id(str(order["faction_id"]))["inventory"], BUILD_COSTS[kind], -1)
		map_data["structures"].append({"id": _new_id("structure"), "kind": kind.trim_prefix("build_"),
			"x": int(order["x"]), "y": int(order["y"]), "built_at": int(state["time"])})
		_event("build", "%s tamamlandı." % _building_name(kind), str(order["site_id"]),
			"event.build", {"building_kind": kind}, [str(colonist["id"])])
	order["status"] = "done"
	order["claimed_by"] = ""
	colonist["current_order"] = ""


func _building_name(kind: String) -> String:
	match kind:
		"build_wall": return "Ahşap duvar"
		"build_stone_wall": return "Taş duvar"
		"build_bed": return "Yatak"
		"build_research_bench": return "Araştırma masası"
		"build_styling_table": return "Styling table"
		"build_barrier": return "Barikat"
		"build_farm": return "Ekim alanı"
	return "Yapı"


func _pickup_drop(colonist: Dictionary, drop: Dictionary) -> void:
	var map_data: Dictionary = state["maps"][colonist["site_id"]]
	colonist["carrying"] = {"kind": str(drop["kind"]), "amount": int(drop["amount"]),
		"source_x": int(drop["x"]), "source_y": int(drop["y"])}
	map_data["drops"].erase(drop)


func _tick_carry_to_stockpile(colonist: Dictionary) -> bool:
	var carried: Dictionary = colonist.get("carrying", {})
	if carried.is_empty(): return true
	var map_data: Dictionary = state["maps"][colonist["site_id"]]
	var stockpile := _stockpile_for(map_data, int(colonist["x"]), int(colonist["y"]), str(carried["kind"]), true)
	if stockpile.is_empty():
		map_data["drops"].append({"id": _new_id("drop"), "x": colonist["x"], "y": colonist["y"],
			"kind": carried["kind"], "amount": carried["amount"]})
		colonist["carrying"] = {}
		return false
	if not _move_towards(colonist, int(stockpile["x"]), int(stockpile["y"])): return false
	var inventory: Dictionary = _faction_by_id(str(colonist["faction_id"]))["inventory"]
	var item: String = str(carried["kind"])
	inventory[item] = int(inventory.get(item, 0)) + int(carried["amount"])
	colonist["carrying"] = {}
	for order in state["orders"]:
		if order["kind"] == "haul" and order["site_id"] == colonist["site_id"] and int(order["x"]) == int(carried["source_x"]) and int(order["y"]) == int(carried["source_y"]) and order["status"] != "done":
			var owner := _colonist_by_id(str(order.get("claimed_by", "")))
			order["status"] = "done"
			order["claimed_by"] = ""
			if not owner.is_empty(): owner["current_order"] = ""
			break
	return true


func _tick_research(colonist: Dictionary) -> bool:
	var priority: int = int(colonist["work_priorities"].get("research", 0))
	if priority == 0: return false
	var faction := _faction_by_id(str(colonist["faction_id"]))
	var research: Dictionary = faction["research"]
	var project: String = str(research["project"])
	if project.is_empty() or not RESEARCH_PROJECTS.has(project): return false
	var map_data: Dictionary = state["maps"][colonist["site_id"]]
	var bench: Dictionary = {}
	for structure in map_data["structures"]:
		if structure["kind"] == "research_bench": bench = structure; break
	if bench.is_empty(): return false
	if not _move_towards(colonist, int(bench["x"]), int(bench["y"]), 1): return not _route_failed(colonist)
	var rate := 0.75 + float(colonist["skills"]["research"]) * 0.13
	if colonist["traits"].has("curious"): rate *= 1.3
	research["progress"] = float(research["progress"]) + rate
	if float(research["progress"]) >= float(RESEARCH_PROJECTS[project]["cost"]):
		research["unlocked"].append(project)
		research["project"] = ""
		research["progress"] = 0.0
		_event("research", "%s araştırması tamamlandı." % RESEARCH_PROJECTS[project]["name"],
			str(colonist["site_id"]), "event.research", {"project_id": project}, [str(colonist["id"])])
	return true


func _move_towards(actor: Dictionary, target_x: int, target_y: int, acceptable_distance: int = 0, allow_quick_step: bool = true) -> bool:
	var origin := Vector2i(int(actor["x"]), int(actor["y"]))
	var destination := Vector2i(target_x, target_y)
	var actor_id := str(actor["id"])
	if abs(origin.x - target_x) + abs(origin.y - target_y) <= acceptable_distance:
		_route_cache.erase(actor_id)
		return true
	var map_data: Dictionary = state["maps"].get(actor["site_id"], {})
	if map_data.is_empty(): return false
	var structure_count: int = map_data["structures"].size()
	var route: Dictionary = _route_cache.get(actor_id, {})
	var route_valid: bool = not route.is_empty() and route.get("destination", Vector2i(-1, -1)) == destination \
		and int(route.get("acceptable_distance", -1)) == acceptable_distance \
		and route.get("origin", Vector2i(-1, -1)) == origin \
		and int(route.get("structure_count", -1)) == structure_count \
		and str(route.get("site_id", "")) == str(actor["site_id"])
	if route_valid and bool(route.get("failed", false)):
		if int(route.get("retry_at", 0)) > int(state["time"]): return false
		route_valid = false
	if route_valid and not bool(route.get("failed", false)):
		var cached_steps: Array[Vector2i] = route["steps"]
		if cached_steps.is_empty() or not _passable(map_data, cached_steps[0].x, cached_steps[0].y):
			route_valid = false
	if not route_valid:
		var found_steps := _find_route(map_data, origin, destination, acceptable_distance)
		route = {"destination": destination, "acceptable_distance": acceptable_distance,
			"origin": origin, "structure_count": structure_count, "site_id": str(actor["site_id"]),
			"steps": found_steps, "failed": found_steps.is_empty(),
			"retry_at": int(state["time"]) + 3}
		_route_cache[actor_id] = route
		if found_steps.is_empty(): return false
	var steps: Array[Vector2i] = route["steps"]
	var next: Vector2i = steps.pop_front()
	actor["x"] = next.x
	actor["y"] = next.y
	actor["facing"] = "right" if next.x > origin.x else "left" if next.x < origin.x else "down" if next.y > origin.y else "up"
	var arrived: bool = abs(next.x - target_x) + abs(next.y - target_y) <= acceptable_distance
	if arrived:
		_route_cache.erase(actor_id)
	else:
		route["origin"] = next
		route["steps"] = steps
		_route_cache[actor_id] = route
	if not arrived and allow_quick_step and actor.get("traits", []).has("quick") and int(state["time"]) % 2 == 0:
		return _move_towards(actor, target_x, target_y, acceptable_distance, false)
	return arrived


func _find_route(map_data: Dictionary, origin: Vector2i, destination: Vector2i, acceptable_distance: int = 0) -> Array[Vector2i]:
	var route: Array[Vector2i] = []
	if map_data.is_empty() or origin.x < 0 or origin.x >= LOCAL_SIZE or origin.y < 0 or origin.y >= LOCAL_SIZE:
		return route
	var start_index := origin.y * LOCAL_SIZE + origin.x
	var parents := PackedInt32Array()
	parents.resize(LOCAL_SIZE * LOCAL_SIZE)
	parents.fill(-1)
	parents[start_index] = start_index
	var queue := PackedInt32Array([start_index])
	var head := 0
	var goal_index := -1
	var directions: Array[Vector2i] = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
	while head < queue.size():
		var index: int = queue[head]
		head += 1
		var cell := Vector2i(index % LOCAL_SIZE, index / LOCAL_SIZE)
		if abs(cell.x - destination.x) + abs(cell.y - destination.y) <= acceptable_distance:
			goal_index = index
			break
		for direction in directions:
			var next: Vector2i = cell + direction
			if not _passable(map_data, next.x, next.y): continue
			var next_index := next.y * LOCAL_SIZE + next.x
			if parents[next_index] != -1: continue
			parents[next_index] = index
			queue.append(next_index)
	if goal_index < 0: return route
	var cursor := goal_index
	while cursor != start_index:
		route.append(Vector2i(cursor % LOCAL_SIZE, cursor / LOCAL_SIZE))
		cursor = parents[cursor]
	route.reverse()
	return route


func _can_reach(map_data: Dictionary, actor: Dictionary, target_x: int, target_y: int, acceptable_distance: int = 0) -> bool:
	var origin := Vector2i(int(actor["x"]), int(actor["y"]))
	if abs(origin.x - target_x) + abs(origin.y - target_y) <= acceptable_distance: return true
	return not _find_route(map_data, origin, Vector2i(target_x, target_y), acceptable_distance).is_empty()


func _route_failed(actor: Dictionary) -> bool:
	return bool((_route_cache.get(str(actor["id"]), {}) as Dictionary).get("failed", false))


func _passable(map_data: Dictionary, x: int, y: int) -> bool:
	if map_data.is_empty() or x < 0 or x >= LOCAL_SIZE or y < 0 or y >= LOCAL_SIZE: return false
	if map_data["terrain"][y * LOCAL_SIZE + x] == "water": return false
	var structure := _structure_at(map_data, x, y)
	if not structure.is_empty() and structure["kind"] in ["wall", "stone_wall", "barrier"]: return false
	return true


func _attack_raider(colonist: Dictionary, raider: Dictionary) -> void:
	if int(colonist.get("attack_cooldown", 0)) > 0: return
	if str(raider.get("phase", "attacking")) == "preparing":
		raider["phase"] = "attacking"
		_event("raid_attack", "The raiders have been provoked.", str(raider["site_id"]), "event.raid_provoked")
	var distance: int = abs(int(colonist["x"]) - int(raider["x"])) + abs(int(colonist["y"]) - int(raider["y"]))
	if distance > 1:
		_move_towards(colonist, int(raider["x"]), int(raider["y"]), 1)
		if _route_failed(colonist) and str((colonist.get("manual", {}) as Dictionary).get("action", "")) == "attack":
			_cancel_unreachable_manual(colonist)
		return
	var damage := 10.0 + float(colonist["skills"]["combat"]) * 1.2
	if colonist["equipment"]["weapon"] == "spear": damage += 10.0
	if colonist["traits"].has("timid"): damage *= 0.75
	raider["hp"] = maxf(0.0, float(raider["hp"]) - damage)
	colonist["attack_cooldown"] = 2
	if float(raider["hp"]) <= 0.0:
		_event("raid_defeated", "Bir akıncı etkisiz hale getirildi.", str(raider["site_id"]),
			"event.raid_defeated")


func _tick_raiders() -> void:
	var removed: Array = []
	for raider in state["raiders"]:
		if float(raider["hp"]) <= 0.0:
			removed.append(raider)
			continue
		if str(raider.get("phase", "attacking")) == "preparing":
			if int(state["time"]) < int(raider.get("attack_at", 0)): continue
			raider["phase"] = "attacking"
			_event("raid_attack", "The raiders begin their attack.", str(raider["site_id"]), "event.raid_attack")
		var target: Dictionary = {}
		var best_distance := 9999
		for colonist in state["colonists"]:
			if colonist["site_id"] != raider["site_id"] or not bool(colonist["alive"]): continue
			var distance: int = abs(int(colonist["x"]) - int(raider["x"])) + abs(int(colonist["y"]) - int(raider["y"]))
			if distance < best_distance:
				best_distance = distance
				target = colonist
		if target.is_empty(): continue
		if best_distance > 1:
			_move_towards(raider, int(target["x"]), int(target["y"]), 1)
			continue
		if int(raider.get("attack_cooldown", 0)) > 0:
			raider["attack_cooldown"] = int(raider["attack_cooldown"]) - 1
			continue
		var damage := 8.0
		if target["equipment"]["apparel"] == "jacket": damage *= 0.72
		target["health"]["hp"] = maxf(0.0, float(target["health"]["hp"]) - damage)
		target["health"]["bleeding"] = minf(4.0, float(target["health"]["bleeding"]) + 0.35)
		target["health"]["wounds"].append({"kind": "cut", "severity": damage, "time": int(state["time"])})
		raider["attack_cooldown"] = 2
	for raider in removed: state["raiders"].erase(raider)


func _spawn_raids() -> void:
	var hostile_sites: Array = state["world"]["sites"].filter(func(s): return s["kind"] == "hostile")
	if hostile_sites.is_empty(): return
	for faction in state["factions"]:
		var living := 0
		for colonist in state["colonists"]:
			if colonist["faction_id"] == faction["id"] and colonist["alive"]: living += 1
		if living == 0: continue
		var site_id: String = str(faction["site_id"])
		var map_data: Dictionary = state["maps"][site_id]
		var difficulty: Dictionary = SetupCatalog.find_by_id(SetupCatalog.DIFFICULTIES, str(state.get("difficulty_id", "frontier")))
		var count := maxi(1, roundi((1.0 if living <= 2 else 2.0) * float(difficulty.get("raid_scale", 1.0))))
		for i in range(count):
			var edge := _find_edge_spawn(map_data, i + int(state["time"]))
			state["raiders"].append({"id": _new_id("raider"), "site_id": site_id,
				"source_site_id": hostile_sites[(int(state["time"]) + i) % hostile_sites.size()]["id"],
				"x": edge.x, "y": edge.y, "previous_x": edge.x, "previous_y": edge.y,
				"hp": 55.0, "attack_cooldown": 0,
				"phase": "preparing", "attack_at": int(state["time"]) + 20})
		_event("raid", "%s yerleşkesine akıncılar girdi; saldırı hazırlığındalar." % faction["settlement_name"],
			site_id, "event.raid", {"settlement_name": str(faction["settlement_name"])})


func _find_edge_spawn(map_data: Dictionary, offset: int) -> Vector2i:
	for i in range(LOCAL_SIZE * 4):
		var index: int = posmod(offset + i * 13, LOCAL_SIZE * 4)
		var point := Vector2i.ZERO
		if index < LOCAL_SIZE: point = Vector2i(index, 0)
		elif index < LOCAL_SIZE * 2: point = Vector2i(LOCAL_SIZE - 1, index - LOCAL_SIZE)
		elif index < LOCAL_SIZE * 3: point = Vector2i(LOCAL_SIZE * 3 - index - 1, LOCAL_SIZE - 1)
		else: point = Vector2i(0, LOCAL_SIZE * 4 - index - 1)
		if _passable(map_data, point.x, point.y): return point
	return Vector2i(25, 25)


func _spawn_npc_caravans() -> void:
	var friendly_sites: Array = state["world"]["sites"].filter(func(s): return s["kind"] == "friendly")
	if friendly_sites.is_empty(): return
	for faction in state["factions"]:
		var already_here := false
		for caravan in state["caravans"]:
			if caravan.get("kind", "") == "npc" and caravan.get("faction_id", "") == faction["id"]:
				already_here = true
				break
		if already_here: continue
		var source_index: int = (floori(float(state["time"]) / 100.0) + state["factions"].find(faction)) % friendly_sites.size()
		var source: Dictionary = friendly_sites[source_index]
		var caravan := {"id": _new_id("caravan"), "kind": "npc", "faction_id": faction["id"],
			"site_id": faction["site_id"], "source_site_id": source["id"],
			"source_name": source["name"], "name": "%s Ticaret Kervanı" % source["name"], "x": 27, "y": 26,
			"ttl": 70, "stock": {"wood": 15, "stone": 12, "food": 18,
				"medicine": 5, "spear": 3, "jacket": 4, "silver": 80}}
		state["caravans"].append(caravan)
		_event("caravan", "%s geldi." % caravan["name"], str(faction["site_id"]),
			"event.caravan_arrived", {"source_name": str(source["name"])})


func _tick_caravans() -> void:
	var removed: Array = []
	for caravan in state["caravans"]:
		if caravan["kind"] == "npc":
			caravan["ttl"] = int(caravan["ttl"]) - 1
			if int(caravan["ttl"]) <= 0:
				removed.append(caravan)
				var source_name := str(caravan.get("source_name", ""))
				if source_name.is_empty():
					source_name = str(_site_by_id(state["world"], str(caravan.get("source_site_id", ""))).get("name", caravan["name"]))
				_event("caravan_left", "%s ayrıldı." % caravan["name"], str(caravan["site_id"]),
					"event.caravan_left", {"source_name": source_name})
		elif caravan["kind"] == "player_trade":
			caravan["eta"] = int(caravan["eta"]) - 1
			if int(caravan["eta"]) <= 0:
				var source := _faction_by_id(str(caravan["from_faction"]))
				var target := _faction_by_id(str(caravan["to_faction"]))
				_change_cargo(target["inventory"], caravan["cargo_to_target"], 1)
				_change_cargo(source["inventory"], caravan["cargo_to_source"], 1)
				var offer := _trade_offer_by_id(str(caravan["offer_id"]))
				if not offer.is_empty(): offer["status"] = "completed"
				removed.append(caravan)
				_event("trade_complete", "Koloniler arası ticaret kervanı ulaştı.", "", "event.trade_complete")
	for caravan in removed: state["caravans"].erase(caravan)


func _tick_farms() -> void:
	if int(state["time"]) % 80 != 0: return
	var day_length := maxi(1, int(state.get("day_length", ClimateCalendar.DEFAULT_DAY_LENGTH)))
	var year_day := (int(state["time"]) / day_length) % ClimateCalendar.DAYS_PER_YEAR
	for faction in state["factions"]:
		var map_data: Dictionary = state["maps"][faction["site_id"]]
		var site_info: Dictionary = map_data.get("site_info", {})
		var outside_temperature: float = ClimateCalendar.temperature_for_day(
			float(site_info.get("temperature", 18.0)), float(site_info.get("latitude", 0.0)), year_day)
		if not ClimateCalendar.can_grow(outside_temperature): continue
		for structure in map_data["structures"]:
			if structure["kind"] != "farm": continue
			if not _drop_at(map_data, int(structure["x"]), int(structure["y"])).is_empty(): continue
			map_data["drops"].append({"id": _new_id("drop"), "x": structure["x"], "y": structure["y"],
				"kind": "food", "amount": 3})
			state["orders"].append({"id": _new_id("order"), "faction_id": faction["id"],
				"site_id": faction["site_id"], "kind": "haul", "x": structure["x"], "y": structure["y"],
				"priority": 5, "status": "queued", "claimed_by": "", "progress": 0.0,
				"created_at": int(state["time"])})
