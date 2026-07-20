class_name TraitRules
extends RefCounted
## Progression rules shared by the skill and talent trees.

const MAX_CHARACTER_LEVEL := 99
const MAX_SKILL_POINTS := 99
const MAX_TALENT_POINTS := 99
const MAX_SKILL_LEVEL := 10
const MAX_SKILL_MASTERY := 5
const MAX_TALENT_RANK := 5

# Talent branches grow from their inner ring into outer nodes. Keystones are
# capstones and require a meaningful investment in their branch.
const TALENT_REQUIREMENTS := {
	# Path I
	&"t_apex": {"points": 20},
	&"t_crit": {"any": [&"t_pow", &"t_vit"]},
	&"t_mind": {"any": [&"t_vit", &"t_arc"]},
	&"t_cd": {"any": [&"t_arc", &"t_bh"]},
	&"t_dodge": {"any": [&"t_bh"]},
	&"t_res": {"any": [&"t_swift"]},
	&"t_life": {"any": [&"t_pow", &"t_swift"]},
	# Path II
	&"t2_ks": {"points": 20},
	&"t2_smte": {"any": [&"t2_atk", &"t2_jdg"]},
	&"t2_wrd": {"any": [&"t2_jdg", &"t2_rge"]},
	&"t2_mntr": {"any": [&"t2_rge", &"t2_hlth"]},
	&"t2_lgt": {"any": [&"t2_hlth"]},
	&"t2_flk": {"any": [&"t2_sp"]},
	&"t2_spd": {"any": [&"t2_atk", &"t2_sp"]},
	# Specialization I
	&"s1_ks": {"points": 15},
	&"s1_pl": {"any": [&"s1_am", &"s1_ms"]},
	&"s1_es": {"any": [&"s1_ms", &"s1_cs"]},
	&"s1_ae": {"any": [&"s1_cs"]},
	&"s1_rw": {"any": [&"s1_am"]},
	# Specialization II
	&"s2_ks": {"points": 15},
	&"s2_nz": {"any": [&"s2_sr", &"s2_rs"]},
	&"s2_dk": {"any": [&"s2_rs", &"s2_bp"]},
	&"s2_vp": {"any": [&"s2_bp"]},
	&"s2_cs2": {"any": [&"s2_sr"]},
}


static func points_for_level(character_level: int) -> int:
	return clampi(character_level, 0, MAX_CHARACTER_LEVEL)


static func skill_level_requirement(next_level: int) -> int:
	if next_level <= 3:
		return 1
	if next_level <= 5:
		return 20
	if next_level <= 7:
		return 40
	if next_level <= 9:
		return 60
	return 80


static func can_upgrade_skill(skill: Dictionary, spent: int, character_level: int) -> bool:
	var level: int = skill["level"]
	return level < MAX_SKILL_LEVEL \
		and spent < points_for_level(character_level) \
		and character_level >= skill_level_requirement(level + 1)


static func can_upgrade_mastery(skill: Dictionary, spent: int, character_level: int) -> bool:
	return skill["level"] >= MAX_SKILL_LEVEL \
		and skill["mastery"] < MAX_SKILL_MASTERY \
		and spent < points_for_level(character_level) \
		and character_level >= 90


static func talent_available(talent: Dictionary, talents: Array[Dictionary], character_level: int, unlock_level: int) -> bool:
	if character_level < unlock_level:
		return false
	var requirement: Dictionary = TALENT_REQUIREMENTS.get(talent["id"], {})
	if _section_points(talents, talent["section"]) < int(requirement.get("points", 0)):
		return false
	var parents: Array = requirement.get("any", [])
	if parents.is_empty():
		return true
	for parent_id in parents:
		if _rank_of(talents, parent_id) > 0:
			return true
	return false


static func can_increase_talent(talent: Dictionary, talents: Array[Dictionary], character_level: int, unlock_level: int) -> bool:
	return talent["rank"] < talent["max"] \
		and _total_points(talents) < points_for_level(character_level) \
		and talent_available(talent, talents, character_level, unlock_level)


static func can_refund_talent(talent_id: StringName, talents: Array[Dictionary], character_level: int, section_unlocks: Dictionary) -> bool:
	var copy: Array[Dictionary] = []
	for talent in talents:
		copy.append(talent.duplicate(true))
	var target := _find_talent(copy, talent_id)
	if target.is_empty() or target["rank"] <= 0:
		return false
	target["rank"] -= 1
	for talent in copy:
		if talent["rank"] <= 0:
			continue
		var unlock_level: int = section_unlocks.get(talent["section"], MAX_CHARACTER_LEVEL + 1)
		if not talent_available(talent, copy, character_level, unlock_level):
			return false
	return true


static func talent_requirement_text(talent: Dictionary, talents: Array[Dictionary]) -> String:
	var requirement: Dictionary = TALENT_REQUIREMENTS.get(talent["id"], {})
	var required_points := int(requirement.get("points", 0))
	if required_points > 0:
		return "Requires %d points in this tree" % required_points
	var parents: Array = requirement.get("any", [])
	if parents.is_empty():
		return "Available"
	var names: Array[String] = []
	for parent_id in parents:
		var parent := _find_talent(talents, parent_id)
		if not parent.is_empty():
			names.append(parent["name"])
	return "Requires " + " or ".join(names)


static func _find_talent(talents: Array[Dictionary], talent_id: StringName) -> Dictionary:
	for talent in talents:
		if talent["id"] == talent_id:
			return talent
	return {}


static func _rank_of(talents: Array[Dictionary], talent_id: StringName) -> int:
	return int(_find_talent(talents, talent_id).get("rank", 0))


static func _section_points(talents: Array[Dictionary], section_id: StringName) -> int:
	var total := 0
	for talent in talents:
		if talent["section"] == section_id:
			total += int(talent["rank"])
	return total


static func _total_points(talents: Array[Dictionary]) -> int:
	var total := 0
	for talent in talents:
		total += int(talent["rank"])
	return total
