class_name EnemyDefinition
extends Resource

var id: StringName
var display_name: String
var icon: StringName
var color: Color
var base_power: int
var behavior: StringName
var max_hp: float
var attack: float
var defense: float
var attack_speed: float


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", "")
	icon = data.get("icon", &"gem")
	color = data.get("color", Color.WHITE)
	base_power = data.get("power", 0)
	behavior = data.get("behavior", &"basic")
	max_hp = float(data.get("max_hp", maxf(100.0, base_power * 2.8)))
	attack = float(data.get("attack", maxf(10.0, base_power * 0.28)))
	defense = float(data.get("defense", maxf(0.0, base_power * 0.25)))
	attack_speed = float(data.get("attack_speed", 85.0))


func combat_snapshot(level: int) -> Dictionary:
	var scale := 1.0 + float(maxi(1, level) - 1) * 0.45
	return {
		"id":id, "name":display_name, "team":&"enemy", "behavior":behavior,
		"stats":{
			&"max_hp":max_hp * scale, &"max_mp":0.0, &"attack":attack * scale,
			&"defense":defense * scale, &"attack_speed":attack_speed,
			&"critical_chance":3.0, &"critical_damage":140.0,
			&"block_chance":2.0, &"evasion":2.0,
		},
	}
