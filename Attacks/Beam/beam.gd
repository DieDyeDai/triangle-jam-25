class_name Beam extends Hitbox

var warning_tick_timer : Timer = null

var beam_tiles_to_draw : Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning_tick_timer = Timer.new()
	warning_tick_timer.set_wait_time(0.05)
	warning_tick_timer.timeout.connect(advance_warning)
	add_child(warning_tick_timer)
	warning_tick_timer.start()

var dir : int
var next_warning_tile : Vector2i
func initialize(pos: Vector2i) -> void:
	base_position = pos
	global_position = Globals.get_global_position(pos)
	next_warning_tile.x = pos.x
	if global_position.x < 0:
		# left, go increasing y
		dir = 1
		next_warning_tile.y = 0
	else:
		# right, go decreasing y
		dir = -1
		next_warning_tile.y = 1
	
	var y = base_position.y
	while (y < Globals.Y_UPPER and y > Globals.Y_LOWER):
		y += dir
		beam_tiles_to_draw.append([Vector2i(base_position.x, y)])
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func advance_warning() -> void:
	next_warning_tile.y += dir
	if next_warning_tile.y <= Globals.Y_UPPER and next_warning_tile.y >= Globals.Y_LOWER:
		warning_positions.append(Vector2i(next_warning_tile.x, next_warning_tile.y))
		warning_tick_timer.start()

func fire() -> void:
	for tile : Vector2i in warning_positions:
		positions.append(tile)
	
	warning_positions.clear()
	
	await get_tree().create_timer(0.25, false, true).timeout
	
	positions.clear()
	queue_free()

func interrupt() -> void:
	warning_positions.clear()
	positions.clear()
	queue_free()
