extends Node
class_name GameModel

## Authoritative, transport-independent game simulation. All values in state are
## JSON-compatible so the server can send snapshots and save the same data.
signal state_changed(snapshot: Dictionary)
signal event_emitted(event: Dictionary)

const LOCAL_SIZE := 50
const WORLD_WIDTH := 64
const WORLD_HEIGHT := 40
const WORK_TYPES := ["chop", "mine", "harvest", "haul", "build", "research", "treat"]
const RESOURCE_KINDS := {"chop": "tree", "mine": "stone", "harvest": "berry"}
const OUTPUT_KINDS := {"chop": "wood", "mine": "stone", "harvest": "food"}
const BUILD_COSTS := {
	"build_wall": {"wood": 3},
	"build_bed": {"wood": 5},
	"build_research_bench": {"wood": 7, "stone": 3},
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
const FIRST_NAMES := ["Ada", "Deniz", "Efe", "Elif", "Emir", "Maya", "Mert", "Nil", "Selin", "Tuna", "Zeynep", "Arda"]
const SITE_NAMES := ["Çınar", "Kavak", "Akkaya", "Yeşilova", "Güneydere", "Kuzeyyaka", "Taşlık", "Yelbayır", "Söğüt", "Gökova", "Kızıltepe", "Ilıca", "Umut", "Serin", "Akpınar", "Günyeli"]

var state: Dictionary = {}
var active_colony_id: String = ""
var _tick_remainder: float = 0.0

var world: Dictionary:
	get:
		return state.get("world", {})

var colonies: Array:
	get:
		return state.get("factions", [])


func preview_world(seed_text: String) -> Dictionary:
	var seed_value := seed_text.strip_edges()
	if seed_value.is_empty():
		seed_value = "Foxtopia-%d" % Time.get_unix_time_from_system()
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number(seed_value)
	var tiles: Array = []
	for y in range(WORLD_HEIGHT):
		for x in range(WORLD_WIDTH):
			var n := rng.randf()
			var biome := "plains"
			if n < 0.095:
				biome = "water"
			elif n < 0.38:
				biome = "forest"
			elif n > 0.86:
				biome = "rocky"
			tiles.append(biome)
	var sites: Array = []
	for i in range(16):
		var pos := _find_site_position(rng, sites, tiles)
		var kind := "vacant"
		if i >= 8 and i < 12:
			kind = "friendly"
		elif i >= 12:
			kind = "hostile"
		var site_name: String = SITE_NAMES[i]
		sites.append({
			"id": "site_%d" % (i + 1), "x": pos.x, "y": pos.y,
			"biome": tiles[pos.y * WORLD_WIDTH + pos.x],
			"kind": kind, "name": site_name,
		})
	return {"seed": seed_value, "width": WORLD_WIDTH, "height": WORLD_HEIGHT,
		"tiles": tiles, "sites": sites}


func start_new_game(config: Dictionary) -> Dictionary:
	var mode: String = str(config.get("mode", "solo"))
	if not mode in ["solo", "coop", "competitive"]:
		mode = "solo"
	var count: int = clampi(int(config.get("colonists_per_faction", config.get("colonist_count", 3))), 1, 3)
	var seed_text: String = str(config.get("seed", ""))
	var generated_world := preview_world(seed_text)
	var specs: Array = config.get("faction_specs", [])
	if specs.is_empty():
		specs = _default_specs(config, mode, generated_world, count)
	var factions: Array = []
	var players: Dictionary = {}
	var colonists: Array = []
	var maps: Dictionary = {}
	var used_sites: Array = []
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		var faction_id := str(spec.get("id", "faction_%d" % (i + 1)))
		var site_id := str(spec.get("site_id", "site_%d" % (i + 1)))
		if used_sites.has(site_id) or _site_by_id(generated_world, site_id).is_empty() or str(_site_by_id(generated_world, site_id).get("kind", "")) != "vacant":
			site_id = _first_free_site(generated_world, used_sites)
		used_sites.append(site_id)
		var faction_name := str(spec.get("name", "Koloni %d" % (i + 1))).strip_edges()
		var settlement_name := str(spec.get("settlement_name", "Yerleşke %d" % (i + 1))).strip_edges()
		if faction_name.is_empty(): faction_name = "Koloni %d" % (i + 1)
		if settlement_name.is_empty(): settlement_name = "Yerleşke %d" % (i + 1)
		var peer_ids: Array = spec.get("players", [i + 1])
		if peer_ids.is_empty(): peer_ids = [i + 1]
		var faction := {
			"id": faction_id, "name": faction_name,
			"settlement_name": settlement_name, "site_id": site_id,
			"players": peer_ids.duplicate(),
			"inventory": {"wood": 12, "stone": 8, "food": 12, "medicine": 2,
				"silver": 25, "spear": 2, "jacket": 3},
			"research": {"project": "", "progress": 0.0, "unlocked": []},
			"relations": {},
		}
		factions.append(faction)
		for peer_id in peer_ids:
			players[str(peer_id)] = faction_id
		var site := _site_by_id(generated_world, site_id)
		site["kind"] = "player"
		site["faction_id"] = faction_id
		site["name"] = settlement_name
		maps[site_id] = _generate_local_map(generated_world["seed"], site_id, str(site.get("biome", "plains")))
		var prepared: Array = spec.get("colonists", [])
		for j in range(count):
			var prepared_one: Dictionary = prepared[j] if j < prepared.size() else {}
			colonists.append(_make_colonist(generated_world["seed"], faction_id, site_id, i, j, prepared_one))
	active_colony_id = str(factions[0]["id"]) if not factions.is_empty() else ""
	state = {
		"schema": 1, "mode": mode, "seed": generated_world["seed"],
		"time": 0, "raid_clock": 0, "caravan_clock": 0, "next_id": 1,
		"world": generated_world, "factions": factions, "players": players,
		"maps": maps, "colonists": colonists, "orders": [], "raiders": [],
		"caravans": [], "trade_offers": [], "events": [],
		"research_projects": RESEARCH_PROJECTS.duplicate(true),
	}
	_tick_remainder = 0.0
	_emit_change()
	return get_snapshot(1)


func issue_command(peer_id: int, command: Dictionary) -> Dictionary:
	if state.is_empty(): return _error("Oyun başlamadı.")
	var faction_id: String = str(state["players"].get(str(peer_id), ""))
	if faction_id.is_empty(): return _error("Oyuncu bir koloniye bağlı değil.")
	var command_type: String = str(command.get("type", ""))
	var result: Dictionary = {}
	match command_type:
		"designate": result = _command_designate(faction_id, command)
		"set_work_priority": result = _command_work_priority(faction_id, command)
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


func save_game(path: String = "user://foxtopia_save.json") -> bool:
	if state.is_empty(): return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(state))
	return true


