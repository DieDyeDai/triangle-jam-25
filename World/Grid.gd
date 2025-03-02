class_name Grid extends Node

const PLAYER = preload("res://Player/Player.tscn")
const TILERED = preload("res://World/TileRed.tscn")
const TILEBLUE = preload("res://World/TileBlue.tscn")

@onready var camera : Camera2D = $Camera2D
@onready var hpbar_1 : UIHealthBar = $UIHealthBar1
@onready var hpbar_2 : UIHealthBar = $UIHealthBar2
@onready var ebar_1: UIEnergyBar = $UIEnergyBar1
@onready var ebar_2: UIEnergyBar = $UIEnergyBar2

#@onready var canvas_layer: ColorRect = $CanvasLayer

@onready var uioverlay : UIOverlay = $UIOverlay

@onready var keys_movement_1: Sprite2D = $KeysMovement1
@onready var key_action_a: Sprite2D = $KeyActionA
@onready var key_action_z: Sprite2D = $KeyActionZ
@onready var key_action_x: Sprite2D = $KeyActionX
@onready var key_action_s: Sprite2D = $KeyActionS
@onready var key_label_1: Sprite2D = $KeyLabel1

@onready var inputs_1 : Dictionary = {
	"movement": keys_movement_1,
	"melee": key_action_a,
	"charge": key_action_z,
	"light": key_action_x,
	"heavy": key_action_s,
}

@onready var keys_movement_2: Sprite2D = $KeysMovement2
@onready var key_action_i: Sprite2D = $KeyActionI
@onready var key_action_k: Sprite2D = $KeyActionK
@onready var key_action_l: Sprite2D = $KeyActionL
@onready var key_action_o: Sprite2D = $KeyActionO
@onready var key_label_2: Sprite2D = $KeyLabel2

@onready var inputs_2 : Dictionary = {
	"movement": keys_movement_2,
	"melee": key_action_i,
	"charge": key_action_k,
	"light": key_action_l,
	"heavy": key_action_o,
}

@warning_ignore("unused_signal")
signal p1died
@warning_ignore("unused_signal")
signal p2died

var p1 : Player
var p2 : Player

var p1_hitboxes : Node = null
var p2_hitboxes : Node = null

var p1_tile_container : Node = null
var p2_tile_container : Node = null

var p1_tiles : Dictionary
var p2_tiles : Dictionary

var screenshake_timer : Timer = null
const SCREENSHAKE_STR : float = 50
const SCREENSHAKE_TIME : float = 0.12

var timescale_tween : Tween = null

