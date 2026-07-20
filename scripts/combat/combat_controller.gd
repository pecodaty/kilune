class_name CombatController
extends RefCounted
## Deterministic, presentation-independent combat encounter.

const Combatant := preload("res://scripts/combat/combatant_state.gd")

signal action_started(actor_id: StringName, target_id: StringName, action_id: StringName)
signal damage_dealt(source_id: StringName, target_id: StringName, amount: int, critical: bool, blocked: bool, evaded: bool)
signal healing_applied(source_id: StringName, target_id: StringName, amount: int)
signal resource_changed(combatant_id: StringName, resource: StringName, current: int, maximum: int)
signal status_added(source_id: StringName, target_id: StringName, status_id: StringName)
signal combatant_defeated(combatant_id: StringName)
signal combat_finished(result: StringName)
signal state_changed(snapshot: Dictionary)

const HERO_ID := &"fern"
const AUTO_INTERVAL := 0.35

var auto_enabled := true
var finished := false
var result: StringName = &""

var _hero: Combatant
var _enemies: Array[Combatant] = []
var _allies: Array[Combatant] = []
var _loadout: Array = []
var _selected_enemy: StringName = &""
var _selected_ally: StringName = HERO_ID
var _auto_timer := AUTO_INTERVAL
var _rng := RandomNumberGenerator.new()


func start(hero_data: Dictionary, enemy_data: Dictionary, seed := 1) -> void:
	_rng.seed = seed
	finished = false
	result = &""
	_loadout = hero_data.get("loadout", []).duplicate(true)
	var hero_stats := _flatten_stats(hero_data.get("stats", []))
	_hero = Combatant.new({
		"id":HERO_ID,
		"name":hero_data.get("identity", {}).get("name", "Fern"),
		"team":&"hero",
		"stats":hero_stats,
	})
	_allies.clear()
	_allies.append(_hero)
	var enemy := Combatant.new(enemy_data)
	_enemies.clear()
	_enemies.append(enemy)
	_selected_enemy = enemy.id
	_selected_ally = _hero.id
	_auto_timer = AUTO_INTERVAL
	_emit_resources(_hero)
	_emit_resources(enemy)
	_emit_state()


func advance(delta: float) -> void:
	if finished or _hero == null or delta <= 0.0:
		return
	_tick_cooldowns(_hero, delta)
	for combatant in _living_combatants():
		_tick_statuses(combatant, delta)
	if finished:
		return
	for ally in _allies.duplicate():
		if ally.alive:
			_tick_basic_attack(ally, delta, _target_enemy())
	for enemy in _enemies:
		if enemy.alive:
			_tick_basic_attack(enemy, delta, _target_hero())
	if auto_enabled and not finished:
		_auto_timer -= delta
		if _auto_timer <= 0.0:
			_auto_timer += AUTO_INTERVAL
			_perform_auto_action()
	_emit_state()


func activate_skill(slot_index: int) -> StateMutationResult:
	if finished:
		return StateMutationResult.rejected(&"combat_finished", "Combat has finished.")
	if slot_index < 0 or slot_index >= _loadout.size() or _loadout[slot_index].is_empty():
		return StateMutationResult.rejected(&"empty_slot", "No skill is equipped in this slot.")
	return activate_skill_data(_loadout[slot_index])


