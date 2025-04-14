extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 200.0  # Slightly slower than player's walk speed
const GRAVITY = 980.0  # Same gravity as player
const CLIFF_CHECK_DISTANCE = 50.0  # How far ahead to check for cliffs
const TURN_DELAY = 0.2  # Seconds to pause after turning

var turn_timer = 0.0  # Timer for turning delay
var current_direction = 1  # Current movement direction (1 = right, -1 = left)

func _ready():
	# Start with the run animation
	animated_sprite.play("run")
	# Set initial direction based on sprite flip
	current_direction = -1 if animated_sprite.flip_h else 1

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle turning delay
	if turn_timer > 0:
		turn_timer -= delta
		velocity.x = 0
		return
	
	# Move in the direction the sprite is facing
	velocity.x = current_direction * SPEED
	
	# Check for cliffs and walls
	if is_on_floor():
		if check_for_cliff(current_direction):
			turn_around()
	
	move_and_slide()
	
	# If we hit a wall, turn around
	if is_on_wall():
		turn_around()

# Check if there's a cliff ahead
func check_for_cliff(direction: float) -> bool:
	# Cast a ray to check for ground ahead
	var space_state = get_world_2d().direct_space_state
	var ray_origin = global_position
	# Check 100 pixels down from the ray end point
	var ray_end = ray_origin + Vector2(direction * CLIFF_CHECK_DISTANCE, 100)
	var query = PhysicsRayQueryParameters2D.create(ray_origin, ray_end)
	query.exclude = [self]  # Don't detect the werewolf itself
	
	var result = space_state.intersect_ray(query)
	return result.is_empty()

# Turn the werewolf around
func turn_around():
	animated_sprite.flip_h = !animated_sprite.flip_h
	current_direction = -current_direction  # Reverse the direction
	turn_timer = TURN_DELAY  # Start the turning delay
