extends Node


@onready var h_slider_bg: HSlider = %HSliderBG
@onready var h_slider_sfx: HSlider = %HSliderSFX
@onready var h_slider_zoom: HSlider = %HSliderZoom


func _ready() -> void:
	reload()


func reload() -> void:
	h_slider_bg.value = Global.bg_sound
	h_slider_sfx.value = Global.sfx_sound
	h_slider_zoom.value = Global.zoom


func _on_h_slider_zoom_value_changed(value: float) -> void:
	Global.zoom = floor(h_slider_zoom.value)
	reload()
	SignalBus.zoom_change.emit()
	SignalBus.settings_change.emit()
	SoundBus.play_action_sfx.emit("ui_hover", 0.1)


func _on_h_slider_sfx_value_changed(value: float) -> void:
	Global.sfx_sound = h_slider_sfx.value
	AudioServer.set_bus_volume_linear(1, Global.sfx_sound)
	reload()
	SignalBus.settings_change.emit()
	SoundBus.play_action_sfx.emit("ui_hover", 0.1)


func _on_h_slider_bg_value_changed(value: float) -> void:
	Global.bg_sound = h_slider_bg.value
	AudioServer.set_bus_volume_linear(2, Global.bg_sound)
	reload()
	SignalBus.settings_change.emit()
	SoundBus.play_action_sfx.emit("ui_hover", 0.1)


func _on_fssfx_button_pressed() -> void:
	Global.fullscreen = !Global.fullscreen
	SignalBus.toggle_fullscreen.emit()
	SignalBus.settings_change.emit()


func _on_exit_sfx_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/Main.tscn")
