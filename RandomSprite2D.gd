class_name RandomSprite2D
extends Sprite2D

@export var time_between_frames : float = 0.2
@export var time_variation : float = 0.0
@export var used_frames : PackedInt32Array = [].duplicate()
var timer : Timer = null

var num_frames : int = 0 # size of used_frames

var new_frame : int = 0 # for switching between >=3 randomly
var idx : int = 0 # for switching between 2 only

func _ready():
	timer = Timer.new()
	
	num_frames = used_frames.size()
	
	if num_frames > 2:
		timer.timeout.connect(switch_to_new_frame_rand)
	elif num_frames == 2:
		timer.timeout.connect(switch_to_new_frame_2)
	else:
		print("RandomSprite2D has <2 used frames!")
	add_child(timer)
	timer.start(time_between_frames)

func switch_to_new_frame_rand():
	while new_frame == frame:
		new_frame = used_frames[randi_range(0, num_frames - 1)]
	frame = new_frame
	
	if time_variation != 0.0:
		timer.start(time_between_frames + randf_range(-1 * time_variation, time_variation))

func switch_to_new_frame_2():
	idx = 1 - idx
	frame = used_frames[idx]
	if time_variation != 0.0:
		timer.start(time_between_frames + randf_range(-1 * time_variation, time_variation))
