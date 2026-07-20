class_name EnemyDefinition
extends Resource

var id: StringName
var display_name: String
var icon: StringName
var color: Color
var base_power: int
var behavior: StringName


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", "")
	icon = data.get("icon", &"gem")
	color = data.get("color", Color.WHITE)
	base_power = data.get("power", 0)
	behavior = data.get("behavior", &"basic")
