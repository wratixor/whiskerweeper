extends Node

@onready var world: Node2D = %World
@onready var cat_paw: TileMapLayer = %CatPaw
@onready var back: TileMapLayer = %Back
@onready var grass: TileMapLayer = %Grass
@onready var flags: TileMapLayer = %Flags
@onready var level_data: LevelData = %LevelData
@onready var stats: Label = %Stats
@onready var mode: Button = %ModeSFXButton


var wx: int = Global.WORLD_SIZE_X
var wy: int = Global.WORLD_SIZE_Y


func _ready() -> void:
	SignalBus.redraw_lvl.connect(redraw_all)
	SignalBus.lvl_lose.connect(draw_cats)
	SignalBus.lvl_win.connect(draw_cats)


func redraw_all() -> void:
	redraw_back()
	redraw_grass()
	redraw_flags()
	redraw_paws()
	redraw_stat()
	redraw_mode()

func redraw_back() -> void:
	for x in wx:
		for y in wy:
			back.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func redraw_grass() -> void:
	for x in wx:
		for y in wy:
			if (level_data.grass[x][y]):
				grass.set_cell(Vector2i(x, y), 0, Vector2i(0, 3))
			else:
				grass.erase_cell(Vector2i(x, y))
			#cats[x][y] = false
			#flags[x][y] = false
			#paw[x][y] = CELL_PAW.NA
			#grass[x][y] = true


func redraw_flags() -> void:
	for x in wx:
		for y in wy:
			if (level_data.flags[x][y]):
				flags.set_cell(Vector2i(x, y), 0, Vector2i(0, 5))
			else:
				flags.erase_cell(Vector2i(x, y))


func redraw_paws() -> void:
	for x in wx:
		for y in wy:
			cat_paw.set_cell(Vector2i(x, y), 0, Vector2i(level_data.paw[x][y], 0))


func draw_cats() -> void:
	for x in wx:
		for y in wy:
			if (level_data.cats[x][y]):
				grass.set_cell(Vector2i(x, y), 0, Vector2i(0, 4))
			else:
				grass.erase_cell(Vector2i(x, y))


func redraw_stat() -> void:
	stats.text = "Level: " + str(Global.level) + " "
	stats.text += " Cats: " + str(level_data.cat_count) + " "
	stats.text += " Flags: " + str(level_data.get_flags_count()) + " "

func redraw_mode() -> void:
	if Global.invert:
		mode.text = "FLAG"
	else:
		mode.text = "CUT"
