extends Control

var client = preload("res://scenes/client.tscn").instance()

func _ready():
	Multiplayer.connect("connection_succeeded", self, "_on_connection_succeeded")
	Multiplayer.connect("connection_failed", self, "_on_connection_failed")
	Multiplayer.connect("client_ready", self, "_on_client_ready")

func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address"
		return

	$Connect/ErrorLabel.text = "Connecting..."
	$Connect/Join.disabled = true
	Multiplayer.join_game(ip)

func _on_client_ready():
	get_tree().get_root().add_child(client)
	hide()

func _on_connection_succeeded():
	var _player_name = $Connect/Name.text
	$Connect/ErrorLabel.set_text("Connected to server.")

func _on_connection_failed():
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")
