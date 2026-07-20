class_name HeroProgressionState
extends RefCounted
## Heroes-owned, session-local progression model. Snapshots are deep copies so
## UI tabs cannot mutate state without passing validation here.

signal changed(change_kind: StringName)

const STAT_ORDER: Array[StringName] = [
	&"power", &"max_hp", &"max_mp", &"attack", &"skill_power",
	&"critical_chance", &"critical_damage", &"attack_speed", &"defense",
	&"block_chance", &"evasion", &"cooldown_reduction", &"move_speed",
	&"healing_power",
]

const STAT_DEFINITIONS := {
	&"power":{"label":"Power", "group":"CORE", "base":650.0, "percent":false},
	&"max_hp":{"label":"Max HP", "group":"CORE", "base":420.0, "percent":false},
	&"max_mp":{"label":"Max MP", "group":"CORE", "base":180.0, "percent":false},
	&"attack":{"label":"Attack", "group":"OFFENSE", "base":86.0, "percent":false},
	&"skill_power":{"label":"Skill Power", "group":"OFFENSE", "base":100.0, "percent":false},
	&"critical_chance":{"label":"Critical Chance", "group":"OFFENSE", "base":5.0, "percent":true},
	&"critical_damage":{"label":"Critical Damage", "group":"OFFENSE", "base":150.0, "percent":true},
	&"attack_speed":{"label":"Attack Speed", "group":"OFFENSE", "base":100.0, "percent":true},
	&"defense":{"label":"Defense", "group":"DEFENSE", "base":54.0, "percent":false},
	&"block_chance":{"label":"Block Chance", "group":"DEFENSE", "base":3.0, "percent":true},
	&"evasion":{"label":"Evasion", "group":"DEFENSE", "base":4.0, "percent":true},
	&"cooldown_reduction":{"label":"Cooldown Reduction", "group":"UTILITY", "base":0.0, "percent":true},
	&"move_speed":{"label":"Move Speed", "group":"UTILITY", "base":100.0, "percent":true},
	&"healing_power":{"label":"Healing Power", "group":"UTILITY", "base":100.0, "percent":true},
}

const TALENT_STAT_MODIFIERS := {
	&"t_pow": {&"attack":4.0}, &"t_vit": {&"max_hp":5.0}, &"t_arc": {&"max_mp":8.0},
	&"t_bh": {&"defense":3.0}, &"t_swift": {&"attack_speed":2.0},
	&"t_crit": {&"critical_chance":1.0}, &"t_mind": {&"healing_power":3.0},
	&"t_cd": {&"cooldown_reduction":1.5}, &"t_dodge": {&"evasion":1.0},
	&"t_res": {&"block_chance":1.0}, &"t_life": {&"skill_power":3.0},
	&"s1_am": {&"skill_power":5.0}, &"s1_ms": {&"healing_power":3.0},
	&"s1_cs": {&"block_chance":2.0}, &"s1_pl": {&"cooldown_reduction":1.0},
	&"s1_es": {&"evasion":1.0}, &"s1_ae": {&"max_mp":4.0},
	&"s1_rw": {&"defense":3.0},
}

var _identity: Dictionary = HeroData.hero()
var _skills: Array[Dictionary] = []
var _loadout: Array[StringName] = []
var _talents: Array[Dictionary] = []
var _inventory: Array[Dictionary] = []
var _equipment: Dictionary = {}


func _init() -> void:
	for skill in HeroData.active_skills():
		_skills.append(skill.duplicate(true))
	_loadout = HeroData.equipped_skills().duplicate()
	for talent in HeroData.constellation_talents():
		_talents.append(talent.duplicate(true))
	for item in HeroData.inventory():
		_inventory.append(item.duplicate(true))
	_equipment = HeroData.initial_equipment().duplicate(true)


func identity_snapshot() -> Dictionary:
	return _identity.duplicate(true)


func skills_snapshot() -> Array[Dictionary]:
	return _skills.duplicate(true)


func loadout_snapshot() -> Array[StringName]:
	return _loadout.duplicate()


func talents_snapshot() -> Array[Dictionary]:
	return _talents.duplicate(true)


func inventory_snapshot() -> Array[Dictionary]:
	return _inventory.duplicate(true)


func equipped_snapshot() -> Dictionary:
	return _equipment.duplicate(true)


func skill_points_spent() -> int:
	var total := 0
	for skill in _skills:
		total += int(skill["level"]) + int(skill["mastery"])
	return total


func talent_points_spent() -> int:
	var total := 0
	for talent in _talents:
		total += int(talent["rank"])
	return total


func upgrade_skill(skill_id: StringName) -> bool:
	var skill := _find(_skills, skill_id)
	if skill.is_empty() or not TraitRules.can_upgrade_skill(skill, skill_points_spent(), int(_identity["level"])):
		return false
	skill["level"] += 1
	changed.emit(&"skills")
	return true


