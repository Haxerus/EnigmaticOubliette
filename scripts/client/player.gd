extends Sprite

export var anim_speed = 1 / 8.0

var data = PlayerData.new(-1, -1) setget _data_changed

signal player_move_complete

func _ready():
	data.position = Vector2(3, 3)
	position = Utils.tile_to_pos(data.position)

func move_path(tile_path):
	for t in tile_path:
		_move_to_tile(t)
		yield($Tween, "tween_completed")
	emit_signal("player_move_complete")

func set_tile_position(t_pos: Vector2):
	position = Utils.tile_to_pos(t_pos)
	
func _data_changed(new_data: Dictionary):
	data.deserialize(new_data)

func _move_to(target: Vector2):
	match position.direction_to(target):
		Vector2(0, 1):
			frame = 0
		Vector2(-1, 0):
			frame = 1
		Vector2(0, -1):
			frame = 2
		Vector2(1, 0):
			frame = 3
	$Tween.interpolate_property(self, "position", position, target, anim_speed)
	$Tween.start()
	
func _move_to_tile(target_tile: Vector2):
	var target = target_tile * 16 + Vector2(8, 8)
	_move_to(target)

func get_tile() -> Vector2:
	return data.position
