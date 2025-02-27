class_name Player
extends Node2D

@onready var sprite: Sprite2D = $Sprites/Sprite2D
@onready var body_sprite: Sprite2D = $Sprites/BodySprite


#@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ap : AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var tree: AnimationTree = $AnimationTree
@onready var sm : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var move_sm : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/move/playback"]

signal moved(dir: String)
const pngP1 = preload("res://Player/player1.png")
const pngP2 = preload("res://Player/player2.png")
const BASIC_ATTACK = preload("res://Attacks/Basic/Basic.tscn")
const BEAM = preload("res://Attacks/Beam/Beam.tscn")
const WIDE = preload("res://Attacks/Basic/Wide.tscn")

var grid : Grid

var target_pos : Vector2i
var pos : Vector2i

var isP1 : bool = false
var isP2 : bool = false

var X_LOWER : int = -2
var X_UPPER : int = 2
var Y_LOWER : int
var Y_UPPER : int

var movement_tween : Tween = null

var movement_timer : Timer = null
const MOVEMENT_CD : float = 0.25
const MOVEMENT_BUFFER : float = 0.2

var basic_attack_timer : Timer = null
const BASIC_ATTACK_CD : float = 0.25

var big_attack_timer : Timer = null
const WIDE_ATTACK_CT : float = 0.5
var big_attack_animlock_timer : Timer = null
const WIDE_ATTACK_AT : float = 0.35

var charge_attack_timer : Timer = null
const BEAM_ATTACK_CT : float = 0.5
var charge_attack_animlock_timer : Timer = null
const CHARGE_ATTACK_AT : float = 0.2

var animlock : bool = false

func _ready():
	
	add_timers()
	
func add_timers():
	movement_timer = Timer.new()
	movement_timer.set_wait_time(MOVEMENT_CD)
	movement_timer.set_one_shot(true)
	movement_timer.set_autostart(false)
	
	add_child(movement_timer)
	
	basic_attack_timer = Timer.new()
	basic_attack_timer.set_wait_time(BASIC_ATTACK_CD)
	basic_attack_timer.set_one_shot(true)
	basic_attack_timer.set_autostart(false)
	basic_attack_timer.timeout.connect(remove_animlock)
	
	add_child(basic_attack_timer)
	
	big_attack_timer = Timer.new()
	big_attack_timer.set_wait_time(WIDE_ATTACK_CT)
	big_attack_timer.set_one_shot(true)
	big_attack_timer.set_autostart(false)
	big_attack_timer.timeout.connect(fire_big_attack)
	
	add_child(big_attack_timer)

	big_attack_animlock_timer = Timer.new()
	big_attack_animlock_timer.set_wait_time(WIDE_ATTACK_AT)
	big_attack_animlock_timer.set_one_shot(true)
	big_attack_animlock_timer.set_autostart(false)
	big_attack_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(big_attack_animlock_timer)
	
	charge_attack_timer = Timer.new()
	charge_attack_timer.set_wait_time(BEAM_ATTACK_CT)
	charge_attack_timer.set_one_shot(true)
	charge_attack_timer.set_autostart(false)
	charge_attack_timer.timeout.connect(enable_charged_ranged_fire_on_release)
	
	add_child(charge_attack_timer)
	
	charge_attack_animlock_timer = Timer.new()
	charge_attack_animlock_timer.set_wait_time(CHARGE_ATTACK_AT)
	charge_attack_animlock_timer.set_one_shot(true)
	charge_attack_animlock_timer.set_autostart(false)
	charge_attack_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(charge_attack_animlock_timer)

@warning_ignore("shadowed_variable")
func initialize(p1 : bool, p2 : bool, grid: Grid):
	self.grid = grid
	if p1:
		isP1 = true
		pos = Vector2i(0,-2)
		target_pos = Vector2i(0, -2)
		Y_LOWER = -4
		Y_UPPER = 0
	elif p2:
		isP2 = true
		pos = Vector2i(0,3)
		target_pos = Vector2i(0, 3)
		Y_LOWER = 1
		Y_UPPER = 5
	else:
		push_warning("DID NOT INITIALIZE TO P1 OR P2")
	global_position = Globals.get_global_position(pos)
	
