class_name Grid extends Node

const PLAYER = preload("res://Player/Player.tscn")
const TILERED = preload("res://World/TileRed.tscn")
const TILEBLUE = preload("res://World/TileBlue.tscn")

@onready var camera : Camera2D = $Camera2D
@onready var hpbar_1 : UIHealthBar = $UIHealthBar1
@onready var hpbar_2 : UIHealthBar = $UIHealthBar2
@onready var ebar_1: UIEnergyBar = $UIEnergyBar1
@onready var ebar_2: UIEnergyBar = $UIEnergyBar2

@onready var keys_movement_1: Sprite2D = $KeysMovement1
@onready var key_action_a: Sprite2D = $KeyActionA
@onready var key_action_z: Sprite2D = $KeyActionZ
@onready var key_action_x: Sprite2D = $KeyActionX
@onready var key_action_s: Sprite2D = $KeyActionS

@onready var inputs_1 : Dictionary = {
	"movement": keys_movement_1,
	"melee": key_action_a,
	"charge": key_action_z,
	"basic": key_action_x,
	"big": key_action_s,
}

@onready var keys_movement_2: Sprite2D = $KeysMovement2
@onready var key_action_i: Sprite2D = $KeyActionI
@onready var key_action_k: Sprite2D = $KeyActionK
@onready var key_action_l: Sprite2D = $KeyActionL
@onready var key_action_o: Sprite2D = $KeyActionO

@onready var inputs_2 : Dictionary = {
	"movement": keys_movement_2,
	"melee": key_action_i,
	"charge": key_action_k,
	"basic": key_action_l,
	"big": key_action_o,
}

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

func _ready() -> void:
	
	##Ensure hitboxes and movement are processed last.
	set_deferred("process_physics_priority", 1)
	
	hpbar_1.reset(10, 10)
	hpbar_2.reset(10, 10)
	
	screenshake_timer = Timer.new()
	screenshake_timer.set_autostart(false)
	screenshake_timer.set_one_shot(true)
	add_child(screenshake_timer)
	
	hpbar_1.set_global_position(Globals.get_global_position(Vector2i(0, -5)))
	hpbar_1.scale.x = -1
	ebar_1.set_global_position(Globals.get_global_position(Vector2i(0, -6)) + Vector2(0, -22))
	ebar_1.scale.x = -1
	ebar_1.counter.initialize(true, false)
	
	hpbar_2.set_global_position(Globals.get_global_position(Vector2i(0,6)))
	ebar_2.set_global_position(Globals.get_global_position(Vector2i(0,7)) + Vector2(0, -22))
	ebar_2.counter.initialize(false, true)
	
	inputs_1["movement"].set_global_position(ebar_1.global_position + Vector2(40, 32))
	inputs_1["melee"].set_global_position(ebar_1.global_position + Vector2(-24, 24))
	inputs_1["big"].set_global_position(ebar_1.global_position + Vector2(-8, 24))
	inputs_1["charge"].set_global_position(ebar_1.global_position + Vector2(-16, 48))
	inputs_1["basic"].set_global_position(ebar_1.global_position + Vector2(0, 48))

	inputs_2["movement"].set_global_position(ebar_2.global_position + Vector2(40, 32))
	inputs_2["melee"].set_global_position(ebar_2.global_position + Vector2(-24, 24))
	inputs_2["big"].set_global_position(ebar_2.global_position + Vector2(-8, 24))
	inputs_2["charge"].set_global_position(ebar_2.global_position + Vector2(-16, 48))
	inputs_2["basic"].set_global_position(ebar_2.global_position + Vector2(0, 48))
	
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

var ct : int = 1
func _physics_process(_delta: float) -> void:
	
	reset_tile_sprites_and_show_players()
	process_hitboxes()
	
	#ct = (ct + 1) % 30
	if ct == 0:
		print(Globals.get_pos(p1.get_global_mouse_position()))
		print("1:" + str(p1.pos))
		print("2:" + str(p2.pos))
	
	if Input.is_action_just_pressed("debug1"):
		for i in p1_tiles.values():
			for j in i.values():
				print(j)
	
	# screenshake
	
	if screenshake_timer.get_time_left() > 0.01:
		camera.offset = Vector2(SCREENSHAKE_STR * screenshake_timer.get_time_left(), 0).rotated(randf_range(0, 2 * PI)) + Vector2(0, Globals.TILE_HEIGHT)
	else:
		camera.offset = Vector2(0, Globals.TILE_HEIGHT)

	if Input.is_action_just_pressed("debug1"):
		screenshake(1.0)
		ebar_1.update(ebar_1.cur - 30, ebar_1.max)
		ebar_2.update(ebar_2.cur - 30, ebar_2.max)

func screenshake(strength : float) -> void:
	screenshake_timer.start(SCREENSHAKE_TIME * strength)

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
					p2.hit(hitbox.damage)
			for hitbox_warning_pos in hitbox.warning_positions:
				if (p2_tiles[hitbox_warning_pos.x] as Dictionary).has(hitbox_warning_pos.y):
					(p2_tiles[hitbox_warning_pos.x][hitbox_warning_pos.y] as Tile).show_warning()
