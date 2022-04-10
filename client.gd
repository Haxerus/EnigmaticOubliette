extends Node

onready var pid = get_tree().get_network_unique_id()
var player = preload("res://player.tscn").instance()

func _ready():
	$Zone/Players.add_child(player)
	$PlayerData.register_player(pid)
	
	Multiplayer.connect("map_sync", self, "_on_map_sync")
	Multiplayer.connect("player_sync", self, "_on_player_sync")

func _process(_delta):
	pass

func _on_player_sync(data):
	match data:
		{"position": var pos}:
			$PlayerData.update_attribute(pid, "position", pos)
			player.set_tile_position(pos)
	
func _on_map_sync(data):
	var map_gen = MapGenerator.new()
	map_gen.generate_map($Zone/Map, data)
