extends Sprite

var player_name = "name"
var tile = Vector2()

onready var player_camera = get_node("PlayerCamera")
onready var tween = get_node("Tween")
onready var name_label = get_node("Name")

func move_to_tile(target_tile):
	var target = target_tile * 16 + Vector2(8, 8)
	_move_to(target)

func _ready():
	player_camera.make_current()
	name_label.text = player_name

func _move_to(target):
	tween.interpolate_property(self, "position", position, target, 0.5)
	tween.start()

func _process(delta):
	tile.x = floor(position.x / 16)
	tile.y = floor(position.y / 16)
