extends Node

var random = RandomNumberGenerator.new()
var turn_engine = TurnEngine.new()

func spawn_enemy():
	var size = GameData.zones[0].map.size
	var spawn_point = Vector2(randi() % int(size.x - 1) + 1, randi() % int(size.y - 1) + 1)
	#spawn_point = Vector2(12, 12)
	var id = GameData.add_enemy(0)
	GameData.update_enemy(id, {"position": spawn_point})
	Multiplayer.send_game_event({
		"type": "enemy_spawned",
		"id": id,
	})
	
func remove_dead_enemies():
	for enemy in GameData.enemies.values():
		if enemy.data.health <= 0:
			GameData.remove_enemy(enemy.id)
			Multiplayer.send_game_event({
				"type": "enemy_removed",
				"id": enemy.id,
			})

func _on_player_joined(id: int):
	GameData.send_existing_entities(id)
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
	random.randomize()
	
	Multiplayer.connect("upnp_completed", self, "_on_upnp_completed")
	Multiplayer.connect("player_joined", self, "_on_player_joined")
	Multiplayer.connect("player_left", self, "_on_player_left")
	
	Multiplayer.connect("action_received", turn_engine, "_on_action_received")
	
	Multiplayer.connect("player_left", turn_engine, "_on_player_left")
	
	print("[INFO] Starting server...")
	
	print("[INFO] Trying UPNP on port 38400")
	Multiplayer.try_upnp()
	
	print("[INFO] Generating starting zone...")
	_init_starting_zone()
	
	$Timer.connect("timeout", self, "_debug_print")

func _process(_delta):
	if turn_engine.turn_is_ready():
		turn_engine.execute_turn()
		yield(Multiplayer, "client_turn_complete")
		next_turn()

func next_turn():
	remove_dead_enemies()
	
	if randf() < 0.55:
		spawn_enemy()	

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
