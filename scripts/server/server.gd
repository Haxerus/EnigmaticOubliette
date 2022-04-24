extends Node

var turn_engine = TurnEngine.new()

func spawn_enemy():
	pass

func _on_player_joined(id: int):
	GameData.send_existing_players(id)
	GameData.add_player(id)
	GameData.add_player_to_zone(id, 0)
	GameData.update_player(id, {"position": GameData.zones[0].map.size / 2})
	GameData.sync_players()
	Multiplayer.send_game_event({
		"type": "player_joined",
		"id": id,
	})
	Multiplayer.enable_client(id)
	
func _on_player_left(id: int):
	GameData.remove_player(id)
	Multiplayer.send_game_event({
		"type": "player_left",
		"id": id,
	})

func _debug_print():
	#print(GameData.players)
	pass

func _ready():
	Multiplayer.connect("upnp_completed", self, "_on_upnp_completed")
	Multiplayer.connect("player_joined", self, "_on_player_joined")
	Multiplayer.connect("player_left", self, "_on_player_left")
	Multiplayer.connect("client_init", self, "_on_client_init")
	
	Multiplayer.connect("action_received", turn_engine, "_on_action_received")
	
	print("[INFO] Starting server...")
	
	print("[INFO] Trying UPNP on port 38400")
	Multiplayer.try_upnp()
	
	print("[INFO] Generating starting zone...")
	_init_starting_zone()
	
	$Timer.connect("timeout", self, "_debug_print")

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
