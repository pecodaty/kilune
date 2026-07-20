class_name ItemDefinition
extends Resource

var id: StringName
var display_name: String
var category: StringName
var rarity: StringName
var icon: StringName
var slot: StringName
var level: int
var default_quantity: int
var stats: Array = []
var modifiers: Dictionary = {}
var enhance: String
var success: String
var locked: Array = []
var description: String


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", "")
	category = data.get("category", &"misc")
	rarity = data.get("rarity", &"common")
	icon = data.get("icon", &"gem")
	slot = data.get("slot", &"")
	level = data.get("level", data.get("lv", 0))
	default_quantity = data.get("quantity", 0)
	stats = data.get("stats", []).duplicate(true)
	modifiers = data.get("modifiers", {}).duplicate(true)
	enhance = data.get("enhance", "+0/0")
	success = data.get("success", "100%")
	locked = data.get("locked", []).duplicate(true)
	description = data.get("desc", "")


func snapshot(quantity := 0, equipped := false) -> Dictionary:
	return {
		"id":id, "name":display_name, "category":category, "rarity":rarity,
		"icon":icon, "slot":slot, "lv":level, "level":level,
		"quantity":quantity, "equipped":equipped, "stats":stats.duplicate(true),
		"modifiers":modifiers.duplicate(true), "enhance":enhance, "success":success,
		"locked":locked.duplicate(true), "desc":description,
	}
