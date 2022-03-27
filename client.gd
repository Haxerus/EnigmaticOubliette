extends Node

enum InputState {NEUTRAL, ATTACK, MOVE}

var input_state = InputState.NEUTRAL

func _process(delta):
	match input_state:
		InputState.NEUTRAL:
			$Zone/TileOverlay.clear()
		InputState.ATTACK:
			$Zone/TileOverlay.set_cellv(Vector2(5, 5), 2)
		InputState.MOVE:
			$Zone/TileOverlay.set_cellv(Vector2(5, 5), 1)

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		input_state = InputState.MOVE
	else:
		input_state = InputState.NEUTRAL

func _on_AttackButton_toggled(button_pressed):
	if button_pressed:
		input_state = InputState.ATTACK
	else:
		input_state = InputState.NEUTRAL
