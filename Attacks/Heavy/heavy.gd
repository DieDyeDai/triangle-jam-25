class_name HeavyAttack extends Hitbox

@onready var sprite_container: Node2D = $SpriteContainer
@onready var sprite: AnimatedSprite2D = $SpriteContainer/Sprite2D
@onready var particles: CPUParticles2D = $SpriteContainer/CPUParticles2D
@onready var particles2: CPUParticles2D = $SpriteContainer/CPUParticles2D2

const CHARGE_TIME : float = 0.2
const ANIMLOCK_TIME : float = 0.35

var movement_timer : Timer = null
var speed : int

var movement_tween : Tween = null

var dir : Vector2i

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

@warning_ignore("shadowed_variable")
func initialize(pos: Vector2i, dir: Vector2i, speed: int) -> void:
	self.base_position = pos
	self.positions = positions_from_pos(base_position)
	self.dir = dir
	self.speed = speed
	
	global_position = Globals.get_global_position(pos)
	#visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
var warped : bool = false

func _physics_process(delta: float) -> void:
	
	global_position += Vector2(speed * dir * Engine.get_physics_ticks_per_second() * delta)
	
	base_position = Globals.get_pos(global_position)
	positions = positions_from_pos(base_position)
	
	if global_position.x < 0:
		#warning_positions = [Vector2i(base_position.x + dir.x, base_position.y - dir.y)]
		warning_positions = positions_from_pos(Vector2i(base_position.x + dir.x, base_position.y - dir.y))
	else:
		warning_positions = positions_from_pos(base_position + dir)
	
	if Globals.should_warp(global_position, dir) and not warped:
		#print(global_position)
		#print(dir)
		#print("warp")
		warped = true
		#print("warp")
		global_position = Globals.get_warp_position(global_position)
		dir.y = -dir.y
		sprite_container.scale.y = -1
	
	label.text = str(base_position) + "  " + str(dir)

func positions_from_pos(pos: Vector2i) -> Array:
	if global_position.x < 0:
		return [pos, pos + dir + Vector2i(1,0), pos + dir + Vector2i(-1,0)]
	else:
		return [pos, pos - dir + Vector2i(1,0), pos - dir + Vector2i(-1,0)]
