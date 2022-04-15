extends Reference

class_name PlayerData

var data = {}

func register_player(id):
	data[id] = {
		"position": Vector2(0, 0),
		"move_range": 2,
		"attack_range": 1,
	}
	
func unregister_player(id):
	if data.has(id):
		data.erase(id)

func update_attribute(id, attr, value):
	if data.has(id) and data[id].has(attr):
		data[id][attr] = value

func get_attribute(id, attr):
	if data.has(id) and data[id].has(attr):
		return data[id][attr]

func get_data(id):
	return data[id]

func get_all_data():
	return data