func load_game(data: Variant = {}) -> bool:
	var loaded: Variant = data
	if not (loaded is Dictionary) or loaded.is_empty():
		var file := FileAccess.open("user://foxtopia_save.json", FileAccess.READ)
		if file == null: return false
		loaded = JSON.parse_string(file.get_as_text())
	if not (loaded is Dictionary): return false
	if int(loaded.get("schema", -1)) != 1: return false
	if not loaded.has("world") or not loaded.has("factions") or not loaded.has("maps"): return false
	state = loaded.duplicate(true)
	active_colony_id = str(state["factions"][0]["id"]) if not state["factions"].is_empty() else ""
	_tick_remainder = 0.0
	_emit_change()
	return true


func load_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.is_empty() or not snapshot.has("world") or not snapshot.has("factions"):
		return false
	state = snapshot.duplicate(true)
	active_colony_id = str(state["factions"][0]["id"]) if not state["factions"].is_empty() else ""
	_emit_change()
	return true


func _default_specs(config: Dictionary, mode: String, generated_world: Dictionary, count: int) -> Array:
	var specs: Array = []
	var player_count: int = clampi(int(config.get("player_count", 1)), 1, 8)
	var faction_count := player_count if mode == "competitive" else 1
	for i in range(faction_count):
		var peer_ids: Array = [i + 1] if mode == "competitive" else range(1, player_count + 1)
		specs.append({"id": "faction_%d" % (i + 1),
			"name": str(config.get("colony_name", "Koloni %d" % (i + 1))),
			"settlement_name": str(config.get("settlement_name", "Yerleşke %d" % (i + 1))),
			"site_id": "site_%d" % (i + 1), "players": peer_ids,
			"colonists": config.get("colonists", []) if i == 0 else []})
	return specs


