extends Node2D

const NUM_POINTS : int = 12 # number of line2d points
const ENDPOINT_LEFT : int = 0
const ENDPOINT_RIGHT : int = 6
const POINT_RANDOM_RANGE : int = 3
const BASE_LEN : float = 50
@onready var line: Line2D = $Line2D
@onready var particles: CPUParticles2D = $Node2D/CPUParticles2D

var line_points_initial : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	line_points_initial = line.points.duplicate()
	
	for i in range(0, line.points.size()-1):
		add_particles_on_segment(line.points[i], line.points[i+1])
	add_particles_on_segment(line.points[0], line.points[-1])
	particles.queue_free()

func add_particles_on_segment(point1: Vector2, point2: Vector2):
	var center : Vector2 = (point1 + point2) / 2.0
	var segment : Vector2 = point1 - point2
	
	var new_particles : CPUParticles2D = particles.duplicate()
	new_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	new_particles.emission_rect_extents = Vector2(segment.length(), 0)
	new_particles.amount *= segment.length() / BASE_LEN
	new_particles.global_position = center
	new_particles.rotation = segment.angle_to(Vector2.RIGHT) * -1
	particles.add_sibling(new_particles)

# Called every frame. 'delta' is the elapsed time since the previous frame.
var ct : int = 1
func _physics_process(_delta: float) -> void:
	ct = (ct + 1) % 6
	
	if ct == 0:
		shuffle_points()

func shuffle_points():
	for i in range(NUM_POINTS):
		if i != ENDPOINT_LEFT and i != ENDPOINT_RIGHT:
			line.points[i] = line_points_initial[i] + Vector2(randf_range(-POINT_RANDOM_RANGE,POINT_RANDOM_RANGE), randf_range(-POINT_RANDOM_RANGE,POINT_RANDOM_RANGE))
