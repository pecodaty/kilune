class_name GameCatalog
extends RefCounted
## Typed, immutable definitions used by runtime state and presentation.

static var _items: Dictionary = {}
static var _skills: Dictionary = {}
static var _enemies: Dictionary = {}
static var _rewards: Dictionary = {}


static func item(id: StringName) -> ItemDefinition:
	_ensure_built()
	return _items.get(id) as ItemDefinition


static func skill(id: StringName) -> SkillDefinition:
	_ensure_built()
	return _skills.get(id) as SkillDefinition


static func enemy(id: StringName) -> EnemyDefinition:
	_ensure_built()
	return _enemies.get(id) as EnemyDefinition


static func reward(id: StringName) -> RewardDefinition:
	_ensure_built()
	return _rewards.get(id) as RewardDefinition


static func item_ids() -> Array[StringName]:
	_ensure_built()
	var out: Array[StringName] = []
	for id in _items:
		out.append(id)
	return out


static func skill_ids() -> Array[StringName]:
	_ensure_built()
	var out: Array[StringName] = []
	for id in _skills:
		out.append(id)
	return out


static func initial_inventory() -> Dictionary:
	_ensure_built()
	var out := {}
	for id in _items:
		var definition: ItemDefinition = _items[id]
		if definition.default_quantity > 0:
			out[id] = definition.default_quantity
	return out


static func initial_equipment() -> Dictionary:
	return {
		&"armor": &"trailguard",
		&"shoes": &"sunstep",
		&"ring": &"ember_signet",
		&"accessory": &"bulwark_band",
	}


static func equipment_definitions() -> Array[ItemDefinition]:
	_ensure_built()
	var out: Array[ItemDefinition] = []
	for id in _items:
		var definition: ItemDefinition = _items[id]
		if definition.category == &"equipment":
			out.append(definition)
	return out


static func dungeon_snapshots() -> Array[Dictionary]:
	_ensure_built()
	var rows := [
		[&"golden", "Golden Dungeon", &"key", "Raid the Sunken Vault and claim Gold.", &"gold", &"gilded_scout"],
		[&"cards", "Card Materials Dungeon", &"gem", "Recover enhancement and refinement reagents.", &"enhancement", &"crystal_guardian"],
		[&"talent", "Talent Dungeon", &"star", "Complete an ancient mastery trial.", &"talent_shard", &"trial_warden"],
		[&"pet", "Pet Growth Dungeon", &"paw", "Gather Pet Essence in a companion sanctuary.", &"pet_essence", &"spirit_familiar"],
	]
	var out: Array[Dictionary] = []
	for row in rows:
		var reward_definition := reward(row[4])
		var enemy_definition := enemy(row[5])
		out.append({
			"id":row[0], "name":row[1], "icon":row[2], "description":row[3],
			"reward":reward_definition.display_name, "reward_description":reward_definition.description,
			"power":enemy_definition.base_power, "enemy":enemy_definition.display_name,
			"enemy_icon":enemy_definition.icon, "color":enemy_definition.color,
		})
	return out


static func _ensure_built() -> void:
	if not _items.is_empty():
		return
	_build_items()
	_build_skills()
	_build_enemies()
	_build_rewards()


static func _build_items() -> void:
	var rows: Array[Dictionary] = [
		{"id":&"thread_ancient","name":"Ancient Thread","category":&"materials","quantity":5,"rarity":&"common","icon":&"ticket"},
		{"id":&"arcane_dust","name":"Arcane Dust","category":&"materials","quantity":909,"rarity":&"uncommon","icon":&"star"},
		{"id":&"beast_leather","name":"Beast Leather","category":&"materials","quantity":8,"rarity":&"common","icon":&"leaf"},
		{"id":&"celestial_dust","name":"Celestial Dust","category":&"materials","quantity":99,"rarity":&"rare","icon":&"star"},
		{"id":&"hardwood","name":"Hardwood","category":&"materials","quantity":12,"rarity":&"common","icon":&"box"},
		{"id":&"iron_ore","name":"Iron Ore","category":&"materials","quantity":20,"rarity":&"common","icon":&"key"},
		{"id":&"moonsteel","name":"Moonsteel","category":&"materials","quantity":99,"rarity":&"rare","icon":&"gem"},
		{"id":&"royal_leather","name":"Royal Leather","category":&"materials","quantity":4,"rarity":&"uncommon","icon":&"dress"},
		{"id":&"spirit_gem","name":"Spirit Gem","category":&"materials","quantity":3,"rarity":&"epic","icon":&"gem"},
		{"id":&"star_crystal","name":"Star Crystal","category":&"materials","quantity":2,"rarity":&"legendary","icon":&"star"},
		{"id":&"thread","name":"Thread","category":&"materials","quantity":12,"rarity":&"common","icon":&"ticket"},
		_equipment(&"trailguard","Trailguard Armor",&"armor",3,&"rare",&"shield",[["Max HP","+22"],["Defense","+2"]],{&"max_hp":22.0,&"defense":2.0},"Enchanted trailguard armor forged for heroes of the Shroomer realm."),
		_equipment(&"sunstep","Sunstep Shoes",&"shoes",2,&"uncommon",&"boot",[["Move Speed","+8%"]],{&"move_speed":8.0},"Feather-light shoes imbued with solar energy for swift movement."),
		_equipment(&"ember_signet","Ember Signet",&"ring",1,&"rare",&"ring",[["Power","+15"],["Critical Chance","+3%"]],{&"power":15.0,&"critical_chance":3.0},"A ring set with an ember crystal that pulses with inner flame."),
		_equipment(&"bulwark_band","Bulwark Band",&"accessory",1,&"common",&"band",[["Defense","+5"],["Max HP","+10"]],{&"defense":5.0,&"max_hp":10.0},"A simple band that offers a modest protective barrier."),
		_equipment(&"oracle_signet","Oracle Signet",&"ring",4,&"epic",&"ring",[["Skill Power","+12"],["Healing Power","+6%"]],{&"skill_power":12.0,&"healing_power":6.0},"A lucid crystal signet aligned with Oracle foresight and restorative flow."),
		{"id":&"ember_bp","name":"Ember Signet BP","category":&"blueprints","quantity":1,"rarity":&"uncommon","icon":&"ticket"},
		{"id":&"moonveil_bp","name":"Moonveil Cap BP","category":&"blueprints","quantity":1,"rarity":&"uncommon","icon":&"ticket"},
		{"id":&"oracle_bp","name":"Oracle Necklace BP","category":&"blueprints","quantity":1,"rarity":&"rare","icon":&"ticket"},
		{"id":&"cleaver_bp","name":"Vanguard Cleaver BP","category":&"blueprints","quantity":1,"rarity":&"epic","icon":&"ticket"},
		{"id":&"health_potion","name":"Health Potion","category":&"consumables","quantity":14,"rarity":&"common","icon":&"lamp"},
		{"id":&"mana_crystal","name":"Mana Crystal","category":&"consumables","quantity":6,"rarity":&"uncommon","icon":&"gem"},
		{"id":&"lost_seal","name":"Lost Seal","category":&"quest","quantity":1,"rarity":&"rare","icon":&"key"},
		{"id":&"valor_token","name":"Token of Valor","category":&"misc","quantity":3,"rarity":&"uncommon","icon":&"star"},
	]
	for row in rows:
		var definition := ItemDefinition.new(row)
		_items[definition.id] = definition


