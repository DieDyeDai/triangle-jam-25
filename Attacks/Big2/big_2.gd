class_name BigAttack2 extends Hitbox

const CHARGE_TIME : float = 0.2
const ANIMLOCK_TIME : float = 0.35

const MOVE_DELAY : float = 0.6
const DURATION : float = 0.1

var movement_timer : Timer = null
var speed : int

var movement_tween : Tween = null

var dir : int

@onready var sprite1: AnimatedSprite2D = $sprite1
@onready var sprite2: AnimatedSprite2D = $sprite2
@onready var sprite3: AnimatedSprite2D = $sprite3
@onready var sprite4: AnimatedSprite2D = $sprite4
@onready var sprite5: AnimatedSprite2D = $sprite5

@onready var label: Label = $Label

@onready var sprites : Array = [sprite1, sprite2, sprite3, sprite4, sprite5]

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

	#movement_timer.start()
	advance()

@warning_ignore("shadowed_variable")
func initialize(pos: Vector2i, dir: int) -> void:
	self.base_position = pos
	self.dir = dir

var warped : bool = false
func advance() -> void:
	#moving up on right: y<lower2, dir<0
	#moving up on left: y>upper1, dir>0
	if warped and (
		(dir < 0 and base_position.y < Globals.Y_LOWER_2) or (dir > 0 and base_position.y > Globals.Y_UPPER_1)
	):
		#print("big 2 oob")
		await get_tree().create_timer(1.0, false).timeout
		queue_free()
	else:
		
		# moving down on right: y>upper2, dir>0
		# moving down on left: y<lower1, dir<0
		
		base_position += Vector2i(0, dir)
		if !warped and (
			(dir > 0 and base_position.y > Globals.Y_UPPER_2) or (dir < 0 and base_position.y < Globals.Y_LOWER_1)
		):
			base_position.y = 1 - base_position.y + dir
			#print("warp")
			warped = true
		
		positions = warning_positions.duplicate()
		
		var i : int = 0
		for pos : Vector2i in positions:
			sprites[i].global_position = Globals.get_global_position(pos)
			sprites[i].visible = true
			sprites[i].play("default")
			i += 1
			if i == sprites.size():
				break
		
		warning_positions.clear()
		warning_positions = get_positions_from_pos(base_position.y)
		movement_timer.start()
		
		#print(base_position.y)
		#print(dir)
		#print(str(positions))
		#print(str(warning_positions))
		
		await get_tree().create_timer(DURATION).timeout
		positions.clear()

func get_positions_from_pos(y: int) -> Array:
	var p = []
	for i in range(Globals.X_LOWER, Globals.X_UPPER + 1, 1):
		p.append(Vector2i(i, y))
	return p
	
