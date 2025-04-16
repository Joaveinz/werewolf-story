extends Camera2D

@export var padding: float = 300.0
@export var lerp_speed: float = 5.0

func _process(delta):
	var players = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return

	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for player in players:
		var pos = player.global_position
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	var center = Vector2((min_x + max_x) / 2, (min_y + max_y) / 2)
	var size = Vector2(max_x - min_x, max_y - min_y) + Vector2(padding, padding)

	global_position = global_position.lerp(center, lerp_speed * delta)

	var viewport = get_viewport_rect().size
	var required_zoom = max(
		size.x / viewport.x,
		size.y / viewport.y,
		1.0 # optional: don't zoom in
	)
	zoom = zoom.lerp(Vector2(required_zoom, required_zoom), lerp_speed * delta)
