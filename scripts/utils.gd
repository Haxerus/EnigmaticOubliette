extends Node

const TILE_SIZE = Vector2(32, 32)

static func pos_to_tile(pos: Vector2) -> Vector2:
	var tile = Vector2()
	tile.x = floor(pos.x / TILE_SIZE.x)
	tile.y = floor(pos.y / TILE_SIZE.y)
	return tile
	
static func tile_to_pos(tile: Vector2) -> Vector2:
	var pos = tile * TILE_SIZE + Vector2(TILE_SIZE.x / 2, TILE_SIZE.y / 2)
	return pos
	
static func tile_dist(t1: Vector2, t2: Vector2):
	return abs(t1.x - t2.x) + abs(t1.y - t2.y)
	
static func tile_id(tile: Vector2, map_width: int):
	return tile.x + tile.y * map_width

static func id_tile(id: int, map_width: int) -> Vector2:
	var x = int(id) % int(map_width)
	var y = floor(id / map_width)
	return Vector2(x, y)
	
static func in_bounds(pos: Vector2, bounds: Vector2) -> bool:
	return pos.x in range(0, bounds.x) and pos.y in range(0, bounds.y)

static func bfs_range(graph: AStar2D, start: int, max_dist: int) -> Array:
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
