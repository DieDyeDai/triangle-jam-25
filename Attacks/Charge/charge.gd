class_name ChargeAttack extends Hitbox

const CHARGE_TIME : float = 0.5
const ANIMLOCK_TIME : float = 0.2
const DURATION : float = 0.2

var warning_tick_timer : Timer = null

var beam_tiles_to_draw : Array = []

@onready var line_section_1: Line2D = $LineSection1
@onready var line_section_2: Line2D = $LineSection2

@onready var charge_particles: CPUParticles2D = $ChargeParticles
@onready var charge_particles2: CPUParticles2D = $ChargeParticles2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning_tick_timer = Timer.new()
	warning_tick_timer.set_wait_time(CHARGE_TIME / Globals.GRID_HEIGHT)
	warning_tick_timer.timeout.connect(advance_warning)
	add_child(warning_tick_timer)
	warning_tick_timer.start()
	
	line_section_1.clear_points()
	line_section_2.clear_points()
	
	charge_particles.global_position = Vector2(Globals.get_global_position(beam_tiles_to_draw[-1]).x + \
		charge_particles.emission_rect_extents.x / 2, 0)
	charge_particles2.global_position = Vector2(Globals.get_global_position(beam_tiles_to_draw[-1]).x - \
		charge_particles2.emission_rect_extents.x / 2, 0)

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
	while (y <= Globals.Y_UPPER and y >= Globals.Y_LOWER):
		beam_tiles_to_draw.append(Vector2i(base_position.x, y))
		y += dir
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func advance_warning() -> void:
	next_warning_tile.y += dir
	if next_warning_tile.y <= Globals.Y_UPPER and next_warning_tile.y >= Globals.Y_LOWER:
		warning_positions.append(Vector2i(next_warning_tile.x, next_warning_tile.y))
		warning_tick_timer.start()

var beam_width_tween : Tween = null
func fire() -> void:
	charge_particles.emitting = false
	charge_particles2.emitting = false
	
	positions = warning_positions.duplicate()
	
	#print(base_position)
	
	line_section_1.add_point(Globals.get_global_position(base_position) + Vector2(0, -0.5 * Globals.TILE_HEIGHT))
	line_section_1.add_point(Vector2(Globals.get_global_position(base_position).x, -3 * Globals.TILE_HEIGHT))

	#print(line_section_1.points)
	
	print(beam_tiles_to_draw)
	
	line_section_2.add_point(Vector2(Globals.get_global_position(beam_tiles_to_draw[-5])) - Vector2(0, Globals.TILE_HEIGHT))
	line_section_2.add_point(Vector2(Globals.get_global_position(beam_tiles_to_draw[-1])) + Vector2(0, Globals.TILE_HEIGHT * 4))
	
	#print(line_section_2.points)
	
	beam_width_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	beam_width_tween.tween_property(line_section_1, "width", 32, 0.03)
	beam_width_tween.tween_property(line_section_2, "width", 32, 0.03)
	
	warning_positions.clear()
	
	await get_tree().create_timer(DURATION, false, true).timeout
	
	positions.clear()
	
	beam_width_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	beam_width_tween.tween_property(line_section_1, "width", 0, 0.2)
	beam_width_tween.tween_property(line_section_2, "width", 0, 0.2)
	
	await beam_width_tween.finished
	
	queue_free()

func interrupt() -> void:
	warning_positions.clear()
	positions.clear()
	queue_free()
