extends Node

var connected = []
var ready = []

onready var player_data = 

func _ready():
	Multiplayer.connect("upnp_completed", self, "_on_upnp_completed")
	Multiplayer.connect("received_action", self, "_on_received_action")
	
	print("[INFO] Starting server...")
	
	print("[INFO] Trying UPNP on port 38400")
	Multiplayer.try_upnp()
	
	print("[INFO] Generating Hub zone...")
	_init_hub_zone()

func _process(_delta):
	pass

func add_player(id):
	var player = load("res://player.tscn").instance()
	player.name = str(id)
	
	$PlayerData.register_player(id)
	if !connected.has(id):
		connected.append(id)
	
	var spawn = Vector2(floor($Zones/Hub/Map.size.x / 2), floor($Zones/Hub/Map.size.y / 2))
	$PlayerData.update_attribute(id, "position", spawn)
	
	$Zones/Hub.add_child(player)

func remove_player(id):
	var player = get_node_or_null("Zones/Hub/Players/"+str(id))
	if player == null:
		return
	
	player.queue_free()
	$PlayerData.unregister_player(id)

func _on_received_action(id, action):
	match action:
		{"type": "move", ..}:
			if !ready.has(id):
				ready.append(id)
			var pos = $PlayerData.get_attribute(id, "position")
			var player_tid = Utils.tile_id(pos, $Zones/Hub/Map.size.x)
			
			var path = $Zones/Hub/Map.nav.get_id_path(player_tid, action["target"])
			path.remove(0)
			
			$PlayerData.update_attribute(id, "position", Utils.id_tile(action["target"], $Zones/Hub/Map.size.x))
			Multiplayer.send_action_result(id, {"path": path, "id": id})
			
		{"type": "attack", ..}:
			if !ready.has(id):
				ready.append(id)

func _on_upnp_completed(err):
	if err == OK:
		print("[INFO] UPNP was successful")
	else:
		print("[ERROR] UPNP failed with error code: ", err)
	
	print("[INFO] Launching host")
	Multiplayer.host_game()
	print("[INFO] Server startup completed")

func _init_hub_zone():
	var zone = load("res://zone.tscn").instance()
	zone.name = "Hub"
	var map_gen =  MapGenerator.new()
	var map = zone.get_node("Map")
	
	map_gen.generate_map(map, {})
	
	$Zones.add_child(zone)