func _make_colonist(seed_text: String, faction_id: String, site_id: String, faction_index: int, index: int, prepared: Dictionary) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number("%s/%s/%d" % [seed_text, faction_id, index])
	var traits: Array = prepared.get("traits", [])
	if traits.is_empty():
		traits = [["hardworking", "calm"], ["quick", "curious"], ["kind", "quick"]][index % 3].duplicate()
	var skills: Dictionary = {"chop": rng.randi_range(2, 6), "mine": rng.randi_range(2, 6),
		"harvest": rng.randi_range(2, 6), "haul": rng.randi_range(2, 6),
		"build": rng.randi_range(2, 6), "research": rng.randi_range(2, 6),
		"treat": rng.randi_range(2, 6), "combat": rng.randi_range(2, 6)}
	for key in prepared.get("skills", {}).keys():
		if skills.has(key): skills[key] = clampi(int(prepared["skills"][key]), 0, 10)
	var priorities: Dictionary = {}
	for work in WORK_TYPES: priorities[work] = 5
	for key in prepared.get("work_priorities", {}).keys():
		if priorities.has(key): priorities[key] = clampi(int(prepared["work_priorities"][key]), 0, 9)
	var appearance: Dictionary = prepared.get("appearance", {})
	return {"id": "colonist_%d_%d" % [faction_index + 1, index + 1],
		"faction_id": faction_id, "site_id": site_id,
		"name": str(prepared.get("name", FIRST_NAMES[(faction_index * 3 + index) % FIRST_NAMES.size()])),
		"x": 23 + index, "y": 25, "facing": "down",
		"appearance": {"hair": str(appearance.get("hair", "short")),
			"hair_color": str(appearance.get("hair_color", "#4e3d32")),
			"skin": str(appearance.get("skin", "medium")),
			"outfit": str(appearance.get("outfit", "blue"))},
		"traits": traits.duplicate(), "skills": skills, "work_priorities": priorities,
		"needs": {"hunger": 100.0, "rest": 100.0, "mood": 75.0},
		"health": {"hp": 100.0, "max_hp": 100.0, "bleeding": 0.0, "wounds": []},
		"equipment": {"weapon": "fists", "apparel": "clothes"},
		"drafted": false, "manual": {}, "current_order": "", "work_left": 0.0,
		"resting": false,
		"attack_cooldown": 0,
		"alive": true}


func _generate_local_map(seed_text: String, site_id: String, biome: String) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = _seed_number("%s/%s/map" % [seed_text, site_id])
	var terrain: Array = []
	var resources: Array = []
	for y in range(LOCAL_SIZE):
		for x in range(LOCAL_SIZE):
			var n := rng.randf()
			var tile := "grass"
			if n < 0.04 and (x < 19 or x > 31 or y < 19 or y > 31):
				tile = "water"
			elif n < 0.21: tile = "dirt"
			elif biome == "rocky" and n > 0.78: tile = "rock_ground"
			terrain.append(tile)
			if x >= 19 and x <= 31 and y >= 19 and y <= 31: continue
			if tile == "water": continue
			var r := rng.randf()
			if r < (0.085 if biome == "forest" else 0.06):
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "tree", "amount": 1})
			elif r < (0.11 if biome == "rocky" else 0.087):
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "stone", "amount": 1})
			elif r < 0.101:
				resources.append({"id": "res_%d_%d" % [x, y], "x": x, "y": y, "kind": "berry", "amount": 1})
	return {"width": LOCAL_SIZE, "height": LOCAL_SIZE, "terrain": terrain,
		"resources": resources, "drops": [],
		"structures": [{"id": "stockpile", "kind": "stockpile", "x": 25, "y": 26}]}


