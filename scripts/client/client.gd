extends Node

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

onready var pid = get_tree().get_network_unique_id()
onready var player_data = GameData.players[pid].data
onready var zone_data = GameData.zones.current

var player = preload("res://scenes/player.tscn").instance()

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

signal input_state_changed(state)

func _ready():
	player.get_node("Camera").make_current()
	player.position = Utils.tile_to_pos(player_data.position)
	$Zone/Players.add_child(player)
	
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

# HUD functions
func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
		var mouse_tid = Utils.tile_id(mouse_tile, zone_data.map.size.x)
		var valid_point = Utils.in_bounds(mouse_tile, zone_data.map.size) and zone_data.nav.has_point(mouse_tid)
		
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					if valid_point:
						var turn = ceil((Utils.tile_dist(player_data.position, mouse_tile) + 1) / 2)

						action = {
							"type": "attack",
							"target": mouse_tid,
						}

						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()
				MOVE:
					if valid_point:
						var turn = ceil(Utils.tile_dist(player_data.position, mouse_tile) / 2)

						action = {
							"type": "move",
							"target": mouse_tid,
						}

						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = MOVE
		emit_signal("input_state_changed", input_state)
		
		$Zone/HighlightTile.hide()
		action.clear()
		
		$Zone/TileOverlay.clear()
		_update_overlay_tiles(player_data.movement)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(zone_data.nav.get_point_position(t), 1)
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
		_update_overlay_tiles(player_data.attack_range)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(zone_data.nav.get_point_position(t), 2)
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
	
# Utility
func _update_overlay_tiles(dist):
	var player_pos = player_data.position
	var player_tid = player_pos.x + player_pos.y * zone_data.map.size.x
	overlay_tiles = Utils.bfs_range(zone_data.nav, player_tid, dist)

func _execute_player_path(id, path):
	var tile_path = []
	for p in path:
		tile_path.append(zone_data.nav.get_point_position(p))
	
	if int(id) == int(pid):
		player.move_path(tile_path)
	else:
		var remote_player = get_node("Zone/Players/"+str(id))
		remote_player.move_path(tile_path)
