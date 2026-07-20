class_name RewardDefinition
extends Resource

var id: StringName
var display_name: String
var description: String
var item_id: StringName
var currency_id: StringName
var quantity: int


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", "")
	description = data.get("description", "")
	item_id = data.get("item_id", &"")
	currency_id = data.get("currency_id", &"")
	quantity = data.get("quantity", 0)
