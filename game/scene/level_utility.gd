extends Node

@onready var camera_2d: Camera2D = %SimpleCamera
@onready var node_2d: Node2D = %World
@onready var level_data: LevelData = %LevelData
@onready var ui: CanvasLayer = %UI
@onready var stats: Label = %Stats



var pause: bool = false

func _ready() -> void:
	level_data.generate_new()
	SignalBus.lvl_lose.connect(lose)
	SignalBus.lvl_win.connect(win)

func convert_mouse_to_cell(mouse_pos: Vector2) -> Vector2i:
	if camera_2d == null || node_2d == null:
		return Vector2i.ZERO
	var cam_pos: Vector2 = camera_2d.position
	var ln_pos: Vector2 = node_2d.to_local(cam_pos)
	var cent_pos: Vector2 = (get_tree().root.content_scale_size / 2) 
	var zoom: Vector2 = camera_2d.zoom
	var mouse_offset_from_center: Vector2 = mouse_pos - cent_pos
	var scaled_offset: Vector2 = mouse_offset_from_center / zoom
	var target_pos: Vector2 = (scaled_offset + ln_pos)
	var cell: Vector2i
	cell.x = floor(target_pos.x / 32)
	cell.y = floor(target_pos.y / 32)
	return cell


func _process(_delta: float) -> void:
	if (pause):
		if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
			pause = false
			print("Regenerate level")
			level_data.generate_new()
	else:
		var screen_pos: Vector2 = stats.get_global_mouse_position()
		var cell: Vector2i = convert_mouse_to_cell(screen_pos)
		if Input.is_action_just_pressed("left_click"):
			SignalBus.l_click.emit(cell.x, cell.y)
			print("lc: ", cell, screen_pos)
		if Input.is_action_just_pressed("right_click"):
			SignalBus.r_click.emit(cell.x, cell.y)
			print("rc: ", cell, screen_pos)


func lose() -> void:
	pause = true
	Global.level = 0

func win() -> void:
	pause = true
	Global.level += 1
	
