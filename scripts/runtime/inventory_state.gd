class_name InventoryState
extends RefCounted
## Authoritative item quantities and equipped-item assignments.

signal changed(change_kind: StringName)

const CAPACITY := 100

var _quantities: Dictionary = {}
var _equipment: Dictionary = {}


func _init(data: Dictionary = {}) -> void:
	_quantities = GameCatalog.initial_inventory()
	_equipment = GameCatalog.initial_equipment()
	if not data.is_empty():
		restore(data, false)


func quantity(item_id: StringName) -> int:
	return int(_quantities.get(item_id, 0))


func used_slots() -> int:
	return _quantities.size()


func capacity() -> int:
	return CAPACITY


func items_snapshot() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id in GameCatalog.item_ids():
		var amount := quantity(item_id)
		if amount <= 0:
			continue
		var definition := GameCatalog.item(item_id)
		out.append(definition.snapshot(amount, _equipment.values().has(item_id)))
	return out


func equipment_items_snapshot() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item in items_snapshot():
		if item["category"] == &"equipment":
			out.append(item)
	return out


func equipment_snapshot() -> Dictionary:
	return _equipment.duplicate(true)


func item_snapshot(item_id: StringName) -> Dictionary:
	var definition := GameCatalog.item(item_id)
	if definition == null or quantity(item_id) <= 0:
		return {}
	return definition.snapshot(quantity(item_id), _equipment.values().has(item_id))


func equipped_item_in(slot_id: StringName) -> Dictionary:
	return item_snapshot(_equipment.get(slot_id, &""))


func item_action(item_id: StringName) -> StringName:
	var item := item_snapshot(item_id)
	if item.is_empty() or item["category"] != &"equipment":
		return &""
	var equipped_id: StringName = _equipment.get(item["slot"], &"")
	if equipped_id == item_id:
		return &"unequip"
	return &"replace" if not equipped_id.is_empty() else &"equip"


func add_item(item_id: StringName, amount: int) -> StateMutationResult:
	if GameCatalog.item(item_id) == null:
		return StateMutationResult.rejected(&"unknown_item", "Unknown item.")
	if amount <= 0:
		return StateMutationResult.rejected(&"invalid_amount", "Amount must be positive.")
	if quantity(item_id) == 0 and used_slots() >= CAPACITY:
		return StateMutationResult.rejected(&"inventory_full", "Backpack capacity reached.")
	_quantities[item_id] = quantity(item_id) + amount
	changed.emit(&"items")
	return StateMutationResult.accepted(&"items", &"item_added")


func remove_item(item_id: StringName, amount: int) -> StateMutationResult:
	if amount <= 0:
		return StateMutationResult.rejected(&"invalid_amount", "Amount must be positive.")
	if quantity(item_id) < amount:
		return StateMutationResult.rejected(&"insufficient_items", "Not enough items.")
	var remaining := quantity(item_id) - amount
	if remaining == 0:
		_quantities.erase(item_id)
		_unequip_without_signal(item_id)
	else:
		_quantities[item_id] = remaining
	changed.emit(&"items")
	return StateMutationResult.accepted(&"items", &"item_removed")


func equip_item(item_id: StringName) -> StateMutationResult:
	var item := item_snapshot(item_id)
	if item.is_empty():
		return StateMutationResult.rejected(&"item_not_owned", "Item is not owned.")
	if item["category"] != &"equipment" or StringName(item["slot"]).is_empty():
		return StateMutationResult.rejected(&"not_equipment", "Item cannot be equipped.")
	var slot: StringName = item["slot"]
	if _equipment.get(slot, &"") == item_id:
		return StateMutationResult.rejected(&"already_equipped", "Item is already equipped.")
	_equipment[slot] = item_id
	changed.emit(&"equipment")
	return StateMutationResult.accepted(&"equipment", &"item_equipped")


func unequip_item(item_id: StringName) -> StateMutationResult:
	var item := item_snapshot(item_id)
	if item.is_empty():
		return StateMutationResult.rejected(&"item_not_owned", "Item is not owned.")
	var slot: StringName = item["slot"]
	if _equipment.get(slot, &"") != item_id:
		return StateMutationResult.rejected(&"not_equipped", "Item is not equipped.")
	_equipment.erase(slot)
	changed.emit(&"equipment")
	return StateMutationResult.accepted(&"equipment", &"item_unequipped")


func to_dict() -> Dictionary:
	return {"quantities":_quantities.duplicate(true), "equipment":_equipment.duplicate(true)}


func restore(data: Dictionary, emit_change := true) -> StateMutationResult:
	var quantities: Dictionary = data.get("quantities", {})
	var equipment: Dictionary = data.get("equipment", {})
	var restored_quantities := {}
	for raw_id in quantities:
		var item_id := StringName(raw_id)
		var amount := int(quantities[raw_id])
		if GameCatalog.item(item_id) != null and amount > 0:
			restored_quantities[item_id] = amount
	if restored_quantities.size() > CAPACITY:
		return StateMutationResult.rejected(&"inventory_full", "Serialized inventory exceeds capacity.")
	var restored_equipment := {}
	for raw_slot in equipment:
		var slot_id := StringName(raw_slot)
		var item_id := StringName(equipment[raw_slot])
		var definition := GameCatalog.item(item_id)
		if definition != null and restored_quantities.get(item_id, 0) > 0 and definition.slot == slot_id:
			restored_equipment[slot_id] = item_id
	_quantities = restored_quantities
	_equipment = restored_equipment
	if emit_change:
		changed.emit(&"restored")
	return StateMutationResult.accepted(&"restored")


func _unequip_without_signal(item_id: StringName) -> void:
	for slot_id in _equipment.keys():
		if _equipment[slot_id] == item_id:
			_equipment.erase(slot_id)
