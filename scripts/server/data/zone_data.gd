extends Reference

class_name ZoneData

var id

var map = MapData.new() setget _map_changed
var nav = AStar2D.new()

# Entities are only stored by ID
var players = []
var enemies = []
var interactables = []

func _init():
	id = self.get_instance_id()

func add_enemy(eid: int):
	if not enemies.has(eid):
		enemies.append(eid)

func remove_enemy(eid: int):
	enemies.erase(eid)
	
func add_player(pid: int):
	if not players.has(pid):
		players.append(pid)
		
func remove_player(pid: int):
	players.erase(pid)

func serialize():	
	return {
		"id": id,
		"map": map.serialize(),
		"enemies": enemies,
		"players": players,
	}

func _map_changed(new_map):
	map = new_map
	_generate_nav()

func _generate_nav():
	nav.clear()
	
	for x in range(map.size.x):
		for y in range(map.size.y):
			nav.add_point(x + y * map.size.x, Vector2(x, y))
	
	for x in range(map.size.x):
		for y in range(map.size.y):
			var t_id = x + y * map.size.x
			
			if (nav.has_point(t_id + 1)):
				nav.connect_points(t_id, t_id + 1)
				
			if (nav.has_point(t_id + map.size.x)):
				nav.connect_points(t_id, t_id + map.size.x)
				
			if (nav.has_point(t_id - 1)):
				nav.connect_points(t_id, t_id - 1)
				
			if (nav.has_point(t_id - map.size.x)):
				nav.connect_points(t_id, t_id - map.size.x)
