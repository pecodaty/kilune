extends SceneTree


func _init() -> void:
	var state := HeroProgressionState.new()
	var identity := state.identity_snapshot()
	_assert(identity["name"] == "FERN" and identity["level"] == 32, "Fern identity")
	_assert(identity["title"] == "ADVENTURER", "Adventurer title")
	_assert(identity["path"] == "Harmony" and identity["specialization"] == "Oracle", "selected traits")
	_assert(state.skills_snapshot().size() == 8, "eight current skills")
	_assert(state.loadout_snapshot().size() == 6, "six loadout slots")
	_assert(not HeroData.talent_sections()[&"path2"]["chosen"] and HeroData.talent_sections()[&"path2"]["unlock"] == 50, "Path II milestone placeholder")
	_assert(not HeroData.talent_sections()[&"spec2"]["chosen"] and HeroData.talent_sections()[&"spec2"]["unlock"] == 70, "Specialization II milestone placeholder")

	var skills := state.skills_snapshot()
	skills[0]["level"] = 0
	_assert(state.skills_snapshot()[0]["level"] == 5, "skill snapshot is defensive")
	_assert(state.toggle_skill_loadout(&"thorn_orb"), "unequip learned skill")
	_assert(not state.loadout_snapshot().has(&"thorn_orb"), "loadout removal")
	_assert(state.toggle_skill_loadout(&"thorn_orb"), "reequip learned skill")
	_assert(state.upgrade_skill(&"spirit_link"), "level-gated skill upgrade")
	_assert(not state.upgrade_skill(&"thorn_orb"), "level 40 skill gate")

	var hp_before := _stat(state, &"max_hp")
	var vitality_rank := _talent_rank(state, &"t_vit")
	_assert(state.set_talent_rank(&"t_vit", vitality_rank - 1), "dependency-safe talent refund")
	_assert(_stat(state, &"max_hp") < hp_before, "talent refreshes calculated stats")
	_assert(state.set_talent_rank(&"t_vit", vitality_rank), "talent rank restore")
	for rank in range(4, -1, -1):
		_assert(state.set_talent_rank(&"t_pow", rank), "refund alternate prerequisite parent")
	_assert(state.set_talent_rank(&"t_vit", 2), "refund vitality to rank two")
	_assert(state.set_talent_rank(&"t_vit", 1), "refund vitality to rank one")
	_assert(not state.set_talent_rank(&"t_vit", 0), "reject refund required by learned child")

	var power_before := _stat(state, &"power")
	_assert(state.item_action(&"oracle_signet") == &"replace", "same-slot replacement action")
	_assert(state.equip_item(&"oracle_signet"), "replace equipped ring")
	_assert(_stat(state, &"power") < power_before, "replaced item is not double-counted")
	_assert(state.item_action(&"oracle_signet") == &"unequip", "equipped item action")
	_assert(state.unequip_item(&"oracle_signet"), "unequip item")
	_assert(state.item_action(&"ember_signet") == &"equip", "empty-slot equip action")
	_assert(state.equip_item(&"ember_signet"), "equip item")
	quit(0)


func _stat(state: HeroProgressionState, stat_id: StringName) -> float:
	for stat in state.stats_snapshot():
		if stat["id"] == stat_id:
			return stat["final"]
	return -1.0


func _talent_rank(state: HeroProgressionState, talent_id: StringName) -> int:
	for talent in state.talents_snapshot():
		if talent["id"] == talent_id:
			return talent["rank"]
	return -1


func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("HeroProgressionState assertion failed: " + label)
		quit(1)
