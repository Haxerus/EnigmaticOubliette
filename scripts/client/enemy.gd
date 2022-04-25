extends Sprite

export var anim_speed = 1 / 32.0

var max_health
var health setget _health_changed

signal enemy_move_complete

func _ready():
	pass

func move_path(tile_path):
	for t in tile_path:
		_move_to_tile(t)
		yield($Tween, "tween_completed")
	emit_signal("enemy_move_complete")

func set_tile_position(t_pos: Vector2):
	position = Utils.tile_to_pos(t_pos)

func _move_to(target: Vector2):
#	match position.direction_to(target):
#		Vector2(0, 1):
#			frame = 1
#		Vector2(1, 0):
#			frame = 0
	$Tween.interpolate_property(self, "position", position, target, anim_speed)
	$Tween.start()
	
func _move_to_tile(target_tile: Vector2):
	var target = Utils.tile_to_pos(target_tile)
	_move_to(target)

func _health_changed(new_value):
	health = new_value
	if health < 0:
		hide()
		health = 0
	$HealthBar.rect_scale.x = float(health) / float(max_health)
