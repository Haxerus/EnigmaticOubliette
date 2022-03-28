extends Control

func _ready():
	if "--server" in OS.get_cmdline_args():
		get_tree().change_scene("res://server.tscn")
	else:
		show()


func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Join.disabled = true

	var player_name = $Connect/Name.text
	Multiplayer.join_game(ip, player_name)
