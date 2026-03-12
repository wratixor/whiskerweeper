extends Node



func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/game.tscn")


func _on_cats_button_pressed() -> void:
	pass # Replace with function body.


func _on_meta_button_pressed() -> void:
	pass # Replace with function body.


func _on_setting_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
