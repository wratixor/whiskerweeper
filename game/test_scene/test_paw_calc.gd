extends Node2D

@onready var level_data: LevelData = $LevelData


func _on_timer_timeout() -> void:
	level_data.generate_new()
	print(level_data.paw)
	
