class_name EquipmentTab
extends SubTabPage
## HERO EQUIPMENT: 12-slot equipped-gear grid over the equipment collection
## list. Filled slots and collection rows open the item detail modal.
## Reference: App.tsx `EquipmentTab`.

signal modal_requested(payload: Dictionary)

## One gear slot: filled (item icon, name, level) or empty (slot label).
class GearSlot extends Control:
	signal pressed

	const HEIGHT := 64.0

	var slot: Dictionary
	var item: Dictionary = {}
	var selected := false:
		set(v):
			selected = v
			queue_redraw()

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, HEIGHT)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		if item.is_empty():
			_draw_empty()
			return
		var rc := HeroData.rarity_color(item["rarity"])
		if selected:
			draw_rect(Rect2(Vector2.ZERO, size).grow(1.0), Color(rc, 0.1))
			draw_rect(Rect2(Vector2.ZERO, size), Color("#120932", 0.6))
		else:
			draw_rect(Rect2(Vector2.ZERO, size), Color("#0A0720"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(rc, 0.53) if selected else Color(rc, 0.2), false, 1.0)
		# Rarity bar on the left edge.
		draw_rect(Rect2(0.0, 6.0, 2.0, size.y - 12.0), rc)
		IconDraw.draw_item_icon(self, item["icon"], Rect2((size.x - 16.0) * 0.5, 8.0, 16.0, 16.0), rc)
		draw_string(UIFonts.rajdhani_semibold(), Vector2(0.0, 42.0),
			String(item["name"]).get_slice(" ", 0), HORIZONTAL_ALIGNMENT_CENTER, size.x, 7,
			UIPalette.TEXT_LAVENDER_DIM)
		draw_string(UIFonts.rajdhani_bold(), Vector2(0.0, 54.0), "Lv.%d" % item["lv"],
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, rc)

	func _draw_empty() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#070518"))
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1433", 0.6), false, 1.0)
		draw_arc(Vector2(size.x * 0.5, 20.0), 9.0, 0.0, TAU, 20, Color("#120930"), 2.0, true)
		draw_string(UIFonts.rajdhani_semibold(), Vector2(0.0, 48.0), slot["label"],
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, UIPalette.BORDER_DARK)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


## One collection row: icon, name, level/rarity, and a two-stat preview.
class ItemTile extends Control:
	signal pressed

	const HEIGHT := 52.0

	var item: Dictionary

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, HEIGHT)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var rc := HeroData.rarity_color(item["rarity"])
		draw_rect(Rect2(Vector2.ZERO, size), Color("#0A0720"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(UIPalette.BORDER_DARK, 0.33), false, 1.0)
		draw_rect(Rect2(0.0, 6.0, 2.0, size.y - 12.0), rc)
		var icon_rect := Rect2(10.0, (size.y - 32.0) * 0.5, 32.0, 32.0)
		var frame := UIDraw.octagon(icon_rect.size, 8.0)
		draw_set_transform(icon_rect.position)
		draw_colored_polygon(frame, UIPalette.HUD_TOP)
		frame.append(frame[0])
		draw_polyline(frame, Color(rc, 0.7), 1.0, true)
		draw_set_transform(Vector2.ZERO)
		IconDraw.draw_item_icon(self, item["icon"], icon_rect.grow(-8.0), rc)
		draw_string(UIFonts.rajdhani_bold(), Vector2(52.0, 22.0), item["name"],
			HORIZONTAL_ALIGNMENT_LEFT, size.x - 140.0, 10, Color("#C8B8E8"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(52.0, 37.0),
			"Lv.%d · %s" % [item["lv"], String(item["rarity"]).capitalize()],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 8, rc)
		# Two-stat preview, right aligned.
		var stats: Array = item["stats"]
		for i in range(mini(2, stats.size())):
			var stat: Array = stats[i]
			var text := "%s %s" % [String(stat[0]).left(3), stat[1]]
			draw_string(UIFonts.rajdhani_bold(), Vector2(0.0, 22.0 + i * 15.0), text,
				HORIZONTAL_ALIGNMENT_RIGHT, size.x - 10.0, 8, UIPalette.CYAN)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


var _slots: Array[GearSlot] = []


func _build() -> void:
	panel.setup("HERO EQUIPMENT", "Forge", UIPalette.GOLD)

	panel.body.add_child(_section_label("EQUIPPED GEAR"))
	panel.body.add_child(_spacer(6))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for slot in HeroData.gear_slots():
		var cell := GearSlot.new()
		cell.slot = slot
		cell.item = HeroData.equipped_in(slot["id"])
		cell.pressed.connect(func() -> void: _on_slot_pressed(cell))
		grid.add_child(cell)
		_slots.append(cell)
	panel.body.add_child(grid)

	panel.body.add_child(_spacer(14))
	panel.body.add_child(_section_label("EQUIPMENT COLLECTION"))
	panel.body.add_child(_spacer(6))
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for item in HeroData.inventory():
		var tile := ItemTile.new()
		tile.item = item
		tile.pressed.connect(func() -> void:
			modal_requested.emit({"type": &"item", "data": tile.item}))
		list.add_child(tile)
	panel.body.add_child(list)


func _on_slot_pressed(slot: GearSlot) -> void:
	for cell in _slots:
		cell.selected = cell == slot and not cell.item.is_empty()
	if not slot.item.is_empty():
		modal_requested.emit({"type": &"item", "data": slot.item})
