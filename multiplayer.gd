extends Node

@onready var multiplayer_ui = $UI/Multiplayer

const PLAYER = preload("res://scenes/player.tscn")

var peer = ENetMultiplayerPeer.new()

func _on_host_pressed():
	print("Hosting game...")
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player(pid)
	)
	
	var local_pid = multiplayer.get_unique_id()
	print("Local player ID: ", local_pid)
	add_player(local_pid)
	multiplayer_ui.hide()

func add_player(pid):
	var player = PLAYER.instantiate()
	player.add_to_group("players")
	player.name = str(pid)
	# Set initial position based on player ID to avoid overlap
	player.position = Vector2(pid * 100, 0)  # Space players horizontally
	call_deferred("add_child", player)

func _on_join_pressed():
	print("Joining game...")
	peer.create_client("localhost", 25565)
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()
