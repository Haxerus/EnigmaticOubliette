extends Node

const DEFAULT_PORT = 3840
const MAX_PEERS = 8

var peer = null

signal connection_succeeded
signal connection_failed
signal network_error(error)

signal map_sync(data)
signal player_sync(data)

# Callbacks from SceneTree

func _player_connected(id):
	if get_tree().is_network_server():
		var server = get_node("/root/Server")
		var player_data = get_node("/root/Server/PlayerData")
		
		server.add_player(id)
		
		rpc_id(id, "sync_map", {})
		rpc_id(id, "sync_player", player_data.get_data(id))
	
func _player_disconnected(id):
	pass

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
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
# Game specific network functions

# Server Side

# Client Side

remote func sync_map(data):
	if not get_tree().is_network_server():
		emit_signal("map_sync", data)

remote func sync_player(data):
	if not get_tree().is_network_server():
		emit_signal("player_sync", data)

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
