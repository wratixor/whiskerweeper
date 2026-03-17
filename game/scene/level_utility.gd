extends Node

@onready var camera_2d: Camera2D = %SimpleCamera
@onready var node_2d: Node2D = %World
@onready var level_data: LevelData = %LevelData
@onready var ui: CanvasLayer = %UI
@onready var stats: Label = %Stats
@onready var win_panel: PanelContainer = %WinPanel
@onready var card_manager: Node = %CardManager


var pause: bool = false
var need_regenerate: bool = false

func _ready() -> void:
	win_panel.visible = false
	level_data.generate_new()
	SignalBus.lvl_lose.connect(lose)
	SignalBus.lvl_win.connect(win)
	SignalBus.regenerate_lvl.connect(regenerate_please)

func regenerate_please() -> void:
	win_panel.visible = false
	need_regenerate = true
	

func convert_mouse_to_cell(mouse_pos: Vector2) -> Vector2i:
	if camera_2d == null || node_2d == null:
		return Vector2i.ZERO
	var cam_pos: Vector2 = camera_2d.position
	var ln_pos: Vector2 = node_2d.to_local(cam_pos)
	var cent_pos: Vector2 = floor(get_tree().root.content_scale_size / 2.0) 
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
		Global.zoom = min(Global.max_zoom, Global.zoom + 1)
		SignalBus.zoom_change.emit()
	if Input.is_action_just_pressed("zoom_out"):
		Global.zoom = max(Global.min_zoom, Global.zoom - 1)
		SignalBus.zoom_change.emit()

	if pause or need_regenerate:
		if Input.is_action_just_pressed("left_click") or Input.is_action_just_pressed("right_click"):
			pause = false
			need_regenerate = false
			level_data.generate_new()
	else:
		var screen_pos: Vector2 = stats.get_global_mouse_position()
		var cell: Vector2i = convert_mouse_to_cell(screen_pos)

		if Rect2(0, 0, Global.WORLD_SIZE_X, Global.WORLD_SIZE_Y).has_point(cell):
			var world_center = Vector2(Global.WORLD_SIZE_X, Global.WORLD_SIZE_Y) / 2.0
			var cell_center = Vector2(cell) + Vector2((Global.WORLD_SIZE_X / 2.0) - int(Global.WORLD_SIZE_X / 2.0), (Global.WORLD_SIZE_Y / 2.0) - int(Global.WORLD_SIZE_Y / 2.0))
			var normalized_offset = (cell_center - world_center) / world_center
			var world_pixels = Vector2(Global.WORLD_SIZE_X + 4, Global.WORLD_SIZE_Y + 4) * Vector2(Global.CELL_SIZE)
			var max_screen_offset = (world_pixels - Vector2(get_tree().root.content_scale_size)) / 2.0
			var base_camera_pos = node_2d.position + Vector2(Global.WORLD_SIZE_X, Global.WORLD_SIZE_Y) * Vector2(Global.CELL_SIZE) / 2.0
			
			camera_2d.position = base_camera_pos + Vector2(
				max_screen_offset.x if max_screen_offset.x > 0 else 0,
				max_screen_offset.y if max_screen_offset.y > 0 else 0
			) * normalized_offset
			
			
			if Input.is_action_just_pressed("left_click"):
				if !Global.invert:
					SignalBus.l_click.emit(cell.x, cell.y)
					SoundBus.play_action_sfx.emit("chop", 0.2)
				else:
					SignalBus.r_click.emit(cell.x, cell.y)
					SoundBus.play_action_sfx.emit("mark", 0.2)
			if Input.is_action_just_pressed("right_click"):
				if !Global.invert:
					SignalBus.r_click.emit(cell.x, cell.y)
					SoundBus.play_action_sfx.emit("mark", 0.2)
				else:
					SignalBus.l_click.emit(cell.x, cell.y)
					SoundBus.play_action_sfx.emit("chop", 0.2)


func lose() -> void:
	pause = true
	Global.level = 0
	SoundBus.play_action_sfx.emit("meow", 0.2)
	SignalBus.settings_change.emit()


func win() -> void:
	pause = true
	win_panel.visible = true
	SignalBus.generate_win_loot.emit(Global.get_cat_count())
	Global.level += 1
	SoundBus.play_action_sfx.emit("clap", 0.2)
	SignalBus.settings_change.emit()


func _on_return_sfx_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/Main.tscn")


func _on_swap_sfx_button_pressed() -> void:
	Global.invert = !Global.invert
	SignalBus.redraw_lvl.emit()
