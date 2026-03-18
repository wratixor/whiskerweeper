extends Node


var upgrade_card_scene: PackedScene = preload("res://game/ext/upgrade_card.tscn")

@onready var grid_collection: FlowContainer = %GridCollection
@onready var meta: Label = %Meta
@onready var swap_sfx_button: Button = %SwapSFXButton


func _ready() -> void:
	meta.text = str(Global.meta)
	SignalBus.generate_shop.connect(re_draw)
	load_collections()

func re_draw() -> void:
	grid_collection.visible = false
	meta.text = str(Global.meta)
	for child in grid_collection.get_children():
		child.queue_free()
	load_collections()
	grid_collection.visible = true

func load_collections() -> void:
	if Global.is_only_available:
		swap_sfx_button.text = "All"
		for key in Shop.get_available_upgrades():
			var card: UpgradeCard = upgrade_card_scene.instantiate()
			card.pre_setup(key)
			grid_collection.add_child(card)
	else:
		swap_sfx_button.text = "Available"
		for key in Shop._upgrade_empty_pool:
			var card: UpgradeCard = upgrade_card_scene.instantiate()
			card.pre_setup(key)
			grid_collection.add_child(card)


func _on_sfx_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/Main.tscn")


func _on_swap_sfx_button_pressed() -> void:
	Global.is_only_available = !Global.is_only_available
	SignalBus.generate_shop.emit()
