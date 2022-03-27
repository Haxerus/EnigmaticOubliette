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
	$Tween.interpolate_property(self, "position", position, target, 0.5)
	$Tween.start()

func _process(_delta):
	tile.x = floor(position.x / 16)
	tile.y = floor(position.y / 16)
