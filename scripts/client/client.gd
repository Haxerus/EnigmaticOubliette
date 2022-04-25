extends Node

# Input States
enum {NEUTRAL, ACTION, MOVEMENT, LOCKED}

# Action Button IDs
enum {MOVE, BASIC, ACTION1, ACTION2, ACTION3, ACTION4}

onready var pid = get_tree().get_network_unique_id()

onready var player_data = GameData.players[pid].data
onready var zone_data = GameData.zones.current

var player_scene = preload("res://scenes/player.tscn")
var attack_anim = preload("res://scenes/attack_animation.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")

var ghost = player_scene.instance()
var player = null

var remote_players = {}
var enemies = {}

var planned_tile = null
var animating = false

var input_state
var last_pressed_action

var overlay_tiles = []

# Probably make real classes for these
var movement = {
	"from": null,
	"to": null,
}

var action = {
	"target": null,
	"slot": null,
}

signal attack_anim_finished
signal input_state_changed(new_state)

func _debug_print():
#	for id in GameData.players:
#		print(GameData.players[id].serialize())
	pass

func _ready():
	_update_input_state(NEUTRAL)
	
	for id in GameData.players:
		_add_player(id)
	
	for id in GameData.enemies:
		_add_enemy(id)
	
	player.get_node("Camera").make_current()
	
	ghost.modulate = Color(1, 1, 1, 0.5)
	ghost.hide()
	$Zone/Players.add_child(ghost)
	
	$Zone/PlannedPos.position = Utils.tile_to_pos(Vector2(30, 15))
	
	$DebugTimer.connect("timeout", self, "_debug_print")
	player.connect("player_move_complete", self, "_on_player_move_complete")
	ghost.connect("player_move_complete", self, "_on_ghost_move_complete")
	Multiplayer.connect("outcome_received", self, "_on_outcome_received")
	Multiplayer.connect("game_event", self, "_on_game_event")

func _process(delta):
	$HUDLayer/HUD/PlayerPos.text = str(Utils.pos_to_tile(player.position))
	$HUDLayer/HUD/PlayerStoredPos.text = str(player_data.position)
	
	$HUDLayer/HUD/Movement.text = str(movement)
	$HUDLayer/HUD/Action.text = str(action)
	
	player.get_node("Nametag").text = player_data.name
	
	for p in remote_players:
		var id = int(remote_players[p].name)
		remote_players[p].get_node("Nametag").text = GameData.players[id].data.name
	
# HUD functions
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if input_state != LOCKED:
				_update_input_state(NEUTRAL)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			
			var mouse_tile = Utils.pos_to_tile($Zone.get_global_mouse_position())
			var mouse_tid = Utils.tile_id(mouse_tile, zone_data.map.size.x)
			var valid_point = Utils.in_bounds(mouse_tile, zone_data.map.size) and zone_data.nav.has_point(mouse_tid)
			
			if mouse_tid in overlay_tiles:
				match input_state:
					MOVEMENT:
						if valid_point and not animating:
							movement.to = mouse_tid
							planned_tile = mouse_tile
							var path = zone_data.nav.get_point_path(
									Utils.tile_id(player_data.position,
									zone_data.map.size.x
								), mouse_tid)
							path.remove(0)
							
							$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
							$Zone/HighlightTile.show()
							
#							player.set_tile_position(player_data.position)
#							player.move_path(path)
							
							ghost.set_tile_position(player_data.position)
							ghost.show()
							ghost.move_path(path)
							animating = true
					ACTION:
						if valid_point:
							action.target = mouse_tid
							
							$Zone/HighlightTile.position = Utils.tile_to_pos(mouse_tile)
							$Zone/HighlightTile.show()

func _on_EndTurnButton_pressed():
	Multiplayer.send_action({"movement": movement, "action": action, "id": pid})
	_update_input_state(LOCKED)

func _on_ActionButton_toggled(pressed: bool, button: int):
	if not pressed:
		return
	
	if button > 1:
		#_update_input_state(NEUTRAL)
		return
	
	match button:
		MOVE:
			if input_state != MOVEMENT:
				_update_input_state(MOVEMENT)
		_:
			action.slot = button
			if input_state != ACTION:
				_update_input_state(ACTION)

