extends Reference

# It is the Turn Engine's job to collect all actions in a given turn
# determine their order and play them out, keeping track of the outcomes
# as a list of steps. Data should be updated after every determinable atomic action

var actions = []

func add_action(action: Dictionary):
	pass

# Run all actions in sequence
func execute_turn():
	pass
