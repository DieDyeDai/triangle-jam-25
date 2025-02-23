class_name Tile extends Sprite2D

@onready var top: AnimatedSprite2D = $Top
@onready var warning: AnimatedSprite2D = $Warning
@onready var player: Sprite2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.reset_tile_sprites.connect(blank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func blank() -> void:
	# reset to no animation
	top.play("default")
	player.visible = false
	warning.visible = false
	pass

func show_player() -> void:
	# show player is on tile
	player.visible = true
	pass

func show_hitbox() -> void:
	# show that a bullet/hitbox is on the tile
	top.play("hurt")
	pass

func show_warning() -> void:
	# show an attack will hit the tile
	warning.visible = true
	warning.play("default")
	pass
