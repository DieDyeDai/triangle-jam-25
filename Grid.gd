class_name Grid extends Node

var p1 : Player
var p2 : Player

var p1_hitboxes : Node = null
var p2_hitboxes : Node = null

func _ready() -> void:
	##Ensure hitboxes and movement are processed last.
	# process_physics_priority = 1
	set_deferred("process_physics_priority", 1)
	
	p1 = Player.new()
	p2 = Player.new()
	p1.initialize(true, false, self)
	p2.initialize(false, true, self)
	add_child(p1)
	add_child(p2)
	
	p1_hitboxes = Node.new()
	p2_hitboxes = Node.new()
	add_child(p1_hitboxes)
	add_child(p2_hitboxes)
	
func _physics_process(_delta: float) -> void:
	process_hitboxes()
	

func process_hitboxes() -> void:
	if not p1.get_has_iframes():
		for hitbox in p2_hitboxes.get_children():
			if hitbox is Hitbox:
				for hitbox_pos in hitbox.positions:
					if p1.pos == hitbox_pos:
						# p1 hit
						break
	
	if not p2.get_has_iframes():
		for hitbox in p1_hitboxes.get_children():
			if hitbox is Hitbox:
				for hitbox_pos in hitbox.positions:
					if p2.pos == hitbox_pos:
						# p2 hit
						break
