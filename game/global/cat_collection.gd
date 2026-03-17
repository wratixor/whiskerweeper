extends Node

var SAVE_PATH: String = "user://collection.save"
var UPGRADE_MUL: int = 10

var _cat_static_pool: Dictionary = {
	"Cat1024": {"name": "Trash Cat",
				"weight": 1024,
				"sprite": preload("res://asset/cat_card/cat1024.png")},
	"Cat512": {"name": "Grass Cat",
				"weight": 512,
				"sprite": preload("res://asset/cat_card/cat512.png")},
	"Cat256": {"name": "Clover Cat",
				"weight": 256,
				"sprite": preload("res://asset/cat_card/cat256.png")},
	"Cat128": {"name": "Dandelion Cat",
				"weight": 128,
				"sprite": preload("res://asset/cat_card/cat128.png")},
	"Cat64": {"name": "Mint Cat",
				"weight": 64,
				"sprite": preload("res://asset/cat_card/cat64.png")},
	"Cat32": {"name": "Chamomile Cat",
				"weight": 32,
				"sprite": preload("res://asset/cat_card/cat32.png")},
	"Cat16": {"name": "Lavender Cat",
				"weight": 16,
				"sprite": preload("res://asset/cat_card/cat16.png")},
	"Cat8": {"name": "Blueberry Cat",
				"weight": 8,
				"sprite": preload("res://asset/cat_card/cat8.png")},
	"Cat4": {"name": "Cherry Cat",
				"weight": 4,
				"sprite": preload("res://asset/cat_card/cat4.png")},
	"Cat2": {"name": "Strawberry Cat",
				"weight": 2,
				"sprite": preload("res://asset/cat_card/cat2.png")},
	"Cat1": {"name": "Jasmine Cat",
				"weight": 1,
				"sprite": preload("res://asset/cat_card/cat1.png")},
}

var _cat_empty_pool: Dictionary = {
	"Cat1024": {"lvl": 0, "count": 0},
	"Cat512": {"lvl": 0, "count": 0},
	"Cat256": {"lvl": 0, "count": 0},
	"Cat128": {"lvl": 0, "count": 0},
	"Cat64": {"lvl": 0, "count": 0},
	"Cat32": {"lvl": 0, "count": 0},
	"Cat16": {"lvl": 0, "count": 0},
	"Cat8": {"lvl": 0, "count": 0},
	"Cat4": {"lvl": 0, "count": 0},
	"Cat2": {"lvl": 0, "count": 0},
	"Cat1": {"lvl": 0, "count": 0},
}

var collected_cat: Dictionary = {}
var sorted_cats: Array = []

func _ready() -> void:
	SignalBus.collection_change.connect(save_collection)
	sorted_cats = _cat_static_pool.keys()
	sorted_cats.sort_custom(
		func(a, b): return _cat_static_pool[a].weight > _cat_static_pool[b].weight
		)
	collected_cat = _cat_empty_pool.duplicate(true)
	load_collection()

func get_cat_info(cat_id: String) -> Dictionary:
	var cat_dict = {
		"name": 0,
		"weight": 1024,
		"sprite": preload("res://asset/cat_card/cat1024.png"),
		"lvl": 0,
		"count": 0,
		"need_to_upgrade": UPGRADE_MUL
	}
	if collected_cat.has(cat_id) and _cat_static_pool.has(cat_id):
		cat_dict["name"] = _cat_static_pool[cat_id]["name"]
		cat_dict["weight"] = _cat_static_pool[cat_id]["weight"]
		cat_dict["sprite"] = _cat_static_pool[cat_id]["sprite"]
		cat_dict["lvl"] = collected_cat[cat_id]["lvl"]
		cat_dict["count"] = collected_cat[cat_id]["count"]
		cat_dict["need_to_upgrade"] = (collected_cat[cat_id]["lvl"] + 1) * UPGRADE_MUL
	return cat_dict



func get_random_cat_key() -> String:
	return "cat1024"

func get_random_cats(count: int) -> Dictionary:
	var new_cat: Dictionary = {}
	for i in count:
		var key = get_random_cat_key()
		if new_cat.has(key):
			new_cat[key] += 1
		else:
			new_cat[key] = 1
	return new_cat


func add_cat_to_collection(new_cat: Dictionary) -> void:
	collected_cat["cat1024"]["count"] += new_cat.get("cat1024", 0)
	collected_cat["cat512"]["count"] += new_cat.get("cat512", 0)
	collected_cat["cat256"]["count"] += new_cat.get("cat256", 0)
	collected_cat["cat128"]["count"] += new_cat.get("cat128", 0)
	collected_cat["cat64"]["count"] += new_cat.get("cat64", 0)
	collected_cat["cat32"]["count"] += new_cat.get("cat32", 0)
	collected_cat["cat16"]["count"] += new_cat.get("cat16", 0)
	collected_cat["cat8"]["count"] += new_cat.get("cat8", 0)
	collected_cat["cat4"]["count"] += new_cat.get("cat4", 0)
	collected_cat["cat2"]["count"] += new_cat.get("cat2", 0)
	collected_cat["cat1"]["count"] += new_cat.get("cat1", 0)
	save_collection()


func upgrade_cat(key: String) -> void:
	if collected_cat.has(key):
		var current_count: int = collected_cat[key]["count"]
		var current_lvl: int = collected_cat[key]["lvl"]
		var need_for_upgrade: int = (current_lvl + 1) * UPGRADE_MUL
		if current_count <= need_for_upgrade:
			current_count -= need_for_upgrade
			current_lvl += 1
		else:
			pass
		collected_cat[key]["count"] = current_count
		collected_cat[key]["lvl"] = current_lvl
	save_collection()


func is_cat_upgradable(key: String):
	if collected_cat.has(key):
		var current_count: int = collected_cat[key]["count"]
		var current_lvl: int = collected_cat[key]["lvl"]
		var need_for_upgrade: int = (current_lvl + 1) * UPGRADE_MUL
		return current_count <= need_for_upgrade
	else:
		return false


func save_collection() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(collected_cat)
	else:
		push_error("Error: File not opened")


func load_collection() -> void:
	var load_dict = {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		if typeof(data) == TYPE_DICTIONARY:
			load_dict = data
		else:
			push_warning("Collection file is corrupted, default values ​​will be used.")
	else:
		push_warning("Collection file not found, default values ​​will be used.")
	apply_collection(load_dict)
	save_collection()


func apply_collection(load_dict: Dictionary) -> void:
	for key in sorted_cats:
		var new_values: Dictionary = load_dict.get(key, _cat_empty_pool[key])
		collected_cat[key]["lvl"] = new_values["lvl"]
		collected_cat[key]["count"] = new_values["count"]
