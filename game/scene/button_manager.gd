extends Node


func _on_play_sfx_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/game.tscn")


func _on_collection_sfx_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/collection.tscn")


func _on_meta_sfx_button_3_pressed() -> void:
	pass # Replace with function body.


func _on_setting_sfx_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/settings.tscn")


func _on_exit_sfx_button_5_pressed() -> void:
	get_tree().quit()
