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

func send_existing_players(receiver):
	for player in players.values():
		if player.id != receiver:
			rpc_id(receiver, "load_player", player.serialize())

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