var movement_input : String

var ct : int = 1
func _physics_process(_delta: float) -> void:
	
	pos = Globals.get_pos(global_position)
	
	if not animlock:
		get_movement_input()
	get_attack_input()
	update_animation_conditions()
	
	label.text = str(pos)
	label_2.text = str(move_sm.get_current_node()) + str(tree.get("parameters/move/conditions/mvup")) + str(tree.get("parameters/move/conditions/mvdown")) + str(tree.get("parameters/move/conditions/mvleft")) + str(tree.get("parameters/move/conditions/mvright"))
	
	#ct = (ct + 1) % 10
	#if ct == 0: print(move_sm.get_current_node())
	
	

func hit() -> void:
	#ap.play("hurt")
	print("hurt")
	sm.travel("hurt")
	
	# Interrupt attacks
	animlock = false
	charged_ranged = false
	if is_instance_valid(current_charge_attack):
		charge_attack_timer.stop()
		current_charge_attack.interrupt()
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
var current_charge_attack : Beam = null
signal released_charge1

func get_attack_input() -> String:
	
	if isP1:
		if Input.is_action_just_released("charge_ranged1"):
			if charged_ranged:
				charged_ranged = false
				released_charge1.emit()
				charge_attack_animlock_timer.start()
			else:
				print("interrupt")
				charge_attack_timer.stop()
				animlock = false
				if is_instance_valid(current_charge_attack):
					current_charge_attack.interrupt()
				
		
		if not animlock:
			if Input.is_action_just_pressed("basic1"):
				animlock = true
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(target_pos, Vector2i(0,-1), 4)
				grid.p1_hitboxes.add_child(atk)
		
				print("1basic")
			elif Input.is_action_just_pressed("charge_ranged1"):
				animlock = true
				charge_attack_timer.start()
				current_charge_attack = BEAM.instantiate()
				current_charge_attack.initialize(target_pos)
				grid.p1_hitboxes.add_child(current_charge_attack)
			
				released_charge1.connect(current_charge_attack.fire)
				print("1beam")
			
			elif Input.is_action_just_pressed("big1"):
				animlock = true
				big_attack_timer.start()
				
			
	elif isP2:
		if Input.is_action_just_released("charge_ranged2"):
			charge_attack_animlock_timer.start()
			if charged_ranged:
				charged_ranged = false
				released_charge1.emit()
			else:
				print("interrupt")
				charge_attack_timer.stop()
				if is_instance_valid(current_charge_attack):
					current_charge_attack.interrupt()
				
		if not animlock:
			if Input.is_action_just_pressed("basic2"):
				animlock = true
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(target_pos, Vector2i(0,-1), 4)
				grid.p2_hitboxes.add_child(atk)
				
				print("2basic")
			elif Input.is_action_just_pressed("charge_ranged2"):
				animlock = true
				charge_attack_timer.start()
				current_charge_attack = BEAM.instantiate()
				current_charge_attack.initialize(target_pos)
				grid.p2_hitboxes.add_child(current_charge_attack)
				
				released_charge1.connect(current_charge_attack.fire)
				print("2beam")
			elif Input.is_action_just_pressed("big2"):
				animlock = true
				big_attack_timer.start()
	return ""

func fire_big_attack() -> void:
	animlock = true
	big_attack_animlock_timer.start()
	var atk = WIDE.instantiate()
	atk.initialize(target_pos, Vector2i(0,-1), 2)
	grid.p2_hitboxes.add_child(atk)

func enable_charged_ranged_fire_on_release() -> void:
	print("charged")
	charged_ranged = true

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
	
	movement_timer.start()
	
	moved.emit(dir)
	
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", Globals.get_global_position(target_pos), MOVEMENT_CD).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	movement_timer.start()
	if isP1:
		print("1" + str(dir))
	else:
		print("2" + str(dir))

func basic_attack() -> void:
	
	pass

func get_has_iframes() -> bool:
	if is_instance_valid(sm):
		return sm.get_current_node() == "hurt"
	else:
		return true

func remove_animlock() -> void:
	animlock = false
