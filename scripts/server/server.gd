extends Node

var zones = {}
var players = {}

func _on_player_joined(id: int):
	var p_data = PlayerData.new(id, 0)
	players[id] = p_data
	zones[0].add_player(id)
	
func _on_player_left(id: int):
	var zid = players[id].zone_id
	zones[zid].remove_player(id)
	players.erase(id)
	
func _on_player_updated(data):
	match data:
		{"id": var id, "name": var n, ..}:
			players[id].data.name = n

func _ready():
	Multiplayer.connect("upnp_completed", self, "_on_upnp_completed")
	Multiplayer.connect("player_joined", self, "_on_player_joined")
	Multiplayer.connect("player_left", self, "_on_player_left")
	Multiplayer.connect("player_updated", self, "_on_player_updated")
	
	print("[INFO] Starting server...")
	
	print("[INFO] Trying UPNP on port 38400")
	Multiplayer.try_upnp()
	
	print("[INFO] Generating starting zone...")
	_init_starting_zone()

func _init_starting_zone():
	var zone = ZoneData.new()
	var generator = MapGenerator.new()
	
	zone.map = generator.generate_map({"size": Vector2(30, 30)})
	zones[0] = zone

func _on_upnp_completed(err):
	if err == OK:
		print("[INFO] UPNP was successful")
	else:
		print("[ERROR] UPNP failed with error code: ", err)
	
	print("[INFO] Launching host")
	Multiplayer.host_game()
	print("[INFO] Server startup completed")
