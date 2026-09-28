extends Node
class_name NetworkBridge

## The host owns Game. Clients only send requests and render filtered snapshots.
signal connection_changed(connected: bool, message: String)
signal lobby_changed(lobby: Dictionary)
signal snapshot_received(snapshot: Dictionary)
signal command_result(result: Dictionary)

const DEFAULT_PORT := 24567
const MAX_PLAYERS := 8

var mode: String = "solo" # solo, host, client
var _connected_peers: Array[int] = []
var _player_setups: Dictionary = {}
var _lobby: Dictionary = {
	"mode": "solo", "seed": "", "colonists_per_faction": 3,
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
		"players": [1], "ready": {"1": true}, "started": false}
	lobby_changed.emit(get_lobby())
	connection_changed.emit(true, "Tek oyunculu oturum hazır.")
	return {"ok": true}


func host(port: int = DEFAULT_PORT) -> Dictionary:
	_close_peer()
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		return {"ok": false, "error": "Oda açılamadı (hata %d). Portu kontrol et." % err}
	multiplayer.multiplayer_peer = peer
	mode = "host"
	_connected_peers.clear()
	_player_setups.clear()
	_lobby = {"mode": "coop", "seed": "", "colonists_per_faction": 3,
		"players": [1], "ready": {"1": true}, "started": false}
	lobby_changed.emit(get_lobby())
	connection_changed.emit(true, "Oda %d portunda açık." % port)
	return {"ok": true, "port": port}


func join(address: String, port: int = DEFAULT_PORT) -> Dictionary:
	_close_peer()
	if address.strip_edges().is_empty():
		return {"ok": false, "error": "Sunucu adresi boş."}
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address.strip_edges(), port)
	if err != OK:
		return {"ok": false, "error": "Bağlantı başlatılamadı (hata %d)." % err}
	multiplayer.multiplayer_peer = peer
	mode = "client"
	connection_changed.emit(false, "Sunucuya bağlanılıyor…")
	return {"ok": true}


func disconnect_session() -> void:
	_close_peer()
	start_solo()


func configure_lobby(rules: Dictionary) -> Dictionary:
	if mode == "client":
		return {"ok": false, "error": "Kuralları yalnızca ev sahibi değiştirebilir."}
	if bool(_lobby.get("started", false)):
		return {"ok": false, "error": "Oyun başladı."}
	var selected_mode := str(rules.get("mode", _lobby.get("mode", "coop")))
	if selected_mode not in ["solo", "coop", "competitive"]:
		return {"ok": false, "error": "Geçersiz oyun modu."}
	_lobby["mode"] = selected_mode
	_lobby["seed"] = str(rules.get("seed", _lobby.get("seed", "")))
	_lobby["colonists_per_faction"] = clampi(int(rules.get("colonists_per_faction", 3)), 1, 3)
	_player_setups.clear()
	_lobby["ready"] = {"1": true}
	_broadcast_lobby()
	return {"ok": true}


func submit_player_setup(spec: Dictionary) -> Dictionary:
	if mode == "client":
		if multiplayer.multiplayer_peer == null:
			return {"ok": false, "error": "Bağlantı yok."}
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
		return {"ok": false, "error": "Oyunu ev sahibi başlatır."}
	var setup := config.duplicate(true)
	var selected_mode := str(setup.get("mode", "solo"))
	if mode == "solo": selected_mode = "solo"
	if selected_mode not in ["solo", "coop", "competitive"]:
		return {"ok": false, "error": "Geçersiz oyun modu."}
	setup["mode"] = selected_mode
	setup["colonists_per_faction"] = clampi(int(setup.get("colonists_per_faction", setup.get("colonist_count", 3))), 1, 3)
	var supplied: Array = setup.get("faction_specs", [])
	var host_spec: Dictionary = supplied[0].duplicate(true) if not supplied.is_empty() else {}
	host_spec["players"] = [1]
	var specs: Array = [host_spec]
	if mode == "host":
		for peer_id in _connected_peers:
			if not _player_setups.has(str(peer_id)):
				return {"ok": false, "error": "%d numaralı oyuncu henüz hazır değil." % peer_id}
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
				return {"ok": false, "error": "Her koloni ayrı bir boş yerleşke seçmeli."}
			selected_sites[site_id] = true
	setup["faction_specs"] = specs
	Game.start_new_game(setup)
	_lobby["started"] = true
	_broadcast_lobby()
	return {"ok": true, "snapshot": get_snapshot()}


func send_command(command: Dictionary) -> Dictionary:
	if mode == "client":
		if multiplayer.multiplayer_peer == null:
			return {"ok": false, "error": "Bağlantı yok."}
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
	return {
		"name": str(spec.get("name", "Koloni")).substr(0, 48),
		"settlement_name": str(spec.get("settlement_name", "Yerleşke")).substr(0, 48),
		"site_id": str(spec.get("site_id", "")),
		"colonists": (spec.get("colonists", []) as Array).slice(0, 3),
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
	_lobby["players"] = [1] + _connected_peers
	_lobby["ready"][str(peer_id)] = false
	_broadcast_lobby()
	if not Game.state.is_empty():
		_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


func _on_peer_disconnected(peer_id: int) -> void:
	if mode != "host": return
	_connected_peers.erase(peer_id)
	_player_setups.erase(str(peer_id))
	_lobby["players"] = [1] + _connected_peers
	_lobby["ready"].erase(str(peer_id))
	_broadcast_lobby()


func _on_connected_to_server() -> void:
	connection_changed.emit(true, "Sunucuya bağlandı.")
	_server_request_lobby.rpc_id(1)


func _on_connection_failed() -> void:
	connection_changed.emit(false, "Sunucuya bağlanılamadı.")
	_close_peer()
	mode = "solo"


func _on_server_disconnected() -> void:
	connection_changed.emit(false, "Sunucu bağlantısı kesildi.")
	_close_peer()
	mode = "solo"


func _on_game_state_changed(_snapshot: Dictionary) -> void:
	if mode == "client": return
	snapshot_received.emit(get_snapshot())
	if mode == "host":
		for peer_id in _connected_peers:
			_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


@rpc("any_peer", "call_remote", "reliable")
func _server_request_lobby() -> void:
	if mode != "host": return
	var peer_id := multiplayer.get_remote_sender_id()
	_receive_lobby.rpc_id(peer_id, get_lobby())
	if not Game.state.is_empty():
		_receive_snapshot.rpc_id(peer_id, Game.get_snapshot(peer_id))


@rpc("any_peer", "call_remote", "reliable")
func _server_submit_setup(spec: Dictionary) -> void:
	if mode != "host" or bool(_lobby.get("started", false)): return
	var peer_id := multiplayer.get_remote_sender_id()
	if not _connected_peers.has(peer_id): return
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