func activate_skill_data(skill: Dictionary) -> StateMutationResult:
	if finished or not _hero.alive:
		return StateMutationResult.rejected(&"combat_finished", "Combat has finished.")
	var skill_id: StringName = skill.get("id", &"")
	if skill_id.is_empty():
		return StateMutationResult.rejected(&"invalid_skill", "Skill definition is invalid.")
	if not _hero.is_skill_ready(skill_id):
		return StateMutationResult.rejected(&"skill_cooldown", "Skill is still cooling down.")
	var mp_cost := int(skill.get("mp_cost", 0))
	if _hero.current_mp < mp_cost:
		return StateMutationResult.rejected(&"insufficient_mp", "Not enough MP.")
	var target: Variant = _skill_target(skill)
	if target == null:
		return StateMutationResult.rejected(&"no_target", "No valid target.")
	_hero.current_mp -= mp_cost
	var cooldown := float(skill.get("cooldown", 0.0))
	var reduction := clampf(_hero.stat(&"cooldown_reduction"), 0.0, 60.0)
	_hero.cooldowns[skill_id] = cooldown * (1.0 - reduction / 100.0)
	_emit_resources(_hero)
	action_started.emit(_hero.id, target.id, skill_id)
	_apply_skill(skill, target)
	_emit_state()
	return StateMutationResult.accepted(&"combat", &"skill_activated")


func select_target(team: StringName, combatant_id: StringName) -> StateMutationResult:
	var candidates := _enemies if team == &"enemy" else _allies
	for candidate in candidates:
		if candidate.id == combatant_id and candidate.alive:
			if team == &"enemy":
				_selected_enemy = combatant_id
			else:
				_selected_ally = combatant_id
			return StateMutationResult.accepted(&"combat", &"target_selected")
	return StateMutationResult.rejected(&"invalid_target", "Target is unavailable.")


func snapshot() -> Dictionary:
	return {
		"finished":finished, "result":result,
		"hero":_hero.snapshot() if _hero != null else {},
		"allies":_snapshots(_allies), "enemies":_snapshots(_enemies),
		"selected_enemy":_selected_enemy, "selected_ally":_selected_ally,
	}


func cooldown_fraction(slot_index: int) -> float:
	if _hero == null or slot_index < 0 or slot_index >= _loadout.size() or _loadout[slot_index].is_empty():
		return 0.0
	var skill: Dictionary = _loadout[slot_index]
	var duration := float(skill.get("cooldown", 0.0)) * (1.0 - clampf(_hero.stat(&"cooldown_reduction"), 0.0, 60.0) / 100.0)
	return 0.0 if duration <= 0.0 else clampf(float(_hero.cooldowns.get(skill.get("id", &""), 0.0)) / duration, 0.0, 1.0)


func _apply_skill(skill: Dictionary, target: Combatant) -> void:
	var effect: StringName = skill.get("effect", &"")
	var magnitude := _skill_magnitude(skill)
	match effect:
		&"damage":
			_deal_damage(_hero, target, magnitude)
		&"control":
			_deal_damage(_hero, target, magnitude * 0.45)
			_add_status(_hero, target, {"id":&"vine_bound", "duration":4.0, "percent":{&"attack_speed":-35.0}})
		&"area":
			for enemy in _enemies:
				if enemy.alive:
					_deal_damage(_hero, enemy, magnitude * 0.82)
		&"summon":
			_summon_companion(magnitude)
		&"heal":
			_heal(_hero, target, magnitude * _hero.stat(&"healing_power") / 100.0)
		&"link":
			_heal(_hero, target, magnitude * 0.45 * _hero.stat(&"healing_power") / 100.0)
			_add_status(_hero, target, {"id":&"spirit_flow", "duration":6.0, "tick_interval":2.0, "periodic_mp":6.0})
		&"barrier":
			target.barrier += magnitude * 0.75
			_heal(_hero, target, magnitude * 0.35 * _hero.stat(&"healing_power") / 100.0)
			_add_status(_hero, target, {"id":&"sanctuary", "duration":5.0, "percent":{&"defense":20.0}})
		&"buff":
			_add_status(_hero, target, {"id":&"guided", "duration":7.0, "percent":{&"attack":20.0, &"skill_power":20.0}})
	_check_finished()


