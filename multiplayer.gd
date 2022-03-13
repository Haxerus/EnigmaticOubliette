extends Node

const DEFAULT_PORT =  3840
const MAX_PEERS = 4

var peer = null

var players = {}

func _player_connected(id):
	pass
	
	
func _player_disconnected(id):
	pass


func _connected_ok():
	pass
	
	
func _connected_fail():
	pass
	
	
func _server_disconnected():
	pass
	

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
