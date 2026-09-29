extends Node
class_name NetworkBridge

## The host owns Game. Clients only send requests and render filtered snapshots.
signal connection_changed(connected: bool, message: String)
signal lobby_changed(lobby: Dictionary)
signal snapshot_received(snapshot: Dictionary)
signal command_result(result: Dictionary)

const DEFAULT_PORT := 24567
const MAX_PLAYERS := 8
const SetupCatalog = preload("res://scripts/model/setup_catalog.gd")


func _net_text(en: String, tr: String, pl: String) -> String:
	match TranslationServer.get_locale().to_lower().split("_")[0]:
		"tr": return tr
		"pl": return pl
		_: return en

var mode: String = "solo" # solo, host, client
var _connected_peers: Array[int] = []
var _player_setups: Dictionary = {}
var _lobby: Dictionary = {
	"mode": "solo", "seed": "", "colonists_per_faction": 3,
	"world_options": {}, "scenario_id": "landfall", "storyteller_id": "steady", "difficulty_id": "frontier",
	"players": [1], "ready": {}, "started": false,
}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	Game.state_changed.connect(_on_game_state_changed)


func start_solo() -> Dictionary:
	_close_peer()
	mode = "solo"
	_player_setups.clear()
	_lobby = {"mode": "solo", "seed": "", "colonists_per_faction": 3,
		"world_options": {}, "scenario_id": "landfall", "storyteller_id": "steady", "difficulty_id": "frontier",
		"players": [1], "ready": {"1": true}, "started": false}
	lobby_changed.emit(get_lobby())
	connection_changed.emit(true, _net_text("Single-player session is ready.", "Tek oyunculu oturum hazır.", "Sesja jednoosobowa jest gotowa."))
	return {"ok": true}


func host(port: int = DEFAULT_PORT) -> Dictionary:
	_close_peer()
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		return {"ok": false, "error": _net_text("Could not open the game room (error %d). Check the port.", "Oda açılamadı (hata %d). Portu kontrol et.", "Nie można otworzyć pokoju (błąd %d). Sprawdź port.") % err}
	multiplayer.multiplayer_peer = peer
	mode = "host"
	_connected_peers.clear()
	_player_setups.clear()
	_lobby = {"mode": "coop", "seed": "", "colonists_per_faction": 3,
		"world_options": {}, "scenario_id": "landfall", "storyteller_id": "steady", "difficulty_id": "frontier",
		"players": [1], "ready": {"1": true}, "started": false}
	lobby_changed.emit(get_lobby())
	connection_changed.emit(true, _net_text("Room is open on port %d.", "Oda %d portunda açık.", "Pokój otwarty na porcie %d.") % port)
	return {"ok": true, "port": port}


func join(address: String, port: int = DEFAULT_PORT) -> Dictionary:
	_close_peer()
	if address.strip_edges().is_empty():
		return {"ok": false, "error": _net_text("Server address is empty.", "Sunucu adresi boş.", "Adres serwera jest pusty.")}
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address.strip_edges(), port)
	if err != OK:
		return {"ok": false, "error": _net_text("Could not start connection (error %d).", "Bağlantı başlatılamadı (hata %d).", "Nie można rozpocząć połączenia (błąd %d).") % err}
	multiplayer.multiplayer_peer = peer
	mode = "client"
	connection_changed.emit(false, _net_text("Connecting to server…", "Sunucuya bağlanılıyor…", "Łączenie z serwerem…"))
	return {"ok": true}


func disconnect_session() -> void:
	_close_peer()
	start_solo()


