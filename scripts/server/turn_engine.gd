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
		
		# then attacks	
		if action.target != null and action.slot != null:
			# add this later...
			pass

	ready.clear()
	actions.clear()
	
	Multiplayer.send_turn_outcome(outcome)
	running = false

func turn_is_ready():
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
