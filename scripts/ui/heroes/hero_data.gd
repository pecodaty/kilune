class_name HeroData
extends RefCounted
## Reference-state hero data for the Heroes sub-tabs (skills, talents,
## equipment, cards). Until hero/progression systems own this state, the
## reference values from references/reference-code/src/app/App.tsx apply.

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
		"level": 12,
		"hp": 154,
		"hp_max": 158,
		"power": 808,
		"class_id": &"druid",
	}


static func stats_line() -> String:
	var h := hero()
	return "Lv.%d · HP %d/%d · Power %d" % [h["level"], h["hp"], h["hp_max"], h["power"]]


# ─── Skills sub-tab ──────────────────────────────────────────────────────────

static func cast_order() -> Array[Dictionary]:
	return [
		{"id": &"thorn_orb", "name": "Thorn Orb", "cast": 3.0, "icon": &"leaf", "color": Color("#22DD6E")},
		{"id": &"dew_restore", "name": "Dew Restore", "cast": 8.0, "icon": &"drop", "color": Color("#448AFF")},
		{"id": &"canopy_wave", "name": "Canopy Wave", "cast": 7.0, "icon": &"wave", "color": Color("#66DDFF")},
	]


const PROGRESSION_LEVEL := 32
const SKILL_POINTS_TOTAL := 32
const TALENT_POINTS_TOTAL := 32


static func skill_sections() -> Dictionary:
	return {
		&"path1": {"label":"PATH OF THE STORM", "color":Color("#22DD6E"), "unlock":1},
		&"path2": {"label":"PATH OF JUDGMENT", "color":Color("#FF7733"), "unlock":50},
		&"spec1": {"label":"ARCANE CONCLAVE", "color":Color("#448AFF"), "unlock":30},
		&"spec2": {"label":"VOID COVENANT", "color":Color("#AA44FF"), "unlock":70},
	}


static func active_skills() -> Array[Dictionary]:
	return [
		_skill(&"searing_bolt","Searing Bolt",&"fire",&"path1",5,0), _skill(&"frost_shield","Frost Shield",&"ice",&"path1",3,0),
		_skill(&"wind_slash","Wind Slash",&"wind",&"path1",2,0), _skill(&"shadow_step","Shadow Step",&"shadow",&"path1",0,0),
		_skill(&"thunder_clap","Thunder Clap",&"bolt",&"path2",0,0), _skill(&"void_surge","Void Surge",&"shadow",&"path2",0,0),
		_skill(&"ember_nova","Ember Nova",&"sparkle",&"path2",0,0), _skill(&"iron_will","Iron Will",&"shield",&"path2",0,0),
		_skill(&"arcane_burst","Arcane Burst",&"gem",&"spec1",3,1), _skill(&"mana_shield","Mana Shield",&"orb",&"spec1",1,0),
		_skill(&"crystal_ward","Crystal Ward",&"gem",&"spec1",0,0), _skill(&"phase_shift","Phase Shift",&"sparkle",&"spec1",0,0),
		_skill(&"soul_rend","Soul Rend",&"skull",&"spec2",0,0), _skill(&"blood_pact","Blood Pact",&"orb",&"spec2",0,0),
		_skill(&"rift_step","Rift Step",&"shadow",&"spec2",0,0), _skill(&"null_zone","Null Zone",&"gem",&"spec2",0,0),
	]


static func equipped_skills() -> Array[StringName]:
	return [&"searing_bolt", &"frost_shield", &"wind_slash", &"arcane_burst", &"mana_shield", &""]


static func skill_level_requirement(level: int) -> int:
	if level <= 3: return 0
	if level <= 5: return 20
	if level <= 7: return 40
	if level <= 9: return 60
	return 80 if level == 10 else 90


static func _skill(id: StringName, name: String, icon: StringName, section: StringName, level: int, mastery: int) -> Dictionary:
	return {"id":id, "name":name, "icon":icon, "section":section, "level":level, "mastery":mastery}