func _find_site_position(rng: RandomNumberGenerator, sites: Array, tiles: Array) -> Vector2i:
	for _attempt in range(500):
		var p := Vector2i(rng.randi_range(3, WORLD_WIDTH - 4), rng.randi_range(3, WORLD_HEIGHT - 4))
		if tiles[p.y * WORLD_WIDTH + p.x] == "water": continue
		var okay := true
		for s in sites:
			if abs(int(s["x"]) - p.x) + abs(int(s["y"]) - p.y) < 7:
				okay = false
				break
		if okay: return p
	return Vector2i(rng.randi_range(3, WORLD_WIDTH - 4), rng.randi_range(3, WORLD_HEIGHT - 4))


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


func _emit_change() -> void:
	state_changed.emit(state.duplicate(true))


func _event(kind: String, message: String, site_id: String = "") -> void:
	var item := {"time": int(state["time"]), "kind": kind, "message": message,
		"site_id": site_id}
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
	if not kind in ["chop", "mine", "harvest", "haul", "build_wall", "build_bed", "build_research_bench", "build_stone_wall", "build_barrier", "build_farm"]:
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


func _command_direct(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty() or not colonist["alive"]: return _error("Kolonist bulunamadı.")
	var action: String = str(command.get("action", ""))
	if not action in ["move", "work", "haul", "equip", "attack", "trade", "clear"]:
		return _error("Geçersiz doğrudan emir.")
	if action == "clear":
		colonist["manual"] = {}
		return _ok()
	if action in ["move", "work", "haul", "trade"]:
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
			colonist["manual"] = {"action": "work", "order_id": order["id"]}
			return _ok()
		if action == "haul":
			var map_data: Dictionary = state["maps"].get(colonist["site_id"], {})
			var drop := _drop_by_id(map_data, str(command.get("target_id", "")))
			if drop.is_empty(): drop = _drop_at(map_data, x, y)
			if drop.is_empty(): return _error("Taşınacak malzeme bulunamadı.")
			x = int(drop["x"])
			y = int(drop["y"])
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
			colonist["manual"] = {"action": "trade", "caravan_id": caravan["id"], "x": x, "y": y}
			return _ok()
		if x < 0 or y < 0 or x >= LOCAL_SIZE or y >= LOCAL_SIZE: return _error("Harita dışında.")
		if not _passable(state["maps"][colonist["site_id"]], x, y): return _error("Bu hücreye gidilemez.")
		colonist["manual"] = {"action": "move", "x": x, "y": y}
		return _ok()
	if action == "equip":
		var item: String = str(command.get("item", ""))
		if not item in ["spear", "jacket"]: return _error("Bu eşya kuşanılamaz.")
		var inventory: Dictionary = _faction_by_id(faction_id)["inventory"]
		if int(inventory.get(item, 0)) < 1: return _error("Depoda eşya yok.")
		var slot := "weapon" if item == "spear" else "apparel"
		var previous: String = str(colonist["equipment"][slot])
		inventory[item] = int(inventory[item]) - 1
		if previous in ["spear", "jacket"]: inventory[previous] = int(inventory.get(previous, 0)) + 1
		colonist["equipment"][slot] = item
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
	if faction["research"]["unlocked"].has(project): return _error("Bu araştırma tamamlandı.")
	for required in RESEARCH_PROJECTS[project]["requires"]:
		if not faction["research"]["unlocked"].has(required): return _error("Ön koşul tamamlanmadı.")
	faction["research"]["project"] = project
	faction["research"]["progress"] = 0.0
	return _ok()


func _command_customize(faction_id: String, command: Dictionary) -> Dictionary:
	var colonist := _owned_colonist(faction_id, str(command.get("colonist_id", "")))
	if colonist.is_empty(): return _error("Kolonist bulunamadı.")
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
	_event("trade_offer", "%s ticaret teklifi gönderdi." % _faction_by_id(faction_id)["name"])
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
	_event("trade_accept", "Ticaret kabul edildi; kervan yola çıktı.")
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
	_event("npc_trade", "Tüccarla alışveriş tamamlandı.", str(caravan["site_id"]))
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
	for colonist in state["colonists"]:
		_tick_colonist(colonist)
	_tick_raiders()
	_tick_caravans()
	_tick_farms()
	state["raid_clock"] = int(state["raid_clock"]) + 1
	state["caravan_clock"] = int(state["caravan_clock"]) + 1
	if int(state["raid_clock"]) == 130:
		for faction in state["factions"]:
			_event("raid_warning", "%s yakınlarında düşman izleri görüldü." % faction["settlement_name"], str(faction["site_id"]))
	if int(state["raid_clock"]) >= 150:
		state["raid_clock"] = -40
		_spawn_raids()
	if int(state["caravan_clock"]) >= 100:
		state["caravan_clock"] = -35
		_spawn_npc_caravans()


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
		_event("death", "%s hayatını kaybetti." % colonist["name"], str(colonist["site_id"]))
		return
	if float(health["bleeding"]) <= 0.0 and float(health["hp"]) < 100.0:
		health["hp"] = minf(100.0, float(health["hp"]) + 0.025)
	if float(needs["hunger"]) < 42.0 and int(faction["inventory"].get("food", 0)) > 0:
		faction["inventory"]["food"] = int(faction["inventory"]["food"]) - 1
		needs["hunger"] = minf(100.0, float(needs["hunger"]) + 42.0)
	if colonist["traits"].has("calm"):
		needs["mood"] = minf(100.0, float(needs["mood"]) + 0.03)
	else:
		needs["mood"] = maxf(0.0, float(needs["mood"]) - 0.005)
	if float(needs["rest"]) < 20.0 and not bool(colonist["drafted"]): colonist["resting"] = true
	if bool(colonist.get("resting", false)) and not bool(colonist["drafted"]):
		var rest_gain := 0.9
		for structure in state["maps"][colonist["site_id"]]["structures"]:
			if structure["kind"] == "bed": rest_gain = 1.7; break
		needs["rest"] = minf(100.0, float(needs["rest"]) + rest_gain)
		if float(needs["rest"]) >= 80.0: colonist["resting"] = false
		return
	if int(colonist.get("attack_cooldown", 0)) > 0:
		colonist["attack_cooldown"] = int(colonist["attack_cooldown"]) - 1
	if not colonist["manual"].is_empty():
		if _tick_manual(colonist): return
	if bool(colonist["drafted"]):
		_tick_drafted(colonist)
		return
	if _tick_treat(colonist): return
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
	_tick_research(colonist)


func _tick_manual(colonist: Dictionary) -> bool:
	var manual: Dictionary = colonist["manual"]
	var action: String = str(manual.get("action", ""))
	if action == "move":
		if _move_towards(colonist, int(manual["x"]), int(manual["y"])):
			colonist["manual"] = {}
		return true
	if action == "work":
		var order := _order_by_id(str(manual.get("order_id", "")))
		if order.is_empty() or order["status"] in ["done", "cancelled"]:
			colonist["manual"] = {}
			return false
		if not _order_can_start(order): return true
		if order["claimed_by"] != colonist["id"]: _claim_order(colonist, order)
		_tick_order(colonist, order)
		if order["status"] == "done": colonist["manual"] = {}
		return true
	if action == "haul":
		var map_data: Dictionary = state["maps"].get(colonist["site_id"], {})
		var drop := _drop_by_id(map_data, str(manual.get("drop_id", "")))
		if drop.is_empty():
			colonist["manual"] = {}
			return false
		if _move_towards(colonist, int(drop["x"]), int(drop["y"])):
			_collect_drop(colonist, drop)
			colonist["manual"] = {}
		return true
	if action == "equip":
		colonist["manual"] = {}
		return false
	if action == "trade":
		var caravan := _caravan_by_id(str(manual.get("caravan_id", "")))
		if caravan.is_empty():
			colonist["manual"] = {}
			return false
		if _move_towards(colonist, int(manual["x"]), int(manual["y"])):
			_event("trade_ready", "%s tüccarla görüşmeye hazır." % colonist["name"], str(colonist["site_id"]))
			colonist["manual"] = {}
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
	if not _move_towards(colonist, int(target["x"]), int(target["y"]), 1): return true
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
		if order["status"] != "queued" or not _order_can_start(order): continue
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
		return not _drop_at(state["maps"][order["site_id"]], int(order["x"]), int(order["y"])).is_empty()
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
	if not _order_can_start(order):
		order["status"] = "queued"
		order["claimed_by"] = ""
		colonist["current_order"] = ""
		return
	if not _move_towards(colonist, int(order["x"]), int(order["y"])): return
	var work_type := _work_for_order(str(order["kind"]))
	var skill: int = int(colonist["skills"].get(work_type, 2))
	var rate := 0.14 + float(skill) * 0.018
	if colonist["traits"].has("hardworking"): rate *= 1.25
	if colonist["traits"].has("timid") and work_type == "build": rate *= 0.9
	order["progress"] = minf(1.0, float(order["progress"]) + rate)
	if float(order["progress"]) >= 1.0:
		_complete_order(colonist, order)


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
	elif kind == "haul":
		var drop := _drop_at(map_data, int(order["x"]), int(order["y"]))
		if not drop.is_empty(): _collect_drop(colonist, drop)
	elif kind.begins_with("build_"):
		if BUILD_COSTS.has(kind):
			_change_cargo(_faction_by_id(str(order["faction_id"]))["inventory"], BUILD_COSTS[kind], -1)
		map_data["structures"].append({"id": _new_id("structure"), "kind": kind.trim_prefix("build_"),
			"x": int(order["x"]), "y": int(order["y"]), "built_at": int(state["time"])})
		_event("build", "%s tamamlandı." % _building_name(kind), str(order["site_id"]))
	order["status"] = "done"
	order["claimed_by"] = ""
	colonist["current_order"] = ""


func _building_name(kind: String) -> String:
	match kind:
		"build_wall": return "Ahşap duvar"
		"build_stone_wall": return "Taş duvar"
		"build_bed": return "Yatak"
		"build_research_bench": return "Araştırma masası"
		"build_barrier": return "Barikat"
		"build_farm": return "Ekim alanı"
	return "Yapı"


func _collect_drop(colonist: Dictionary, drop: Dictionary) -> void:
	var map_data: Dictionary = state["maps"][colonist["site_id"]]
	var inventory: Dictionary = _faction_by_id(str(colonist["faction_id"]))["inventory"]
	var item: String = str(drop["kind"])
	inventory[item] = int(inventory.get(item, 0)) + int(drop["amount"])
	map_data["drops"].erase(drop)
	for order in state["orders"]:
		if order["kind"] == "haul" and order["site_id"] == colonist["site_id"] and int(order["x"]) == int(drop["x"]) and int(order["y"]) == int(drop["y"]) and order["status"] != "done":
			order["status"] = "done"
			order["claimed_by"] = ""
			break


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
	if not _move_towards(colonist, int(bench["x"]), int(bench["y"]), 1): return true
	var rate := 0.75 + float(colonist["skills"]["research"]) * 0.13
	if colonist["traits"].has("curious"): rate *= 1.3
	research["progress"] = float(research["progress"]) + rate
	if float(research["progress"]) >= float(RESEARCH_PROJECTS[project]["cost"]):
		research["unlocked"].append(project)
		research["project"] = ""
		research["progress"] = 0.0
		_event("research", "%s araştırması tamamlandı." % RESEARCH_PROJECTS[project]["name"], str(colonist["site_id"]))
	return true


func _move_towards(actor: Dictionary, target_x: int, target_y: int, acceptable_distance: int = 0, allow_quick_step: bool = true) -> bool:
	var x: int = int(actor["x"])
	var y: int = int(actor["y"])
	if abs(x - target_x) + abs(y - target_y) <= acceptable_distance: return true
	var steps: Array = []
	if target_x != x: steps.append(Vector2i(signi(target_x - x), 0))
	if target_y != y: steps.append(Vector2i(0, signi(target_y - y)))
	if abs(target_y - y) > abs(target_x - x): steps.reverse()
	steps.append_array([Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)])
	var map_data: Dictionary = state["maps"].get(actor["site_id"], {})
	var previous_distance: int = abs(x - target_x) + abs(y - target_y)
	var moved := false
	for step in steps:
		var nx: int = x + step.x
		var ny: int = y + step.y
		if nx < 0 or nx >= LOCAL_SIZE or ny < 0 or ny >= LOCAL_SIZE: continue
		if int(abs(nx - target_x) + abs(ny - target_y)) > previous_distance: continue
		if not _passable(map_data, nx, ny): continue
		actor["x"] = nx
		actor["y"] = ny
		actor["facing"] = "right" if step.x > 0 else "left" if step.x < 0 else "down" if step.y > 0 else "up"
		moved = true
		break
	if not moved:
		_move_with_bfs(actor, target_x, target_y, acceptable_distance, map_data)
	if allow_quick_step and actor.get("traits", []).has("quick") and int(state["time"]) % 2 == 0:
		if abs(int(actor["x"]) - target_x) + abs(int(actor["y"]) - target_y) > acceptable_distance:
			_move_towards(actor, target_x, target_y, acceptable_distance, false)
	return abs(int(actor["x"]) - target_x) + abs(int(actor["y"]) - target_y) <= acceptable_distance


