class_name ActivityState
extends RefCounted

signal changed(change_kind: StringName)

const DEFAULT_ATTEMPTS := 3
var _attempts: Dictionary = {&"golden":3, &"cards":3, &"talent":3, &"pet":3}


func _init(data: Dictionary = {}) -> void:
	if not data.is_empty():
		restore(data, false)


func attempts(activity_id: StringName) -> int:
	return int(_attempts.get(activity_id, 0))


func snapshot() -> Dictionary:
	return _attempts.duplicate(true)


func consume_attempt(activity_id: StringName) -> StateMutationResult:
	if attempts(activity_id) <= 0:
		return StateMutationResult.rejected(&"no_attempts", "No attempts remaining.")
	_attempts[activity_id] = attempts(activity_id) - 1
	changed.emit(&"attempts")
	return StateMutationResult.accepted(&"attempts", &"attempt_consumed")


func set_attempts(activity_id: StringName, amount: int) -> StateMutationResult:
	if amount < 0:
		return StateMutationResult.rejected(&"invalid_amount", "Attempts cannot be negative.")
	_attempts[activity_id] = amount
	changed.emit(&"attempts")
	return StateMutationResult.accepted(&"attempts")


func to_dict() -> Dictionary:
	return {"attempts":snapshot()}


func restore(data: Dictionary, emit_change := true) -> StateMutationResult:
	var attempts_data: Dictionary = data.get("attempts", {})
	var restored := {}
	for activity in GameCatalog.dungeon_snapshots():
		var id: StringName = activity["id"]
		restored[id] = maxi(0, int(attempts_data.get(id, DEFAULT_ATTEMPTS)))
	_attempts = restored
	if emit_change:
		changed.emit(&"restored")
	return StateMutationResult.accepted(&"restored")
