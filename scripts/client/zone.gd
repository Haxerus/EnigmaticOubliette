extends Node2D

func _ready():
	load_map()

func load_map():
	var map = GameData.zones.current.map
	print(map.size)
	
	for x in range(0, map.size.x):
		for y in range(0, map.size.y):
			var tile = map.tiles[x + y * map.size.x]
			$Map.set_cell(x, y, tile)
