extends Node2D

@onready var fire = $fireEffect
@onready var player = get_parent()
@onready var damage_area = $damageArea

var direction = -1
var shooting = false

func _process(_delta):
	# Only check multiplayer authority if in multiplayer mode
	if GameState.is_multiplayer_mode and not player.is_multiplayer_authority():
		fire.emitting = false
		damage_area.monitorable = false
		damage_area.monitoring = false
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
		damage_area.monitorable = false
		damage_area.monitoring = false
		
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
		damage_area.monitorable = true
		damage_area.monitoring = true
		var direction_vector = (get_global_mouse_position() - player.global_position).normalized()
		fire.process_material.set("gravity", Vector3(direction_vector.x * 26, direction_vector.y * 26, 0))
	else:
		shooting = false
		fire.emitting = false
		damage_area.monitorable = false
		damage_area.monitoring = false


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and shooting:
		body.onFire = true


func _on_damage_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.onFire = false
