extends Reference

class_name TurnEngine

# It is the Turn Engine's job to collect all actions in a given turn
# determine their order and play them out, keeping track of the outcomes
# as a list of steps. Data should be updated after every determinable atomic action

# Turns are executed in two phases, player phase and enemy phase

var ready = []
var actions = []

var running = false

# Run all actions in sequence
func execute_turn():
	running = true
	var outcome = []
	
	for enemy in GameData.enemies.values():
		var zone = GameData.zones[enemy.zone_id]
		var e_act = {}
		
		e_act.movement = {
			"from": Utils.tile_id(enemy.data.position, zone.map.size.x),
			"to": _move_tile(enemy.data.position, 5, zone),
		}
		
		e_act.action = {
			"target": null,
			"slot": null,
		}
		
		e_act.id = enemy.id
		e_act.is_player = false
		
		actions.append(e_act)
		
	for action_obj in actions:
		var movement = action_obj.movement
		var action = action_obj.action
		var id = action_obj.id
		
		# do movement first
		if movement.to != null and movement.from != null:
			if action_obj.is_player:
				var zone = GameData.zones[GameData.players[id].zone_id]
				
				GameData.update_player(id, {"position": Utils.id_tile(movement.to, zone.map.size.x)})
				
				var path = zone.nav.get_point_path(movement.from, movement.to)
				path.remove(0)
				
				outcome.append({
					"type": "player_move",
					"id": id,
					"path": path,
				})
			else:
				var zone = GameData.zones[GameData.enemies[id].zone_id]
				
				GameData.update_enemy(id, {"position": Utils.id_tile(movement.to, zone.map.size.x)})
				
				var path = zone.nav.get_point_path(movement.from, movement.to)
				path.remove(0)
				
				outcome.append({
					"type": "enemy_move",
					"id": id,
					"path": path,
				})
		
		# then attacks	
		if action.target != null and action.slot != null:
			if action_obj.is_player:
				# TODO: Add attack logic
				
				outcome.append({
					"type": "attack_anim",
					"name": "slash",
					"target": action.target,
				})

	ready.clear()
	actions.clear()
	
	Multiplayer.send_turn_outcome(outcome)
	running = false

func turn_is_ready():
	if GameData.players.empty():
		return false
	
	if running:
		return false
	
	for i in GameData.players.keys():
		if not ready.has(i):
			return false
	
	return true

func _on_action_received(action: Dictionary):
	if not ready.has(action.id):
		ready.append(action.id)
	
	action.is_player = true
	actions.append(action)
	
func _on_player_left(id: int):
	ready.erase(id)

# REMOVE LATER
func _move_tile(start, dist, zone):
	var start_tid = Utils.tile_id(start, zone.map.size.x)
	var tiles = Utils.bfs_range(zone.nav, start_tid, dist)
	var i = randi() % len(tiles)
	return tiles[i]
