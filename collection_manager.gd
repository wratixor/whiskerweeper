extends Node

var cat_card_scene: PackedScene = preload("res://game/ext/cat_card.tscn")

@onready var grid_collection: FlowContainer = %GridCollection
@onready var meta: Label = %Meta


func _ready() -> void:
	meta.text = str(Global.meta)
	load_collections()
	

func load_collections() -> void:
	for key in CatCollection.sorted_cats:
		var card: CatCard = cat_card_scene.instantiate()
		card.pre_setup(key, 0, true)
		grid_collection.add_child(card)


func _on_sfx_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game/scene/Main.tscn")
