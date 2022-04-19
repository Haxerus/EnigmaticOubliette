extends Reference

class_name MapData

var size = Vector2() setget _size_changed
var tiles = []

func get_tile(pos: Vector2):
	return tiles[pos.x + pos.y * size.x]
	
func set_tile(pos: Vector2, tile: int):
	tiles[pos.x + pos.y * size.x] = tile

func serialize():
	return {
		"size": size,
		"tiles": tiles,
	}

func _size_changed(new_size):
	size = new_size
	tiles.clear()
	for _i in range(size.x * size.y):
		tiles.append(0)
