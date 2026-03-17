extends Node

const SETTING_PATH: String = "user://settings.save"

func _ready() -> void:
	SignalBus.settings_change.connect(save_settings)
	load_settings()

func save_settings() -> void:
	var settings_dict = {
		"bg_sound": Global.bg_sound,
		"sfx_sound": Global.sfx_sound,
		"zoom": Global.zoom,
		"fullscreen": Global.fullscreen
	}
	
	var file = FileAccess.open(SETTING_PATH, FileAccess.WRITE)
	if file:
		file.store_var(settings_dict)
	else:
		push_error("Error: File not opened")

func load_settings() -> void:
	var settings_dict = {}
	var file = FileAccess.open(SETTING_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			settings_dict = data
		else:
			push_warning("The settings file is corrupted, default values ​​will be used.")
	else:
		push_warning("Settings file not found, default values ​​will be used.")
	apply_settings(settings_dict)
	save_settings()

func apply_settings(settings: Dictionary) -> void:
	var default_bg = 0.5
	var default_sfx = 0.5
	var default_zoom = 1.0
	var default_fullscreen = false
	
	Global.bg_sound = settings.get("bg_sound", default_bg)
	Global.sfx_sound = settings.get("sfx_sound", default_sfx)
	Global.zoom = settings.get("zoom", default_zoom)
	Global.fullscreen = settings.get("fullscreen", default_fullscreen)
	
	set_bus_volume("BG", Global.bg_sound)
	set_bus_volume("SFX", Global.sfx_sound)


func set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_linear(bus_index, volume)
	else:
		push_error("Error: Bus '%s' not found" % bus_name)
