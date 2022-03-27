extends Node

enum InputState {NEUTRAL, ATTACK, MOVE}

var input_state = InputState.NEUTRAL

var overlay_tiles = []

func _ready():
	var zone = load("res://zone.tscn").instance()
	var map_gen =  MapGenerator.new()
	
	map_gen.generate_map(Vector2(10, 10), Vector2(20, 20), zone.get_node("Map"))
	zone.get_node("Map").generate_nav_map()
	
	add_child_below_node($HUDLayer, zone)

func _process(_delta):
	var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
	
	match input_state:
		InputState.NEUTRAL:
			$Zone/TileOverlay.clear()
		InputState.ATTACK:
			pass
		InputState.MOVE:
			pass

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = InputState.MOVE
		
		_update_overlay_tiles($PlayerStats.move_range)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv($Zone/Map.nav_map.get_point_position(t), 1)
	else:
		input_state = InputState.NEUTRAL

func _on_AttackButton_toggled(button_pressed):
	if button_pressed:
		input_state = InputState.ATTACK
		
		_update_overlay_tiles($PlayerStats.attack_range)
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv($Zone/Map.nav_map.get_point_position(t), 2)
	else:
		input_state = InputState.NEUTRAL

func _update_overlay_tiles(dist):
	var player_tid = $Player.tile.x + $Player.tile.y * $Zone/Map.map_size.x
	overlay_tiles = Utils.bfs_range($Zone/Map.nav_map, player_tid, dist)
