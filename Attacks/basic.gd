extends Hitbox

var movement_timer : Timer = null
var movement_cd : float

var dir : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	movement_timer.start()

@warning_ignore("shadowed_variable")
func initialize(pos: Vector2i, dir: Vector2i, speed: float) -> void:
	self.positions = [pos]
	self.base_position = pos
	self.dir = dir
	
	global_position = pos * 32
	#visible = true
	
	movement_timer = Timer.new()
	movement_timer.set_wait_time(speed)
	movement_cd = speed
	movement_timer.set_one_shot(false)
	movement_timer.set_autostart(false)
	
	movement_timer.timeout.connect(do_move)
	
	add_child(movement_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func do_move():
	super.move(dir)
	if !is_inbounds():
		start_free_timer()
	var movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", Vector2(base_position * 32), movement_cd).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	movement_timer.start()
