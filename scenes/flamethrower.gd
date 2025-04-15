extends Node2D

@onready var fire = $fireEffect

var direction = -1
var shooting = false

func _process(delta):
	look_at(get_global_mouse_position())
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
