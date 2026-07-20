extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var profile := PlayerProfile.new()
	_assert(GameCatalog.skill(&"thorn_orb") is SkillDefinition, "typed skill catalog")
	_assert(GameCatalog.item(&"trailguard") is ItemDefinition, "typed item catalog")
	_assert(GameCatalog.enemy(&"gilded_scout") is EnemyDefinition, "typed enemy catalog")
	_assert(GameCatalog.reward(&"gold") is RewardDefinition, "typed reward catalog")
	_assert(profile.inventory.used_slots() == 24, "shared initial inventory")
	_assert(profile.inventory.equipment_snapshot()[&"ring"] == &"ember_signet", "shared initial equipment")
	_assert(profile.hero.inventory_snapshot().size() == 5, "hero reads shared equipment collection")

	var changed_domains: Array[StringName] = []
	profile.changed.connect(func(domain: StringName, _kind: StringName) -> void: changed_domains.append(domain))
	var power_before := _stat(profile, &"power")
	_assert(profile.hero.equip_item(&"oracle_signet").ok, "equip through hero facade")
	_assert(profile.inventory.equipment_snapshot()[&"ring"] == &"oracle_signet", "inventory owns equipped slot")
	_assert(_stat(profile, &"power") < power_before, "shared equipment recalculates hero stats")
	_assert(changed_domains.has(&"inventory") and changed_domains.has(&"hero"), "aggregate emits domain changes")

	_assert(profile.inventory.add_item(&"arcane_dust", 5).ok, "validated item credit")
	_assert(profile.inventory.quantity(&"arcane_dust") == 914, "inventory quantity mutation")
	_assert(not profile.inventory.remove_item(&"arcane_dust", 9999).ok, "reject excessive item debit")
	_assert(profile.wallet.debit(&"gold", 100).ok, "validated wallet debit")
	_assert(not profile.wallet.debit(&"gold", 999999).ok, "reject excessive wallet debit")
	_assert(profile.activity.consume_attempt(&"golden").ok, "validated activity attempt")
	_assert(profile.activity.attempts(&"golden") == 2, "activity mutation applied")

	var combat := profile.combat_snapshot()
	_assert(combat["loadout"].size() == 6, "combat snapshot has six loadout slots")
	_assert(combat["loadout"][0]["id"] == &"thorn_orb", "combat snapshot uses hero loadout")
	_assert(combat["loadout"][0]["effect"] == &"damage", "combat snapshot uses typed definition")

	var saved := profile.to_dict()
	_assert(saved["version"] == PlayerProfile.SAVE_VERSION, "versioned profile schema")
	var restored := PlayerProfile.from_dict(saved)
	_assert(restored.to_dict() == saved, "profile dictionary round trip")
	_assert(restored.inventory.equipment_snapshot()[&"ring"] == &"oracle_signet", "equipment round trip")
	_assert(restored.wallet.balance(&"gold") == profile.wallet.balance(&"gold"), "wallet round trip")
	_assert(restored.activity.attempts(&"golden") == 2, "activity round trip")

	var scene: PackedScene = load("res://scenes/ui/gameplay/main_gameplay_interface.tscn")
	var interface := scene.instantiate()
	root.add_child(interface)
	await process_frame
	var session: GameSession = interface.get_node("GameSession")
	var heroes: HeroesTab = interface.get_node("SafeAreaContainer/MainColumn/HeroesTab")
	var top_hud: TopHud = interface.get_node("SafeAreaContainer/MainColumn/TopHud")
	var skill_dock: SkillDock = interface.get_node("SafeAreaContainer/MainColumn/SkillDock")
	var backpack: BackpackScreen = interface.get_node("SafeAreaContainer/MainColumn/BackpackScreen")
	var shop: ShopScreen = interface.get_node("SafeAreaContainer/MainColumn/ShopScreen")
	var dungeon: DungeonFlow = interface.get_node("DungeonFlow")
	_assert(heroes._profile == session.profile, "Heroes bound to scene profile")
	_assert(top_hud._profile == session.profile, "HUD bound to scene profile")
	_assert(skill_dock._profile == session.profile, "combat loadout bound to scene profile")
	_assert(backpack._inventory_state == session.profile.inventory, "Backpack bound to shared inventory")
	_assert(shop._wallet_state == session.profile.wallet, "Shop bound to shared wallet")
	_assert(dungeon._activity_state == session.profile.activity, "Dungeon bound to shared activity")
	_assert(not session.replace_profile({"version":999}).ok, "reject unsupported profile version")
	_assert(session.replace_profile(saved).ok, "replace session profile from serialized data")
	_assert(heroes._profile == session.profile and backpack._inventory_state == session.profile.inventory, "screens rebind after profile replacement")
	interface.queue_free()
	await process_frame
	call_deferred("_finish")


func _finish() -> void:
	quit(0)


func _stat(profile: PlayerProfile, stat_id: StringName) -> float:
	for stat in profile.hero.stats_snapshot():
		if stat["id"] == stat_id:
			return stat["final"]
	return -1.0


func _assert(condition: bool, label: String) -> void:
	if not condition:
		push_error("Phase 1 assertion failed: " + label)
		quit(1)
