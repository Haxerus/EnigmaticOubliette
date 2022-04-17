extends Node2D

var data = ZoneData.new() setget _data_changed

func _ready():
	pass

func _data_changed(new_data: Dictionary):
	data.deserialize(new_data)

func map_size() -> Vector2:
	return data.map.size

func get_nav() -> AStar2D:
	return data.nav
