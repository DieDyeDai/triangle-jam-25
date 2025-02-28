class_name Counter extends Sprite2D

var count : int = 0
const UIE_COUNT_RED = preload("res://Assets/UIECountRed.png")
const UIE_COUNT_BLUE = preload("res://Assets/UIECountBlue.png")

var flash_white_timer : Timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash_white_timer = Timer.new()
	flash_white_timer.set_one_shot(false)
	flash_white_timer.set_wait_time(0.1)
	add_child(flash_white_timer)
	flash_white_timer.timeout.connect(self.on_flash_white_end)

func initialize(isP1: bool, isP2: bool):
	if isP1:
		texture = UIE_COUNT_BLUE
	elif isP2:
		texture = UIE_COUNT_RED
	

func update(count: int):
	count = clampi(count, 0, UIEnergyBar.MAX_I)
	if frame != count:
		frame = count
		flash_white()

func flash_white():
	material.set("shader_parameter/enabled", true)
	flash_white_timer.start()

func on_flash_white_end():
	material.set("shader_parameter/enabled", false)
	flash_white_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
