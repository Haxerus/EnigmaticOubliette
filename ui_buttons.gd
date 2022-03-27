extends Control

enum {NEUTRAL, ATTACK, MOVE}

func _ready():
	pass
	#connect("input_state_changed", self, "_on_input_state_changed")

func _on_input_state_changed(state):
	match state:
		NEUTRAL:
			$AttackButton.disabled = false
			$AttackButton.pressed = false
			
			$MoveButton.disabled = false
			$MoveButton.pressed = false
		ATTACK:
			$MoveButton.disabled = true
		MOVE:
			$AttackButton.disabled = true
