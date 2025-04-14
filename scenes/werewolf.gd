extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 200.0  # Slightly slower than player's walk speed
const GRAVITY = 980.0  # Same gravity as player
const TURN_DELAY = 0.2  # Seconds to pause after turning
const ATTACK_DURATION = 1.0  # How long the attack animation plays
const ATTACK_DAMAGE = 10  # Damage done per attack
const ATTACK_RANGE = 50.0  # Range at which the werewolf can damage the player


var turn_timer = 0.0  # Timer for turning delay
var current_direction = 1  # Current movement direction (1 = right, -1 = left)
var is_attacking = false  # Whether the werewolf is currently attacking
var attack_timer = 0.0  # Timer for attack animation
var has_dealt_damage = false  # Whether damage has been dealt in current attack
var current_target = null  # Current target of the attack

func _ready():
	# Start with the run animation
	animated_sprite.play("run")
	# Set initial direction based on sprite flip
	current_direction = -1 if animated_sprite.flip_h else 1

func _physics_process(delta: float) -> void:
	# Add the gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle attack animation
	if is_attacking:
		attack_timer -= delta
		
		# Check if we need to deal damage to the player
		if not has_dealt_damage and current_target:
			try_deal_damage()
		
		if attack_timer <= 0:
			# Reset attack state
			is_attacking = false
			has_dealt_damage = false
			current_target = null
			animated_sprite.play("run")
		
		# Stop moving during attack
		velocity.x = 0
		move_and_slide()
		return
	
	# Handle turning delay
	if turn_timer > 0:
		turn_timer -= delta
		velocity.x = 0
		move_and_slide()
		return
	
	# Move in the direction the sprite is facing
	velocity.x = current_direction * SPEED
	
	move_and_slide()
	
	# If we hit a wall, turn around
	if is_on_wall():
		turn_around()
	
	# Check for cliffs
	if is_on_floor():
		# Simple cliff detection - check if there's no floor just ahead
		var space_state = get_world_2d().direct_space_state
		var check_pos = global_position + Vector2(current_direction * 30, 5)
		var check_end = check_pos + Vector2(0, 50)
		
		var query = PhysicsRayQueryParameters2D.create(check_pos, check_end)
		query.exclude = [self]
		
		var result = space_state.intersect_ray(query)
		
		# If we didn't hit anything, there's a cliff ahead
		if result.is_empty():
			turn_around()
	
	# Check for collision with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Check if the collider is the player (either by group or by name)
		if collider.is_in_group("player") or collider.name == "Player":
			face_player(collider)
			current_target = collider  # Store the player as current target
			start_attack()
			break

# Try to deal damage to the player if in range
func try_deal_damage():
	print("try to deal damage")
	if not current_target:
		return
		
	# Check if player is still in range
	var distance = global_position.distance_to(current_target.global_position)
	if distance <= ATTACK_RANGE:
		# Deal damage to the player
		if current_target.has_method("take_damage"):
			current_target.take_damage(ATTACK_DAMAGE)
		else:
			# Fall back to directly accessing health if the method doesn't exist
			if "health" in current_target:
				current_target.health -= ATTACK_DAMAGE
				
				# Update health bar if it exists
				if current_target.has_node("HealthBar"):
					var health_bar = current_target.get_node("HealthBar")
					health_bar.value = current_target.health
					
		# Mark that we've dealt damage in this attack
		has_dealt_damage = true
		print("Werewolf dealt " + str(ATTACK_DAMAGE) + " damage to player")

# Turn the werewolf around
func turn_around():
	animated_sprite.flip_h = !animated_sprite.flip_h
	current_direction = -current_direction  # Reverse the direction
	turn_timer = TURN_DELAY  # Start the turning delay

# Make the werewolf face the player
func face_player(player):
	# Determine the direction to the player
	var direction_to_player = player.global_position.x - global_position.x
	
	# Flip the sprite based on the player's position
	if direction_to_player > 0:  # Player is to the right
		animated_sprite.flip_h = false
		current_direction = 1
	else:  # Player is to the left
		animated_sprite.flip_h = true
		current_direction = -1

# Start the attack animation
func start_attack():
	if not is_attacking:
		is_attacking = true
		attack_timer = ATTACK_DURATION
		has_dealt_damage = false
		animated_sprite.play("attack_1")
	
