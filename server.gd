extends Node

func _ready():
	Multiplayer.host_game()
	print("Generating Hub Zone")
	_init_hub_zone()
	print("Server starup completed")

func _init_hub_zone():
	var zone = load("res://zone.tscn").instance()
	zone.name = "Hub"
	var map_gen =  MapGenerator.new()
	var map = zone.get_node("Map")
	
	map_gen.generate_map(map, {})
	
	$Zones.add_child(zone)

func add_player(id):
	var player = load("res://player.tscn").instance()
	player.name = str(id)
	
	$PlayerData.register_player(id)
	
	var spawn = Vector2(floor($Zones/Hub/Map.size.x / 2), floor($Zones/Hub/Map.size.y / 2))
	player.position = Utils.tile_to_pos(spawn)
	
	$PlayerData.update_attribute(id, "position", Utils.tile_to_pos(spawn))
	
	print($PlayerData.get_data(id))
	
	$Zones/Hub.add_child(player)
