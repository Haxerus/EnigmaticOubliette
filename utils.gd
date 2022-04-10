extends Node

static func pos_to_tile(pos):
	var tile = Vector2()
	tile.x = floor(pos.x / 16)
	tile.y = floor(pos.y / 16)
	return tile
	
static func tile_to_pos(tile):
	var pos = tile * 16 + Vector2(8, 8)
	return pos
	
static func tile_dist(t1, t2):
	return abs(t1.x - t2.x) + abs(t1.y - t2.y)
	
static func tile_id(tile, map_width):
	return tile.x + tile.y * map_width

static func id_tile(id, map_width):
	var x = int(id) % int(map_width)
	var y = floor(id / map_width)
	return Vector2(x, y)

static func bfs_range(graph, start, max_dist):
	var visited = []
	var queue = []
	
	visited.append(start)
	queue.append(start)
	
	while queue:
		var p = queue.pop_front()
		
		for adj in graph.get_point_connections(p):
			if not adj in visited:
				if tile_dist(graph.get_point_position(start),
						graph.get_point_position(adj)) <= max_dist:
					visited.append(adj)
					queue.append(adj)
	
	visited.pop_front()
	return visited
