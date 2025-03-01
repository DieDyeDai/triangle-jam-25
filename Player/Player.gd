class_name Player
extends Node2D

@onready var sprite_container: Node2D = $Sprites
@onready var body_sprite: Sprite2D = $Sprites/BodySprite
@onready var hair_sprite: RandomSprite2D = $Sprites/HairRandomSprite
@onready var hat_sprite: Sprite2D = $Sprites/HatSprite

#@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ap : AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var tree: AnimationTree = $AnimationTree
@onready var sm : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var move_sm : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/move/playback"]

@onready var hurt_ap: AnimationPlayer = $hurtAP

signal moved(dir: String)
const pngP1 = preload("res://Player/player1.png")
const pngP2 = preload("res://Player/player2.png")

const BASIC_ATTACK = preload("res://Attacks/Basic/Basic.tscn")
const BEAM = preload("res://Attacks/Beam/Beam.tscn")
const WIDE = preload("res://Attacks/Big/Big.tscn")
const MELEE = preload("res://Attacks/Melee/Melee.tscn")

var enabled : bool = false

var grid : Grid

var ebar : UIEnergyBar = null
var hpbar : UIHealthBar = null

var target_pos : Vector2i
var pos : Vector2i

var isP1 : bool = false
var isP2 : bool = false

var X_LOWER : int = -2
var X_UPPER : int = 2
var Y_LOWER : int
var Y_UPPER : int

var movement_tween : Tween = null

const MOVEMENT_TIME : float = 0.25

var basic_attack_timer : Timer = null
var big_attack_timer : Timer = null
var big_attack_animlock_timer : Timer = null
var charge_attack_timer : Timer = null
var charge_attack_animlock_timer : Timer = null
var melee_attack_timer : Timer = null
var melee_charge_attack_timer : Timer = null
var melee_animlock_timer : Timer = null

var animlock : bool = false

func _ready():
	add_timers()
	
func add_timers():	
	basic_attack_timer = Timer.new()
	basic_attack_timer.set_wait_time(BasicAttack.ANIMLOCK_TIME)
	basic_attack_timer.set_one_shot(true)
	basic_attack_timer.set_autostart(false)
	basic_attack_timer.timeout.connect(remove_animlock)
	
	add_child(basic_attack_timer)
	
	big_attack_timer = Timer.new()
	big_attack_timer.set_wait_time(BigAttack.CHARGE_TIME)
	big_attack_timer.set_one_shot(true)
	big_attack_timer.set_autostart(false)
	big_attack_timer.timeout.connect(fire_big_attack)
	
	add_child(big_attack_timer)

	big_attack_animlock_timer = Timer.new()
	big_attack_animlock_timer.set_wait_time(BigAttack.ANIMLOCK_TIME)
	big_attack_animlock_timer.set_one_shot(true)
	big_attack_animlock_timer.set_autostart(false)
	big_attack_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(big_attack_animlock_timer)
	
	charge_attack_timer = Timer.new()
	charge_attack_timer.set_wait_time(Beam.CHARGE_TIME)
	charge_attack_timer.set_one_shot(true)
	charge_attack_timer.set_autostart(false)
	charge_attack_timer.timeout.connect(enable_charged_ranged_fire_on_release)
	
	add_child(charge_attack_timer)
	
	charge_attack_animlock_timer = Timer.new()
	charge_attack_animlock_timer.set_wait_time(Beam.ANIMLOCK_TIME)
	charge_attack_animlock_timer.set_one_shot(true)
	charge_attack_animlock_timer.set_autostart(false)
	charge_attack_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(charge_attack_animlock_timer)
	
	melee_attack_timer = Timer.new()
	melee_attack_timer.set_wait_time(Melee.FIRST_DELAY_TIME)
	melee_attack_timer.set_one_shot(true)
	melee_attack_timer.set_autostart(false)
	melee_attack_timer.timeout.connect(start_charging_melee)
	
	add_child(melee_attack_timer)
	
	melee_charge_attack_timer = Timer.new()
	melee_charge_attack_timer.set_wait_time(Melee.CHARGE_TIME)
	melee_charge_attack_timer.set_one_shot(true)
	melee_charge_attack_timer.set_autostart(false)
	melee_charge_attack_timer.timeout.connect(enable_charged_melee_fire_on_release)
	
	add_child(melee_charge_attack_timer)
	
	melee_animlock_timer = Timer.new()
	melee_animlock_timer.set_wait_time(Melee.ANIMLOCK_TIME)
	melee_animlock_timer.set_one_shot(true)
	melee_animlock_timer.set_autostart(false)
	melee_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(melee_animlock_timer)

