extends Node

var zones = {}
var players = {}
var enemies = {}

puppet func updated_players(p_list):
	pass
	
puppet func load_player(data: Dictionary):
	if players.has(data.id):
		return
	
	var player = PlayerData.new(data.id, data.zone_id)
	player.data = data.data
	
	players[data.id] = player
	
puppet func load_enemy(data: Dictionary):
	if enemies.has(data.id):
		return
	
	var enemy = EnemyData.new()
	enemy.data = data.data
	
	enemies[data.id] = enemy
	
puppet func load_zone(data: Dictionary):	
	var zone = ZoneData.new()
	var map = MapData.new()
	if zones.has("current"):
		zone = zones.current
		map = zone.map
	else:
		zones.current = zone
	
	zone.id = data.id
	zone.map.size = data.map.size
	zone.map.tiles = data.map.tiles
	zone.enemies = data.enemies
	zone.players = data.players

puppet func player_changed_zone(id: int, zid: int):
	players[id].zone_id = zid
	if zones.current.id == zid:
		zones.current.add_player(id)
	else:
		zones.current.remove_player(id)

remote func add_player(id: int):
	players[id] = PlayerData.new(id, -1)
	
	if get_tree().is_network_server():
		rpc("add_player", id)
		
remote func update_player(id: int, data: Dictionary):
	for key in data.keys():
		players[id].data[key] = data[key]
		
	if get_tree().is_network_server():
		rpc("update_player", id, data)

remote func remove_player(id: int):
	if get_tree().is_network_server():
		var zid = players[id].zone_id
		zones[zid].remove_player(id)
		players.erase(id)
	
		rpc("remove_player", id)
	else:
		zones.current.remove_player(id)
		players.erase(id)

func add_player_to_zone(pid: int, zid: int):
	var old = players[pid].zone_id
	if old != -1:
		zones[old].remove_player(pid)
	zones[zid].add_player(pid)
	players[pid].zone_id = zid
	
	rpc_id(pid, "load_zone", zones[zid].serialize())
	rpc("player_changed_zone", pid, zid)

func send_existing_entities(receiver):
	for player in players.values():
		if player.id != receiver:
			rpc_id(receiver, "load_player", player.serialize())
	
	for enemy in enemies.values():
		rpc_id(receiver, "load_enemy", enemy.serialize())

func sync_players():
	var packet = []
	for player in players.values():
		packet.append(player.serialize())
	
	rpc("updated_players", packet)
	
func add_zone(zid: int = -1):
	var zone = ZoneData.new()
	if zid != -1:
		zone.id = zid
	zones[zone.id] = zone

func remove_zone(id: int):
	zones.erase(id)

func set_zone_map(id: int, map: MapData):
	zones[id].map = map

remote func add_enemy(zid: int, eid: int = -1):
	var enemy = EnemyData.new()
	if eid != -1:
		enemy.id = eid
	enemy.zone_id = zid
	enemies[enemy.id] = enemy
	
	if get_tree().is_network_server():
		rpc("add_enemy", zid, enemy.id)
		zones[zid].add_enemy(enemy.id)
	else:
		if zones.current.id == zid:
			zones.current.add_enemy(enemy.id)
			
	return enemy.id
			
remote func remove_enemy(id: int):
	if get_tree().is_network_server():
		var zid = enemies[id].zone_id
		zones[zid].remove_enemy(id)
		enemies.erase(id)
	
		rpc("remove_enemy", id)
	else:
		zones.current.remove_enemy(id)
		enemies.erase(id)
		
remote func update_enemy(id: int, data: Dictionary):
	for key in data.keys():
		enemies[id].data[key] = data[key]
		
	if get_tree().is_network_server():
		rpc("update_enemy", id, data)
