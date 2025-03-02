class_name Player
extends Node2D

@onready var sprite_container: Node2D = $Sprites
@onready var body_sprite: Sprite2D = $Sprites/BodySprite
@onready var hair_sprite: RandomSprite2D = $Sprites/HairRandomSprite
@onready var hat_sprite: Sprite2D = $Sprites/HatSprite
@onready var lock_sprite: Sprite2D = $Sprites/LockSprite
@onready var charge_particles: CPUParticles2D = $Sprites/ChargeParticles

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

const LIGHT = preload("res://Attacks/Light/Light.tscn")
const CHARGE = preload("res://Attacks/Charge/Charge.tscn")
const HEAVY = preload("res://Attacks/Heavy/Heavy.tscn")

const LIGHT_2 = preload("res://Attacks/Light2/Light2.tscn")
const HEAVY_2 = preload("res://Attacks/Heavy2/Heavy2.tscn")
const CHARGE_2 = preload("res://Attacks/Charge2/Charge2.tscn")

const MELEE = preload("res://Attacks/Melee/Melee.tscn")

var enabled : bool = false
var grid : Grid

var ebar : UIEnergyBar = null
var hpbar : UIHealthBar = null

var target_pos : Vector2i
var pos : Vector2i

var isP1 : bool = false
var isP2 : bool = false

var skills : Dictionary
var char : Globals.CHARS = 1

var X_LOWER : int = -2
var X_UPPER : int = 2
var Y_LOWER : int
var Y_UPPER : int

var movement_tween : Tween = null

const MOVEMENT_TIME : float = 0.25

var light_attack_timer : Timer = null
var basic_attack_cd_timer : Timer = null
var heavy_attack_timer : Timer = null
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
	light_attack_timer = Timer.new()
	light_attack_timer.set_wait_time(LightAttack.ANIMLOCK_TIME)
	light_attack_timer.set_one_shot(true)
	light_attack_timer.set_autostart(false)
	light_attack_timer.timeout.connect(remove_animlock)
	
	add_child(light_attack_timer)
	
	basic_attack_cd_timer = Timer.new()
	basic_attack_cd_timer.set_one_shot(true)
	basic_attack_cd_timer.set_autostart(false)
	
	add_child(basic_attack_cd_timer)
	
	heavy_attack_timer = Timer.new()
	heavy_attack_timer.set_one_shot(true)
	heavy_attack_timer.set_autostart(false)
	heavy_attack_timer.timeout.connect(fire_big_attack)
	
	add_child(heavy_attack_timer)

	big_attack_animlock_timer = Timer.new()
	big_attack_animlock_timer.set_one_shot(true)
	big_attack_animlock_timer.set_autostart(false)
	big_attack_animlock_timer.timeout.connect(remove_animlock)
	
	add_child(big_attack_animlock_timer)
	
	charge_attack_timer = Timer.new()
	charge_attack_timer.set_one_shot(true)
	charge_attack_timer.set_autostart(false)
	charge_attack_timer.timeout.connect(enable_charged_fire_on_release)
	
	add_child(charge_attack_timer)
	
	charge_attack_animlock_timer = Timer.new()
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
		
		skills = Globals.p1_skills
		
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
		
		skills = Globals.p2_skills
		
		body_sprite.texture = pngP2
		hair_sprite.texture = pngP2
		hat_sprite.texture = pngP2
		hair_sprite.flip_h = true
		
		char = 2
	else:
		push_warning("DID NOT INITIALIZE TO P1 OR P2")
	global_position = Globals.get_global_position(pos)
	
	ebar.reset(48, ebar.max)
	
var movement_input : String

#var ct : int = 1
func _physics_process(_delta: float) -> void:
	
	pos = Globals.get_pos(global_position)
	
	ebar.global_position = global_position + Vector2(0, 24)
	
	if enabled and Globals.scene_switcher.enable_inputs:
		if not animlock:
			get_movement_input()
		get_attack_input()
		update_animation_conditions()
	
	label.text = str(pos)
	label_2.text = str(charging_melee)
	#str(sm.get_current_node()) + str(move_sm.get_current_node())
	#+ str(tree.get("parameters/move/conditions/mvup")) + str(tree.get("parameters/move/conditions/mvdown")) + str(tree.get("parameters/move/conditions/mvleft")) + str(tree.get("parameters/move/conditions/mvright"))
	updateInputDisplay()

