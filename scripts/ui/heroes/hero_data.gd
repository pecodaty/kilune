class_name HeroData
extends RefCounted
## Immutable catalog/default data for Fern's Heroes screens. Mutable session
## state lives in HeroProgressionState.

const RARITY_COLORS := {
	&"common": Color("#A090C0"),
	&"uncommon": Color("#22DD6E"),
	&"rare": Color("#448AFF"),
	&"epic": Color("#AA44FF"),
	&"legendary": Color("#FFD700"),
}


static func rarity_color(rarity: StringName) -> Color:
	return RARITY_COLORS.get(rarity, RARITY_COLORS[&"common"])


static func hero() -> Dictionary:
	return {
		"name": "FERN",
		"level": 32,
		"title": "ADVENTURER",
		"path": "Harmony",
		"specialization": "Oracle",
		"milestone": "Level 50 · Choose a Second Path or deepen Harmony",
	}


static func stats_line() -> String:
	var h := hero()
	return "Lv.%d · %s → %s" % [h["level"], h["path"], h["specialization"]]


# ─── Skills sub-tab ──────────────────────────────────────────────────────────

static func cast_order() -> Array[Dictionary]:
	return [
		{"id": &"thorn_orb", "name": "Thorn Orb", "cast": 3.0, "icon": &"leaf", "color": Color("#22DD6E")},
		{"id": &"dew_restore", "name": "Dew Restore", "cast": 8.0, "icon": &"drop", "color": Color("#448AFF")},
		{"id": &"canopy_wave", "name": "Canopy Wave", "cast": 7.0, "icon": &"wave", "color": Color("#66DDFF")},
	]


const PROGRESSION_LEVEL := 32
const SKILL_POINTS_TOTAL := 32 # One point per current character level.
const TALENT_POINTS_TOTAL := 32 # One point per current character level.


static func skill_sections() -> Dictionary:
	return {
		&"path1": {"label":"HARMONY", "color":Color("#22DD6E"), "unlock":1, "chosen":true},
		&"path2": {"label":"PATH II · UNCHOSEN", "color":Color("#66DDFF"), "unlock":50, "chosen":false},
		&"spec1": {"label":"ORACLE", "color":Color("#448AFF"), "unlock":30, "chosen":true},
		&"spec2": {"label":"SPECIALIZATION II · UNCHOSEN", "color":Color("#AA44FF"), "unlock":70, "chosen":false},
	}


static func active_skills() -> Array[Dictionary]:
	return [
		_progression_skill(&"thorn_orb",5,0), _progression_skill(&"vine_web",3,0),
		_progression_skill(&"canopy_wave",2,0), _progression_skill(&"send_companion",0,0),
		_progression_skill(&"dew_restore",3,1), _progression_skill(&"spirit_link",1,0),
		_progression_skill(&"sanctuary_bloom",0,0), _progression_skill(&"guiding_light",0,0),
	]


static func equipped_skills() -> Array[StringName]:
	return [&"thorn_orb", &"vine_web", &"canopy_wave", &"dew_restore", &"spirit_link", &""]


static func skill_level_requirement(level: int) -> int:
	return 90 if level > 10 else TraitRules.skill_level_requirement(level)


static func _progression_skill(id: StringName, level: int, mastery: int) -> Dictionary:
	return GameCatalog.skill(id).progression_snapshot(level, mastery)


static func talent_sections() -> Dictionary:
	return {
		&"path1":{"label":"HARMONY", "short":"PATH I", "color":Color("#22DD6E"), "unlock":1, "nodes":12, "chosen":true},
		&"path2":{"label":"UNCHOSEN PATH", "short":"PATH II", "color":Color("#66DDFF"), "unlock":50, "nodes":12, "chosen":false},
		&"spec1":{"label":"ORACLE", "short":"SPEC I", "color":Color("#448AFF"), "unlock":30, "nodes":8, "chosen":true},
		&"spec2":{"label":"UNCHOSEN SPECIALIZATION", "short":"SPEC II", "color":Color("#AA44FF"), "unlock":70, "nodes":8, "chosen":false},
	}