@warning_ignore("shadowed_variable")
func initialize(p1 : bool, p2 : bool, grid: Grid):
	self.grid = grid
	if p1:
		isP1 = true
		pos = Vector2i(0,-2)
		target_pos = Vector2i(0, -2)
		Y_LOWER = -4
		Y_UPPER = 0
		ebar = grid.ebar_1
		hpbar = grid.hpbar_1
		
		body_sprite.texture = pngP1
		hair_sprite.texture = pngP1
		hat_sprite.texture = pngP1
		
	elif p2:
		isP2 = true
		pos = Vector2i(0,3)
		target_pos = Vector2i(0, 3)
		Y_LOWER = 1
		Y_UPPER = 5
		ebar = grid.ebar_2
		hpbar = grid.hpbar_2
		
		body_sprite.texture = pngP2
		hair_sprite.texture = pngP2
		hat_sprite.texture = pngP2
		hair_sprite.flip_h = true
	else:
		push_warning("DID NOT INITIALIZE TO P1 OR P2")
	global_position = Globals.get_global_position(pos)
	
	ebar.reset(48, ebar.max)
	
var movement_input : String

#var ct : int = 1
func _physics_process(_delta: float) -> void:
	
	pos = Globals.get_pos(global_position)
	
	if enabled:
		if not animlock:
			get_movement_input()
		get_attack_input()
		update_animation_conditions()
	
	label.text = str(pos)
	label_2.text = str(charging_melee)
	#str(sm.get_current_node()) + str(move_sm.get_current_node())
	#+ str(tree.get("parameters/move/conditions/mvup")) + str(tree.get("parameters/move/conditions/mvdown")) + str(tree.get("parameters/move/conditions/mvleft")) + str(tree.get("parameters/move/conditions/mvright"))
	
	if isP1:
		if animlock:
			grid.inputs_1["movement"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_1["movement"].set_modulate(Color(1,1,1,1))
		if ebar.cur < ebar.COST:
			grid.inputs_1["charge"].set_modulate(Color(1,0,0,1))
			grid.inputs_1["big"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_1["charge"].set_modulate(Color(1,1,1,1))
			grid.inputs_1["big"].set_modulate(Color(1,1,1,1))
	elif isP2:
		if animlock:
			grid.inputs_2["movement"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_2["movement"].set_modulate(Color(1,1,1,1))
		if ebar.cur < ebar.COST:
			grid.inputs_2["charge"].set_modulate(Color(1,0,0,1))
			grid.inputs_2["big"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_2["charge"].set_modulate(Color(1,1,1,1))
			grid.inputs_2["big"].set_modulate(Color(1,1,1,1))
	

func hit(damage: int) -> void:
	
	hpbar.hit(damage)
	ebar.shrink(hpbar.cur / hpbar.max)
	
	if hpbar.cur < 1:
		ebar.update(0, ebar.max)
		ebar.gain = 0
		if isP1:
			print("1hurt")
			grid.p1died.emit()
		elif isP2:
			print("2hurt")
			grid.p2died.emit()

	grid.screenshake(1)
	#sm.travel("hurt")
	hurt_ap.play("hurt")
	# Interrupt attacks
	animlock = false
	charged_ranged = false
	if is_instance_valid(current_charge_ranged_attack):
		charge_attack_timer.stop()
		current_charge_ranged_attack.interrupt()
	big_attack_timer.stop()

func update_animation_conditions() -> void:
	var current_movement = Globals.get_global_position(target_pos) - global_position
	tree.set("parameters/move/conditions/mvup", current_movement.y < 0)
	tree.set("parameters/move/conditions/mvdown", current_movement.y > 0)
	tree.set("parameters/move/conditions/mvleft", current_movement.x < 0)
	tree.set("parameters/move/conditions/mvright", current_movement.x > 0)
	tree.set("parameters/move/conditions/mvidle", current_movement.length_squared() < 0.01)

func get_movement_input() -> void:
	if isP1:
		if Input.is_action_just_pressed("up1"):
			move ("up")
		if Input.is_action_just_pressed("down1"):
			move ("down")
		if Input.is_action_just_pressed("left1"):
			move ("left")
		if Input.is_action_just_pressed("right1"):
			move ("right")
	elif isP2:
		if Input.is_action_just_pressed("up2"):
			move ("up")
		if Input.is_action_just_pressed("down2"):
			move ("down")
		if Input.is_action_just_pressed("left2"):
			move ("left")
		if Input.is_action_just_pressed("right2"):
			move ("right")

var charged_ranged : bool = false
var current_charge_ranged_attack : Beam = null
var charging_melee : bool = false
var charged_melee : bool = false
var current_charged_melee_attack : Melee = null

func get_attack_input() -> String:
	
	if isP1:
		if Input.is_action_just_released("charge_ranged1"):
			release_charged_ranged()
		elif Input.is_action_just_released("melee2"):
			release_charged_melee()
		
		if not animlock:
			if Input.is_action_just_pressed("basic1"):
				press_basic()
				print("1basic")
			
			elif Input.is_action_just_pressed("melee1"):
				press_melee()
				print("1melee")
			
			elif ebar.cur_i > 0:
				if Input.is_action_just_pressed("charge_ranged1"):
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_charged_ranged()
					print("1beam")
				
				elif Input.is_action_just_pressed("big1"):
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_big()
	
	elif isP2:
		if Input.is_action_just_released("charge_ranged2"):
			release_charged_ranged()
		elif Input.is_action_just_released("melee2"):
			release_charged_melee()
		
		if not animlock:
			if Input.is_action_just_pressed("basic2"):
				press_basic()
				print("2basic")
				
			elif Input.is_action_just_pressed("melee2"):
				press_melee()
				print("2melee")
				
			elif ebar.cur_i >= 1:
				if Input.is_action_just_pressed("charge_ranged2"):
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_charged_ranged()
					print("2beam")
			
				elif Input.is_action_just_pressed("big2"):
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_big()
	return ""

func press_melee():
	animlock = true
	target_pos = Vector2i(pos.x, Y_UPPER - 1 if isP1 else Y_LOWER + 1)
	_move("up")
	melee_attack_timer.start()
	
	current_charged_melee_attack = MELEE.instantiate()
	melee_attack_timer.timeout.connect(current_charged_melee_attack.fire)
	current_charged_melee_attack.initialize(target_pos)
	current_charged_melee_attack.charging = true
	
	if isP1:
		grid.p1_hitboxes.add_child(current_charged_melee_attack)
	elif isP2:
		grid.p2_hitboxes.add_child(current_charged_melee_attack)

func start_charging_melee() -> void:
	print("start charging melee")
	if (isP1 and Input.is_action_pressed("melee1")) or (isP2 and Input.is_action_pressed("melee2")):
		current_charged_melee_attack.charge()
		melee_charge_attack_timer.start()
		charging_melee = true
	else:
		animlock = false

func release_charged_melee():
	print("release melee")
	if charged_melee:
		print("release charged melee at charged")
		charged_melee = false
		charging_melee = false
		current_charged_melee_attack.fire_charged()
		melee_animlock_timer.start()
		grid.screenshake(0.75)
		return
	# if it's done with the first attack
	elif charging_melee:
		melee_charge_attack_timer.stop()
		current_charged_melee_attack.queue_free()
		animlock = false
	
	charging_melee = false
	

func press_charged_ranged():
	animlock = true
	charge_attack_timer.start()
	current_charge_ranged_attack = BEAM.instantiate()
	current_charge_ranged_attack.initialize(target_pos)
	if isP1:
		grid.p1_hitboxes.add_child(current_charge_ranged_attack)
	elif isP2:
		grid.p2_hitboxes.add_child(current_charge_ranged_attack)

func release_charged_ranged():
	if charged_ranged:
		charged_ranged = false
		current_charge_ranged_attack.fire()
		charge_attack_animlock_timer.start()
		grid.screenshake(0.75)
	else:
		print("interrupt")
		charge_attack_timer.stop()
		animlock = false
		if is_instance_valid(current_charge_ranged_attack):
			current_charge_ranged_attack.interrupt()

func press_basic():
	animlock = true
	basic_attack_timer.start()
	var atk = BASIC_ATTACK.instantiate()
	atk.initialize(target_pos, Vector2i(0,-1), 4)
	if isP1:
		grid.p1_hitboxes.add_child(atk)
	elif isP2:
		grid.p2_hitboxes.add_child(atk)

func press_big() -> void:
	animlock = true
	big_attack_timer.start()
	

func fire_big_attack() -> void:
	animlock = true
	big_attack_animlock_timer.start()
	var atk = WIDE.instantiate()
	atk.initialize(target_pos, Vector2i(0,-1), 2)
	if isP1:
		grid.p1_hitboxes.add_child(atk)
	elif isP2:
		grid.p2_hitboxes.add_child(atk)

func enable_charged_ranged_fire_on_release() -> void:
	print("charged")
	charged_ranged = true

func enable_charged_melee_fire_on_release() -> void:
	print("charged melee")
	charged_melee = true

var already_buffered_move : bool = false
func move(dir: String):
	#var did_move : bool = false
	#var buffered_move : bool = false
	#if not already_buffered_move:
	match dir:
		"up":
			if (isP1 and pos.y < Y_UPPER) or (isP2 and pos.y > Y_LOWER):
				_move(dir)
				#print("up")
				##pos.y -= 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"down":
			if (isP1 and pos.y > Y_LOWER) or (isP2 and pos.y < Y_UPPER):
				_move(dir)
				#print("down")
				##pos.y += 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"left":
			if pos.x > X_LOWER:
				_move(dir)
				#print("left")
				##pos.x -= 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"right":
			if pos.x < X_UPPER:
				_move(dir)
				#print("right")
				##pos.x += 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		_:
			pass
	#print(buffered_move)
	#print(movement_timer.get_time_left())
	#
	#if did_move:
		#_move(dir)
	#
	#elif buffered_move:
		##already_buffered_move = true
		#print("buffering")
		#await movement_timer.timeout
		#already_buffered_move = false
		#_move(dir)
		

func _move(dir):
	#global_position = Globals.get_global_position(target_pos)
	
	match dir:
		"up":
			if isP1: target_pos.y += 1
			else: target_pos.y -= 1
		"down":
			if isP1: target_pos.y -= 1
			else: target_pos.y += 1
		"left":
			target_pos.x -= 1
		"right":
			target_pos.x += 1
	
	moved.emit(dir)
	
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", Globals.get_global_position(target_pos), MOVEMENT_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if isP1:
		print("1" + str(dir))
	else:
		print("2" + str(dir))

func get_has_iframes() -> bool:
	if is_instance_valid(hurt_ap):
		return hurt_ap.is_playing()
	else:
		return true

func remove_animlock() -> void:
	animlock = false
