extends MarginContainer
class_name UpgradeCard

@onready var name_upgrade: Label = %NameUpgrade
@onready var upgrade_desc: Label = %UpgradeDesc
@onready var upgrade_sfx_button: Button = %UpgradeSFXButton

var self_id: String = ""

func _ready() -> void:
	re_draw()

func re_draw() -> void:
	setup(self_id)

func pre_setup(upgrade_id: String) -> void:
	self_id = upgrade_id

		#"Dependency": null,
		#"Cost": 0,
		#"Name": "",
		#"Desc": "",
		#"Is_purchased": false,
		#"Is_available": false

func setup(upgrade_id: String) -> void:
	var info: Dictionary = Shop.get_upgrade_info(upgrade_id)
	name_upgrade.text = info["Name"]
	upgrade_desc.text = info["Desc"]
	if info["Is_available"]:
		if info["Cost"] <= Global.meta:
			upgrade_sfx_button.disabled = false
		else:
			upgrade_sfx_button.disabled = true
		upgrade_sfx_button.text = "Buy: " + str(info["Cost"])
	else:
		upgrade_sfx_button.disabled = true
		if info["Is_purchased"]:
			upgrade_sfx_button.text = "Bought"
			upgrade_sfx_button.add_theme_color_override("font_color", Color.GREEN)
		else:
			upgrade_sfx_button.text = "A previous upgrade is required!"
			upgrade_sfx_button.add_theme_font_size_override("font_size", 11)


func _on_upgrade_sfx_button_pressed() -> void:
	Shop.buy_upgrade(self_id)
	SignalBus.generate_shop.emit()
