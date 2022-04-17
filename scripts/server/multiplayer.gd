extends Node

const DEFAULT_PORT = 38400
const MAX_PEERS = 8

var peer
var upnp_thread

enum { PLAYER_DATA, ZONE_DATA, MAP_DATA, ENEMY_DATA }

signal connection_succeeded
signal connection_failed
signal network_error(error)

# Server Only
signal upnp_completed(error)

signal player_joined(id)
signal player_left(id)

# Shared
signal player_updated(data)

# Client Only
signal zone_updated(data)
signal enemy_updated(data)
	
# Game specific network functions

# Server Side
# This syncs client data to the server when one joins
remote func init_client_data(data: Dictionary):
	if get_tree().is_network_server():
		emit_signal("player_updated", data)

# Client Side
remote func sync_data(packet: Dictionary):
	if not get_tree().is_network_server():
		match packet:
			{"type": PLAYER_DATA, "data": var data}:
				emit_signal("player_updated", data)
			{"type": ZONE_DATA, "data": var data}:
				emit_signal("zone_updated", data)
			{"type": ENEMY_DATA, "data": var data}:
				emit_signal("enemy_updated", data)

# Make Real
func send_action(action):
	pass
		
func client_init(n: String):
	if not get_tree().is_network_server():
		var data = {
			"id": get_tree().get_network_unique_id(),
			"name": n,
		}
		rpc_id(1, "init_client_data", data)

# General Multiplayer Functions

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT)
	# Figure out what this actually does
	# peer.set_server_relay_enabled(false)
	get_tree().set_network_peer(peer)
	
func join_game(ip):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

# Callbacks from SceneTree

func _player_connected(id):
	if get_tree().is_network_server():
		emit_signal("player_joined", id)
	
func _player_disconnected(id):
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
