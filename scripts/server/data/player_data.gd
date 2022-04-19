extends Reference

class_name PlayerData

var id
var zone_id

var data = {}

func _init(pid: int, zid: int):
	id = pid
	zone_id = zid
	
	data = DataDefaults.player_stats.default
	data.name = str(id)

func serialize():
	return {
		"id": id,
		"zone_id": zone_id,
		"data": data,
	}
