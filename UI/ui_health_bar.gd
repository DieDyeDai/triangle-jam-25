class_name UIHealthBar extends Control

#var health : Health

@onready var decayBar : Sprite2D = $Decay
@onready var fillBar : Sprite2D = $Fill
@onready var endBar : Sprite2D = $End
@onready var flashWhite : Sprite2D = $FlashWhite
@onready var curHPLabel : Label = $curHP
@onready var maxHPLabel : Label = $maxHP

var flash_white_timer : Timer = null

var cur : float = 0
@warning_ignore("shadowed_global_identifier")
var max : float = 0

var neg_px_diff : float = 0
var prev_px_pos : float = 0
var px_pos : float = 0

var decay_tween : Tween = null

const LEN : int = 144

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#reset(Flags.base_player_max_hp, Flags.base_player_max_hp)
	
	flash_white_timer = Timer.new()
	flash_white_timer.set_one_shot(false)
	flash_white_timer.set_wait_time(0.1)
	add_child(flash_white_timer)
	flash_white_timer.timeout.connect(self.on_flash_white_end)
	
	#Signals.player_hp_changed.connect(self.update)
	#Signals.player_hp_reset.connect(self.reset)

@warning_ignore("shadowed_variable", "shadowed_global_identifier")
func reset(cur, max):
	if decay_tween:
		decay_tween.kill()
	set_hps_and_labels(cur, max)
	if self.cur > 0:
		px_pos = min(LEN, max(1, floor(LEN * self.cur / self.max)))
	else:
		px_pos = 0
	prev_px_pos = px_pos
	fillBar.scale.x = px_pos / LEN
	endBar.position.x = px_pos
	decayBar.scale.x = fillBar.scale.x
	
@warning_ignore("shadowed_variable", "shadowed_global_identifier")
func update(cur, max):
	#print("update energy bar: " + str(cur) + "/" + str(max))
	if self.cur != cur or self.max != max:
		
		set_hps_and_labels(cur, max)
		
		if self.cur > 0:
			px_pos = min(LEN, max(1, floor(LEN * self.cur / self.max)))
		else:
			px_pos = 0
		neg_px_diff = prev_px_pos - px_pos
		#print("px: " + str(prev_px_pos) + "->" + str(px_pos) + " - " + str(neg_px_diff))
		prev_px_pos = px_pos
		
		fillBar.scale.x = px_pos / LEN
		endBar.position.x = px_pos
		
		if neg_px_diff > 0:
			if decay_tween:
				decay_tween.kill()
			decay_tween = create_tween()
			decay_tween.tween_property(decayBar, "scale", Vector2(px_pos / LEN, 1), 1)
			decay_tween.play()
		else:
			decayBar.scale.x = fillBar.scale.x
		
		flash_white()

func hit(damage: int):
	update(max(0, cur - damage), max)

func flash_white():
	flashWhite.scale.x = decayBar.scale.x
	flashWhite.visible = true
	flash_white_timer.start()

func on_flash_white_end():
	flashWhite.visible = false

func set_hps_and_labels(hp: int, mhp: int):
	self.cur = hp
	curHPLabel.text = str(self.cur)
	self.max = mhp
	maxHPLabel.text = str(self.max)