func updateInputDisplay() -> void:
	if isP1:
		if animlock:
			grid.inputs_1["movement"].set_modulate(Color(1,0,0,1))
			lock_sprite.visible = true
		else:
			grid.inputs_1["movement"].set_modulate(Color(1,1,1,1))
			lock_sprite.visible = false
		if ebar.cur < ebar.COST:
			grid.inputs_1["charge"].set_modulate(Color(1,0,0,1))
			grid.inputs_1["heavy"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_1["charge"].set_modulate(Color(1,1,1,1))
			grid.inputs_1["heavy"].set_modulate(Color(1,1,1,1))
		if basic_attack_cd_timer.is_stopped():
			grid.inputs_1["light"].set_modulate(Color(1,1,1,1))
		else:
			grid.inputs_1["light"].set_modulate(Color(1,0,0,1))	
	elif isP2:
		if animlock:
			grid.inputs_2["movement"].set_modulate(Color(1,0,0,1))
			lock_sprite.visible = true
		else:
			grid.inputs_2["movement"].set_modulate(Color(1,1,1,1))
			lock_sprite.visible = false
		if ebar.cur < ebar.COST:
			grid.inputs_2["charge"].set_modulate(Color(1,0,0,1))
			grid.inputs_2["heavy"].set_modulate(Color(1,0,0,1))
		else:
			grid.inputs_2["charge"].set_modulate(Color(1,1,1,1))
			grid.inputs_2["heavy"].set_modulate(Color(1,1,1,1))
		if basic_attack_cd_timer.is_stopped():
			grid.inputs_2["light"].set_modulate(Color(1,1,1,1))
		else:
			grid.inputs_2["light"].set_modulate(Color(1,0,0,1))

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
	if is_instance_valid(current_charge):
		charge_attack_timer.stop()
		current_charge.interrupt()
		start_charge_flash(0.0)
	heavy_attack_timer.stop()

func update_animation_conditions() -> void:
	var current_movement = Globals.get_global_position(target_pos) - global_position
	tree.set("parameters/move/conditions/mvup", current_movement.y < -0.1)
	tree.set("parameters/move/conditions/mvdown", current_movement.y > 0.1)
	tree.set("parameters/move/conditions/mvleft", current_movement.x < -0.1)
	tree.set("parameters/move/conditions/mvright", current_movement.x > 0.1)
	tree.set("parameters/move/conditions/mvidle", current_movement.length_squared() < 0.01)
	
	if animlock:
		sm.travel("attack")
	else:
		sm.travel("move")

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
var current_charge : Hitbox = null
var charging_melee : bool = false
var charged_melee : bool = false
var current_charge_melee : Melee = null

func get_attack_input() -> String:
	
	if isP1:
		if Input.is_action_just_released("charge1"):
			release_charged_ranged()
		elif Input.is_action_just_released("melee1"):
			release_charged_melee()
		
		if not animlock:
			if Input.is_action_just_pressed("light1") and basic_attack_cd_timer.is_stopped():
				press_basic()
				print("1basic")
			
			elif Input.is_action_just_pressed("melee1"):
				press_melee()
				print("1melee")
			
			if Input.is_action_just_pressed("charge1"):
				if ebar.cur_i >= 1:
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_charged_ranged()
					print("1beam")
				else:
					ebar.shake_counter(1.0)
				
			elif Input.is_action_just_pressed("heavy1"):
				if ebar.cur_i >= 1:
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_heavy()
				else:
					ebar.shake_counter(1.0)
	
	elif isP2:
		if Input.is_action_just_released("charge2"):
			release_charged_ranged()
		elif Input.is_action_just_released("melee2"):
			release_charged_melee()
		
		if not animlock:
			if Input.is_action_just_pressed("light2") and basic_attack_cd_timer.is_stopped():
				press_basic()
				print("2basic")
				
			elif Input.is_action_just_pressed("melee2"):
				press_melee()
				print("2melee")
				
			elif Input.is_action_just_pressed("charge2"):
				if ebar.cur_i >= 1:
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_charged_ranged()
					print("2beam")
				else:
					ebar.shake_counter(1.0)
			
			elif Input.is_action_just_pressed("heavy2"):
				if ebar.cur_i >= 1:
					ebar.update(ebar.cur - ebar.COST, ebar.max)
					press_heavy()
				else:
					ebar.shake_counter(1.0)
	return ""

func press_melee():
	animlock = true
	target_pos = Vector2i(target_pos.x, Y_UPPER - 1 if isP1 else Y_LOWER + 1)
	_move("up")
	melee_attack_timer.start()
	
	current_charge_melee = MELEE.instantiate()
	melee_attack_timer.timeout.connect(current_charge_melee.fire_first)
	current_charge_melee.initialize(target_pos)
	current_charge_melee.charging = true
	
	add_hitbox(current_charge_melee)

func start_charging_melee() -> void:
	if (isP1 and Input.is_action_pressed("melee1")) or (isP2 and Input.is_action_pressed("melee2")):
		current_charge_melee.charge()
		melee_charge_attack_timer.start()
		charging_melee = true
		charge_particles.emitting = true
	else:
		animlock = false

func release_charged_melee():
	print("release melee")
	charge_particles.emitting = false
	if charged_melee:
		print("release charged melee at charged")
		start_charge_flash(0.0)
		charged_melee = false
		charging_melee = false
		current_charge_melee.fire_charged()
		melee_animlock_timer.start()
		grid.screenshake(0.75)
		return
	# if it's done with the first attack
	elif charging_melee:
		melee_charge_attack_timer.stop()
		current_charge_melee.queue_free()
		animlock = false
	
	if is_instance_valid(current_charge_melee):
		current_charge_melee.charging = false
	charging_melee = false

func press_charged_ranged():
	animlock = true
	charge_particles.emitting = true
	if skills[Globals.SKILLS.CHARGE] == 1:
		current_charge = CHARGE.instantiate()
		current_charge.initialize(target_pos)
	elif skills[Globals.SKILLS.CHARGE] == 2:
		current_charge = CHARGE_2.instantiate()
		current_charge.initialize(Vector2i(target_pos.x, 1 - target_pos.y))
	charge_attack_timer.start(current_charge.CHARGE_TIME)
	add_hitbox(current_charge)

func release_charged_ranged():
	if charged_ranged:
		start_charge_flash(0.0)
		charged_ranged = false
		current_charge.fire()
		charge_attack_animlock_timer.start(current_charge.ANIMLOCK_TIME)
		grid.screenshake(0.75)
	elif not charging_melee:
		charge_particles.emitting = false
		print("interrupt")
		charge_attack_timer.stop()
		animlock = false
		if is_instance_valid(current_charge):
			current_charge.interrupt()

func press_basic():
	animlock = true
	light_attack_timer.start()
	
	if skills[Globals.SKILLS.LIGHT] == 1:
	
		var atk = LIGHT.instantiate()
		atk.initialize(target_pos, Vector2i(0,-1), 4)
		add_hitbox(atk)
			
		basic_attack_cd_timer.start(atk.COOLDOWN)
	
	elif skills[Globals.SKILLS.LIGHT] == 2:
		
		var atk = LIGHT_2.instantiate()
		atk.initialize(Vector2i(target_pos.x, 1 - target_pos.y)) # 5 <-> -4, 4 <-> -3, etc.
		add_hitbox(atk)
		atk.fire()
	
		basic_attack_cd_timer.start(atk.COOLDOWN)

func press_heavy() -> void:
	animlock = true
	if skills[Globals.SKILLS.HEAVY] == 1:
		heavy_attack_timer.start(HeavyAttack.CHARGE_TIME)
	elif skills[Globals.SKILLS.HEAVY] == 2:
		heavy_attack_timer.start(HeavyAttack2.CHARGE_TIME)

func fire_big_attack() -> void:
	animlock = true
	big_attack_animlock_timer.start()
	
	if skills[Globals.SKILLS.HEAVY] == 1:
		var atk = HEAVY.instantiate()
		atk.initialize(target_pos, Vector2i(0,-1), 2)
		add_hitbox(atk)
	
	elif skills[Globals.SKILLS.HEAVY] == 2:
		var atk = HEAVY_2.instantiate()	
		atk.initialize(target_pos, -1 if isP1 else 1) # dir is -1 if p1, -1 if p2, to move downward
		add_hitbox(atk)

func enable_charged_fire_on_release() -> void:
	print("charged")
	charged_ranged = true
	charge_particles.emitting = false
	start_charge_flash(1.0)

func enable_charged_melee_fire_on_release() -> void:
	print("charged melee")
	charged_melee = true
	charge_particles.emitting = false
	start_charge_flash(1.0)

func move(dir: String):
	#var did_move : bool = false
	#var buffered_move : bool = false
	#if not already_buffered_move:
	match dir:
		"up":
			if (isP1 and target_pos.y < Y_UPPER) or (isP2 and target_pos.y > Y_LOWER):
				_move(dir)
				#print("up")
				##pos.y -= 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"down":
			if (isP1 and target_pos.y > Y_LOWER) or (isP2 and target_pos.y < Y_UPPER):
				_move(dir)
				#print("down")
				##pos.y += 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"left":
			if target_pos.x > X_LOWER:
				_move(dir)
				#print("left")
				##pos.x -= 1
				#did_move = movement_timer.is_stopped()
				#buffered_move = movement_timer.get_time_left() < MOVEMENT_BUFFER
		"right":
			if target_pos.x < X_UPPER:
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

func add_hitbox(atk : Hitbox) -> void:
	if isP1:
		grid.p1_hitboxes.add_child(atk)
	elif isP2:
		grid.p2_hitboxes.add_child(atk)

func start_charge_flash(strength: float) -> void:
	sprite_container.material.set_shader_parameter("strength", strength)
	sprite_container.material.set_shader_parameter("start_time", Time.get_ticks_msec() / 1000.0)
	print("start charge flash")
