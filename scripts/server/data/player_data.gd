extends Reference

class_name PlayerData

var id
var zone_id

var position = Vector2()
var data = {}

func _init(pid: int, zid: int):
	id = pid
	zone_id = zid
	
	data = DataDefaults.player_stats.default
	data.name = str(id)
	
func deserialize(player: Dictionary):
	id = player.id
	zone_id = player.zone_id
	position = player.position
	data = player.data

func serialize():
	var output = {
		"id": id,
		"zone_id": zone_id,
		"position": position,
		"data": data,
	}
