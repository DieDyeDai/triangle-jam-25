class_name UIEnergyBar extends Control

#var health : Health

@onready var decayBar : Sprite2D = $Decay
@onready var fillBar : Sprite2D = $Fill
@onready var endBar : Sprite2D = $End
@onready var flashWhite : Sprite2D = $FlashWhite

@onready var tick1: Sprite2D = $Tick1
@onready var tick2: Sprite2D = $Tick2
@onready var tick3: Sprite2D = $Tick3

@onready var counter: Counter = $DiamondCount

#@onready var curHPLabel : Label = $curHP
#@onready var maxHPLabel : Label = $maxHP

var flash_white_timer : Timer = null

const LEN_INITIAL : int = 144
var px_len : int = 144

const GAIN_INITIAL : float = 0.2
var gain : float = 0.2

var cur_i : int = 1
@warning_ignore("shadowed_global_identifier")
var max : float = LEN_INITIAL
const MAX_I : int = 3
@warning_ignore("integer_division")
const COST : float = floor(LEN_INITIAL / MAX_I)
var cur : float = 0

var neg_px_diff : float = 0
var prev_px_pos : float = 0
var px_pos : float = 0

var decay_tween : Tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash_white_timer = Timer.new()
	flash_white_timer.set_one_shot(false)
	flash_white_timer.set_wait_time(0.1)
	add_child(flash_white_timer)
	flash_white_timer.timeout.connect(self.on_flash_white_end)

var ct : int = 1
func _physics_process(_delta: float) -> void:
	#ct = (ct + 1) % 5
	#if ct == 0:
	#print(min(cur + gain, max))
	#print(cur)
	update(min(cur + gain, max), max)
	if floor(cur * MAX_I / max) != cur_i:
		flash_white()
	@warning_ignore("integer_division")
	cur_i = floor(cur * MAX_I / max)
	
	counter.update(cur_i)
	
@warning_ignore("shadowed_variable", "shadowed_global_identifier")
func reset(cur, max):
	px_len = LEN_INITIAL
	gain = GAIN_INITIAL
	shrink(1.0)
	
	print("reset")
	
	if decay_tween:
		decay_tween.kill()
	set_hps_and_labels(cur, max)
	if self.cur > 0:
		px_pos = min(px_len, max(1, floor(px_len * self.cur / self.max)))
	else:
		px_pos = 0
	prev_px_pos = px_pos
	fillBar.scale.x = px_pos / LEN_INITIAL
	endBar.position.x = px_pos
	decayBar.scale.x = fillBar.scale.x
	
@warning_ignore("shadowed_variable", "shadowed_global_identifier")
func update(cur, max):
	#print("update energy bar: " + str(cur) + "/" + str(max))
	if self.cur != cur or self.max != max:
		
		set_hps_and_labels(cur, max)
		
		if self.cur > 0:
			px_pos = min(px_len, max(1, floor(px_len * self.cur / self.max)))
		else:
			px_pos = 0
		neg_px_diff = prev_px_pos - px_pos
		#print("px: " + str(prev_px_pos) + "->" + str(px_pos) + " - " + str(neg_px_diff))
		prev_px_pos = px_pos
		
		fillBar.scale.x = px_pos / LEN_INITIAL
		endBar.position.x = px_pos
		
		if neg_px_diff > 0:
			if decay_tween:
				decay_tween.kill()
			decay_tween = create_tween()
			decay_tween.tween_property(decayBar, "scale", Vector2(0.01,1), decayBar.scale.x)
			decay_tween.play()
		else:
			decayBar.scale.x = fillBar.scale.x
		
		# flash_white()

func shrink(factor: float):
	px_len = ceil(LEN_INITIAL * factor)
	gain = GAIN_INITIAL / factor
	tick1.position.x = ceil(px_len / 3.0)
	tick2.position.x = ceil(px_len * 2 / 3.0)
	tick3.position.x = px_len
	
	update(cur, max)

func flash_white():
	flashWhite.scale.x = decayBar.scale.x
	flashWhite.visible = true
	flash_white_timer.start()

func on_flash_white_end():
	flashWhite.visible = false

func set_hps_and_labels(hp: float, mhp: float):
	self.cur = hp
	#curHPLabel.text = str(self.cur)
	self.max = mhp
	#maxHPLabel.text = str(self.max)
