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
