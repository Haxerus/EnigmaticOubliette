extends Node

var connected = []
var ready = []

func _ready():
	Multiplayer.host_game()
	Multiplayer.connect("received_action", self, "_on_received_action")
	
	print("Generating Hub Zone")
	_init_hub_zone()
	print("Server starup completed")

func _process(_delta):
	pass

func add_player(id):
	var player = load("res://player.tscn").instance()
	player.name = str(id)
	
	$PlayerData.register_player(id)
	connected.append(id)
	
	var spawn = Vector2(floor($Zones/Hub/Map.size.x / 2), floor($Zones/Hub/Map.size.y / 2))
	$PlayerData.update_attribute(id, "position", spawn)
	
	$Zones/Hub.add_child(player)

func _on_received_action(id, action):
	print(ready == connected)
	match action:
		{"type": "move", ..}:
			ready.append(id)
			var pos = $PlayerData.get_attribute(id, "position")
			var player_tid = Utils.tile_id(pos, $Zones/Hub/Map.size.x)
			
			var path = $Zones/Hub/Map.nav.get_id_path(player_tid, action["target"])
			path.remove(0)
			
			$PlayerData.update_attribute(id, "position", Utils.id_tile(action["target"], $Zones/Hub/Map.size.x))
			Multiplayer.send_action_result(id, {"path": path})
			
		{"type": "attack", ..}:
			ready.append(id)

func _init_hub_zone():
	var zone = load("res://zone.tscn").instance()
	zone.name = "Hub"
	var map_gen =  MapGenerator.new()
	var map = zone.get_node("Map")
	
	map_gen.generate_map(map, {})
	
	$Zones.add_child(zone)
