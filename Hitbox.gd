class_name Hitbox extends Node2D

var target_positions: Array = []

var positions : Array = []
var base_position : Vector2i = Vector2i.ZERO

#signal remove(node: Hitbox)

func move(dir: Vector2i):
	var old_positions : Array = positions.duplicate(true)
	positions.clear()
	for pos : Vector2i in old_positions:
		positions.append(pos + dir)
	base_position += dir

func is_inbounds() -> bool:
	for pos : Vector2 in positions:
		if pos.x == clampi(pos.x, Globals.X_LOWER, Globals.X_UPPER) and pos.y == clampi(pos.y, Globals.Y_LOWER, Globals.Y_UPPER):
			return true
	return false

func start_free_timer() -> void:
	await get_tree().create_timer(2, false, true).timeout
	queue_free()
