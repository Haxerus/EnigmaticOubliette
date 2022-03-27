extends Node

enum {NEUTRAL, ATTACK, MOVE}

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

var map

signal input_state_changed(state)

func _ready():
	var zone = load("res://zone.tscn").instance()
	var map_gen =  MapGenerator.new()
	map = zone.get_node("Map")
	
	map_gen.generate_map(Vector2(10, 10), Vector2(20, 20), map)
	map.generate_nav_map()
	
	var spawn = Vector2()
	spawn.x = floor(map.size.x / 2)
	spawn.y = floor(map.size.y / 2)
	$Player.position = Utils.tile_to_pos(spawn)
	
	add_child_below_node($HUDLayer, zone)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					var mouse_tid = mouse_tile.x + mouse_tile.y * map.size.x
					var turn = Utils.tile_dist($Player.tile, mouse_tile) / $PlayerStats.move_range
					
					$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
					$Zone/HighlightTile/Turn.text = str(ceil(turn))
					$Zone/HighlightTile.show()
				MOVE:
					var mouse_tid = mouse_tile.x + mouse_tile.y * map.size.x
					var turn = Utils.tile_dist($Player.tile, mouse_tile) / $PlayerStats.move_range
					
					action = {
						"type": "move",
						"target": mouse_tid,
					}
					
					$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
					$Zone/HighlightTile/Turn.text = str(ceil(turn))
					$Zone/HighlightTile.show()

func _process(_delta):
	#var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
	
	if action.empty():
		$HUDLayer/HUD/EndTurnButton.disabled = true
	else:
		$HUDLayer/HUD/EndTurnButton.disabled = false
	
	match input_state:
		NEUTRAL:
			$Zone/TileOverlay.clear()
			$Zone/HighlightTile.hide()
			action.clear()
		ATTACK:
			pass
		MOVE:
			pass
				

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = MOVE
		emit_signal("input_state_changed", input_state)
		
		_update_overlay_tiles($PlayerStats.move_range)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(map.nav_map.get_point_position(t), 1)
	else:
		input_state = NEUTRAL
		emit_signal("input_state_changed", input_state)

func _on_AttackButton_toggled(button_pressed):
	if button_pressed:
		input_state = ATTACK
		emit_signal("input_state_changed", input_state)
		
		_update_overlay_tiles($PlayerStats.attack_range)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(map.nav_map.get_point_position(t), 2)
	else:
		input_state = NEUTRAL
		emit_signal("input_state_changed", input_state)

func _on_EndTurnButton_pressed():
	if not action.empty():
		match action["type"]:
			"move":
				var path = map.nav_map.get_id_path($Player.get_tid(map.size.x), action["target"])
				path.remove(0)
				_execute_player_path(path)
				action = {}
				input_state = NEUTRAL
				emit_signal("input_state_changed", input_state)
			_:
				print("what?")

func _update_overlay_tiles(dist):
	var player_tid = $Player.tile.x + $Player.tile.y * map.size.x
	overlay_tiles = Utils.bfs_range(map.nav_map, player_tid, dist)
	
func _execute_player_path(path):
	for p in path:
		var tile = map.nav_map.get_point_position(p)
		$Player.move_to_tile(tile)
		yield($Player/Tween, "tween_completed")