func _skill_magnitude(skill: Dictionary) -> float:
	var level := maxi(1, int(skill.get("level", 1)))
	var mastery := maxi(0, int(skill.get("mastery", 0)))
	var rank_scale := 1.0 + float(level - 1) * 0.08 + float(mastery) * 0.05
	return float(skill.get("base_power", 0.0)) * rank_scale * _hero.stat(&"skill_power") / 100.0


func _tick_basic_attack(actor: Combatant, delta: float, target: Combatant) -> void:
	actor.attack_timer -= delta
	if actor.attack_timer > 0.0 or target == null:
		return
	actor.attack_timer += actor.attack_interval()
	action_started.emit(actor.id, target.id, &"basic_attack")
	_deal_damage(actor, target, actor.stat(&"attack"))


func _deal_damage(source: Combatant, target: Combatant, raw_amount: float) -> int:
	if target == null or not target.alive:
		return 0
	var evaded := _roll(target.stat(&"evasion"))
	if evaded:
		damage_dealt.emit(source.id, target.id, 0, false, false, true)
		return 0
	var critical := _roll(source.stat(&"critical_chance"))
	var blocked := _roll(target.stat(&"block_chance"))
	var amount: float = raw_amount * (100.0 / (100.0 + target.stat(&"defense")))
	if critical:
		amount *= maxf(1.0, source.stat(&"critical_damage") / 100.0)
	if blocked:
		amount *= 0.5
	var rounded := maxi(1, int(round(amount)))
	var absorbed := minf(target.barrier, rounded)
	target.barrier -= absorbed
	var hp_damage := maxi(0, rounded - int(round(absorbed)))
	target.current_hp = maxf(0.0, target.current_hp - hp_damage)
	damage_dealt.emit(source.id, target.id, hp_damage, critical, blocked, false)
	_emit_resources(target)
	if target.current_hp <= 0.0:
		target.alive = false
		combatant_defeated.emit(target.id)
		_check_finished()
	return hp_damage


func _heal(source: Combatant, target: Combatant, raw_amount: float) -> int:
	if target == null or not target.alive:
		return 0
	var before: float = target.current_hp
	target.current_hp = minf(target.stat(&"max_hp"), target.current_hp + raw_amount)
	var amount := int(round(target.current_hp - before))
	if amount > 0:
		healing_applied.emit(source.id, target.id, amount)
		_emit_resources(target)
	return amount


func _add_status(source: Combatant, target: Combatant, data: Dictionary) -> void:
	for existing in target.statuses:
		if existing.get("id", &"") == data.get("id", &""):
			existing.merge(data, true)
			existing["next_tick"] = float(data.get("tick_interval", 0.0))
			status_added.emit(source.id, target.id, data.get("id", &""))
			return
	var status := data.duplicate(true)
	status["next_tick"] = float(status.get("tick_interval", 0.0))
	target.statuses.append(status)
	status_added.emit(source.id, target.id, status.get("id", &""))


func _tick_statuses(target: Combatant, delta: float) -> void:
	for status in target.statuses.duplicate():
		status["duration"] = float(status.get("duration", 0.0)) - delta
		var interval := float(status.get("tick_interval", 0.0))
		if interval > 0.0:
			status["next_tick"] = float(status.get("next_tick", interval)) - delta
			if float(status["next_tick"]) <= 0.0:
				status["next_tick"] = float(status["next_tick"]) + interval
				if float(status.get("periodic_damage", 0.0)) > 0.0:
					_deal_damage(_hero, target, float(status["periodic_damage"]))
				if float(status.get("periodic_heal", 0.0)) > 0.0:
					_heal(_hero, target, float(status["periodic_heal"]))
				if float(status.get("periodic_mp", 0.0)) > 0.0:
					target.current_mp = minf(target.stat(&"max_mp"), target.current_mp + float(status["periodic_mp"]))
					_emit_resources(target)
		if float(status["duration"]) <= 0.0:
			target.statuses.erase(status)


