class_name GameSession
extends Node
## Scene-owned runtime composition root. Persistence will attach here in Phase 4.

const COMBAT_CONTROLLER_SCRIPT := preload("res://scripts/combat/combat_controller.gd")

signal profile_replaced(profile: PlayerProfile)

var profile: PlayerProfile
var combat: COMBAT_CONTROLLER_SCRIPT


func _ready() -> void:
	if profile == null:
		profile = PlayerProfile.new()
	if combat == null:
		combat = COMBAT_CONTROLLER_SCRIPT.new()


func replace_profile(data: Dictionary) -> StateMutationResult:
	if int(data.get("version", -1)) != PlayerProfile.SAVE_VERSION:
		return StateMutationResult.rejected(&"unsupported_version", "Unsupported profile version.")
	profile = PlayerProfile.from_dict(data)
	profile_replaced.emit(profile)
	return StateMutationResult.accepted(&"profile", &"profile_replaced")


func start_combat(enemy_id: StringName, level: int, seed: int) -> StateMutationResult:
	var enemy_definition := GameCatalog.enemy(enemy_id)
	if enemy_definition == null:
		return StateMutationResult.rejected(&"unknown_enemy", "Unknown enemy definition.")
	combat.start(profile.combat_snapshot(), enemy_definition.combat_snapshot(level), seed)
	return StateMutationResult.accepted(&"combat", &"combat_started")
