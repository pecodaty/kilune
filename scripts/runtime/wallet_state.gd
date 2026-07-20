class_name WalletState
extends RefCounted

signal changed(change_kind: StringName)

var _balances: Dictionary = {&"gems":26791, &"gold":11734}


func _init(data: Dictionary = {}) -> void:
	if not data.is_empty():
		restore(data, false)


func balance(currency_id: StringName) -> int:
	return int(_balances.get(currency_id, 0))


func snapshot() -> Dictionary:
	return _balances.duplicate(true)


func credit(currency_id: StringName, amount: int) -> StateMutationResult:
	if amount <= 0:
		return StateMutationResult.rejected(&"invalid_amount", "Amount must be positive.")
	_balances[currency_id] = balance(currency_id) + amount
	changed.emit(&"wallet")
	return StateMutationResult.accepted(&"wallet", &"currency_credited")


func debit(currency_id: StringName, amount: int) -> StateMutationResult:
	if amount <= 0:
		return StateMutationResult.rejected(&"invalid_amount", "Amount must be positive.")
	if balance(currency_id) < amount:
		return StateMutationResult.rejected(&"insufficient_currency", "Insufficient currency.")
	_balances[currency_id] = balance(currency_id) - amount
	changed.emit(&"wallet")
	return StateMutationResult.accepted(&"wallet", &"currency_debited")


func to_dict() -> Dictionary:
	return {"balances":snapshot()}


func restore(data: Dictionary, emit_change := true) -> StateMutationResult:
	var balances: Dictionary = data.get("balances", {})
	var restored := {}
	for raw_id in balances:
		var amount := int(balances[raw_id])
		if amount >= 0:
			restored[StringName(raw_id)] = amount
	for required_id in [&"gems", &"gold"]:
		if not restored.has(required_id):
			restored[required_id] = 0
	_balances = restored
	if emit_change:
		changed.emit(&"restored")
	return StateMutationResult.accepted(&"restored")
