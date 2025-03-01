class_name Melee extends Hitbox

var dir : int

var active : bool = true
var charging : bool = true

const FIRST_DELAY_TIME : float = 0.25
const CHARGE_TIME : float = 0.8
const ANIMLOCK_TIME : float = 0.25

const RANGE : int = 3

var warning_tick_timer : Timer = null

var next_warning_tile : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning_tick_timer = Timer.new()
	warning_tick_timer.set_wait_time(0.05)
	warning_tick_timer.timeout.connect(advance_warning)
	add_child(warning_tick_timer)
	warning_tick_timer.set_autostart(false)

var warning_tiles_added : int = 0 # goes up to 3 wide, 4 long
func advance_warning() -> void:
	pass

func initialize(pos: Vector2i) -> void:
	base_position = pos
	global_position = Globals.get_global_position(pos)
	if global_position.x < 0:
		# from left, go increasing y to go down
		dir = 1
	else:
		# right, go decreasing y to go down
		dir = -1
	base_position += Vector2i(0, dir)
	
	next_warning_tile = base_position
	
	warning_positions = [
		base_position,
		base_position + Vector2i(0,dir)
	]
	if base_position.x > -2:
		warning_positions.append(Vector2i(base_position + Vector2i(-1,0)))
	if base_position.x < 2:
		warning_positions.append(Vector2i(base_position + Vector2i(1,0)))

func fire() -> void:
	positions = warning_positions.duplicate()
	warning_positions.clear()
	await get_tree().create_timer(0.3, false).timeout
	positions.clear()
	if !charging:
		queue_free()

func charge() -> void:
	print("melee charge start")
	await get_tree().create_timer(CHARGE_TIME / (RANGE+1), false).timeout
	warning_positions.append(next_warning_tile)
	print(str(next_warning_tile))
	for i in range(RANGE):
		await get_tree().create_timer(CHARGE_TIME / (RANGE+1), false).timeout
		
		if next_warning_tile.x > -2:
			warning_positions.append(Vector2i(next_warning_tile + Vector2i(-1,0)))
		if next_warning_tile.x < 2:
			warning_positions.append(Vector2i(next_warning_tile + Vector2i(1,0)))
		warning_positions.append(Vector2i(next_warning_tile + Vector2i(0,dir)))
		next_warning_tile.y += dir
	

func fire_charged() -> void:
	print("melee fire charged")
	damage = 2
	charging = false
	fire()
