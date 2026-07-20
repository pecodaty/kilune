class_name HeroProgressionState
extends RefCounted
## Hero-specific progression composed into PlayerProfile. Inventory/equipment
## ownership is delegated to the profile's shared InventoryState.

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
var _inventory_state: InventoryState


func _init(inventory_state: InventoryState = null, data: Dictionary = {}) -> void:
	_inventory_state = inventory_state if inventory_state != null else InventoryState.new()
	_inventory_state.changed.connect(_on_inventory_changed)
	for skill in HeroData.active_skills():
		_skills.append(skill.duplicate(true))
	_loadout = HeroData.equipped_skills().duplicate()
	for talent in HeroData.constellation_talents():
		_talents.append(talent.duplicate(true))
	if not data.is_empty():
		restore(data, false)


func identity_snapshot() -> Dictionary:
	return _identity.duplicate(true)


func skills_snapshot() -> Array[Dictionary]:
	return _skills.duplicate(true)


func loadout_snapshot() -> Array[StringName]:
	return _loadout.duplicate()


func talents_snapshot() -> Array[Dictionary]:
	return _talents.duplicate(true)


func inventory_snapshot() -> Array[Dictionary]:
	return _inventory_state.equipment_items_snapshot()


func equipped_snapshot() -> Dictionary:
	return _inventory_state.equipment_snapshot()


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


func upgrade_skill(skill_id: StringName) -> StateMutationResult:
	var skill := _find(_skills, skill_id)
	if skill.is_empty() or not TraitRules.can_upgrade_skill(skill, skill_points_spent(), int(_identity["level"])):
		return StateMutationResult.rejected(&"skill_upgrade_blocked", "Skill cannot be upgraded.")
	skill["level"] += 1
	changed.emit(&"skills")
	return StateMutationResult.accepted(&"skills", &"skill_upgraded")


func upgrade_mastery(skill_id: StringName) -> StateMutationResult:
	var skill := _find(_skills, skill_id)
	if skill.is_empty() or not TraitRules.can_upgrade_mastery(skill, skill_points_spent(), int(_identity["level"])):
		return StateMutationResult.rejected(&"mastery_upgrade_blocked", "Mastery cannot be upgraded.")
	skill["mastery"] += 1
	changed.emit(&"skills")
	return StateMutationResult.accepted(&"skills", &"mastery_upgraded")


func set_loadout_slot(slot_index: int, skill_id: StringName) -> StateMutationResult:
	if slot_index < 0 or slot_index >= _loadout.size():
		return StateMutationResult.rejected(&"invalid_slot", "Invalid loadout slot.")
	if not skill_id.is_empty():
		var skill := _find(_skills, skill_id)
		if skill.is_empty() or int(skill["level"]) <= 0 or _loadout.has(skill_id):
			return StateMutationResult.rejected(&"invalid_skill", "Skill is unavailable or already equipped.")
	_loadout[slot_index] = skill_id
	changed.emit(&"loadout")
	return StateMutationResult.accepted(&"loadout")


func toggle_skill_loadout(skill_id: StringName) -> StateMutationResult:
	var occupied := _loadout.find(skill_id)
	if occupied >= 0:
		return set_loadout_slot(occupied, &"")
	var empty := _loadout.find(&"")
	if empty < 0:
		return StateMutationResult.rejected(&"loadout_full", "No empty loadout slot.")
	return set_loadout_slot(empty, skill_id)


func set_talent_rank(talent_id: StringName, rank: int) -> StateMutationResult:
	var talent := _find(_talents, talent_id)
	if talent.is_empty() or abs(rank - int(talent["rank"])) != 1:
		return StateMutationResult.rejected(&"invalid_rank_change", "Talent ranks change one point at a time.")
	var level := int(_identity["level"])
	var section: Dictionary = HeroData.talent_sections()[talent["section"]]
	if rank > int(talent["rank"]):
		if not bool(section["chosen"]) or not TraitRules.can_increase_talent(talent, _talents, level, int(section["unlock"])):
			return StateMutationResult.rejected(&"talent_upgrade_blocked", "Talent requirements are not met.")
	else:
		if not TraitRules.can_refund_talent(talent_id, _talents, level, _section_unlocks()):
			return StateMutationResult.rejected(&"talent_refund_blocked", "Another learned talent depends on this rank.")
	talent["rank"] = rank
	changed.emit(&"talents")
	return StateMutationResult.accepted(&"talents", &"talent_rank_changed")


func equip_item(item_id: StringName) -> StateMutationResult:
	return _inventory_state.equip_item(item_id)


func unequip_item(item_id: StringName) -> StateMutationResult:
	return _inventory_state.unequip_item(item_id)


func item_snapshot(item_id: StringName) -> Dictionary:
	return _inventory_state.item_snapshot(item_id)


func equipped_item_in(slot_id: StringName) -> Dictionary:
	return _inventory_state.equipped_item_in(slot_id)


func item_action(item_id: StringName) -> StringName:
	return _inventory_state.item_action(item_id)


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
			"final":base + equipment + talent, "percent":definition["percent"],
		})
	return out


func _equipment_modifiers() -> Dictionary:
	var totals := {}
	for item_id in _inventory_state.equipment_snapshot().values():
		var item := _inventory_state.item_snapshot(item_id)
		for stat_id in item.get("modifiers", {}):
			totals[stat_id] = totals.get(stat_id, 0.0) + float(item["modifiers"][stat_id])
	return totals


func to_dict() -> Dictionary:
	var skill_ranks := {}
	for skill in _skills:
		skill_ranks[skill["id"]] = {"level":skill["level"], "mastery":skill["mastery"]}
	var talent_ranks := {}
	for talent in _talents:
		talent_ranks[talent["id"]] = talent["rank"]
	return {"skills":skill_ranks, "loadout":_loadout.duplicate(), "talents":talent_ranks}


func restore(data: Dictionary, emit_change := true) -> StateMutationResult:
	var skill_ranks: Dictionary = data.get("skills", {})
	for skill in _skills:
		var saved: Dictionary = skill_ranks.get(skill["id"], {})
		if not saved.is_empty():
			skill["level"] = clampi(int(saved.get("level", skill["level"])), 0, TraitRules.MAX_SKILL_LEVEL)
			skill["mastery"] = clampi(int(saved.get("mastery", skill["mastery"])), 0, TraitRules.MAX_SKILL_MASTERY)
	var loadout_data: Array = data.get("loadout", _loadout)
	var restored_loadout: Array[StringName] = []
	for raw_id in loadout_data.slice(0, 6):
		var id := StringName(raw_id)
		restored_loadout.append(id if id.is_empty() or not _find(_skills, id).is_empty() else &"")
	while restored_loadout.size() < 6:
		restored_loadout.append(&"")
	_loadout = restored_loadout
	var talent_ranks: Dictionary = data.get("talents", {})
	for talent in _talents:
		if talent_ranks.has(talent["id"]):
			talent["rank"] = clampi(int(talent_ranks[talent["id"]]), 0, int(talent["max"]))
	if emit_change:
		changed.emit(&"restored")
	return StateMutationResult.accepted(&"restored")


func _on_inventory_changed(change_kind: StringName) -> void:
	if change_kind == &"equipment" or change_kind == &"restored" or change_kind == &"items":
		changed.emit(&"equipment")


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
