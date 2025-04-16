extends Camera2D

@export var padding: float = 300.0
@export var lerp_speed: float = 5.0
@export var default_position: Vector2 = Vector2.ZERO
@export var min_zoom: float = 1.0
@export var max_zoom: float = 2.0

func _process(delta):
	var viewport = get_viewport_rect()
	if viewport.size == Vector2.ZERO:
		return
	
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		# Smoothly move to default position when no players are present
		global_position = global_position.lerp(default_position, lerp_speed * delta)
		zoom = zoom.lerp(Vector2.ONE, lerp_speed * delta)
		return

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for player in players:
		if not is_instance_valid(player):
			continue
		var pos = player.global_position
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# If all players are invalid, use default position
	if min_x == INF:
		global_position = global_position.lerp(default_position, lerp_speed * delta)
		zoom = zoom.lerp(Vector2.ONE, lerp_speed * delta)
		return
	
	var center = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	var size = Vector2(max_x - min_x, max_y - min_y) + Vector2(padding, padding)

	# Smoothly move camera to center
	global_position = global_position.lerp(center, lerp_speed * delta)

	# Calculate and clamp zoom
	var required_zoom = max(
		size.x / viewport.size.x,
		size.y / viewport.size.y,
		min_zoom
	)
	required_zoom = clamp(required_zoom, min_zoom, max_zoom)
	zoom = zoom.lerp(Vector2(required_zoom, required_zoom), lerp_speed * delta)
