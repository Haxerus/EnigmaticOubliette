extends Button

enum {NEUTRAL, ACTION, MOVEMENT, LOCKED}

export var hotkey: String setget _update_hotkey
export var action_icon: Texture setget _update_icon

onready var default_pos = rect_position
var ascended = false

func _ready():
	if not hotkey.empty():
		_update_hotkey(hotkey)
	
	if action_icon:
		_update_icon(action_icon)
		
	group.connect("pressed", self, "_on_group_pressed")			

func _update_icon(new_icon: Texture):
	action_icon = new_icon
	$Icon.texture = new_icon

func _update_hotkey(new_key: String):
	hotkey = new_key
	$HotkeyFrame/Label.text = new_key.to_upper()

func _on_group_pressed(button):
	if button == self:
		#$Frame.modulate = Color(0, 1, 0)
		#$Icon.modulate = Color(0.35, 0.35, 0.35)
		if not ascended:
			rect_position.y -= 8
			ascended = true
	else:
		$Icon.modulate = Color(1, 1, 1)
		rect_position = default_pos
		ascended = false

func _on_Client_input_state_changed(new_state):
	if new_state == NEUTRAL:
		disabled = false
		pressed = false
		$Icon.modulate = Color(1, 1, 1)
		rect_position = default_pos
		ascended = false
	if new_state == LOCKED:
		disabled = true
		$Icon.modulate = Color(0.15, 0.15, 0.15)
		rect_position = default_pos
		ascended = false
