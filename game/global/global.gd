extends Node

const CELL_SIZE: Vector2i = Vector2i(32, 32)
const WORLD_SIZE_X: int = 11
const WORLD_SIZE_Y: int = 11
const WORLD_SIZE: Vector2i = Vector2i(WORLD_SIZE_X, WORLD_SIZE_Y)
const WORLD_SIZE_PX: Vector2i = WORLD_SIZE * CELL_SIZE

const START_CAT_COUNT: int = int(floor((WORLD_SIZE_X * WORLD_SIZE_Y) * 0.1))
const INCREMENT_CAT: int = 2
const MAX_CAT_COUNT: int = int(floor((WORLD_SIZE_X * WORLD_SIZE_Y) * 0.5))

var level: int = 0
var zoom: int = 2

func get_cat_count() -> int:
	return min(MAX_CAT_COUNT, (START_CAT_COUNT + (level * INCREMENT_CAT)))
