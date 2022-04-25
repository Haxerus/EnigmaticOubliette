extends Node

func _ready():
	randomize()
	
	if "--server" in OS.get_cmdline_args():
		get_tree().change_scene("res://scenes/server.tscn")
	else:
		get_tree().change_scene("res://scenes/lobby.tscn")
