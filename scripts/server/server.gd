extends Node

func _on_player_joined(id: int):
	GameData.add_player(id)
	GameData.add_player_to_zone(id, 0)
	
func _on_player_left(id: int):
	GameData.remove_player(id)
	
func _on_client_init(id, data):
	GameData.update_player(id, data)
	GameData.sync_players()
	Multiplayer.enable_client(id)

func _ready():
	Multiplayer.connect("upnp_completed", self, "_on_upnp_completed")
	Multiplayer.connect("player_joined", self, "_on_player_joined")
	Multiplayer.connect("player_left", self, "_on_player_left")
	Multiplayer.connect("client_init", self, "_on_client_init")
	
	print("[INFO] Starting server...")
	
	print("[INFO] Trying UPNP on port 38400")
	Multiplayer.try_upnp()
	
	print("[INFO] Generating starting zone...")
	_init_starting_zone()

func _init_starting_zone():
	var generator = MapGenerator.new()
	var map = generator.generate_map({"size": Vector2(50, 30)})
	
	GameData.add_zone(0)
	GameData.set_zone_map(0, map)

func _on_upnp_completed(err):
	if err == OK:
		print("[INFO] UPNP was successful")
	else:
		print("[ERROR] UPNP failed with error code: ", err)
	
	print("[INFO] Launching host")
	Multiplayer.host_game()
	print("[INFO] Server startup completed")
