class_name BasicAttack2 extends Hitbox

const DELAY : float = 0.8
const DURATION : float = 0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(pos: Vector2i, dir: Vector2i) -> void:
	base_position = pos + dir
	
func fire() -> void:
	warning_positions = [base_position]
	if base_position.x > -2:
		warning_positions.append(base_position + Vector2i(-1,0))
	if base_position.x < 2:
		warning_positions.append(base_position + Vector2i(1,0))
	
	if (base_position.y < Globals.Y_UPPER_1) \
		or (base_position.y >= Globals.Y_LOWER_2 and base_position.y < Globals.Y_UPPER_2):
		warning_positions.append(base_position + Vector2i(0,1))
	
	if (base_position.y > Globals.Y_LOWER_2) \
		or (base_position.y <= Globals.Y_UPPER_1 and base_position.y > Globals.Y_LOWER_1):
		warning_positions.append(base_position + Vector2i(0,-1))
	
	await get_tree().create_timer(DELAY).timeout
	
	positions = warning_positions.duplicate()
	warning_positions.clear()
	
	await get_tree().create_timer(DURATION).timeout
	
	positions.clear()
	queue_free()