func _ready() -> void:
	
	##Ensure hitboxes and movement are processed last.
	set_deferred("process_physics_priority", 1)
	
	p1died.connect(self.on_p1_died)
	p2died.connect(self.on_p2_died)
	
	hpbar_1.reset(10, 10)
	hpbar_2.reset(10, 10)
	
	screenshake_timer = Timer.new()
	screenshake_timer.set_autostart(false)
	screenshake_timer.set_one_shot(true)
	add_child(screenshake_timer)
	
	hpbar_1.set_global_position(Globals.get_global_position(Vector2i(-3, -3)) + Vector2(12, 0))
	ebar_1.set_global_position(Globals.get_global_position(Vector2i(-3, -3)))
	#ebar_1.counter.scale.x = -1
	ebar_1.counter.initialize(true, false)
	
	hpbar_2.set_global_position(Globals.get_global_position(Vector2i(3,4)) + Vector2(-12, 0))
	ebar_2.set_global_position(Globals.get_global_position(Vector2i(3,4)))
	ebar_2.counter.initialize(false, true)
	
	if Globals.p1_skills[Globals.SKILLS.LIGHT] == 1:
		inputs_1["light"].frame = 10
	elif Globals.p1_skills[Globals.SKILLS.LIGHT] == 2:
		inputs_1["light"].frame = 18
	
	if Globals.p1_skills[Globals.SKILLS.HEAVY] == 1:
		inputs_1["heavy"].frame = 11
	elif Globals.p1_skills[Globals.SKILLS.HEAVY] == 2:
		inputs_1["heavy"].frame = 19
	
	if Globals.p1_skills[Globals.SKILLS.CHARGE] == 1:
		inputs_1["charge"].frame = 9
	elif Globals.p1_skills[Globals.SKILLS.CHARGE] == 2:
		inputs_1["charge"].frame = 17
	
	if Globals.p2_skills[Globals.SKILLS.LIGHT] == 1:
		inputs_2["light"].frame = 14
	elif Globals.p2_skills[Globals.SKILLS.LIGHT] == 2:
		inputs_2["light"].frame = 22
	
	if Globals.p2_skills[Globals.SKILLS.HEAVY] == 1:
		inputs_2["heavy"].frame = 15
	elif Globals.p2_skills[Globals.SKILLS.HEAVY] == 2:
		inputs_2["heavy"].frame = 23
	
	if Globals.p2_skills[Globals.SKILLS.CHARGE] == 1:
		inputs_2["charge"].frame = 13
	elif Globals.p2_skills[Globals.SKILLS.CHARGE] == 2:
		inputs_2["charge"].frame = 21
	
	var inputs1_starting_pos = Globals.get_global_position(Vector2i(0,-5))
	inputs_1["movement"].set_global_position(inputs1_starting_pos + Vector2(40, 24))
	inputs_1["melee"].set_global_position(inputs1_starting_pos + Vector2(-24, 24))
	inputs_1["heavy"].set_global_position(inputs1_starting_pos + Vector2(-8, 24))
	inputs_1["charge"].set_global_position(inputs1_starting_pos + Vector2(-16, 48))
	inputs_1["light"].set_global_position(inputs1_starting_pos + Vector2(0, 48))
	
	key_label_1.set_global_position(inputs1_starting_pos + Vector2(-9, 4))
	
	var inputs2_starting_pos = Globals.get_global_position(Vector2i(0,6))
	inputs_2["movement"].set_global_position(inputs2_starting_pos + Vector2(40, 24))
	inputs_2["melee"].set_global_position(inputs2_starting_pos + Vector2(-24, 24))
	inputs_2["heavy"].set_global_position(inputs2_starting_pos + Vector2(-8, 24))
	inputs_2["charge"].set_global_position(inputs2_starting_pos + Vector2(-16, 48))
	inputs_2["light"].set_global_position(inputs2_starting_pos + Vector2(0, 48))
	
	key_label_2.set_global_position(inputs2_starting_pos + Vector2(-9, 4))
	
	for i in range(Globals.X_LOWER, Globals.X_UPPER + 1, 1):
		p1_tiles[i] = {}
		p2_tiles[i] = {}
	
	p1_tile_container = Node.new()
	p2_tile_container = Node.new()
	add_child(p1_tile_container)
	add_child(p2_tile_container)
	for i in range(Globals.X_LOWER, Globals.X_UPPER + 1, 1):
		for j in range(Globals.Y_LOWER_1,Globals.Y_UPPER_1 + 1,1):
			var new_tile : Tile = TILERED.instantiate()
			new_tile.global_position = Globals.get_global_position(Vector2i(i,j))
			p1_tiles[i][j] = new_tile
			p1_tile_container.add_child(new_tile)
	for i in range(Globals.X_LOWER, Globals.X_UPPER + 1, 1):
		for j in range(Globals.Y_LOWER_2,Globals.Y_UPPER_2 + 1,1):
			var new_tile : Tile = TILEBLUE.instantiate()
			new_tile.global_position = Globals.get_global_position(Vector2i(i,j))
			p2_tiles[i][j] = new_tile
			p2_tile_container.add_child(new_tile)
	
	p1_hitboxes = Node.new()
	p2_hitboxes = Node.new()
	add_child(p1_hitboxes)
	add_child(p2_hitboxes)
	
	p1 = PLAYER.instantiate()
	p2 = PLAYER.instantiate()
	add_child(p1)
	add_child(p2)
	p1.initialize(true, false, self)
	p2.initialize(false, true, self)
	
	ebar_1.gain = 0
	ebar_2.gain = 0
	
	Globals.scene_switcher.done_loading.connect(self.on_done_loading_enable_players)

func on_done_loading_enable_players() -> void:
	uioverlay.on_load()
	
	await uioverlay.done_playing
	
	ebar_1.gain = ebar_1.GAIN_INITIAL
	ebar_2.gain = ebar_2.GAIN_INITIAL
	p1.enabled = true
	p2.enabled = true

var p1won : bool = false
var p2won : bool = false
var game_over : bool = false
func on_p1_died() -> void:
	p2won = true
	Globals.p2score += 1
	on_player_win()

func on_p2_died() -> void:
	p1won = true
	Globals.p1score += 1
	on_player_win()

