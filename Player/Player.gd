class_name Player
extends Node2D

signal moved(dir: String)

const BASIC_ATTACK = preload("res://Attacks/Basic.tscn")

var grid : Grid

var pos : Vector2i

var isP1 : bool = false
var isP2 : bool = false

var X_LOWER : int = -2
var X_UPPER : int = 2
var Y_LOWER : int
var Y_UPPER : int

var movement_timer : Timer = null
const MOVEMENT_CD : float = 0.25

var iframes_timer : Timer = null
const IFRAMES : float = 1

var basic_attack_timer : Timer = null
const BASIC_ATTACK_CD : float = 0.25

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

	iframes_timer = Timer.new()
	iframes_timer.set_wait_time(IFRAMES)
	iframes_timer.set_one_shot(true)
	iframes_timer.set_autostart(false)
	
	add_child(iframes_timer)

@warning_ignore("shadowed_variable")
func initialize(p1 : bool, p2 : bool, grid: Grid):
	self.grid = grid
	if p1:
		isP1 = true
		pos = Vector2i(0,-5)
		Y_LOWER = -5
		Y_UPPER = -1
	elif p2:
		isP2 = true
		pos = Vector2i(0,5)
		Y_LOWER = 1
		Y_UPPER = 5
	else:
		push_warning("DID NOT INITIALIZE TO P1 OR P2")
	global_position = pos * 32
	
var movement_input : String

func _physics_process(_delta: float) -> void:
	movement_input = get_movement_input()
	if movement_input:
		move(movement_input)
	
	get_attack_input()

func get_movement_input() -> String:
	if isP1:
		if Input.is_action_just_pressed("up1"):
			return ("up")
		elif Input.is_action_just_pressed("down1"):
			return ("down")
		elif Input.is_action_just_pressed("left1"):
			return ("left")
		elif Input.is_action_just_pressed("right1"):
			return ("right")
	elif isP2:
		if Input.is_action_just_pressed("up2"):
			return ("up")
		elif Input.is_action_just_pressed("down2"):
			return ("down")
		elif Input.is_action_just_pressed("left2"):
			return ("left")
		elif Input.is_action_just_pressed("right2"):
			return ("right")
	return ""

func get_attack_input() -> String:
	
	if basic_attack_timer.is_stopped():
		if isP1:
			if Input.is_action_just_pressed("basic1"):
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(pos, Vector2i(0,1), 0.2)
				grid.p1_hitboxes.add_child(atk)
		
				print("1basic")
		elif isP2:
			if Input.is_action_just_pressed("basic2"):
				basic_attack_timer.start()
				var atk = BASIC_ATTACK.instantiate()
				atk.initialize(pos, Vector2i(0,-1), 0.2)
				grid.p2_hitboxes.add_child(atk)
				
				print("2basic")
	return ""

func move(dir: String):
	
	if movement_timer.is_stopped():
		var did_move : bool = false
		match dir:
			"up":
				if pos.y > Y_LOWER:
					pos.y -= 1
					did_move = true
			"down":
				if pos.y < Y_UPPER:
					pos.y += 1
					did_move = true
			"left":
				if pos.x > X_LOWER:
					pos.x -= 1
					did_move = true
			"right":
				if pos.x < X_UPPER:
					pos.x += 1
					did_move = true
			_:
				pass
		if did_move:
			moved.emit(dir)
			movement_timer.start()
			if isP1:
				print("1" + str(dir))
			else:
				print("2" + str(dir))
func basic_attack() -> void:
	
	pass

func get_has_iframes() -> bool:
	if iframes_timer:
		return not iframes_timer.is_stopped
	else:
		return true
