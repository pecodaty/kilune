class_name SkillDefinition
extends Resource

var id: StringName
var display_name: String
var icon: StringName
var section: StringName
var effect_kind: StringName
var base_power: float
var mp_cost: int
var cooldown: float


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", "")
	icon = data.get("icon", &"star")
	section = data.get("section", &"path1")
	effect_kind = data.get("effect", &"unimplemented")
	base_power = data.get("power", 0.0)
	mp_cost = data.get("mp_cost", 0)
	cooldown = data.get("cooldown", 0.0)


func progression_snapshot(level: int, mastery: int) -> Dictionary:
	return {"id":id, "name":display_name, "icon":icon, "section":section, "level":level, "mastery":mastery}