func configure_lobby(rules: Dictionary) -> Dictionary:
	if mode == "client":
		return {"ok": false, "error": _net_text("Only the host can change game rules.", "Kuralları yalnızca ev sahibi değiştirebilir.", "Tylko gospodarz może zmieniać zasady gry.")}
	if bool(_lobby.get("started", false)):
		return {"ok": false, "error": _net_text("The game has already started.", "Oyun başladı.", "Gra już się rozpoczęła.")}
	var selected_mode := str(rules.get("mode", _lobby.get("mode", "coop")))
	if selected_mode not in ["solo", "coop", "competitive"]:
		return {"ok": false, "error": _net_text("Invalid game mode.", "Geçersiz oyun modu.", "Nieprawidłowy tryb gry.")}
	_lobby["mode"] = selected_mode
	_lobby["seed"] = str(rules.get("seed", _lobby.get("seed", "")))
	var supplied_options: Variant = rules.get("world_options", {})
	if supplied_options is Dictionary:
		var options: Dictionary = {}
		for key in ["coverage", "rainfall", "temperature", "population"]:
			options[key] = clampf(float(supplied_options.get(key, 0.5)), 0.25 if key == "coverage" else 0.0, 0.75 if key == "coverage" else 1.0)
		_lobby["world_options"] = options
	for key in ["scenario_id", "storyteller_id", "difficulty_id"]:
		_lobby[key] = str(rules.get(key, _lobby.get(key, "")))
	_lobby["colonists_per_faction"] = int(SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, str(_lobby["scenario_id"])).get("colonist_count", 3))
	_player_setups.clear()
	_lobby["ready"] = {"1": true}
	_broadcast_lobby()
	return {"ok": true}


func submit_player_setup(spec: Dictionary) -> Dictionary:
	if mode == "client":
		if multiplayer.multiplayer_peer == null:
			return {"ok": false, "error": _net_text("No connection.", "Bağlantı yok.", "Brak połączenia.")}
		_server_submit_setup.rpc_id(1, _clean_setup(spec))
		return {"ok": true, "pending": true}
	if mode == "host":
		_player_setups["1"] = _clean_setup(spec)
		_lobby["ready"]["1"] = true
		_broadcast_lobby()
		return {"ok": true}
	return {"ok": true}


func start_game(config: Dictionary) -> Dictionary:
	if mode == "client":
		return {"ok": false, "error": _net_text("Only the host can start the game.", "Oyunu ev sahibi başlatır.", "Tylko gospodarz może rozpocząć grę.")}
	var setup := config.duplicate(true)
	var selected_mode := str(setup.get("mode", "solo"))
	if mode == "solo": selected_mode = "solo"
	if selected_mode not in ["solo", "coop", "competitive"]:
		return {"ok": false, "error": _net_text("Invalid game mode.", "Geçersiz oyun modu.", "Nieprawidłowy tryb gry.")}
	setup["mode"] = selected_mode
	var scenario: Dictionary = SetupCatalog.find_by_id(SetupCatalog.SCENARIOS, str(setup.get("scenario_id", "landfall")))
	setup["colonists_per_faction"] = int(scenario.get("colonist_count", 3))
	var supplied: Array = setup.get("faction_specs", [])
	var host_spec: Dictionary = supplied[0].duplicate(true) if not supplied.is_empty() else {}
	host_spec["players"] = [1]
	var specs: Array = [host_spec]
	if mode == "host":
		for peer_id in _connected_peers:
			if not _player_setups.has(str(peer_id)):
				return {"ok": false, "error": _net_text("Player %d is not ready yet.", "%d numaralı oyuncu henüz hazır değil.", "Gracz %d nie jest jeszcze gotowy.") % peer_id}
			if selected_mode == "coop":
				host_spec["players"].append(peer_id)
			else:
				var peer_spec: Dictionary = _player_setups[str(peer_id)].duplicate(true)
				peer_spec["players"] = [peer_id]
				specs.append(peer_spec)
	if selected_mode == "competitive":
		var selected_sites: Dictionary = {}
		for spec in specs:
			var site_id := str(spec.get("site_id", ""))
			if site_id.is_empty() or selected_sites.has(site_id):
				return {"ok": false, "error": _net_text("Each colony must choose a different empty settlement.", "Her koloni ayrı bir boş yerleşke seçmeli.", "Każda kolonia musi wybrać inną pustą osadę.")}
			selected_sites[site_id] = true
	setup["faction_specs"] = specs
	var started: Dictionary = Game.start_new_game(setup)
	if started.has("ok") and not bool(started.get("ok", false)): return started
	_lobby["started"] = true
	_broadcast_lobby()
	return {"ok": true, "snapshot": get_snapshot()}


