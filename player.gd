extends Sprite

export var anim_speed = 1 / 8.0
var tile = Vector2()

signal player_move_complete

func _ready():
	pass
	#$Camera.make_current()

func _move_to(target):
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
	
func _move_to_tile(target_tile):
	var target = target_tile * 16 + Vector2(8, 8)
	_move_to(target)
	
func move_path(tile_path):
	for t in tile_path:
		_move_to_tile(t)
		yield($Tween, "tween_completed")
	emit_signal("player_move_complete")

func _process(_delta):
	tile.x = floor(position.x / 16)
	tile.y = floor(position.y / 16)

func get_tid(width):
	return Utils.tile_id(tile, width)

func set_tile_position(tpos):
	position = Utils.tile_to_pos(tpos)
