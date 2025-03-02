class_name LightAttack2 extends Hitbox

const DELAY : float = 0.8
const DURATION : float = 0.1
const COOLDOWN : float = 1.5

@onready var sprite1: AnimatedSprite2D = $sprite1
@onready var sprite2: AnimatedSprite2D = $sprite2
@onready var sprite3: AnimatedSprite2D = $sprite3
@onready var sprite4: AnimatedSprite2D = $sprite4
@onready var sprite5: AnimatedSprite2D = $sprite5

@onready var sprites : Array = [sprite1, sprite2, sprite3, sprite4, sprite5]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func initialize(pos: Vector2i) -> void:
	base_position = pos
	
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
	
	var i : int = 0
	for pos : Vector2i in positions:
		sprites[i].global_position = Globals.get_global_position(pos)
		sprites[i].visible = true
		sprites[i].play("default")
		i += 1
		if i == sprites.size():
			break
	
	warning_positions.clear()
	
	await get_tree().create_timer(DURATION).timeout
	
	positions.clear()
	
	await sprite1.animation_finished
	queue_free()
