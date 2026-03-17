extends MarginContainer
class_name CatCard

@onready var name_cat: Label = %NameCat
@onready var image_container: CenterContainer = %ImageContainer
@onready var texture_rect: TextureRect = %TextureRect
@onready var cat_count: Label = %CatCount
@onready var upgrade_sfx_button: Button = %UpgradeSFXButton

var self_cat_id: String = "Cat1024"
var self_count: int = 0
var self_is_collection: bool = false

func _ready() -> void:
	re_draw()

func re_draw() -> void:
	setup(self_cat_id, self_count, self_is_collection)

func pre_setup(cat_id: String, count: int, visible_upgrade: bool) -> void:
	self_cat_id = cat_id
	self_count = count
	self_is_collection = visible_upgrade

func setup(cat_id: String, count: int, visible_upgrade: bool) -> void:
	var cat_info: Dictionary = CatCollection.get_cat_info(cat_id)
	name_cat.text = cat_info["name"]
	texture_rect.texture = cat_info["sprite"]
	if visible_upgrade:
		if cat_info["count"] < 1 and cat_info["lvl"] < 1:
			image_container.modulate = Color(0.2, 0.2, 0.2, 1)
		cat_count.text = str(cat_info["lvl"])
		
		if cat_info["count"] >= cat_info["need_to_upgrade"]:
			upgrade_sfx_button.disabled = false
		else:
			upgrade_sfx_button.disabled = true
		
		if cat_info["count"] > 0:
			upgrade_sfx_button.text = str(cat_info["count"] * 100
									 / cat_info["need_to_upgrade"]) + "%"
		else:
			upgrade_sfx_button.text = "0%"
		
		upgrade_sfx_button.visible = true
	
	else:
		cat_count.text = str(count)
		upgrade_sfx_button.disabled = true
		upgrade_sfx_button.visible = false


func _on_upgrade_sfx_button_pressed() -> void:
	if CatCollection.is_cat_upgradable(self_cat_id):
		CatCollection.upgrade_cat(self_cat_id)
		re_draw()
		
