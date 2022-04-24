extends Reference

class_name MapGenerator

var random = RandomNumberGenerator.new()

func _init(gen_seed: int = 0):
	if gen_seed:
		random.set_seed(gen_seed)
	else:
		random.randomize()

func generate_map(settings: Dictionary) -> MapData:
	var map = MapData.new()
	
	match settings:
		{"size": var s, ..}:
			map.size = s
	
	for x in range(map.size.x):
		for y in range(map.size.y):
			var tile_id = 1
			
			if x == 0 or x == map.size.x - 1:
				tile_id = 2
			
			if y == 0 or y == map.size.y - 1:
				tile_id = 2
			
			map.tiles[x + y * map.size.x] = tile_id
	
	return map