func _move_with_bfs(actor: Dictionary, target_x: int, target_y: int, acceptable_distance: int, map_data: Dictionary) -> void:
	var origin := Vector2i(int(actor["x"]), int(actor["y"]))
	var start_index: int = origin.y * LOCAL_SIZE + origin.x
	var queue: Array[Vector2i] = [origin]
	var parent: Dictionary = {start_index: -1}
	var head := 0
	var destination_index := -1
	var directions: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		var cell_index: int = cell.y * LOCAL_SIZE + cell.x
		if abs(cell.x - target_x) + abs(cell.y - target_y) <= acceptable_distance:
			destination_index = cell_index
			break
		for direction in directions:
			var next: Vector2i = cell + direction
			if next.x < 0 or next.x >= LOCAL_SIZE or next.y < 0 or next.y >= LOCAL_SIZE: continue
			var next_index: int = next.y * LOCAL_SIZE + next.x
			if parent.has(next_index) or not _passable(map_data, next.x, next.y): continue
			parent[next_index] = cell_index
			queue.append(next)
	if destination_index < 0 or destination_index == start_index: return
	var step_index := destination_index
	while int(parent[step_index]) != start_index:
		step_index = int(parent[step_index])
	var nx: int = step_index % LOCAL_SIZE
	var ny: int = floori(float(step_index) / float(LOCAL_SIZE))
	actor["x"] = nx
	actor["y"] = ny
	actor["facing"] = "right" if nx > origin.x else "left" if nx < origin.x else "down" if ny > origin.y else "up"


