extends Node

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

onready var pid = get_tree().get_network_unique_id()

var player = preload("res://scenes/player.tscn").instance()

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

signal input_state_changed(state)

func _ready():
	player.get_node("Camera").make_current()
	$Zone/Players.add_child(player)
	
	Multiplayer.connect("player_updated", self, "_on_player_updated")
	Multiplayer.connect("zone_updated", self, "_on_zone_updated")
	
	player.connect("player_move_complete", self, "_on_player_move_complete")

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

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
		var mouse_tid = Utils.tile_id(mouse_tile, $Zone.map_size().x)
		var valid_point = Utils.in_bounds(mouse_tile, $Zone.map_size()) and $Zone.get_nav().has_point(mouse_tid)
		
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					if valid_point:
						var turn = ceil((Utils.tile_dist(player.get_tile(), mouse_tile) + 1) / 2)

						action = {
							"type": "attack",
							"target": mouse_tid,
						}

						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()
				MOVE:
					if valid_point:
						var turn = ceil(Utils.tile_dist(player.get_tile(), mouse_tile) / 2)

						action = {
							"type": "move",
							"target": mouse_tid,
						}

						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()

# HUD functions
func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = MOVE
		emit_signal("input_state_changed", input_state)
		
		$Zone/HighlightTile.hide()
		action.clear()
		
		$Zone/TileOverlay.clear()
		_update_overlay_tiles(1)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv($Zone.get_nav().get_point_position(t), 1)
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
		_update_overlay_tiles(1)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv($Zone.get_nav().get_point_position(t), 2)
	else:
		input_state = NEUTRAL
		emit_signal("input_state_changed", input_state)

func _on_EndTurnButton_pressed():
	if not action.empty():
		Multiplayer.send_action(action)
		
		if action["type"] != "attack":
			input_state = LOCKED
		
		action = {}
			
		emit_signal("input_state_changed", input_state)

func _on_player_move_complete():
	input_state = NEUTRAL
	emit_signal("input_state_changed", input_state)

# Multiplayer Linked Functions
func _on_player_updated(data: Dictionary):
	player.data = data
	
func _on_zone_updated(data: Dictionary):
	$Zone.zone = data
	
# Utility
func _update_overlay_tiles(dist):
	var player_tid = player.get_tile().x + player.get_tile().y * $Zone.map_size().x
	overlay_tiles = Utils.bfs_range($Zone.get_nav(), player_tid, dist)

func _execute_player_path(id, path):
	var tile_path = []
	for p in path:
		tile_path.append($Zone.get_nav().get_point_position(p))
	
	if int(id) == int(pid):
		player.move_path(tile_path)
	else:
		var remote_player = get_node("Zone/Players/"+str(id))
		remote_player.move_path(tile_path)
