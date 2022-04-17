extends Reference

class_name EnemyData

var id

var position = Vector2()
var data = {}

func _init(_id: int = -1):
	if _id == -1:
		id = self.get_instance_id()
	else:
		id = _id
	data = DataDefaults.enemy_stats.default

func deserialize(enemy: Dictionary):
	id = enemy.id
	position = enemy.position
	data = enemy.data

func serialize():
	var output = {
		"id": id,
		"position": position,
		"data": data,
	}
