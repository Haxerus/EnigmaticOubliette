extends Node

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

onready var pid = get_tree().get_network_unique_id()
onready var map = get_node("Zone/Map")

var player = preload("res://player.tscn").instance()

var input_state = NEUTRAL

var overlay_tiles = []
var action = {}

signal input_state_changed(state)

func _ready():
	player.get_node("Camera").make_current()
	$Zone/Players.add_child(player)
	$PlayerData.register_player(pid)
	
	player.connect("player_move_complete", self, "_on_player_move_complete")
	
	Multiplayer.connect("action_results", self, "_on_action_results")
	Multiplayer.connect("map_sync", self, "_on_map_sync")
	Multiplayer.connect("player_sync", self, "_on_player_sync")
	Multiplayer.connect("force_update", self, "_on_force_update")

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
		var mouse_tid = Utils.tile_id(mouse_tile, map.size.x)
		if event.button_index == BUTTON_LEFT and event.pressed:
			match input_state:
				ATTACK:
					if map.in_bounds(mouse_tile) and map.nav.has_point(mouse_tid):
						var turn = ceil((Utils.tile_dist(player.tile, mouse_tile) + 1) / 2)
						
						action = {
							"type": "attack",
							"target": mouse_tid,
						}
						
						$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
						$Zone/HighlightTile/Turn.text = str(turn)
						$Zone/HighlightTile.show()
				MOVE:
					if map.in_bounds(mouse_tile) and map.nav.has_point(mouse_tid):
						var turn = ceil(Utils.tile_dist(player.tile, mouse_tile) / 2)
						
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
		_update_overlay_tiles($PlayerData.get_attribute(pid, "move_range"))
		
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
		_update_overlay_tiles($PlayerData.get_attribute(pid, "attack_range"))
		
		for t in overlay_tiles:
			$Zone/TileOverlay.set_cellv(map.nav.get_point_position(t), 2)
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
func _on_action_results(results):
	match results:
		{"path": var path, "id": var id, ..}:
			_execute_player_path(id, path)

func _on_force_update():
	player.set_tile_position($PlayerData.get_attribute(pid, "position"))
	

# Receives ALL player data
func _on_player_sync(data):
	for id in data:
		if int(id) == int(pid):
			match data[id]:
				{"position": var pos, ..}:
					$PlayerData.update_attribute(pid, "position", pos)
		else:
			if not has_node("Zone/Players/" + str(id)):
				var new_player = preload("res://player.tscn").instance()
				new_player.set_name(str(id))
				new_player.set_tile_position(data[id]["position"])
				$Zone/Players.add_child(new_player)
	
func _on_map_sync(data):
	print(data)
	var map_gen = MapGenerator.new()
	map_gen.generate_map(map, data)
	
# Utility

func _update_overlay_tiles(dist):
	var player_tid = player.tile.x + player.tile.y * map.size.x
	overlay_tiles = Utils.bfs_range(map.nav, player_tid, dist)

func _execute_player_path(id, path):
	var tile_path = []
	for p in path:
		tile_path.append(map.nav.get_point_position(p))
	
	if int(id) == int(pid):
		player.move_path(tile_path)
	else:
		var remote_player = get_node("Zone/Players/"+str(id))
		remote_player.move_path(tile_path)
