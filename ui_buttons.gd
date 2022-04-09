extends Control

enum {NEUTRAL, ATTACK, MOVE, LOCKED}

func _on_input_state_changed(state):
	match state:
		NEUTRAL:
			$AttackButton.disabled = false
			$AttackButton.set_pressed_no_signal(false)
			
			$MoveButton.disabled = false
			$MoveButton.set_pressed_no_signal(false)
		ATTACK:
			$MoveButton.set_pressed_no_signal(false)
		MOVE:
			$AttackButton.set_pressed_no_signal(false)
		LOCKED:
			$AttackButton.disabled = true
			$MoveButton.disabled = true