func send_command(command: Dictionary) -> Dictionary:
	if mode == "client":
		if multiplayer.multiplayer_peer == null:
			return {"ok": false, "error": _net_text("No connection.", "Bağlantı yok.", "Brak połączenia.")}
		_server_command.rpc_id(1, command)
		return {"ok": true, "pending": true}
	var result: Dictionary = Game.issue_command(1, command)
	command_result.emit(result)
	return result


func get_snapshot() -> Dictionary:
	if mode == "client": return Game.state.duplicate(true)
	return Game.get_snapshot(1)


func get_lobby() -> Dictionary:
	return _lobby.duplicate(true)


func get_local_peer_id() -> int:
	if mode == "client" and multiplayer.multiplayer_peer != null:
		return multiplayer.get_unique_id()
	return 1


func is_authority() -> bool:
	return mode != "client"


func _clean_setup(spec: Dictionary) -> Dictionary:
	var clean_cargo: Dictionary = {}
	var raw_cargo: Variant = spec.get("starting_cargo", {})
	if raw_cargo is Dictionary:
		for item in ["wood", "stone", "food", "medicine", "silver", "spear", "jacket"]:
			if raw_cargo.has(item): clean_cargo[item] = clampi(int(raw_cargo[item]), 0, 999)
	var clean_colonists: Array = []
	var raw_colonists: Variant = spec.get("colonists", [])
	if raw_colonists is Array:
		for raw_person in (raw_colonists as Array).slice(0, 3):
			if not raw_person is Dictionary: continue
			var person: Dictionary = raw_person
			var appearance: Dictionary = {}
			var raw_appearance: Variant = person.get("appearance", {})
			if raw_appearance is Dictionary:
				for key in ["hair", "hair_color", "skin", "outfit"]:
					if raw_appearance.has(key): appearance[key] = str(raw_appearance[key]).substr(0, 24)
			var traits: Array = []
			var raw_traits: Variant = person.get("traits", [])
			if raw_traits is Array:
				for value in (raw_traits as Array).slice(0, 3): traits.append(str(value).substr(0, 32))
			var conditions: Array = []
			var raw_conditions: Variant = person.get("health_conditions", [])
			if raw_conditions is Array:
				for value in (raw_conditions as Array).slice(0, 3): conditions.append(str(value).substr(0, 32))
			var skills: Dictionary = {}
			var raw_skills: Variant = person.get("skills", {})
			if raw_skills is Dictionary:
				for key in raw_skills.keys():
					if Game.WORK_TYPES.has(str(key)) or str(key) == "combat": skills[str(key)] = clampi(int(raw_skills[key]), 0, 10)
			var starting_gear: Dictionary = {}
			var raw_gear: Variant = person.get("starting_gear", {})
			if raw_gear is Dictionary:
				for key in ["weapon", "apparel"]:
					if raw_gear.has(key): starting_gear[key] = str(raw_gear[key]).substr(0, 16)
			var starting_relationships: Dictionary = {}
			var raw_relationships: Variant = person.get("starting_relationships", {})
			if raw_relationships is Dictionary:
				for key in raw_relationships.keys():
					if str(key) in ["0", "1", "2"]:
						starting_relationships[str(key)] = str(raw_relationships[key]).substr(0, 16)
			clean_colonists.append({"name": str(person.get("name", "Colonist")).substr(0, 48),
				"age": int(person.get("age", 24)),
				"childhood": str(person.get("childhood", "rural_child")).substr(0, 32),
				"adulthood": str(person.get("adulthood", "farmer")).substr(0, 32),
				"sex": str(person.get("sex", "female")).substr(0, 16),
				"gender": str(person.get("gender", "woman")).substr(0, 16),
				"appearance": appearance, "traits": traits, "health_conditions": conditions,
				"skills": skills, "starting_gear": starting_gear,
				"starting_relationships": starting_relationships})
	return {
		"name": str(spec.get("name", "Unnamed colony")).substr(0, 48),
		"settlement_name": str(spec.get("settlement_name", "Unnamed settlement")).substr(0, 48),
		"site_id": str(spec.get("site_id", "")).substr(0, 64),
		"starting_cargo": clean_cargo,
		"colonists": clean_colonists,
	}


func _close_peer() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_connected_peers.clear()


func _broadcast_lobby() -> void:
	lobby_changed.emit(get_lobby())
	if mode == "host":
		for peer_id in _connected_peers:
			_receive_lobby.rpc_id(peer_id, get_lobby())


