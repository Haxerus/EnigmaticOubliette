extends Node

func _ready():
	if "--server" in OS.get_cmdline_args():
		get_tree().change_scene("res://server.tscn")
	else:
		get_tree().change_scene("res://lobby.tscn")
