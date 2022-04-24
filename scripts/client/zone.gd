extends Node2D

func _ready():
	$Map.cell_size = Utils.TILE_SIZE
	$TileOverlay.cell_size = Utils.TILE_SIZE
	
	load_map()

func load_map():
	if GameData.zones.has("current"):
		var map = GameData.zones.current.map
		print(map.size)
		
		for x in range(0, map.size.x):
			for y in range(0, map.size.y):
				var tile = map.tiles[x + y * map.size.x]
				$Map.set_cell(x, y, tile)
