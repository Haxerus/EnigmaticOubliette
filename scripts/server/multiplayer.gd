extends Node

const DEFAULT_PORT = 38400
const MAX_PEERS = 8

var peer
var upnp_thread

var clients = []

signal connection_succeeded
signal connection_failed
signal network_error(error)

# Server Only
signal upnp_completed(error)

signal player_joined(id)
signal player_left(id)

signal action_received(action)
signal outcome_received(outcome)

signal client_turn_complete

# Client Only
signal client_ready

signal player_updated(data)
signal zone_updated(data)
signal enemy_updated(data)

signal game_event(event)
	
# Game specific network functions

# Server Side
remote func recv_client_config(config: Dictionary):
	if get_tree().is_network_server():
		match config:
			{"name": var p_name}:
				var id = get_tree().get_rpc_sender_id()
				GameData.update_player(id, {"name": p_name})

remote func recv_client_action(action: Dictionary):
	if get_tree().is_network_server():
		emit_signal("action_received", action)

remote func client_turn_process_complete():
	if get_tree().is_network_server():
		clients.append(get_tree().get_rpc_sender_id())
		
		var ready = true
		for i in GameData.players.keys():
			if not clients.has(i):
				ready = false
		
		if ready:
			clients.clear()
			emit_signal("client_turn_complete")

func enable_client(id):
	if get_tree().is_network_server():
		rpc_id(id, "setup_end")
		
func send_turn_outcome(outcome: Array):
	if get_tree().is_network_server():
		rpc("recv_turn_outcome", outcome)

func send_game_event(event: Dictionary, receiver=null):
	if get_tree().is_network_server():
		if receiver == null:
			rpc("dispatch_game_event", event)
		else:
			rpc_id(receiver, "dispatch_game_event", event)

# Client Side
remote func setup_end():
	if not get_tree().is_network_server():
		emit_signal("client_ready")
		
remote func recv_turn_outcome(outcome: Array):
	if not get_tree().is_network_server():
		emit_signal("outcome_received", outcome)

remote func dispatch_game_event(event: Dictionary):
	if not get_tree().is_network_server():
		emit_signal("game_event", event)

func send_action(action: Dictionary):
	if not get_tree().is_network_server():
		rpc_id(1, "recv_client_action", action)
		
func send_client_config(config: Dictionary):
	if not get_tree().is_network_server():
		rpc_id(1, "recv_client_config", config)
		
func turn_complete():
	if not get_tree().is_network_server():
		rpc_id(1, "client_turn_process_complete")

# General Multiplayer Functions

func host_game():
	peer = NetworkedMultiplayerENet.new()
	# Figure out what this actually does
	peer.set_server_relay_enabled(false)
	peer.create_server(DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

# Callbacks from SceneTree

func _player_connected(id):
	print("Peer ", id, " connected")
	if get_tree().is_network_server():
		emit_signal("player_joined", id)
	
func _player_disconnected(id):
	print("Peer ", id, " disconnected")
	if get_tree().is_network_server():
		emit_signal("player_left", id)

func _connected_ok():
	emit_signal("connection_succeeded")
	
func _connected_fail():
	emit_signal("connection_failed")
	
func _server_disconnected():
	emit_signal("network_error", "Server disconnected")
	
# Other functions

func try_upnp():
	upnp_thread.start(self, "_upnp_setup", DEFAULT_PORT)
	
func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		emit_signal("upnp_completed", OK)

func _ready():
	upnp_thread = Thread.new()
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _exit_tree():
	if peer:
		peer.close_connection()
	# Wait for thread finish here to handle game exit while the thread is running.
	if upnp_thread.is_active():
		upnp_thread.wait_to_finish()
