extends Control

func _on_AttackButton_toggled(button_pressed):
	if button_pressed:
		$MoveButton.disabled = true
		#$ItemsButton.disabled = true
	else:
		$MoveButton.disabled = false
		#$ItemsButton.disabled = false

func _on_MoveButton_toggled(button_pressed):
	if button_pressed:
		$AttackButton.disabled = true
		#$ItemsButton.disabled = true
	else:
		$AttackButton.disabled = false
		#$ItemsButton.disabled = false

func _on_ItemsButton_toggled(button_pressed):
	if button_pressed:
		$MoveButton.disabled = true
		$AttackButton.disabled = true
	else:
		$MoveButton.disabled = false
		$AttackButton.disabled = false
