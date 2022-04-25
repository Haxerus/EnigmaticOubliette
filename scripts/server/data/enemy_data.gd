extends Reference

class_name EnemyData

var id
var zone_id

var data = {}

func _init():
	id = self.get_instance_id()
	zone_id = -1
	data = DataDefaults.enemy_stats.default.duplicate(true)

func serialize():
	return {
		"id": id,
		"zone_id": zone_id,
		"data": data,
	}