func _passable(map_data: Dictionary, x: int, y: int) -> bool:
	if map_data.is_empty(): return false
	if map_data["terrain"][y * LOCAL_SIZE + x] == "water": return false
	var structure := _structure_at(map_data, x, y)
	if not structure.is_empty() and structure["kind"] in ["wall", "stone_wall", "barrier"]: return false
	return true


func _attack_raider(colonist: Dictionary, raider: Dictionary) -> void:
	if int(colonist.get("attack_cooldown", 0)) > 0: return
	var distance: int = abs(int(colonist["x"]) - int(raider["x"])) + abs(int(colonist["y"]) - int(raider["y"]))
	if distance > 1:
		_move_towards(colonist, int(raider["x"]), int(raider["y"]), 1)
		return
	var damage := 10.0 + float(colonist["skills"]["combat"]) * 1.2
	if colonist["equipment"]["weapon"] == "spear": damage += 10.0
	if colonist["traits"].has("timid"): damage *= 0.75
	raider["hp"] = maxf(0.0, float(raider["hp"]) - damage)
	colonist["attack_cooldown"] = 2
	if float(raider["hp"]) <= 0.0:
		_event("raid_defeated", "Bir akıncı etkisiz hale getirildi.", str(raider["site_id"]))


func _tick_raiders() -> void:
	var removed: Array = []
	for raider in state["raiders"]:
		if float(raider["hp"]) <= 0.0:
			removed.append(raider)
			continue
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
		var count := 1 if living <= 2 else 2
		for i in range(count):
			var x := 1 if i % 2 == 0 else 48
			var y := 10 + ((int(state["time"]) + i * 19) % 30)
			while not _passable(map_data, x, y) and y < 48: y += 1
			state["raiders"].append({"id": _new_id("raider"), "site_id": site_id,
				"source_site_id": hostile_sites[(int(state["time"]) + i) % hostile_sites.size()]["id"],
				"x": x, "y": y, "hp": 55.0, "attack_cooldown": 0})
		_event("raid", "%s yerleşkesine akıncılar yaklaşıyor!" % faction["settlement_name"], site_id)


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
			"name": "%s Ticaret Kervanı" % source["name"], "x": 27, "y": 26,
			"ttl": 70, "stock": {"wood": 15, "stone": 12, "food": 18,
				"medicine": 5, "spear": 3, "jacket": 4, "silver": 80}}
		state["caravans"].append(caravan)
		_event("caravan", "%s geldi." % caravan["name"], str(faction["site_id"]))


