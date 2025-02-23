class_name Grid extends Node

const PLAYER = preload("res://Player/Player.tscn")
const TILERED = preload("res://World/TileRed.tscn")
const TILEBLUE = preload("res://World/TileBlue.tscn")

var p1 : Player
var p2 : Player

var p1_hitboxes : Node = null
var p2_hitboxes : Node = null

var p1_tile_container : Node = null
var p2_tile_container : Node = null

var p1_tiles : Dictionary
var p2_tiles : Dictionary

func _ready() -> void:
	
	##Ensure hitboxes and movement are processed last.
	set_deferred("process_physics_priority", 1)
	
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
	p1.initialize(true, false, self)
	p2.initialize(false, true, self)
	add_child(p1)
	add_child(p2)
	

	


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
					p1.hit()
			for hitbox_warning_pos in hitbox.warning_positions:
				if (p1_tiles[hitbox_warning_pos.x] as Dictionary).has(hitbox_warning_pos.y):
					(p1_tiles[hitbox_warning_pos.x][hitbox_warning_pos.y] as Tile).show_warning()

	for hitbox in p1_hitboxes.get_children():
		if hitbox is Hitbox:
			for hitbox_pos in hitbox.positions:
				if (p2_tiles[hitbox_pos.x] as Dictionary).has(hitbox_pos.y):
					(p2_tiles[hitbox_pos.x][hitbox_pos.y] as Tile).show_hitbox()
				if not p2.get_has_iframes() and p2.pos == hitbox_pos:
					p2.hit()
			for hitbox_warning_pos in hitbox.warning_positions:
				if (p2_tiles[hitbox_warning_pos.x] as Dictionary).has(hitbox_warning_pos.y):
					(p2_tiles[hitbox_warning_pos.x][hitbox_warning_pos.y] as Tile).show_warning()