static func talent_sections() -> Dictionary:
	return {
		&"path1":{"label":"PATH OF THE STORM", "short":"PATH I", "color":Color("#22DD6E"), "unlock":1, "nodes":12},
		&"path2":{"label":"PATH OF JUDGMENT", "short":"PATH II", "color":Color("#FF7733"), "unlock":50, "nodes":12},
		&"spec1":{"label":"ARCANE CONCLAVE", "short":"SPEC I", "color":Color("#448AFF"), "unlock":30, "nodes":8},
		&"spec2":{"label":"VOID COVENANT", "short":"SPEC II", "color":Color("#AA44FF"), "unlock":70, "nodes":8},
	}


static func constellation_talents() -> Array[Dictionary]:
	return [
		_talent(&"t_apex","Apex Predator",&"swords",&"keystone",&"path1",0), _talent(&"t_pow","Power Surge",&"fire",&"passive",&"path1",5),
		_talent(&"t_vit","Vitality Core",&"heart",&"passive",&"path1",3), _talent(&"t_arc","Arcane Reserves",&"orb",&"utility",&"path1",2),
		_talent(&"t_bh","Battle Hardened",&"shield",&"passive",&"path1",2), _talent(&"t_swift","Swift Strikes",&"bolt",&"passive",&"path1",1),
		_talent(&"t_crit","Precision Strike",&"target",&"passive",&"path1",3), _talent(&"t_mind","Iron Mind",&"orb",&"passive",&"path1",1),
		_talent(&"t_cd","Arcane Flow",&"sparkle",&"utility",&"path1",2), _talent(&"t_dodge","Shadow Walk",&"shadow",&"utility",&"path1",0),
		_talent(&"t_res","Resilient Soul",&"heart",&"passive",&"path1",0), _talent(&"t_life","Blood Rush",&"bolt",&"passive",&"path1",0),
		_talent(&"t2_ks","Divine Wrath",&"star",&"keystone",&"path2",0), _talent(&"t2_atk","Wrath of Thunder",&"bolt",&"passive",&"path2",0),
		_talent(&"t2_jdg","Judgment Call",&"target",&"utility",&"path2",0), _talent(&"t2_rge","Righteous Fury",&"swords",&"passive",&"path2",0),
		_talent(&"t2_hlth","Unyielding",&"shield",&"passive",&"path2",0), _talent(&"t2_sp","Storm Presence",&"wind",&"passive",&"path2",0),
		_talent(&"t2_smte","Holy Smite",&"sparkle",&"passive",&"path2",0), _talent(&"t2_wrd","Sacred Ward",&"shield",&"passive",&"path2",0),
		_talent(&"t2_mntr","Iron Guard",&"shield",&"passive",&"path2",0), _talent(&"t2_lgt","Lightning Reflexes",&"bolt",&"utility",&"path2",0),
		_talent(&"t2_flk","Battle Momentum",&"wind",&"utility",&"path2",0), _talent(&"t2_spd","Rapid Advance",&"bolt",&"utility",&"path2",0),
		_talent(&"s1_ks","Arcane Annihilation",&"skull",&"keystone",&"spec1",0), _talent(&"s1_am","Arcane Mastery",&"gem",&"passive",&"spec1",4),
		_talent(&"s1_ms","Mana Surge",&"orb",&"passive",&"spec1",3), _talent(&"s1_cs","Crystal Skin",&"gem",&"passive",&"spec1",2),
		_talent(&"s1_pl","Phase Lock",&"globe",&"utility",&"spec1",1), _talent(&"s1_es","Ethereal Step",&"shadow",&"utility",&"spec1",0),
		_talent(&"s1_ae","Arcane Empowerment",&"sparkle",&"utility",&"spec1",0), _talent(&"s1_rw","Runic Ward",&"gem",&"passive",&"spec1",0),
		_talent(&"s2_ks","Oblivion",&"shadow",&"keystone",&"spec2",0), _talent(&"s2_sr","Soul Harvest",&"skull",&"passive",&"spec2",0),
		_talent(&"s2_rs","Rift Mastery",&"shadow",&"passive",&"spec2",0), _talent(&"s2_bp","Blood Ritual",&"orb",&"utility",&"spec2",0),
		_talent(&"s2_nz","Null Field",&"gem",&"utility",&"spec2",0), _talent(&"s2_dk","Dark Knowledge",&"book",&"passive",&"spec2",0),
		_talent(&"s2_vp","Void Presence",&"shadow",&"utility",&"spec2",0), _talent(&"s2_cs2","Cursed Strike",&"swords",&"passive",&"spec2",0),
	]


