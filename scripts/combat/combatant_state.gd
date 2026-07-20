class_name CombatantState
extends RefCounted
## Mutable state for one participant in a CombatController encounter.

var id: StringName
var display_name: String
var team: StringName
var stats: Dictionary
var current_hp: float
var current_mp: float
var barrier := 0.0
var alive := true
var is_summon := false
var attack_timer := 0.0
var cooldowns: Dictionary = {}
var statuses: Array[Dictionary] = []


func _init(data: Dictionary = {}) -> void:
	id = data.get("id", &"")
	display_name = data.get("name", String(id))
	team = data.get("team", &"enemy")
	stats = data.get("stats", {}).duplicate(true)
	current_hp = float(data.get("current_hp", stat(&"max_hp")))
	current_mp = float(data.get("current_mp", stat(&"max_mp")))
	is_summon = bool(data.get("is_summon", false))
	attack_timer = attack_interval()


func stat(stat_id: StringName) -> float:
	var value := float(stats.get(stat_id, 0.0))
	for status in statuses:
		value += float(status.get("flat", {}).get(stat_id, 0.0))
		value *= 1.0 + float(status.get("percent", {}).get(stat_id, 0.0)) / 100.0
	return maxf(0.0, value)


func attack_interval() -> float:
	return 2.0 / maxf(0.1, stat(&"attack_speed") / 100.0)


func is_skill_ready(skill_id: StringName) -> bool:
	return float(cooldowns.get(skill_id, 0.0)) <= 0.0


func snapshot() -> Dictionary:
	return {
		"id":id, "name":display_name, "team":team, "alive":alive,
		"hp":current_hp, "max_hp":stat(&"max_hp"),
		"mp":current_mp, "max_mp":stat(&"max_mp"),
		"barrier":barrier, "cooldowns":cooldowns.duplicate(true),
		"statuses":statuses.duplicate(true), "is_summon":is_summon,
	}
