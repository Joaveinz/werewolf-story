extends Node2D
 
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var has_spawned_initial_player = false

func _ready():
	# Reset the flag when the scene is loaded
	has_spawned_initial_player = false

func _on_host_pressed():
	if not has_spawned_initial_player:
		peer.create_server(135)
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_add_player)
		_add_player()
		has_spawned_initial_player = true
	print("Hosting game")
 
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
	print("Added player", id)
	
func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	print("Joined game")
