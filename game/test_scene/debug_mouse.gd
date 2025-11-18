extends RichTextLabel

@onready var node_2d: Node2D = %World
@onready var camera_2d: Camera2D = %SimpleCamera


func _process(_delta: float) -> void:
	var screen_pos: Vector2 = get_global_mouse_position()
	text = "Global: (" + str(int(screen_pos.x)) + ", " + str(int(screen_pos.y)) + ")"
	var cam_pos: Vector2 = camera_2d.position
	text += " Cam: (" + str(int(cam_pos.x)) + ", " + str(int(cam_pos.y)) + ")"
	var n_pos: Vector2 = node_2d.position
	text += " Node: (" + str(int(n_pos.x)) + ", " + str(int(n_pos.y)) + ")\n"
	
	var ln_pos: Vector2 = node_2d.to_local(cam_pos)
	text += "Local: (" + str(int(ln_pos.x)) + ", " + str(int(ln_pos.y)) + ")"
	
	var cent_pos: Vector2 = (get_tree().root.content_scale_size / 2) 
	text += " Center: (" + str(int(cent_pos.x)) + ", " + str(int(cent_pos.y)) + ")\n"
	
	var zoom: Vector2 = camera_2d.zoom
	var mouse_offset_from_center: Vector2 = screen_pos - cent_pos
	var scaled_offset: Vector2 = mouse_offset_from_center / zoom
	text += "Zoom: (" + str(zoom.x) + ", " + str(zoom.y) + ")\n"
	
	
	var target_pos: Vector2 = (scaled_offset + ln_pos) #/ global_scale_factor()
	text += "Target: (" + str(int(target_pos.x)) + ", " + str(int(target_pos.y)) + ")"
	
	var cell: Vector2i
	cell.x = floor(target_pos.x / 32)
	cell.y = floor(target_pos.y / 32)
	text += " Cell: (" + str(cell.x) + ", " + str(cell.y) + ")"
	
	
