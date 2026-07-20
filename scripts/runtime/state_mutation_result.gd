class_name StateMutationResult
extends RefCounted
## Standard result for validated runtime-state mutations.

var ok: bool
var code: StringName
var message: String
var change_kind: StringName


func _init(succeeded: bool, result_code: StringName, result_message := "", kind: StringName = &"") -> void:
	ok = succeeded
	code = result_code
	message = result_message
	change_kind = kind


static func accepted(kind: StringName, result_code: StringName = &"ok") -> StateMutationResult:
	return StateMutationResult.new(true, result_code, "", kind)


static func rejected(result_code: StringName, result_message: String) -> StateMutationResult:
	return StateMutationResult.new(false, result_code, result_message)
