extends TileMap

var map_size = Vector2()
var nav_map = AStar2D.new()

func generate_nav_map():
	for i in range(map_size.x):
		for j in range(map_size.y):
			if get_cell(i, j) != 1:
				nav_map.add_point(i + j * map_size.x, Vector2(i, j))
				
	for i in range(map_size.x):
		for j in range(map_size.y):
			var id = i + j * map_size.x
			_connect_points(id, id - map_size.x) # UP
			_connect_points(id, id - 1) # LEFT
			_connect_points(id, id + map_size.x) # DOWN
			_connect_points(id, id + 1) # RIGHT

func _connect_points(p1, p2):
	if (
		nav_map.has_point(p1)
		and nav_map.has_point(p2)
		and not nav_map.are_points_connected(p1, p2)
	):
		nav_map.connect_points(p1, p2)
