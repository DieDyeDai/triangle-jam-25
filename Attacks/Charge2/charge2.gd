class_name ChargeAttack2 extends Hitbox

const CHARGE_TIME : float = 1.2
const ANIMLOCK_TIME : float = 0.3
const DURATION = 0.2
const RADIUS : int = 3

var warning_tick_timer : Timer = null

@onready var left_right: Line2D = $"left-right"
@onready var top_bottom: Line2D = $"top-bottom"
@onready var tr_bl: Line2D = $"tr-bl"
@onready var tl_br: Line2D = $"tl-br"

var left_pt : Vector2i = base_position
var right_pt : Vector2i = base_position
var top_pt : Vector2i = base_position
var bottom_pt : Vector2i = base_position
var tl_pt : Vector2i = base_position
var br_pt : Vector2i = base_position
var bl_pt : Vector2i = base_position
var tr_pt : Vector2i = base_position
var beam_endpoints : Array = [
	right_pt,
	top_pt,
	left_pt,
	bottom_pt,
	tr_pt,
	tl_pt,
	bl_pt,
	br_pt
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning_tick_timer = Timer.new()
	warning_tick_timer.set_wait_time(CHARGE_TIME / (RADIUS - 1))
	warning_tick_timer.timeout.connect(advance)
	add_child(warning_tick_timer)
	warning_tick_timer.start()
	
	advance()

func initialize(pos: Vector2i) -> void:
	base_position = pos
	global_position = Globals.get_global_position(pos)
	
	beam_endpoints.clear()
	for i in range(8):
		beam_endpoints.append(base_position)
	
	print(beam_endpoints)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

var current_radius : int = 0

func advance() -> void:
	match current_radius:
		2:
			warning_positions.append(base_position)
			current_radius += 1
			warning_tick_timer.start()
		1:
			var positions_to_check = [
				base_position + Vector2i(1,0), # right
				base_position + Vector2i(0,1), # top
				base_position + Vector2i(-1,0), # left
				base_position + Vector2i(0,-1), # bottom
			]
			for p in range(0,4,1):
				if check_pos_is_inbounds(positions_to_check[p]):
					warning_positions.append(positions_to_check[p])
					if beam_endpoints[p] == base_position:
						beam_endpoints[p] = Vector2i(positions_to_check[p])
			current_radius += 1
			warning_tick_timer.start()
		0:
			var positions_to_check = [
				base_position + Vector2i(2,0), # right
				base_position + Vector2i(0,2), # top
				base_position + Vector2i(-2,0), # left
				base_position + Vector2i(0,-2), # bottom
				base_position + Vector2i(1,1), # tr
				base_position + Vector2i(-1,1), # tl
				base_position + Vector2i(-1,-1), # bl
				base_position + Vector2i(1,-1), # br
			]
			for p in range(0,8,1):
				if check_pos_is_inbounds(positions_to_check[p]):
					warning_positions.append(positions_to_check[p])
					beam_endpoints[p] = Vector2i(positions_to_check[p])
			
			current_radius += 1
			warning_tick_timer.start()
		3:
			warning_tick_timer.stop()

var beam_width_tween : Tween = null
func fire() -> void:
	
	positions = warning_positions.duplicate()
	
	var lines : Array = [left_right, top_bottom, tr_bl, tl_br]
	left_right.add_point(Globals.get_global_position(beam_endpoints[0]))
	left_right.add_point(Globals.get_global_position(beam_endpoints[2]))
	top_bottom.add_point(Globals.get_global_position(beam_endpoints[1]))
	top_bottom.add_point(Globals.get_global_position(beam_endpoints[3]))
	tr_bl.add_point(Globals.get_global_position(beam_endpoints[4]))
	tr_bl.add_point(Globals.get_global_position(beam_endpoints[6]))
	tl_br.add_point(Globals.get_global_position(beam_endpoints[5]))
	tl_br.add_point(Globals.get_global_position(beam_endpoints[7]))
	
	print(str(base_position))
	print(str(beam_endpoints))
	for line in lines:
		print(str(line.points))
	
	beam_width_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	for line : Line2D in lines:
		beam_width_tween.tween_property(line, "width", 32, 0.03)
	
	warning_positions.clear()
	
	await get_tree().create_timer(DURATION, false, true).timeout
	
	positions.clear()
	
	beam_width_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	for line : Line2D in lines:
		beam_width_tween.tween_property(line, "width", 0, 0.3)
	
	await beam_width_tween.finished
	
	queue_free()

func interrupt() -> void:
	warning_positions.clear()
	positions.clear()
	queue_free()