func _on_peer_connected(peer_id: int) -> void:
	if mode != "host": return
	if not _connected_peers.has(peer_id): _connected_peers.append(peer_id)
	if bool(_lobby.get("started", false)) and str(_lobby.get("mode", "")) == "coop":
		Game.add_late_player(peer_id)
	_lobby["players"] = [1] + _connected_peers
	_lobby["ready"][str(peer_id)] = bool(_lobby.get("started", false)) and str(_lobby.get("mode", "")) == "coop"
	_broadcast_lobby()
	if not Game.state.is_empty() and Game.state.get("players", {}).has(str(peer_id)):
		_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


func _on_peer_disconnected(peer_id: int) -> void:
	if mode != "host": return
	_connected_peers.erase(peer_id)
	if bool(_lobby.get("started", false)): Game.remove_player(peer_id)
	_player_setups.erase(str(peer_id))
	_lobby["players"] = [1] + _connected_peers
	_lobby["ready"].erase(str(peer_id))
	_broadcast_lobby()


func _on_connected_to_server() -> void:
	connection_changed.emit(true, _net_text("Connected to server.", "Sunucuya bağlandı.", "Połączono z serwerem."))
	_server_request_lobby.rpc_id(1)


func _on_connection_failed() -> void:
	connection_changed.emit(false, _net_text("Could not connect to server.", "Sunucuya bağlanılamadı.", "Nie można połączyć się z serwerem."))
	_close_peer()
	mode = "solo"


func _on_server_disconnected() -> void:
	connection_changed.emit(false, _net_text("Disconnected from server.", "Sunucu bağlantısı kesildi.", "Rozłączono z serwerem."))
	_close_peer()
	mode = "solo"


func _on_game_state_changed(_snapshot: Dictionary) -> void:
	if mode == "client": return
	snapshot_received.emit(Game.state)
	if mode == "host":
		for peer_id in _connected_peers:
			_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


@rpc("any_peer", "call_remote", "reliable")
func _server_request_lobby() -> void:
	if mode != "host": return
	var peer_id := multiplayer.get_remote_sender_id()
	_receive_lobby.rpc_id(peer_id, get_lobby())
	if not Game.state.is_empty() and Game.state.get("players", {}).has(str(peer_id)):
		_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


@rpc("any_peer", "call_remote", "reliable")
func _server_submit_setup(spec: Dictionary) -> void:
	if mode != "host": return
	var peer_id := multiplayer.get_remote_sender_id()
	if not _connected_peers.has(peer_id): return
	if bool(_lobby.get("started", false)):
		if str(_lobby.get("mode", "")) == "coop":
			_receive_command_result.rpc_id(peer_id, {"ok": true})
			_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))
			return
		var late_result: Dictionary = Game.add_late_player(peer_id, _clean_setup(spec))
		_receive_command_result.rpc_id(peer_id, late_result)
		if bool(late_result.get("ok", false)):
			_lobby["ready"][str(peer_id)] = true
			_broadcast_lobby()
			_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))
		return
	_player_setups[str(peer_id)] = _clean_setup(spec)
	_lobby["ready"][str(peer_id)] = true
	_broadcast_lobby()


@rpc("any_peer", "call_remote", "reliable")
func _server_command(command: Dictionary) -> void:
	if mode != "host": return
	var peer_id := multiplayer.get_remote_sender_id()
	if not _connected_peers.has(peer_id): return
	var result := Game.issue_command(peer_id, command)
	_receive_command_result.rpc_id(peer_id, result)


@rpc("authority", "call_remote", "reliable")
func _receive_lobby(remote_lobby: Dictionary) -> void:
	if mode != "client": return
	_lobby = remote_lobby.duplicate(true)
	lobby_changed.emit(get_lobby())


@rpc("authority", "call_remote", "reliable")
func _receive_snapshot(snapshot: Dictionary) -> void:
	if mode != "client": return
	if Game.load_snapshot(snapshot):
		snapshot_received.emit(snapshot)


@rpc("authority", "call_remote", "reliable")
func _receive_command_result(result: Dictionary) -> void:
	if mode == "client": command_result.emit(result)