func _tick_cooldowns(combatant: Combatant, delta: float) -> void:
	for skill_id in combatant.cooldowns.keys():
		combatant.cooldowns[skill_id] = maxf(0.0, float(combatant.cooldowns[skill_id]) - delta)


func _perform_auto_action() -> void:
	var preferred_effects: Array[StringName] = []
	var hp_ratio: float = _hero.current_hp / maxf(1.0, _hero.stat(&"max_hp"))
	if hp_ratio < 0.55:
		preferred_effects = [&"heal", &"barrier", &"link"]
	else:
		preferred_effects = [&"damage", &"area", &"control", &"summon", &"buff", &"link", &"barrier", &"heal"]
	for effect in preferred_effects:
		for skill in _loadout:
			if not skill.is_empty() and skill.get("effect", &"") == effect:
				var outcome := activate_skill_data(skill)
				if outcome.ok:
					return


func _summon_companion(magnitude: float) -> void:
	for ally in _allies:
		if ally.is_summon and ally.alive:
			_add_status(_hero, ally, {"id":&"renewed_companion", "duration":6.0, "percent":{&"attack":20.0}})
			return
	var companion := Combatant.new({
		"id":&"harmony_companion", "name":"Harmony Companion", "team":&"hero", "is_summon":true,
		"stats":{&"max_hp":maxf(1.0, magnitude), &"max_mp":0.0, &"attack":maxf(1.0, magnitude * 0.35),
			&"attack_speed":115.0, &"defense":_hero.stat(&"defense") * 0.5, &"critical_chance":0.0,
			&"critical_damage":150.0, &"block_chance":0.0, &"evasion":0.0},
	})
	_allies.append(companion)
	status_added.emit(_hero.id, companion.id, &"companion_summoned")


func _skill_target(skill: Dictionary) -> Combatant:
	var effect: StringName = skill.get("effect", &"")
	if effect in [&"heal", &"link", &"barrier", &"buff"]:
		return _target_ally()
	return _target_enemy()


func _target_enemy() -> Combatant:
	for enemy in _enemies:
		if enemy.id == _selected_enemy and enemy.alive:
			return enemy
	for enemy in _enemies:
		if enemy.alive:
			_selected_enemy = enemy.id
			return enemy
	return null


func _target_ally() -> Combatant:
	for ally in _allies:
		if ally.id == _selected_ally and ally.alive:
			return ally
	return _target_hero()


func _target_hero() -> Combatant:
	return _hero if _hero != null and _hero.alive else null


func _check_finished() -> void:
	if finished:
		return
	if _hero == null or not _hero.alive:
		_finish(&"defeat")
		return
	for enemy in _enemies:
		if enemy.alive:
			return
	_finish(&"victory")


func _finish(outcome: StringName) -> void:
	finished = true
	result = outcome
	combat_finished.emit(outcome)
	_emit_state()


func _emit_resources(combatant: Combatant) -> void:
	resource_changed.emit(combatant.id, &"hp", int(round(combatant.current_hp)), int(round(combatant.stat(&"max_hp"))))
	resource_changed.emit(combatant.id, &"mp", int(round(combatant.current_mp)), int(round(combatant.stat(&"max_mp"))))


func _emit_state() -> void:
	state_changed.emit(snapshot())


func _living_combatants() -> Array[Combatant]:
	var out: Array[Combatant] = []
	for ally in _allies:
		if ally.alive:
			out.append(ally)
	for enemy in _enemies:
		if enemy.alive:
			out.append(enemy)
	return out


func _snapshots(combatants: Array[Combatant]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for combatant in combatants:
		out.append(combatant.snapshot())
	return out


func _flatten_stats(rows: Array) -> Dictionary:
	var out := {}
	for row in rows:
		out[row.get("id", &"")] = float(row.get("final", 0.0))
	return out


func _roll(chance_percent: float) -> bool:
	return chance_percent > 0.0 and _rng.randf() * 100.0 < clampf(chance_percent, 0.0, 100.0)
