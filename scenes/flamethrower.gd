extends Node2D

@onready var fire = $fireEffect
@onready var player = get_parent()

var direction = -1
var shooting = false

func _process(delta):
	if not player.is_multiplayer_authority():
		fire.emitting = false
		return
		
	# Get mouse position relative to player
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position
	
	# Calculate direction to mouse
	var direction_to_mouse = mouse_pos.x - player_pos.x
	
	# Only allow firing in the direction the player is facing
	if (direction_to_mouse > 0 and player.animated_sprite.flip_h) or \
	   (direction_to_mouse < 0 and not player.animated_sprite.flip_h):
		fire.emitting = false
		return
		
	look_at(mouse_pos)
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	if rotation_degrees > 90 and rotation_degrees < 270:
		direction = -1
	else:
		direction = 1
		
	scale.y = direction

	if Input.is_action_pressed("shoot"):
		shooting = true
		fire.emitting = true
		fire.process_material.set("gravity", Vector3(26 if direction > 0 else -26,0,0))
	else:
		shooting = false
		fire.emitting = false