func _tick_caravans() -> void:
	var removed: Array = []
	for caravan in state["caravans"]:
		if caravan["kind"] == "npc":
			caravan["ttl"] = int(caravan["ttl"]) - 1
			if int(caravan["ttl"]) <= 0:
				removed.append(caravan)
				_event("caravan_left", "%s ayrıldı." % caravan["name"], str(caravan["site_id"]))
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
				_event("trade_complete", "Koloniler arası ticaret kervanı ulaştı.")
	for caravan in removed: state["caravans"].erase(caravan)


func _tick_farms() -> void:
	if int(state["time"]) % 80 != 0: return
	for faction in state["factions"]:
		var map_data: Dictionary = state["maps"][faction["site_id"]]
		for structure in map_data["structures"]:
			if structure["kind"] != "farm": continue
			if not _drop_at(map_data, int(structure["x"]), int(structure["y"])).is_empty(): continue
			map_data["drops"].append({"id": _new_id("drop"), "x": structure["x"], "y": structure["y"],
				"kind": "food", "amount": 3})
			state["orders"].append({"id": _new_id("order"), "faction_id": faction["id"],
				"site_id": faction["site_id"], "kind": "haul", "x": structure["x"], "y": structure["y"],
				"priority": 5, "status": "queued", "claimed_by": "", "progress": 0.0,
				"created_at": int(state["time"])})
