extends Node

const DEFAULT_PORT = 3840
const MAX_PEERS = 8

var peer = null

var local_player = "player"
var remote_players = {}

signal connection_succeeded
signal connection_failed
signal network_error(error)

# Callbacks from SceneTree

func _player_connected(id):
	if get_tree().is_network_server():
		rpc_id(id, "create_client")
		get_node("/root/Server").add_player(id)
	else:
		rpc_id(id, "register_player", local_player)
	
func _player_disconnected(id):
	unregister_player(id)

func _connected_ok():
	emit_signal("connection_succeeded")
	
func _connected_fail():
	emit_signal("connection_failed")
	
func _server_disconnected():
	emit_signal("network_error", "Server disconnected")

# General Multiplayer Functions

func host_game():	
	print("Server Starting")
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
func join_game(ip, player_name):
	local_player = player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	
remote func register_player(player_name):
	var id = get_tree().get_rpc_sender_id()
	remote_players[id] = player_name
	print("registered ", id, player_name)
	
func unregister_player(id):
	remote_players.erase(id)
	
# Game specific network functions

remote func create_client():
	if not get_tree().is_network_server():
		if not has_node("/root/Client"):
			var client = load("res://client.tscn").instance()
			var hub_zone = load("res://zone.tscn").instance()
			var player = load("res://player.tscn").instance()
			var map_gen =  MapGenerator.new(100)
			var map = hub_zone.get_node("Map")
			
			map_gen.generate_map(Vector2(10, 10), Vector2(10, 10), map)
			map.generate_nav()
			
			var spawn = Vector2(floor(map.size.x / 2), floor(map.size.y / 2))
			player.position = Utils.tile_to_pos(spawn)
			
			hub_zone.get_node("Players").add_child(player)
			client.add_child(hub_zone)
			get_tree().get_root().add_child(client)

remote func sync_zone(gen_params):
	if not get_tree().is_network_server():
		var zone = load("res://zone.tscn").instance()
		var map_gen =  MapGenerator.new(gen_params["seed"])
		var map = zone.get_node("Map")
		
		map_gen.generate_map(gen_params["min_size"], gen_params["max_size"], map)
		map.generate_nav()
		
		get_node("/root/Client").add_child(zone)
	
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
