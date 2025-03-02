extends Node

@warning_ignore("unused_signal")
signal reset_tile_sprites

var scene_switcher : SceneSwitcherMinimal

const TILE_SIZE : int = 32

const TILE_WIDTH : int = 48
const TILE_HEIGHT : int = 32

const Y_UPPER : int = 5
const Y_LOWER : int = -4
const X_UPPER : int = 2
const X_LOWER : int = -2

const Y_UPPER_1 : int = 0
const Y_LOWER_1 : int = -4
const Y_UPPER_2 : int = 5
const Y_LOWER_2 : int = 1

const GRID_WIDTH : int = 5
const GRID_HEIGHT : int = 5

var p1score : int = 0
var p2score : int = 0

enum CHARS {
	ONE = 1,
	TWO = 2
}

enum SKILLS {
	LIGHT,
	HEAVY,
	CHARGE
}

var p1_skills = {
	SKILLS.LIGHT: 1,
	SKILLS.HEAVY: 1,
	SKILLS.CHARGE: 1,
}

var p2_skills = {
	SKILLS.LIGHT: 1,
	SKILLS.HEAVY: 1,
	SKILLS.CHARGE: 1,
}

func _ready() -> void:
	scene_switcher = get_tree().get_first_node_in_group("SceneSwitcher")

func reset_score() -> void:
	p1score = 0
	p2score = 0

func get_global_position(pos: Vector2i) -> Vector2:
	if pos.y > 0:
		return Vector2(TILE_WIDTH * (pos.x + 2.5), TILE_HEIGHT * (pos.y - 3))
	else:
		return Vector2(TILE_WIDTH * (pos.x - 2.5), -TILE_HEIGHT * (pos.y + 2))

func get_pos(global_position: Vector2) -> Vector2i:
	var p: Vector2i = Vector2i.ZERO
	if global_position.x < 0:
		p.x = floor(float(global_position.x + (3 * TILE_WIDTH)) / TILE_WIDTH)
		p.y = -floor(float(global_position.y + (3.5 * TILE_HEIGHT)) / TILE_HEIGHT) + 1
	else:
		p.x = floor(float(global_position.x + (-2 * TILE_WIDTH)) / TILE_WIDTH)
		p.y = floor(float(global_position.y + (3.5 * TILE_HEIGHT)) / TILE_HEIGHT)
	return p

func should_warp(global_position: Vector2, dir: Vector2i) -> bool:
	return (global_position.y < -2.8 * TILE_HEIGHT and dir.y < 0) or (global_position.y > 2.8 * TILE_HEIGHT and dir.y > 0)

func get_warp_position(global_position: Vector2) -> Vector2:
	if global_position.x < 0:
		return Vector2(global_position.x + 5 * TILE_WIDTH, global_position.y + 0.25 * TILE_HEIGHT)
	else:
		return Vector2(global_position.x - 5 * TILE_WIDTH, global_position.y + 0.25 * TILE_HEIGHT)
