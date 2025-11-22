extends Node

@onready var camera_2d: Camera2D = %SimpleCamera
@onready var node_2d: Node2D = %World
@onready var level_data: LevelData = %LevelData
@onready var ui: CanvasLayer = %UI
@onready var stats: Label = %Stats


var pause: bool = false
var invert: bool = false

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
	if Input.is_action_just_pressed("zoom_in"):
		Global.zoom = min(4, Global.zoom + 1)
		SignalBus.zoom_change.emit()
	if Input.is_action_just_pressed("zoom_out"):
		Global.zoom = max(1, Global.zoom - 1)
		SignalBus.zoom_change.emit()

	if (pause):
		if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
			pause = false
			level_data.generate_new()
	else:
		var screen_pos: Vector2 = stats.get_global_mouse_position()
		var cell: Vector2i = convert_mouse_to_cell(screen_pos)
		if cell.x >= 0 && cell.y >= 0 && cell.x < Global.WORLD_SIZE_X && cell.y < Global.WORLD_SIZE_Y:
			var cwx: float = Global.WORLD_SIZE_X / 2.0
			var cwy: float = Global.WORLD_SIZE_Y / 2.0
			var cdfx: float = float(cell.x) + 0.5 - cwx
			var cdfy: float = float(cell.y) + 0.5 - cwy
			var cdfxn: float = cdfx / cwx
			var cdfyn: float = cdfy / cwy
			var window_size: Vector2 = get_tree().root.content_scale_size
			#var scr_r: float = min(window_size.x / 2.0, window_size.y / 2.0)
			var max_dif_scr_x: float = (float((Global.WORLD_SIZE_X + 4) * Global.CELL_SIZE.x) - window_size.x) / 2.0
			var max_dif_scr_y: float = (float((Global.WORLD_SIZE_Y + 4) * Global.CELL_SIZE.y) - window_size.y) / 2.0
			var cam_dif_x: float = cdfxn * max_dif_scr_x
			var cam_dif_y: float = cdfyn * max_dif_scr_y
			var start_cam_pos_x: float = node_2d.position.x + (float(Global.WORLD_SIZE_X * Global.CELL_SIZE.x) / 2.0)
			var start_cam_pos_y: float = node_2d.position.y + (float(Global.WORLD_SIZE_Y * Global.CELL_SIZE.y) / 2.0)
			var new_cam_pos_x: float = start_cam_pos_x + cam_dif_x
			var new_cam_pos_y: float = start_cam_pos_y + cam_dif_y
			if max_dif_scr_x < 0:
				new_cam_pos_x = start_cam_pos_x
			if max_dif_scr_y < 0:
				new_cam_pos_y = start_cam_pos_y
			camera_2d.position = Vector2(new_cam_pos_x, new_cam_pos_y)
			
			
			
			if Input.is_action_just_pressed("left_click"):
				if !invert:
					SignalBus.l_click.emit(cell.x, cell.y)
				else:
					SignalBus.r_click.emit(cell.x, cell.y)
			if Input.is_action_just_pressed("right_click"):
				if !invert:
					SignalBus.r_click.emit(cell.x, cell.y)
				else:
					SignalBus.l_click.emit(cell.x, cell.y)
		else:
			if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
				#print("i: ", cell, screen_pos)
				invert = !invert


func lose() -> void:
	pause = true
	Global.level = 0

func win() -> void:
	pause = true
	Global.level += 1
	