# Multiplayer Linked Functions
func _on_outcome_received(outcome):
	for n in outcome:
		match n:
			{"type": "player_move", "id": var id, "path": var path}:
				if id == pid:
					# Local player
					player.move_path(path)
					yield(player, "player_move_complete")
				else:
					remote_players[id].move_path(path)
					yield(remote_players[id], "player_move_complete")
			{"type": "attack_anim", "name": var anim_name, "target": var target}:
				_create_and_play(anim_name, target)
				yield(self, "attack_anim_finished")
			{"type": "enemy_move", "id": var id, "path": var path}:
				enemies[id].move_path(path)
				yield(enemies[id], "enemy_move_complete")
	
	_update_input_state(NEUTRAL)
	
func _on_game_event(event: Dictionary):
	match event:
		{"type": "player_joined", "id": var id}:
			if id != pid:
				_add_player(id)
		{"type": "player_left", "id": var id}:
			if id != pid and remote_players.has(id):
				remote_players[id].queue_free()
				remote_players.erase(id)
		{"type": "enemy_spawned", "id": var id}:
			_add_enemy(id)
		{"type": "enemy_removed", "id": var id}:
			if enemies.has(id):
				enemies[id].queue_free()
				enemies.erase(id)

# Utility
func _update_input_state(new_state):
	$Zone/HighlightTile.hide()
	
	match new_state:
		NEUTRAL:
			_reset_action()
			planned_tile = null
			ghost.hide()
			$Zone/TileOverlay.hide()
			overlay_tiles.clear()
			$HUDLayer/HUD/EndTurnButton.disabled = false
		MOVEMENT:
			# Show player movement tiles
			_reset_action()
			
			movement.from = Utils.tile_id(
								player_data.position,
								zone_data.map.size.x
							)
			
			ghost.hide()
			planned_tile = null
			
			_update_overlay_tiles(player_data.movement)
			_show_overlay_tiles(1)
		ACTION:
			# Show player action tiles
			_update_overlay_tiles(player_data.attack_range)
			_show_overlay_tiles(2)
		LOCKED:
			_reset_action()
			player.set_tile_position(player_data.position)
			planned_tile = null
			ghost.hide()
			$Zone/TileOverlay.hide()
			overlay_tiles.clear()
			$HUDLayer/HUD/EndTurnButton.disabled = true
	
	input_state = new_state
	emit_signal("input_state_changed", new_state)

func _on_ghost_move_complete():
	animating = false
	
func _on_player_move_complete():
	pass
	
func _add_player(id: int):
	var new_player = player_scene.instance()
	new_player.name = str(id)
	new_player.set_tile_position(GameData.players[id].data.position)
	
	if id == pid:
		player = new_player
	else:
		remote_players[id] = new_player
	
	$Zone/Players.add_child(new_player)
	
func _add_enemy(id: int):
	var enemy = enemy_scene.instance()
	enemy.name = str(id)
	enemy.set_tile_position(GameData.enemies[id].data.position)
	enemy.max_health = GameData.enemies[id].data.max_health
	enemy.health = GameData.enemies[id].data.health
	enemies[id] = enemy
	$Zone/Enemies.add_child(enemy)

func _create_and_play(anim_name, target):
	var anim = attack_anim.instance()
	var tile = Utils.id_tile(target, zone_data.map.size.x)
	anim.position = Utils.tile_to_pos(tile)
	$Zone.add_child(anim)
	anim.play(anim_name)
	yield(anim, "animation_finished")
	anim.queue_free()
	emit_signal("attack_anim_finished")

func _show_overlay_tiles(tile_type):
	$Zone/TileOverlay.clear()
	for t in overlay_tiles:
		var t_pos = zone_data.nav.get_point_position(t)
		$Zone/TileOverlay.set_cellv(t_pos, tile_type)
	$Zone/TileOverlay.show()

func _update_overlay_tiles(dist):
	var start = player_data.position
	if planned_tile != null:
		start = planned_tile
	
	var start_tid = Utils.tile_id(start, zone_data.map.size.x)
	overlay_tiles = Utils.bfs_range(zone_data.nav, start_tid, dist)

func _reset_action():
	movement.from = null
	movement.to = null
	action.target = null
	action.slot = null
