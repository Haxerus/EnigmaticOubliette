extends Reference

class_name ZoneData

var id

var map setget _map_changed
var nav = AStar2D.new()

var enemies = {}
var interactables = {}

var player_ids = []

func _init(_id: int = -1):
	if _id == -1:
		id = self.get_instance_id()
	else:
		id = _id
	map = MapData.new()
	_generate_nav()

func add_enemy(enemy: EnemyData):
	enemies[enemy.get_instance_id()] = enemy

func remove_enemy(eid: int):
	enemies.erase(eid)
	
func add_player(pid: int):
	if not player_ids.has(pid):
		player_ids.append(pid)
		
func remove_player(pid: int):
	player_ids.erase(pid)

func deserialize(zone: Dictionary):
	id = zone.id
	map.deserialize(zone.map)
	_generate_nav()
	
	enemies.clear()
	for enemy in zone.enemies:
		enemies[enemy.id] = EnemyData.new()
		enemies[enemy.id].deserialize(enemy)
		
	player_ids = zone.players

func serialize():
	var enemy_data = []
	for enemy in enemies.values():
		enemy_data.append(enemy.serialize())
	
#   TODO: Add interactable data class
#	var interactable_data = []
#	for interactable in interactables.values():
#		interactable_data.append(interactable.serialize())
		
	return {
		"id": id,
		"map": map.serialize(),
		"enemies": enemy_data,
		"players": player_ids,
	}

func _map_changed(new_map):
	map = new_map
	_generate_nav()

func _generate_nav():
	nav.clear()
	
	for x in range(map.size.x):
		for y in range(map.size.y):
			nav.add_point(x + y * map.size.x, Vector2(x, y))
	
	# TODO: Fix later lol
	# specifically, check if points exist and are not already connected
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