func upgrade_mastery(skill_id: StringName) -> bool:
	var skill := _find(_skills, skill_id)
	if skill.is_empty() or not TraitRules.can_upgrade_mastery(skill, skill_points_spent(), int(_identity["level"])):
		return false
	skill["mastery"] += 1
	changed.emit(&"skills")
	return true


func set_loadout_slot(slot_index: int, skill_id: StringName) -> bool:
	if slot_index < 0 or slot_index >= _loadout.size():
		return false
	if not skill_id.is_empty():
		var skill := _find(_skills, skill_id)
		if skill.is_empty() or int(skill["level"]) <= 0 or _loadout.has(skill_id):
			return false
	_loadout[slot_index] = skill_id
	changed.emit(&"loadout")
	return true


func toggle_skill_loadout(skill_id: StringName) -> bool:
	var occupied := _loadout.find(skill_id)
	if occupied >= 0:
		return set_loadout_slot(occupied, &"")
	var empty := _loadout.find(&"")
	return empty >= 0 and set_loadout_slot(empty, skill_id)


func set_talent_rank(talent_id: StringName, rank: int) -> bool:
	var talent := _find(_talents, talent_id)
	if talent.is_empty() or abs(rank - int(talent["rank"])) != 1:
		return false
	var level := int(_identity["level"])
	var section: Dictionary = HeroData.talent_sections()[talent["section"]]
	if rank > int(talent["rank"]):
		if not bool(section["chosen"]) or not TraitRules.can_increase_talent(talent, _talents, level, int(section["unlock"])):
			return false
	else:
		if not TraitRules.can_refund_talent(talent_id, _talents, level, _section_unlocks()):
			return false
	talent["rank"] = rank
	changed.emit(&"talents")
	return true


func equip_item(item_id: StringName) -> bool:
	var item := _find(_inventory, item_id)
	if item.is_empty():
		return false
	var slot: StringName = item["slot"]
	if _equipment.get(slot, &"") == item_id:
		return false
	_equipment[slot] = item_id
	changed.emit(&"equipment")
	return true


func unequip_item(item_id: StringName) -> bool:
	var item := _find(_inventory, item_id)
	if item.is_empty():
		return false
	var slot: StringName = item["slot"]
	if _equipment.get(slot, &"") != item_id:
		return false
	_equipment.erase(slot)
	changed.emit(&"equipment")
	return true


func item_snapshot(item_id: StringName) -> Dictionary:
	return _find(_inventory, item_id).duplicate(true)


func equipped_item_in(slot_id: StringName) -> Dictionary:
	return item_snapshot(_equipment.get(slot_id, &""))


func item_action(item_id: StringName) -> StringName:
	var item := _find(_inventory, item_id)
	if item.is_empty():
		return &""
	var equipped_id: StringName = _equipment.get(item["slot"], &"")
	if equipped_id == item_id:
		return &"unequip"
	return &"replace" if not equipped_id.is_empty() else &"equip"


func stats_snapshot() -> Array[Dictionary]:
	var equipment_flat := _equipment_modifiers()
	var talent_percent := _talent_modifiers()
	var out: Array[Dictionary] = []
	for stat_id in STAT_ORDER:
		var definition: Dictionary = STAT_DEFINITIONS[stat_id]
		var base: float = definition["base"]
		var equipment: float = equipment_flat.get(stat_id, 0.0)
		var talent: float = (base + equipment) * talent_percent.get(stat_id, 0.0) / 100.0
		out.append({
			"id":stat_id, "label":definition["label"], "group":definition["group"],
			"base":base, "equipment":equipment, "talent":talent,
			"talent_percent":talent_percent.get(stat_id, 0.0),
			"final":base + equipment + talent, "percent":definition["percent"],
		})
	return out


func _equipment_modifiers() -> Dictionary:
	var totals := {}
	for item_id in _equipment.values():
		var item := _find(_inventory, item_id)
		for stat_id in item.get("modifiers", {}):
			totals[stat_id] = totals.get(stat_id, 0.0) + float(item["modifiers"][stat_id])
	return totals


func _talent_modifiers() -> Dictionary:
	var totals := {}
	for talent in _talents:
		var rank := int(talent["rank"])
		if rank <= 0:
			continue
		for stat_id in TALENT_STAT_MODIFIERS.get(talent["id"], {}):
			totals[stat_id] = totals.get(stat_id, 0.0) + float(TALENT_STAT_MODIFIERS[talent["id"]][stat_id]) * rank
	return totals


func _section_unlocks() -> Dictionary:
	var out := {}
	for section_id in HeroData.talent_sections():
		out[section_id] = HeroData.talent_sections()[section_id]["unlock"]
	return out


func _find(entries: Array[Dictionary], id: StringName) -> Dictionary:
	for entry in entries:
		if entry["id"] == id:
			return entry
	return {}
