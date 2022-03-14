extends Sprite

var target = null setget set_target
export var speed = 80

signal move_finished

func _ready():
	$PlayerCamera.make_current()

func _process(delta):
	if target != null:
		var velocity = position.direction_to(target) * speed
		
		if position.distance_to(target) > 1:
			position += velocity * delta
		else:
			position = target
			target = null
			emit_signal("move_finished")

func set_target(new_target):
	target = new_target
	match position.direction_to(target):
			Vector2(0, 1):
				set_frame(0)
			Vector2(-1, 0):
				set_frame(1)
			Vector2(0, -1):
				set_frame(2)
			Vector2(1, 0):
				set_frame(3)
	
