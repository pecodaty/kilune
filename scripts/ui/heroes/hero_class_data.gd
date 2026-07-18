class_name HeroClassData
extends RefCounted
## Canonical class catalog for the Heroes tab.
## Source of truth: docs/art-direction/interface-heroes-screen.md

static var _classes: Dictionary = {}

const ORDER: Array[StringName] = [&"druid", &"mage", &"warrior", &"assassin", &"hunter"]


## Returns the catalog as {class_id: Dictionary}, built once.
static func classes() -> Dictionary:
	if _classes.is_empty():
		_classes = {
			&"druid": _make(&"druid", "Druid", "#22DD6E", "#0A2018", "Growth Staff", "Sustain Support",
				"A sustaining nature channeler who restores allies and commands living magic.",
				["Thorn Orb", "Draw Barriers", "Thorn Ball", "Vine Web", "Screaming Light", "Send Companion", "Canopy Wave", "Barn Guard"],
				["Thornweaver", "Grove Warden", "Lifebloom Sage"]),
			&"mage": _make(&"mage", "Mage", "#448AFF", "#0A1428", "Arcane Tome", "Burst Damage",
				"A master of forbidden arcane arts who channels raw magical energy into devastating spells.",
				["Arcane Bolt", "Mana Shield", "Frost Nova", "Blink", "Arcane Surge", "Ice Lance", "Time Warp", "Polymorph"],
				["Archwizard", "Spellbinder", "Void Caller"]),
			&"warrior": _make(&"warrior", "Warrior", "#FF7733", "#2A1408", "Greatsword", "Tank / DPS",
				"An unyielding frontline fighter who absorbs punishment and retaliates with crushing force.",
				["Shield Bash", "Battle Cry", "Whirlwind", "Iron Skin", "Charge", "Rend", "Rallying Cry", "Bloodthirst"],
				["Berserker", "Paladin", "Gladiator"]),
			&"assassin": _make(&"assassin", "Assassin", "#AA44FF", "#180A2A", "Twin Daggers", "Single Target DPS",
				"A shadow-walking predator who eliminates single targets with precision and deadly efficiency.",
				["Backstab", "Shadow Step", "Smoke Screen", "Poison Blade", "Evasion", "Fan of Knives", "Death Mark", "Shadowmeld"],
				["Shadowblade", "Nightstalker", "Voidwalker"]),
			&"hunter": _make(&"hunter", "Hunter", "#FFD700", "#2A2008", "Longbow", "Ranged DPS",
				"A keen-eyed tracker who commands beast companions and strikes from range with deadly arrows.",
				["Arrow Shot", "Multi-Shot", "Track Prey", "Beast Bond", "Camouflage", "Explosive Trap", "Eagle Eye", "Volley"],
				["Beastmaster", "Ranger", "Deadeye"]),
		}
	return _classes


static func class_data(class_id: StringName) -> Dictionary:
	return classes()[class_id]


static func _make(id: StringName, display_name: String, color: String, tint: String, weapon: String,
		role: String, description: String, skills: Array, advancements: Array) -> Dictionary:
	return {
		"id": id,
		"name": display_name,
		"color": Color(color),
		"bg_tint": Color(tint),
		"weapon": weapon,
		"role": role,
		"description": description,
		"tier": "Tier 0 · 8 Class Skills",
		"skills": skills,
		"advancements": advancements,
	}
