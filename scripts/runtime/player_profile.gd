class_name PlayerProfile
extends RefCounted
## Versioned aggregate root for all persistent player-owned runtime state.

signal changed(domain: StringName, change_kind: StringName)

const SAVE_VERSION := 1

var hero: HeroProgressionState
var inventory: InventoryState
var wallet: WalletState
var activity: ActivityState


func _init(data: Dictionary = {}) -> void:
	inventory = InventoryState.new(data.get("inventory", {}))
	hero = HeroProgressionState.new(inventory, data.get("hero", {}))
	wallet = WalletState.new(data.get("wallet", {}))
	activity = ActivityState.new(data.get("activity", {}))
	hero.changed.connect(_on_hero_changed)
	inventory.changed.connect(_on_inventory_changed)
	wallet.changed.connect(_on_wallet_changed)
	activity.changed.connect(_on_activity_changed)


func to_dict() -> Dictionary:
	return {
		"version":SAVE_VERSION,
		"hero":hero.to_dict(),
		"inventory":inventory.to_dict(),
		"wallet":wallet.to_dict(),
		"activity":activity.to_dict(),
	}


func combat_snapshot() -> Dictionary:
	var loadout: Array[Dictionary] = []
	for skill_id in hero.loadout_snapshot():
		if skill_id.is_empty():
			loadout.append({})
		else:
			var definition := GameCatalog.skill(skill_id)
			var progression := {}
			for skill_state in hero.skills_snapshot():
				if skill_state["id"] == skill_id:
					progression = skill_state
					break
			loadout.append(definition.combat_snapshot(
				int(progression.get("level", 0)), int(progression.get("mastery", 0))))
	return {"identity":hero.identity_snapshot(), "stats":hero.stats_snapshot(), "loadout":loadout}


static func from_dict(data: Dictionary) -> PlayerProfile:
	if int(data.get("version", SAVE_VERSION)) != SAVE_VERSION:
		return PlayerProfile.new()
	return PlayerProfile.new(data)


func _on_hero_changed(change_kind: StringName) -> void:
	changed.emit(&"hero", change_kind)


func _on_inventory_changed(change_kind: StringName) -> void:
	changed.emit(&"inventory", change_kind)


func _on_wallet_changed(change_kind: StringName) -> void:
	changed.emit(&"wallet", change_kind)


func _on_activity_changed(change_kind: StringName) -> void:
	changed.emit(&"activity", change_kind)
