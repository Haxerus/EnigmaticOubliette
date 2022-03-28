extends Node

signal upnp_completed(error)

const DEFAULT_PORT = 3840
const MAX_PEERS = 8

var peer = null
var thread = null

var local_player = "player"
var remote_players = {}

func host_game():
#	thread.start(self, "_upnp_setup", DEFAULT_PORT)
#	yield(self, "upnp_completed")
	
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

remote func sync_players(players):
	remote_players = players

func _player_connected(id):
	if get_tree().is_network_server():
		rpc_id(id, "sync_players", remote_players)
	
func _player_disconnected(id):
	pass

func _connected_ok():
	rpc_id(1, "register_player", local_player)
	
func _connected_fail():
	pass
	
func _server_disconnected():
	pass
	
func _upnp_setup(port):
	var upnp = UPNP.new()
	var err = upnp.discover()
	
	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return
		
	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(port, port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(port, port, ProjectSettings.get_setting("application/config/name"), "TCP")
		emit_signal("upnp_completed", OK)

func _ready():
	thread = Thread.new()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _exit_tree():
	if thread.is_active():
		thread.wait_to_finish()
