extends TileMap

var size = Vector2()
var nav = AStar2D.new()

func generate_nav():
	for i in range(size.x):
		for j in range(size.y):
			if get_cell(i, j) != 1:
				nav.add_point(i + j * size.x, Vector2(i, j))
				
	for i in range(size.x):
		for j in range(size.y):
			var id = i + j * size.x
			_connect_points(id, id - size.x) # UP
			_connect_points(id, id - 1) # LEFT
			_connect_points(id, id + size.x) # DOWN
			_connect_points(id, id + 1) # RIGHT

func _connect_points(p1, p2):
	if (
		nav.has_point(p1)
		and nav.has_point(p2)
		and not nav.are_points_connected(p1, p2)
	):
		nav.connect_points(p1, p2)
