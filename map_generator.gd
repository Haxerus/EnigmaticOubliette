extends Reference

class_name MapGenerator

var random = null

func _init():
	random = RandomNumberGenerator.new()


func generate_map(min_size, max_size, map):
	var size_x = random.randi_range(min_size.x, max_size.x)
	var size_y = random.randi_range(min_size.y, max_size.y)
	map.map_size = Vector2(size_x, size_y)
	
	map.clear()
	
	for x in range(size_x):
		for y in range(size_y):
			var tile_id = 0
			
			if x == 0 or x == size_x - 1:
				tile_id = 1
			
			if y == 0 or y == size_y - 1:
				tile_id = 1
			
			map.set_cellv(Vector2(x, y), tile_id)

