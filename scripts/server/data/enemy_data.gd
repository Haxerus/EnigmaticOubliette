extends Reference

class_name EnemyData

var id

var data = {}

func _init():
	id = self.get_instance_id()
	data = DataDefaults.enemy_stats.default

func serialize():
	return {
		"id": id,
		"data": data,
	}
