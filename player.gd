extends Sprite

var player_name = "name"
var tile = Vector2()

func move_to_tile(target_tile):
	var target = target_tile * 16 + Vector2(8, 8)
	_move_to(target)

func _ready():
	$PlayerCamera.make_current()
	$Name.text = player_name

func _move_to(target):
	print(position.direction_to(target))
	match position.direction_to(target):
		Vector2(0, 1):
			frame = 0
		Vector2(-1, 0):
			frame = 1
		Vector2(0, -1):
			frame = 2
		Vector2(1, 0):
			frame = 3
	$Tween.interpolate_property(self, "position", position, target, 0.25)
	$Tween.start()

func _process(_delta):
	tile.x = floor(position.x / 16)
	tile.y = floor(position.y / 16)

func get_tid(width):
	return tile.x + tile.y * width