static func constellation_talents() -> Array[Dictionary]:
	return [
		_talent(&"t_apex","Verdant Covenant",&"leaf",&"keystone",&"path1",0), _talent(&"t_pow","Nature's Might",&"leaf",&"passive",&"path1",5),
		_talent(&"t_vit","Living Vitality",&"heart",&"passive",&"path1",3), _talent(&"t_arc","Wellspring",&"drop",&"utility",&"path1",2),
		_talent(&"t_bh","Barkskin",&"shield",&"passive",&"path1",2), _talent(&"t_swift","Adaptive Rhythm",&"wave",&"passive",&"path1",1),
		_talent(&"t_crit","Thorn Precision",&"target",&"passive",&"path1",3), _talent(&"t_mind","Rooted Mind",&"orb",&"passive",&"path1",1),
		_talent(&"t_cd","Verdant Flow",&"sparkle",&"utility",&"path1",2), _talent(&"t_dodge","Wildstep",&"wind",&"utility",&"path1",0),
		_talent(&"t_res","Guardian Growth",&"shield",&"passive",&"path1",0), _talent(&"t_life","Companion Bond",&"paw",&"passive",&"path1",0),
		_talent(&"s1_ks","Cycle of Renewal",&"star",&"keystone",&"spec1",0), _talent(&"s1_am","Oracle's Insight",&"gem",&"passive",&"spec1",4),
		_talent(&"s1_ms","Flowing Grace",&"drop",&"passive",&"spec1",3), _talent(&"s1_cs","Crystal Aegis",&"shield",&"passive",&"spec1",2),
		_talent(&"s1_pl","Prescient Calm",&"globe",&"utility",&"spec1",1), _talent(&"s1_es","Foreseen Step",&"wind",&"utility",&"spec1",0),
		_talent(&"s1_ae","Guiding Current",&"sparkle",&"utility",&"spec1",0), _talent(&"s1_rw","Sanctuary Ward",&"gem",&"passive",&"spec1",0),
	]


static func _talent(id: StringName, name: String, icon: StringName, type: StringName, section: StringName, rank: int) -> Dictionary:
	return {"id":id, "name":name, "icon":icon, "type":type, "section":section, "rank":rank, "max":5, "bonus":_talent_bonus(id)}


static func _talent_bonus(id: StringName) -> String:
	return {
		&"t_pow":"+4% Attack per rank", &"t_vit":"+5% Max HP per rank", &"t_arc":"+8% Max MP per rank",
		&"t_bh":"+3% Defense per rank", &"t_swift":"+2% Attack Speed per rank", &"t_crit":"+1% Critical Chance per rank",
		&"t_mind":"+3% Healing Power per rank", &"t_cd":"+1.5% Cooldown Reduction per rank",
		&"t_dodge":"+1% Evasion per rank", &"t_res":"+1% Block Chance per rank", &"t_life":"+3% Skill Power per rank",
		&"s1_am":"+5% Skill Power per rank", &"s1_ms":"+3% Healing Power per rank", &"s1_cs":"+2% Block Chance per rank",
		&"s1_pl":"+1% Cooldown Reduction per rank", &"s1_es":"+1% Evasion per rank", &"s1_ae":"+4% Max MP per rank",
		&"s1_rw":"+3% Defense per rank", &"t_apex":"Healing and protection effects reinforce each other.",
		&"s1_ks":"Major healing restores a portion of its resource cost.",
	}.get(id, "Improves this constellation effect per rank.")


# ─── Talents sub-tab ─────────────────────────────────────────────────────────

static func talents() -> Array[Dictionary]:
	return [
		{"id": &"atk", "name": "Attack", "icon": &"swords", "current": 2, "max": 5,
			"color": Color("#FF7733"), "desc": "Increases base Attack by 3% per level."},
		{"id": &"hp", "name": "Health", "icon": &"heart", "current": 1, "max": 5,
			"color": Color("#22DD6E"), "desc": "Increases max HP by 5% per level."},
		{"id": &"def", "name": "Defense", "icon": &"shield", "current": 0, "max": 5,
			"color": Color("#448AFF"), "desc": "Increases Defense by 4% per level."},
		{"id": &"spd", "name": "Attack Speed", "icon": &"bolt", "current": 0, "max": 5,
			"color": Color("#FFD700"), "desc": "Increases attack speed by 2% per level."},
		{"id": &"crit", "name": "Critical Chance", "icon": &"target", "current": 0, "max": 5,
			"color": Color("#AA44FF"), "desc": "Increases critical hit chance by 2% per level."},
		{"id": &"skill", "name": "Skill Power", "icon": &"sparkle", "current": 1, "max": 5,
			"color": Color("#00E5C8"), "desc": "Increases Skill damage by 4% per level."},
	]


# ─── Equipment / Cards sub-tabs ──────────────────────────────────────────────

static func gear_slots() -> Array[Dictionary]:
	return [
		{"id": &"armor", "label": "Armor"},
		{"id": &"legs", "label": "Legs"},
		{"id": &"helmet", "label": "Helmet"},
		{"id": &"belt", "label": "Belt"},
		{"id": &"shoes", "label": "Shoes"},
		{"id": &"shoulderpads", "label": "Shoulderpads"},
		{"id": &"weapon", "label": "Weapon"},
		{"id": &"cape", "label": "Cape"},
		{"id": &"ring", "label": "Ring"},
		{"id": &"accessory", "label": "Accessory"},
		{"id": &"necklace", "label": "Necklace"},
		{"id": &"wrist", "label": "Wrist"},
	]


static func inventory() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for definition in GameCatalog.equipment_definitions():
		out.append(definition.snapshot(1, false))
	return out


static func initial_equipment() -> Dictionary:
	return GameCatalog.initial_equipment()
