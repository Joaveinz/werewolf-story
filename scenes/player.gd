extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar if has_node("HealthBar") else null

@export var WALK_SPEED = 150.0

const RUN_SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 100

var health = MAX_HEALTH
var invincible = false
var invincibility_time = 0.1  # Seconds of invincibility after taking damage

func _ready():
	# Initialize health bar if it exists
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health

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

# Take damage from an attack
func take_damage(damage):
	# Don't take damage if invincible
	if invincible:
		return
	
	# Reduce health
	health -= damage
	
	# Update health bar
	if health_bar:
		health_bar.value = health
	
	# Visual feedback
	animated_sprite.modulate = Color(1, 0.5, 0.5)  # Flash red
	
	# Make player briefly invincible
	invincible = true
	
	# Use a timer to restore normal appearance and remove invincibility
	await get_tree().create_timer(0.2).timeout
	animated_sprite.modulate = Color(1, 1, 1)  # Return to normal color
	
	await get_tree().create_timer(invincibility_time - 0.2).timeout
	invincible = false
	
	# Check if player is dead
	if health <= 0:
		die()
	
	print("Player took " + str(damage) + " damage. Health: " + str(health))

# Handle player death
func die():
	# Play death animation if available
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	else:
		# If no death animation, just fade out
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.0)
		await tween.finished
	
	# Game over logic
	# You might want to show a game over screen, restart level, etc.
	print("Game Over")
	# Optionally restart the current scene
	# get_tree().reload_current_scene()
