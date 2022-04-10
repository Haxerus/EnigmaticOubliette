extends Reference

class_name MapGenerator

var random = RandomNumberGenerator.new()

func _init(gen_seed=null):
	if gen_seed:
		random.set_seed(gen_seed)
	else:
		random.randomize()

func generate_map(map, settings):
	map.clear()
	
	var size = Vector2(20, 20)
	
	match settings:
		{"size": var _size, ..}:
			size = _size
	
	for x in range(size.x):
		for y in range(size.y):
			var tile_id = 0
			
			if x == 0 or x == size.x - 1:
				tile_id = 1
			
			if y == 0 or y == size.y - 1:
				tile_id = 1
			
			map.set_cellv(Vector2(x, y), tile_id)
	
	map.generate_nav()

