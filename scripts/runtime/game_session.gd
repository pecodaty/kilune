class_name GameSession
extends Node
## Scene-owned runtime composition root. Persistence will attach here in Phase 4.

signal profile_replaced(profile: PlayerProfile)

var profile: PlayerProfile


func _ready() -> void:
	if profile == null:
		profile = PlayerProfile.new()


func replace_profile(data: Dictionary) -> StateMutationResult:
	if int(data.get("version", -1)) != PlayerProfile.SAVE_VERSION:
		return StateMutationResult.rejected(&"unsupported_version", "Unsupported profile version.")
	profile = PlayerProfile.from_dict(data)
	profile_replaced.emit(profile)
	return StateMutationResult.accepted(&"profile", &"profile_replaced")
