extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var WALK_SPEED = 150.0

const RUN_SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_cancel"):
		# game turn off
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		# Set speed based on whether running or walking
		var current_speed = RUN_SPEED if Input.is_action_pressed("ui_shift") else WALK_SPEED
		velocity.x = direction * current_speed
		# Play running animation when moving and holding shift, otherwise walk
		if Input.is_action_pressed("ui_shift"):
			animated_sprite.play("run")
		else:
			animated_sprite.play("walk")
		# Flip the sprite based on direction
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)
		# Play idle animation when not moving
		animated_sprite.play("idle")

	move_and_slide()
