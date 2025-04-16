extends Control

func _on_singleplayer_pressed() -> void:
	GameState.set_game_mode(false)
	# TODO: Load the game scene for singleplayer
	get_tree().change_scene_to_file("res://test_level.tscn")

func _on_multiplayer_pressed() -> void:
	GameState.set_game_mode(true)
	# TODO: Load the multiplayer scene
	get_tree().change_scene_to_file("res://game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
