extends Node

var role := ""
var game_mode := "competitive"
var submitted := false
var started := false
var got_result := false


func _ready() -> void:
	role = OS.get_environment("FOXTOPIA_TEST_ROLE")
	game_mode = OS.get_environment("FOXTOPIA_TEST_MODE")
	if game_mode.is_empty(): game_mode = "competitive"
	Net.lobby_changed.connect(_on_lobby)
	Net.snapshot_received.connect(_on_snapshot)
	Net.command_result.connect(_on_result)
	Net.connection_changed.connect(func(connected: bool, message: String): print("NET_CONNECTION:", role, ":", connected, ":", message))
	multiplayer.peer_disconnected.connect(func(_peer_id: int):
		if role == "host" and started:
			print("HOST_CLIENT_FINISHED:", game_mode)
			get_tree().quit())
	var timeout := get_tree().create_timer(12.0)
	timeout.timeout.connect(func():
		push_error("NETWORK_PROBE_TIMEOUT:%s" % role)
		get_tree().quit(2))
	if role == "host":
		var result: Dictionary = Net.host(24579)
		print("HOST_START:", result)
		assert(result.get("ok", false))
		Net.configure_lobby({"mode": game_mode, "seed": "network-test", "colonists_per_faction": 1})
	elif role == "client":
		var result: Dictionary = Net.join("127.0.0.1", 24579)
		print("CLIENT_JOIN:", result)
		assert(result.get("ok", false))
	else:
		push_error("Invalid test role")
		get_tree().quit(2)


func _on_lobby(lobby: Dictionary) -> void:
	if role == "client" and not submitted and not bool(lobby.get("started", false)) and (lobby.get("players", []) as Array).size() > 1:
		submitted = true
		var spec := {"name": "Client", "settlement_name": "Client Town", "site_id": "site_2", "colonists": [{"name": "Client Pawn"}]}
		assert(Net.submit_player_setup(spec).get("ok", false))
	if role == "host" and not started and (lobby.get("players", []) as Array).size() > 1:
		var peer_id := int((lobby["players"] as Array)[1])
		if bool((lobby.get("ready", {}) as Dictionary).get(str(peer_id), false)):
			started = true
			var config := {"mode": game_mode, "seed": "network-test", "colonists_per_faction": 1,
				"faction_specs": [{"name": "Host", "settlement_name": "Host Town", "site_id": "site_1", "colonists": [{"name": "Host Pawn"}]}]}
			var result: Dictionary = Net.start_game(config)
			assert(result.get("ok", false))
			assert((Game.state.get("players", {}) as Dictionary).has(str(peer_id)))
			if game_mode == "competitive":
				assert((Game.get_snapshot(peer_id).get("maps", {}) as Dictionary).size() == 1)
			else:
				assert((Game.get_snapshot(peer_id).get("maps", {}) as Dictionary).size() == 1)
			print("HOST_GAME_STARTED:", game_mode)


func _on_snapshot(snapshot: Dictionary) -> void:
	if role != "client" or got_result: return
	if snapshot.is_empty(): return
	var peer_id := Net.get_local_peer_id()
	if not (snapshot.get("players", {}) as Dictionary).has(str(peer_id)): return
	var factions: Array = snapshot.get("factions", [])
	var people: Array = snapshot.get("colonists", [])
	if game_mode == "competitive":
		assert((snapshot.get("maps", {}) as Dictionary).size() == 1)
		assert(people.size() == 1)
		assert(factions.size() == 2)
	else:
		assert((snapshot.get("maps", {}) as Dictionary).size() == 1)
		assert(people.size() == 1)
	var own_id := str(people[0].get("id", ""))
	assert(Net.send_command({"type": "direct", "colonist_id": own_id, "action": "move", "x": 24, "y": 24}).get("ok", false))
	got_result = true
	print("CLIENT_SNAPSHOT_OK:", game_mode, ":", peer_id)


func _on_result(result: Dictionary) -> void:
	if role != "client" or not got_result: return
	assert(result.get("ok", false))
	print("CLIENT_COMMAND_OK:", game_mode)
	get_tree().quit()
