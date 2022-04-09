extends Node

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

onready var map = get_node("Zone/Map")
onready var player = get_node("Zone/Players/Player")

signal input_state_changed(state)

func _ready():
	player.connect("player_move_complete", self, "_on_player_move_complete")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
		var mouse_tid = Utils.tile_id(mouse_tile, map.size.x)
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					if Utils.in_bounds(mouse_tile, map.size) and map.nav.has_point(mouse_tid):
						var turn = ceil((Utils.tile_dist(player.tile, mouse_tile) + 1) / 2)
						
						action = {
							"type": "attack",
							"target": mouse_tid,
						}
						
						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()
				MOVE:
					if Utils.in_bounds(mouse_tile, map.size) and map.nav.has_point(mouse_tid):
						var turn = ceil(Utils.tile_dist(player.tile, mouse_tile) / 2)
						
						action = {
							"type": "move",
							"target": mouse_tid,
						}
						
						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()

func _process(_delta):
	if action.empty():
		$HUDLayer/HUD/EndTurnButton.disabled = true
	else:
		$HUDLayer/HUD/EndTurnButton.disabled = false
	
	match input_state:
		ATTACK:
			pass
		MOVE:
			pass
		_:
			$Zone/TileOverlay.clear()
			$Zone/HighlightTile.hide()
			action.clear()

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = MOVE
		emit_signal("input_state_changed", input_state)
		
		$Zone/HighlightTile.hide()
		action.clear()
		
		$Zone/TileOverlay.clear()
		_update_overlay_tiles(2)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(map.nav.get_point_position(t), 1)
	else:
		input_state = NEUTRAL
		emit_signal("input_state_changed", input_state)

func _on_AttackButton_toggled(button_pressed):
	if button_pressed:
		input_state = ATTACK
		emit_signal("input_state_changed", input_state)
		
		$Zone/HighlightTile.hide()
		action.clear()
		
		$Zone/TileOverlay.clear()
		_update_overlay_tiles(2)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(map.nav.get_point_position(t), 2)
	else:
		input_state = NEUTRAL
		emit_signal("input_state_changed", input_state)

func _on_EndTurnButton_pressed():
	if not action.empty():
		match action["type"]:
			"move":
				var path = map.nav.get_id_path(player.get_tid(map.size.x), action["target"])
				_execute_player_path(path)
				action = {}
				input_state = LOCKED
				emit_signal("input_state_changed", input_state)
			_:
				pass

func _on_player_move_complete():
	input_state = NEUTRAL
	emit_signal("input_state_changed", input_state)

func _update_overlay_tiles(dist):
	var player_tid = player.tile.x + player.tile.y * map.size.x
	overlay_tiles = Utils.bfs_range(map.nav, player_tid, dist)	

func _execute_player_path(path):
	var tile_path = []
	path.remove(0)
	for p in path:
		tile_path.append(map.nav.get_point_position(p))
	player.move_path(tile_path)
