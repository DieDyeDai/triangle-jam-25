class_name Tile extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func blank() -> void:
	# reset to no animation
	pass

func show_player() -> void:
	# show player is on tile
	pass

func remove_player() -> void:
	# remove player is on tile
	pass

func show_hitbox() -> void:
	# show that a bullet/hitbox is on the tile
	pass

func show_warning() -> void:
	# show an attack will hit the tile
	pass
