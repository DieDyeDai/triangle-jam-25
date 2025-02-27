extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var parent : Player = get_parent().get_parent()
	
	await parent.ready
	
	if parent.isP1:
		texture = parent.pngP1
		flip_h = true
	else:
		texture = parent.pngP2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
