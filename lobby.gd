extends Control

func _ready():
	Multiplayer.connect("connection_succeeded", self, "_on_connection_succeeded")
	Multiplayer.connect("connection_failed", self, "_on_connection_failed")

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
	Multiplayer.join_game(ip)

func _on_connection_succeeded():
	hide()
	$Connect/ErrorLabel.set_text("Connected to server.")

func _on_connection_failed():
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")
