extends Button

func _on_pressed() -> void:
	SoundBus.play_action_sfx.emit("ui_click", 0.1)


func _on_mouse_entered() -> void:
	SoundBus.play_action_sfx.emit("ui_hover", 0.1)


func _on_mouse_exited() -> void:
	#SoundBus.play_action_sfx.emit("ui_hover", 0.1)
	pass