static func _equipment(id: StringName, name: String, slot: StringName, level: int, rarity: StringName, icon: StringName, stats: Array, modifiers: Dictionary, description: String) -> Dictionary:
	return {"id":id,"name":name,"category":&"equipment","quantity":1,"slot":slot,"level":level,"rarity":rarity,"icon":icon,"stats":stats,"modifiers":modifiers,"enhance":"+0/12","success":"100%","locked":[],"desc":description}


static func _build_skills() -> void:
	var rows := [
		{"id":&"thorn_orb","name":"Thorn Orb","icon":&"leaf","section":&"path1","effect":&"damage","power":90.0,"mp_cost":8,"cooldown":3.0},
		{"id":&"vine_web","name":"Vine Web","icon":&"globe","section":&"path1","effect":&"control","power":35.0,"mp_cost":12,"cooldown":7.0},
		{"id":&"canopy_wave","name":"Canopy Wave","icon":&"wave","section":&"path1","effect":&"area","power":70.0,"mp_cost":16,"cooldown":7.0},
		{"id":&"send_companion","name":"Send Companion","icon":&"paw","section":&"path1","effect":&"summon","mp_cost":22,"cooldown":14.0},
		{"id":&"dew_restore","name":"Dew Restore","icon":&"drop","section":&"spec1","effect":&"heal","power":95.0,"mp_cost":14,"cooldown":8.0},
		{"id":&"spirit_link","name":"Spirit Link","icon":&"orb","section":&"spec1","effect":&"link","mp_cost":18,"cooldown":10.0},
		{"id":&"sanctuary_bloom","name":"Sanctuary Bloom","icon":&"flower","section":&"spec1","effect":&"barrier","power":75.0,"mp_cost":24,"cooldown":15.0},
		{"id":&"guiding_light","name":"Guiding Light","icon":&"star","section":&"spec1","effect":&"buff","mp_cost":16,"cooldown":12.0},
	]
	for row in rows:
		var definition := SkillDefinition.new(row)
		_skills[definition.id] = definition


static func _build_enemies() -> void:
	for row in [
		{"id":&"gilded_scout","name":"Gilded Scout","icon":&"crown","color":Color("#FFD700"),"power":100},
		{"id":&"crystal_guardian","name":"Crystal Guardian","icon":&"gem","color":Color("#448AFF"),"power":150},
		{"id":&"trial_warden","name":"Trial Warden","icon":&"star","color":Color("#AA44FF"),"power":200},
		{"id":&"spirit_familiar","name":"Spirit Familiar","icon":&"paw","color":Color("#22DD6E"),"power":120},
	]:
		var definition := EnemyDefinition.new(row)
		_enemies[definition.id] = definition


static func _build_rewards() -> void:
	for row in [
		{"id":&"gold","name":"Gold","description":"Gold ×100","currency_id":&"gold","quantity":100},
		{"id":&"enhancement","name":"Enhancement & Refinement","description":"Arcane Dust ×5","item_id":&"arcane_dust","quantity":5},
		{"id":&"talent_shard","name":"Talent Materials","description":"Talent Shard ×3","quantity":3},
		{"id":&"pet_essence","name":"Pet Materials","description":"Pet Essence ×10","quantity":10},
	]:
		var definition := RewardDefinition.new(row)
		_rewards[definition.id] = definition
