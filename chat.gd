extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_text_entered(new_text):
	if new_text != "": 
		$Edit.clear()
		$Text.add_text("<player name> ")
		$Text.add_text(new_text)
		$Text.add_text('\n')
