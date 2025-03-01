class_name BigAttack2 extends Hitbox

const CHARGE_TIME : float = 0.5
const ANIMLOCK_TIME : float = 0.35

const MOVE_DELAY : float = 0.7
const DURATION : float = 0.2

var movement_timer : Timer = null
var speed : int

var movement_tween : Tween = null

var dir : int

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_timer = Timer.new()
	movement_timer.set_wait_time(MOVE_DELAY)
	movement_timer.set_autostart(false)
	movement_timer.set_one_shot(true)
	movement_timer.timeout.connect(advance)
	add_child(movement_timer)
	
	warning_positions = get_positions_from_pos(base_position.y)

	print(str(positions))
	print(str(warning_positions))

	movement_timer.start()

@warning_ignore("shadowed_variable")
func initialize(pos: Vector2i, dir: int) -> void:
	self.base_position = pos + Vector2i(0, dir)
	self.dir = dir

func advance() -> void:
	base_position += Vector2i(0, dir)
	#positions.clear()
	
	positions = warning_positions.duplicate()
	
	if !is_inbounds():
		print("big 2 oob")
		await get_tree().create_timer(1.0, false).timeout
		queue_free()
	else:
		warning_positions.clear()
		warning_positions = get_positions_from_pos(base_position.y)
		movement_timer.start()
		
		await get_tree().create_timer(DURATION).timeout
		positions.clear()

func get_positions_from_pos(y: int) -> Array:
	var p = []
	for i in range(Globals.X_LOWER, Globals.X_UPPER + 1, 1):
		p.append(Vector2i(i, y))
	return p
	
