class_name Player
extends Node2D

#@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ap : AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var tree: AnimationTree = $AnimationTree
@onready var sm : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

signal moved(dir: String)

const BASIC_ATTACK = preload("res://Attacks/Basic.tscn")

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

var movement_locked : bool = false

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
	
	add_child(basic_attack_timer)

@warning_ignore("shadowed_variable")
func initialize(p1 : bool, p2 : bool, grid: Grid):
	self.grid = grid
	if p1:
		isP1 = true
		pos = Vector2i(0,-4)
		target_pos = Vector2i(0, -4)
		Y_LOWER = -4
		Y_UPPER = 0
	elif p2:
		isP2 = true
		pos = Vector2i(0,5)
		target_pos = Vector2i(0, 5)
		Y_LOWER = 1
		Y_UPPER = 5
	else:
		push_warning("DID NOT INITIALIZE TO P1 OR P2")
	global_position = Globals.get_global_position(pos)
	
var movement_input : String

func _physics_process(_delta: float) -> void:
	
	pos = Globals.get_pos(global_position)
	
	movement_locked = not basic_attack_timer.is_stopped()
	
	if not movement_locked:
		get_movement_input()
	
	get_attack_input()
	
	label.text = str(pos)

func hit() -> void:
	ap.play("hurt")
	print("hurt")
	sm.travel("hurt")

func update_animation_conditions() -> void:
	var current_movement = Globals.get_global_position(target_pos) - global_position
	tree.set("parameters/move/conditions/mvup", current_movement.y < 0)
	tree.set("parameters/move/conditions/mvdown", current_movement.y > 0)
	tree.set("parameters/move/conditions/mvleft", current_movement.x < 0)
	tree.set("parameters/move/conditions/mvright", current_movement.x > 0)
	tree.set("parameters/move/conditions/mvidle", current_movement.length_squared() < 0.08)
	pass

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

func get_attack_input() -> String:
	
	if basic_attack_timer.is_stopped():
		if isP1:
			if Input.is_action_just_pressed("basic1"):
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(pos, Vector2i(0,1), 4)
				grid.p1_hitboxes.add_child(atk)
		
				print("1basic")
		elif isP2:
			if Input.is_action_just_pressed("basic2"):
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(pos, Vector2i(0,-1), 4)
				grid.p2_hitboxes.add_child(atk)
				
				print("2basic")
	return ""

var already_buffered_move : bool = false
func move(dir: String):
	#var did_move : bool = false
	#var buffered_move : bool = false
	#if not already_buffered_move:
	match dir:
		"up":
			if pos.y > Y_LOWER:
				_move(dir)
				#print("up")
				##pos.y -= 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"down":
			if pos.y < Y_UPPER:
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
			target_pos.y -= 1
		"down":
			target_pos.y += 1
		"left":
			target_pos.x -= 1
		"right":
			target_pos.x += 1
	
	movement_timer.start()
	
	moved.emit(dir)
	
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.tween_property(self, "global_position", Globals.get_global_position(target_pos), MOVEMENT_CD*0.8).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	movement_timer.start()
	if isP1:
		print("1" + str(dir))
	else:
		print("2" + str(dir))

func basic_attack() -> void:
	
	pass

func get_has_iframes() -> bool:
	if sm != null:
		return sm.get_current_node() == "hurt"
	else:
		return false
