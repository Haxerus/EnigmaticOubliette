extends Node

const DEFAULT_PORT = 38400
const MAX_PEERS = 8

var peer

signal connection_succeeded
signal connection_failed
signal network_error(error)

signal received_action(id, action)

signal force_update
signal map_sync(data)
signal player_sync(data)
signal action_results(results)

signal upnp_completed(error)
var thread = null

# Callbacks from SceneTree

func _player_connected(id):
	if get_tree().is_network_server():
		var server = get_node("/root/Server")
		var player_data = get_node("/root/Server/PlayerData")
		
		server.add_player(id)
		
		# Sync to connecting client
		rpc_id(id, "sync_client", {"type": "map_data", "data": {}})
		
		# Sync to all clients
		rpc("sync_client", {"type": "player_data", "data": player_data.get_all_data()})
		rpc("force_update")
	
func _player_disconnected(id):
	print("Peer ", id, " disconnected")

func _connected_ok():
	emit_signal("connection_succeeded")
	
func _connected_fail():
	emit_signal("connection_failed")
	
func _server_disconnected():
	emit_signal("network_error", "Server disconnected")

# General Multiplayer Functions

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT, 0, 0, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func try_upnp():
	thread.start(self, "_upnp_setup", DEFAULT_PORT)
	
# Game specific network functions

# Server Side
remote func player_action(action):
	if not get_tree().is_network_server():
		return
	
	emit_signal("received_action", get_tree().get_rpc_sender_id(), action)

# TODO: Make this function call all clients and send the results of the turn
func send_action_result(id, result):
	var player_data = get_node("/root/Server/PlayerData")
	rpc("sync_client", {"type": "player_data", "data": player_data.get_all_data()})
	rpc("action_results", result)

# Client Side

remote func sync_client(packet):
	if get_tree().is_network_server():
		return

	match packet:
		{"type": "player_data", ..}:
			emit_signal("player_sync", packet["data"])
		{"type": "map_data", ..}:
			emit_signal("map_sync", packet["data"])

remote func force_update():
	if get_tree().is_network_server():
		return
	
	emit_signal("force_update")

remote func action_results(results):
	if get_tree().is_network_server():
		return
	
	emit_signal("action_results", results)

func send_action(action):
	rpc_id(1, "player_action", action)
	
func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		var e = upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		emit_signal("upnp_completed", e)

func _ready():
	thread = Thread.new()
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	if thread.is_active():
		thread.wait_to_finish()