static func _talent(id: StringName, name: String, icon: StringName, type: StringName, section: StringName, rank: int) -> Dictionary:
	return {"id":id, "name":name, "icon":icon, "type":type, "section":section, "rank":rank, "max":5, "bonus":_talent_bonus(id)}


static func _talent_bonus(id: StringName) -> String:
	return {
		&"t_pow":"+4% ATK per rank", &"t_vit":"+5% Max HP per rank", &"t_arc":"+8% Max Mana per rank",
		&"t_bh":"+3% Defense per rank", &"t_swift":"+2% Attack Speed per rank", &"t_crit":"+1% Crit Chance per rank",
		&"s1_am":"+5% Magic DMG per rank", &"s1_ms":"+3% Skill DMG per rank", &"s1_cs":"+2% Block Chance per rank",
		&"s1_pl":"Slow Duration +10% per rank", &"t_apex":"All damage +8%, but Max HP -10%",
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
	return [
		{
			"id": &"trailguard", "name": "Trailguard Armor", "slot": &"armor",
			"lv": 3, "rarity": &"rare", "icon": &"shield",
			"stats": [["Health", "+22"], ["Defense", "+2"]],
			"enhance": "+0/12", "success": "100%",
			"locked": [["+3", "4 Common or Rare"], ["+6", "3 Rare"], ["+9", "2 Epic"], ["+12", "1 Legendary"]],
			"actions": ["Enhance +1", "Arcane Dust ×1", "Refine"],
			"desc": "Enchanted trailguard armor forged for heroes of the Shroomer realm.",
		},
		{
			"id": &"sunstep", "name": "Sunstep Shoes", "slot": &"shoes",
			"lv": 2, "rarity": &"uncommon", "icon": &"boot",
			"stats": [["Speed", "+8"], ["Agility", "+4"]],
			"enhance": "+0/10", "success": "100%",
			"locked": [["+3", "3 Common"], ["+6", "2 Uncommon"], ["+9", "1 Rare"]],
			"actions": ["Enhance +1", "Solar Dust ×1", "Refine"],
			"desc": "Feather-light shoes imbued with solar energy for swift movement.",
		},
		{
			"id": &"ember_signet", "name": "Ember Signet", "slot": &"ring",
			"lv": 1, "rarity": &"rare", "icon": &"ring",
			"stats": [["Power", "+15"], ["Crit Chance", "+3%"]],
			"enhance": "+0/12", "success": "100%",
			"locked": [["+3", "4 Common or Rare"], ["+6", "3 Rare"], ["+9", "2 Epic"], ["+12", "1 Legendary"]],
			"actions": ["Enhance +1", "Arcane Dust ×1", "Refine"],
			"desc": "A ring set with an ember crystal that pulses with inner flame.",
		},
		{
			"id": &"bulwark_band", "name": "Bulwark Band", "slot": &"accessory",
			"lv": 1, "rarity": &"common", "icon": &"band",
			"stats": [["Defense", "+5"], ["HP", "+10"]],
			"enhance": "+0/8", "success": "100%",
			"locked": [["+3", "3 Common"], ["+6", "2 Uncommon"]],
			"actions": ["Enhance +1", "Stone Dust ×1", "Refine"],
			"desc": "A simple band that offers a modest protective barrier.",
		},
	]


## Item equipped in the given gear slot, or an empty Dictionary.
static func equipped_in(slot_id: StringName) -> Dictionary:
	for item in inventory():
		if item["slot"] == slot_id:
			return item
	return {}
