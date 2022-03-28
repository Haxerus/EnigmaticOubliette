extends Node

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

var map
var player

signal input_state_changed(state)

func _ready():
	var zone = load("res://zone.tscn").instance()
	var map_gen =  MapGenerator.new()
	map = zone.get_node("Map")
	
	map_gen.generate_map(Vector2(5, 5), Vector2(9, 9), map)
	map.generate_nav()
	
	player = load("res://player.tscn").instance()
	player.connect("player_move_complete", self, "_on_player_move_complete")
	
	var spawn = Vector2()
	spawn.x = floor(map.size.x / 2)
	spawn.y = floor(map.size.y / 2)
	player.position = Utils.tile_to_pos(spawn)
	zone.get_node("Players").add_child(player)
	
	add_child_below_node($HUDLayer, zone)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
		var mouse_tid = Utils.tile_id(mouse_tile, map.size.x)
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					if Utils.in_bounds(mouse_tile, map.size) and map.nav.has_point(mouse_tid):
						print(mouse_tile)
						var turn = ceil((Utils.tile_dist(player.tile, mouse_tile) + 1) / $PlayerStats.move_range)
						
						action = {
							"type": "attack",
							"target": mouse_tid,
						}
						
						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()
				MOVE:
					if Utils.in_bounds(mouse_tile, map.size) and map.nav.has_point(mouse_tid):		
						print(mouse_tile)				
						var turn = ceil(Utils.tile_dist(player.tile, mouse_tile) / $PlayerStats.move_range)
						
						action = {
							"type": "move",
							"target": mouse_tid,
						}
						
						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()

func _process(_delta):
	#var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
	
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
		_update_overlay_tiles($PlayerStats.move_range)
		
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
		_update_overlay_tiles($PlayerStats.attack_range)
		
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
