class_name Hitbox extends Node2D

var warning_positions: Array = []

var positions : Array = []
var base_position : Vector2i = Vector2i.ZERO

@export var damage : int = 1

#signal remove(node: Hitbox)

func move(dir: Vector2i):
	var old_positions : Array = positions.duplicate(true)
	positions.clear()
	for pos : Vector2i in old_positions:
		positions.append(pos + dir)
	base_position += dir

func is_inbounds() -> bool:
	for pos : Vector2 in positions:
		@warning_ignore("narrowing_conversion")
		if pos.x == clampi(pos.x, Globals.X_LOWER, Globals.X_UPPER) and pos.y == clampi(pos.y, Globals.Y_LOWER, Globals.Y_UPPER):
			return true
	return false

func check_pos_is_inbounds(pos: Vector2i) -> bool:
	if Globals.X_LOWER <= pos.x and pos.x <= Globals.X_UPPER:
		if base_position.y <= Globals.Y_UPPER_1: # left side, y = 0 to -4
			return (Globals.Y_LOWER_1 <= pos.y and pos.y <= Globals.Y_UPPER_1)
		else: # right side, y = 1 to 5
			return (Globals.Y_LOWER_2 <= pos.y and pos.y <= Globals.Y_UPPER_2)
	else:
		return false

func start_free_timer() -> void:
	await get_tree().create_timer(2, false, true).timeout
	queue_free()
