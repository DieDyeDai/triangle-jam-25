extends Node

const TILE_SIZE : int = 32

const Y_UPPER : int = 5
const Y_LOWER : int = -4
const X_UPPER : int = 2
const X_LOWER : int = -2

func get_global_position(pos: Vector2i) -> Vector2:
	
	if pos.y > 0:
		return TILE_SIZE * Vector2(pos.x + 2.5, pos.y - 3)
	else:
		return TILE_SIZE * Vector2(pos.x - 2.5, pos.y + 2)

func get_pos(global_position: Vector2) -> Vector2i:
	var p: Vector2i = Vector2i.ZERO
	if global_position.x < 0:
		p.x = floor(float(global_position.x + (3 * TILE_SIZE)) / TILE_SIZE)
		p.y = floor(float(global_position.y + (-1.5 * TILE_SIZE)) / TILE_SIZE)
	else:
		p.x = floor(float(global_position.x + (-2 * TILE_SIZE)) / TILE_SIZE)
		p.y = floor(float(global_position.y + (3.5 * TILE_SIZE)) / TILE_SIZE)
	return p

func should_warp(global_position: Vector2, dir: Vector2i) -> bool:
	return (
		(global_position.x < 0 and global_position.y > 3 * TILE_SIZE and dir.y > 0)
		or (global_position.x > 0 and global_position.y < -3 * TILE_SIZE and dir.y < 0)
	)

func get_warp_position(global_position: Vector2) -> Vector2:
	if global_position.x < 0:
		return Vector2(global_position.x + 5 * TILE_SIZE, -1 * global_position.y)
	else:
		return Vector2(global_position.x - 5 * TILE_SIZE, -1 * global_position.y)
