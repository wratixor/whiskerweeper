extends Node

var SAVE_PATH: String = "user://purchase.save"

var _upgrade_static_pool: Dictionary = {
	"F7": {"Dependency": null, "Cost": 50, "Name": "Small field",
		"Desc": "Increases the playing field to 7x7"},
	"F9": {"Dependency": "F7", "Cost": 500, "Name": "Medium field",
		"Desc": "Increases the playing field to 9x9"},
	"F11": {"Dependency": "F9", "Cost": 5000, "Name": "Large field",
		"Desc": "Increases the playing field to 11x11"},
	"R1": {"Dependency": null, "Cost": 50, "Name": "Radar x1",
		"Desc": "Places a flag instead of cutting a bush if there is a cat there, 1 time."},
	"R2": {"Dependency": "R1", "Cost": 500, "Name": "Radar x2",
		"Desc": "Places a flag instead of cutting a bush if there is a cat there, 2 times."},
	"R3": {"Dependency": "R2", "Cost": 5000, "Name": "Radar x3",
		"Desc": "Places a flag instead of cutting a bush if there is a cat there, 3 times."},
	"S1": {"Dependency": null, "Cost": 1000, "Name": "Scythe",
		"Desc": "If a field is open without cat tracks, it automatically removes bushes horizontally and vertically."},
}

var _upgrade_empty_pool: Dictionary = {
	"F7": false,
	"F9": false,
	"F11": false,
	"R1": false,
	"R2": false,
	"R3": false,
	"S1": false,
}

var purchased_upgrades: Dictionary = _upgrade_empty_pool.duplicate(true)

func _ready() -> void:
	load_purchase()

func is_available_upgrade(key: String) -> bool:
	if !purchased_upgrades[key]:
		var need_upg = _upgrade_static_pool[key]["Dependency"]
		if need_upg == null:
			return true
		elif purchased_upgrades[need_upg]:
			return true
	return false


func get_available_upgrades() -> Array:
	var available_upgrades: Array = []
	for key in purchased_upgrades:
		if is_available_upgrade(key):
			available_upgrades.push_back(key)
	return available_upgrades


func get_upgrade_info(key: String) -> Dictionary:
	var upg_info: Dictionary = {
		"Dependency": null,
		"Cost": 0,
		"Name": "",
		"Desc": "",
		"Is_purchased": false,
		"Is_available": false
	}
	if _upgrade_static_pool.has(key) and purchased_upgrades.has(key):
		upg_info["Dependency"] = _upgrade_static_pool[key]["Dependency"]
		upg_info["Cost"] = _upgrade_static_pool[key]["Cost"]
		upg_info["Name"] = _upgrade_static_pool[key]["Name"]
		upg_info["Desc"] = _upgrade_static_pool[key]["Desc"]
		upg_info["Is_purchased"] = purchased_upgrades[key]
		upg_info["Is_available"] = is_available_upgrade(key)
	return upg_info

func buy_upgrade(key: String) -> void:
	var need_meta: int = _upgrade_static_pool[key]["Cost"]
	if is_available_upgrade(key):
		if Global.meta > need_meta:
			Global.meta -= need_meta
			purchased_upgrades[key] = true
			SignalBus.settings_change.emit()
			save_purchase()


func save_purchase() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(purchased_upgrades)
	else:
		push_error("Error: File not opened")

func load_purchase() -> void:
	var load_dict: Dictionary = {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			load_dict = data
		else:
			push_warning("Purchase file is corrupted, default values ​​will be used.")
	else:
		push_warning("Purchase file not found, default values ​​will be used.")
	apply_purchase(load_dict)
	save_purchase()

func apply_purchase(load_dict: Dictionary) -> void:
	for key in _upgrade_empty_pool:
		purchased_upgrades[key] = load_dict[key]
