extends SceneTree

const CONTROLLER := preload("res://scripts/combat/combat_controller.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_manual_skill_cost_and_cooldown()
	_test_all_skill_effects()
	_test_combat_resolution_rules()
	_test_progression_stats_feed_combat()
	_test_target_selection()
	_test_deterministic_auto_encounter()
	await _test_dungeon_integration()
	call_deferred("_finish")


func _test_manual_skill_cost_and_cooldown() -> void:
	var profile := PlayerProfile.new()
	var controller = CONTROLLER.new()
	controller.auto_enabled = false
	controller.start(profile.combat_snapshot(), _durable_enemy(), 7)
	var before: Dictionary = controller.snapshot()
	var outcome: StateMutationResult = controller.activate_skill(0)
	_assert(outcome.ok, "equipped skill activates manually")
	var after: Dictionary = controller.snapshot()
	_assert(after["hero"]["mp"] == before["hero"]["mp"] - 8, "skill spends MP")
	_assert(after["enemies"][0]["hp"] < before["enemies"][0]["hp"], "damage skill changes enemy HP")
	_assert(controller.cooldown_fraction(0) > 0.0, "skill starts cooldown")
	_assert(not controller.activate_skill(0).ok, "cooldown prevents immediate reuse")
	controller.advance(4.0)
	_assert(controller.cooldown_fraction(0) == 0.0, "cooldown advances deterministically")


func _test_all_skill_effects() -> void:
	var ids: Array[StringName] = [
		&"thorn_orb", &"vine_web", &"canopy_wave", &"send_companion",
		&"dew_restore", &"spirit_link", &"sanctuary_bloom", &"guiding_light",
	]
	for skill_id in ids:
		var controller = CONTROLLER.new()
		controller.auto_enabled = false
		controller.start(_hero_with_loadout([GameCatalog.skill(skill_id).combat_snapshot(3, 1)]), _durable_enemy(), 11)
		_assert(controller.activate_skill(0).ok, "%s activates" % skill_id)
		var state: Dictionary = controller.snapshot()
		match skill_id:
			&"vine_web":
				_assert(_has_status(state["enemies"][0], &"vine_bound"), "control applies debuff")
			&"send_companion":
				_assert(state["allies"].size() == 2 and state["allies"][1]["is_summon"], "summon creates companion")
			&"spirit_link":
				var spent_mp := float(state["hero"]["mp"])
				controller.advance(2.1)
				_assert(float(controller.snapshot()["hero"]["mp"]) > spent_mp, "resource-flow status restores MP")
			&"sanctuary_bloom":
				_assert(float(state["hero"]["barrier"]) > 0.0 and _has_status(state["hero"], &"sanctuary"), "barrier skill protects hero")
			&"guiding_light":
				_assert(_has_status(state["hero"], &"guided"), "buff applies to selected ally")


func _test_combat_resolution_rules() -> void:
	var attack_events: Array[Dictionary] = []
	var controller = CONTROLLER.new()
	controller.auto_enabled = false
	var hero := _hero_with_loadout([])
	_set_stat(hero, &"attack", 100.0)
	_set_stat(hero, &"critical_chance", 100.0)
	var enemy := _durable_enemy()
	enemy["stats"][&"block_chance"] = 100.0
	enemy["stats"][&"evasion"] = 0.0
	controller.damage_dealt.connect(func(_source: StringName, _target: StringName, amount: int, critical: bool, blocked: bool, evaded: bool) -> void:
		attack_events.append({"amount":amount, "critical":critical, "blocked":blocked, "evaded":evaded}))
	controller.start(hero, enemy, 19)
	controller.advance(2.1)
	_assert(attack_events[0]["critical"] and attack_events[0]["blocked"], "critical and block rules resolve")

	var evade_events: Array[Dictionary] = []
	var evasion_controller = CONTROLLER.new()
	evasion_controller.auto_enabled = false
	enemy = _durable_enemy()
	enemy["stats"][&"evasion"] = 100.0
	evasion_controller.damage_dealt.connect(func(_source: StringName, _target: StringName, amount: int, _critical: bool, _blocked: bool, evaded: bool) -> void:
		evade_events.append({"amount":amount, "evaded":evaded}))
	evasion_controller.start(hero, enemy, 19)
	evasion_controller.advance(2.1)
	_assert(evade_events[0]["evaded"] and evade_events[0]["amount"] == 0, "evasion prevents damage")


func _test_progression_stats_feed_combat() -> void:
	var base_profile := PlayerProfile.new()
	var equipped_profile := PlayerProfile.new()
	_assert(equipped_profile.hero.equip_item(&"oracle_signet").ok, "combat equipment setup")
	var base_hero := base_profile.combat_snapshot()
	var equipped_hero := equipped_profile.combat_snapshot()
	_set_stat(base_hero, &"critical_chance", 0.0)
	_set_stat(equipped_hero, &"critical_chance", 0.0)
	var base_controller = CONTROLLER.new()
	var equipped_controller = CONTROLLER.new()
	base_controller.auto_enabled = false
	equipped_controller.auto_enabled = false
	base_controller.start(base_hero, _durable_enemy(), 29)
	equipped_controller.start(equipped_hero, _durable_enemy(), 29)
	base_controller.activate_skill(0)
	equipped_controller.activate_skill(0)
	_assert(float(equipped_controller.snapshot()["enemies"][0]["hp"]) < float(base_controller.snapshot()["enemies"][0]["hp"]), "equipment-derived Skill Power affects damage")

	var rank_one := CONTROLLER.new()
	var ranked := CONTROLLER.new()
	rank_one.auto_enabled = false
	ranked.auto_enabled = false
	rank_one.start(_hero_with_loadout([GameCatalog.skill(&"thorn_orb").combat_snapshot(1, 0)]), _durable_enemy(), 31)
	ranked.start(_hero_with_loadout([GameCatalog.skill(&"thorn_orb").combat_snapshot(5, 2)]), _durable_enemy(), 31)
	rank_one.activate_skill(0)
	ranked.activate_skill(0)
	_assert(float(ranked.snapshot()["enemies"][0]["hp"]) < float(rank_one.snapshot()["enemies"][0]["hp"]), "skill rank and mastery scale magnitude")


func _test_target_selection() -> void:
	var controller = CONTROLLER.new()
	controller.start(_hero_with_loadout([]), _durable_enemy(), 23)
	_assert(controller.select_target(&"enemy", &"training_enemy").ok, "living enemy can be selected")
	_assert(not controller.select_target(&"enemy", &"missing").ok, "unknown target is rejected")


func _test_deterministic_auto_encounter() -> void:
	var profile := PlayerProfile.new()
	var enemy := GameCatalog.enemy(&"gilded_scout").combat_snapshot(1)
	var first = CONTROLLER.new()
	var second = CONTROLLER.new()
	first.start(profile.combat_snapshot(), enemy, 101)
	second.start(profile.combat_snapshot(), enemy, 101)
	for i in range(400):
		first.advance(0.05)
		second.advance(0.05)
		if first.finished and second.finished:
			break
	_assert(first.finished and first.result == &"victory", "auto combat reaches real victory")
	_assert(first.snapshot() == second.snapshot(), "same seed and inputs produce identical combat")

	var defeat = CONTROLLER.new()
	defeat.auto_enabled = false
	var fragile := _hero_with_loadout([])
	_set_stat(fragile, &"max_hp", 10.0)
	var lethal := _durable_enemy()
	lethal["stats"][&"attack"] = 1000.0
	lethal["stats"][&"attack_speed"] = 1000.0
	defeat.start(fragile, lethal, 5)
	defeat.advance(0.25)
	_assert(defeat.finished and defeat.result == &"defeat", "enemy damage causes real defeat")


func _test_dungeon_integration() -> void:
	var scene: PackedScene = load("res://scenes/ui/gameplay/main_gameplay_interface.tscn")
	var interface := scene.instantiate()
	root.add_child(interface)
	await process_frame
	var dungeon: DungeonFlow = interface.get_node("DungeonFlow")
	dungeon.visible = true
	dungeon._selected = GameCatalog.dungeon_snapshots()[0]
	dungeon._level = 1
	dungeon._show_combat()
	await process_frame
	_assert(dungeon._combat_controller != null, "Dungeon creates real combat controller")
	_assert(dungeon._combat_controller == interface.get_node("GameSession").combat, "GameSession owns active combat")
	_assert(dungeon._skill_dock != null and dungeon._combat_view != null, "Dungeon binds combat presentation")
	dungeon._combat_controller.auto_enabled = false
	var mp_before := float(dungeon._combat_controller.snapshot()["hero"]["mp"])
	dungeon._on_skill_pressed(0)
	_assert(float(dungeon._combat_controller.snapshot()["hero"]["mp"]) < mp_before, "Dungeon skill input reaches combat engine")
	_assert(dungeon._enemy_hp_label.text != "--/--", "combat state updates enemy UI")
	interface.queue_free()
	await process_frame


func _hero_with_loadout(loadout: Array) -> Dictionary:
	var profile := PlayerProfile.new().combat_snapshot()
	profile["loadout"] = loadout.duplicate(true)
	while profile["loadout"].size() < 6:
		profile["loadout"].append({})
	return profile


func _durable_enemy() -> Dictionary:
	return {
		"id":&"training_enemy", "name":"Training Enemy", "team":&"enemy",
		"stats":{
			&"max_hp":5000.0, &"max_mp":0.0, &"attack":5.0, &"defense":20.0,
			&"attack_speed":50.0, &"critical_chance":0.0, &"critical_damage":150.0,
			&"block_chance":0.0, &"evasion":0.0,
		},
	}


func _set_stat(hero: Dictionary, stat_id: StringName, value: float) -> void:
	for stat in hero["stats"]:
		if stat["id"] == stat_id:
			stat["final"] = value
			return


func _has_status(combatant: Dictionary, status_id: StringName) -> bool:
	for status in combatant["statuses"]:
		if status["id"] == status_id:
			return true
	return false


func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("Phase 2 assertion failed: " + label)
		quit(1)


func _finish() -> void:
	quit(0)
