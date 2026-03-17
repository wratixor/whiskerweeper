extends Node

var cat_card_scene: PackedScene = preload("res://game/ext/cat_card.tscn")

@onready var win_panel: PanelContainer = %WinPanel
@onready var finded_cat: FlowContainer = %FindedCat
@onready var meta_count: Label = %Meta


func _ready() -> void:
	SignalBus.generate_win_loot.connect(generate)

func _on_sfx_button_pressed() -> void:
	SignalBus.regenerate_lvl.emit()
	win_panel.visible = false
	for child in finded_cat.get_children():
		child.free()


func generate(count: int) -> void:
	var collected_cats: Dictionary = CatCollection.get_random_cats(count)
	var local_meta: int = 0
	for key in collected_cats:
		var cat_info: Dictionary = CatCollection.get_cat_info(key)
		var card: CatCard = cat_card_scene.instantiate()
		local_meta += cat_info["meta_collected"] * collected_cats[key]
		card.pre_setup(key, collected_cats[key], false)
		finded_cat.add_child(card)
	meta_count.text = str(local_meta)
	Global.meta += local_meta
	CatCollection.add_cat_to_collection(collected_cats)
	SignalBus.settings_change.emit()