func on_player_win() -> void:
	game_over = true
	timeslow(0.1, 2.0)
	p1.enabled = false
	p2.enabled = false
	
	ebar_1.gain = 0
	ebar_2.gain = 0
	if p1won:
		uioverlay.on_win(true, false)
	elif p2won:
		uioverlay.on_win(false, true)

func _physics_process(_delta: float) -> void:
	
	reset_tile_sprites_and_show_players()
	if !game_over:
		process_hitboxes()
	
	#if Input.is_action_just_pressed("debug1"):
		#for i in p1_tiles.values():
			#for j in i.values():
				#print(j)
	
	#if Input.is_action_just_pressed("debug2"):
		#timeslow(0.2, 1.0)
	
	# timeslow
	
	if timescale_tween:
		timescale_tween.set_speed_scale(1.0 / Engine.time_scale)
	
	# screenshake
	
	if screenshake_timer.get_time_left() > 0.01:
		camera.offset = Vector2(SCREENSHAKE_STR * screenshake_timer.get_time_left(), 0).rotated(randf_range(0, 2 * PI)) + Vector2(0, Globals.TILE_HEIGHT)
	else:
		camera.offset = Vector2(0, Globals.TILE_HEIGHT)

	#if Input.is_action_just_pressed("debug1"):
		#screenshake(1.0)
		#ebar_1.update(ebar_1.cur - 30, ebar_1.max)
		#ebar_2.update(ebar_2.cur - 30, ebar_2.max)
	
	if game_over and !uioverlay.is_playing and Globals.scene_switcher.enable_inputs:
		if Input.is_action_just_pressed("restart"):
			Globals.scene_switcher.handle_scene_change({"next_scene": preload("res://World/Grid.tscn")})
		if Input.is_action_just_pressed("back"):
			Globals.scene_switcher.handle_scene_change({"next_scene": preload("res://UI/SkillSelectMenu.tscn"),
			"hack": "yes"})
	
	if Input.is_action_just_pressed("back"):
		Globals.scene_switcher.handle_scene_change({"next_scene": preload("res://UI/SkillSelectMenu.tscn"),
			"hack": "yes"})
	

func screenshake(strength : float) -> void:
	screenshake_timer.start(SCREENSHAKE_TIME * strength)

func timeslow(strength : float, duration : float) -> void:
	if timescale_tween:
		timescale_tween.kill()
	timescale_tween = get_tree().create_tween()
	timescale_tween.tween_property(Engine, "time_scale", 1.0, duration).from(strength).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func reset_tile_sprites_and_show_players() -> void:
	Globals.reset_tile_sprites.emit()
	(p1_tiles[p1.pos.x][p1.pos.y] as Tile).show_player()
	(p2_tiles[p2.pos.x][p2.pos.y] as Tile).show_player()

func process_hitboxes() -> void:
	
	for hitbox in p2_hitboxes.get_children():
		if hitbox is Hitbox:
			for hitbox_pos in hitbox.positions:
				if (p1_tiles[hitbox_pos.x] as Dictionary).has(hitbox_pos.y):
					(p1_tiles[hitbox_pos.x][hitbox_pos.y] as Tile).show_hitbox()
				if not p1.get_has_iframes() and p1.pos == hitbox_pos:
					timeslow(0.2, 0.5)
					p1.hit(hitbox.damage)
			for hitbox_warning_pos in hitbox.warning_positions:
				if (p1_tiles[hitbox_warning_pos.x] as Dictionary).has(hitbox_warning_pos.y):
					(p1_tiles[hitbox_warning_pos.x][hitbox_warning_pos.y] as Tile).show_warning()

	for hitbox in p1_hitboxes.get_children():
		if hitbox is Hitbox:
			for hitbox_pos in hitbox.positions:
				if (p2_tiles[hitbox_pos.x] as Dictionary).has(hitbox_pos.y):
					(p2_tiles[hitbox_pos.x][hitbox_pos.y] as Tile).show_hitbox()
				if not p2.get_has_iframes() and p2.pos == hitbox_pos:
					timeslow(0.2, 0.5)
					p2.hit(hitbox.damage)
			for hitbox_warning_pos in hitbox.warning_positions:
				if (p2_tiles[hitbox_warning_pos.x] as Dictionary).has(hitbox_warning_pos.y):
					(p2_tiles[hitbox_warning_pos.x][hitbox_warning_pos.y] as Tile).show_warning()
