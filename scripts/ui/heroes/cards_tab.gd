class_name CardsTab
extends SubTabPage
## EQUIPMENT CARDS: 3-column grid of card cells over the shared inventory.
## Tapping a card selects it and opens the item detail modal.
## Reference: App.tsx `CardsTab`.

signal modal_requested(payload: Dictionary)

## One equipment card: rarity frame, octagon icon, name, level.
class CardCell extends Control:
	signal pressed

	const HEIGHT := 128.0

	var item: Dictionary
	var selected := false:
		set(v):
			selected = v
			queue_redraw()

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, HEIGHT)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var rc := HeroData.rarity_color(item["rarity"])
		if selected:
			draw_rect(Rect2(Vector2.ZERO, size).grow(1.0), Color(rc, 0.1))
			draw_rect(Rect2(Vector2.ZERO, size), Color("#120932", 0.6))
		else:
			draw_rect(Rect2(Vector2.ZERO, size), Color("#0A0720"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(rc, 0.6) if selected else Color(rc, 0.2), false, 1.0)
		if selected:
			UIDraw.draw_h_gradient_line(self, 1.0, size.x - 16.0, [
				[0.0, Color(rc, 0.0)], [0.5, Color(rc, 0.53)], [1.0, Color(rc, 0.0)],
			], 1.0, 16)
		# Rarity bar on the left edge.
		draw_rect(Rect2(0.0, 8.0, 2.0, size.y - 16.0), rc)
		# Octagon icon frame.
		var icon_rect := Rect2((size.x - 34.0) * 0.5, 24.0, 34.0, 34.0)
		var frame := UIDraw.octagon(icon_rect.size, 8.0)
		draw_set_transform(icon_rect.position)
		draw_colored_polygon(frame, Color("#120932") if selected else UIPalette.HUD_TOP)
		frame.append(frame[0])
		draw_polyline(frame, rc, 1.0, true)
		draw_set_transform(Vector2.ZERO)
		IconDraw.draw_item_icon(self, item["icon"], icon_rect.grow(-9.0), rc)
		# Name (first two words) and level.
		var words := String(item["name"]).split(" ")
		var short_name := " ".join(words.slice(0, 2))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(0.0, 86.0), short_name,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 8,
			Color("#C8B8E8") if selected else Color("#5A4080"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(0.0, 102.0), "Lv.%d" % item["lv"],
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, rc)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


var _cards: Array[CardCell] = []
var _inventory_state: InventoryState


func _build() -> void:
	panel.setup("EQUIPMENT CARDS")
	_populate()


func bind_inventory_state(inventory_state: InventoryState) -> void:
	if _inventory_state != null and _inventory_state.changed.is_connected(_on_inventory_changed):
		_inventory_state.changed.disconnect(_on_inventory_changed)
	_inventory_state = inventory_state
	_inventory_state.changed.connect(_on_inventory_changed)
	_populate()


func _on_inventory_changed(_change_kind: StringName) -> void:
	_populate()


func _populate() -> void:
	if _inventory_state == null or panel == null:
		return
	for child in panel.body.get_children():
		panel.body.remove_child(child)
		child.queue_free()
	_cards.clear()
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for item in _inventory_state.equipment_items_snapshot():
		var cell := CardCell.new()
		cell.item = item
		cell.selected = item["id"] == &"ember_signet" # Reference initial selection.
		cell.pressed.connect(func() -> void: _on_card_pressed(cell))
		grid.add_child(cell)
		_cards.append(cell)
	panel.body.add_child(grid)


func _on_card_pressed(card: CardCell) -> void:
	for cell in _cards:
		cell.selected = cell == card
	modal_requested.emit({"type":&"item", "data":card.item, "action":_inventory_state.item_action(card.item["id"])})
