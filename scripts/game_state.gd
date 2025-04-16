extends Node

# Global game state variables
var is_multiplayer_mode: bool = false

# Function to set the game mode
func set_game_mode(multiplayer: bool) -> void:
	is_multiplayer_mode = multiplayer 