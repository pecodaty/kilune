class_name SkillsTab
extends SubTabPage
## AUTO-CAST SETUP: reorderable cast order, cast delay, unavailable behavior,
## and one-cycle toggle. Reset/Cancel/Apply work against a local snapshot
## until an auto-cast system owns this state. Reference: App.tsx `SkillsTab`.

signal settings_applied(settings: Dictionary)

## Stacked chevron button used to reorder cast rows.
class ChevronBtn extends Control:
	signal pressed

	var up := true
	var enabled_state := true:
		set(v):
			enabled_state = v
			modulate.a = 1.0 if v else 0.3
			mouse_filter = Control.MOUSE_FILTER_STOP if v else Control.MOUSE_FILTER_IGNORE

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		if up:
			IconDraw.chevron_up(self, Rect2(Vector2.ZERO, size), UIPalette.TEXT_MUTED)
		else:
			IconDraw.chevron_down(self, Rect2(Vector2.ZERO, size), UIPalette.TEXT_MUTED)

	func _gui_input(event: InputEvent) -> void:
		if not enabled_state:
			return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


## One cast-order row: position badge, skill icon, name, cast time, reorder.
class CastRow extends Control:
	signal move_requested(direction: int)

	const HEIGHT := 44.0

	var entry: Dictionary
	var row_index := 0

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, HEIGHT)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for i in range(2):
			var btn := ChevronBtn.new()
			btn.up = i == 0
			btn.anchor_left = 1.0
			btn.anchor_right = 1.0
			btn.offset_left = -30.0
			btn.offset_right = -8.0
			btn.offset_top = 3.0 + i * 20.0
			btn.offset_bottom = 19.0 + i * 20.0
			btn.pressed.connect(func() -> void: move_requested.emit(1 if i == 0 else -1))
			add_child(btn)

	func refresh(pos: int, total: int) -> void:
		row_index = pos
		for i in range(2):
			(get_child(i) as ChevronBtn).enabled_state = (pos > 0) if i == 0 else (pos < total - 1)
		queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#0A0720"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(UIPalette.BORDER_DARK, 0.33), false, 1.0)
		# Position badge.
		var badge := Rect2(10.0, (size.y - 20.0) * 0.5, 20.0, 20.0)
		draw_rect(badge, Color("#0D0825"))
		draw_rect(badge, Color(UIPalette.BORDER_DARK, 0.6), false, 1.0)
		draw_string(UIFonts.rajdhani_bold(), badge.position + Vector2(0.0, 14.5), str(row_index + 1),
			HORIZONTAL_ALIGNMENT_CENTER, badge.size.x, 9, Color("#5A4080"))
		# Skill icon in an octagon frame.
		var icon_rect := Rect2(38.0, (size.y - 28.0) * 0.5, 28.0, 28.0)
		var frame := UIDraw.octagon(icon_rect.size, 7.0)
		draw_set_transform(icon_rect.position)
		draw_colored_polygon(frame, Color("#0D0825"))
		frame.append(frame[0])
		draw_polyline(frame, Color(UIPalette.PURPLE_STRUCTURE, 0.47), 1.0, true)
		draw_set_transform(Vector2.ZERO)
		IconDraw.draw_item_icon(self, entry["icon"], icon_rect.grow(-6.0), entry["color"])
		# Name and cast time.
		draw_string(UIFonts.rajdhani_bold(), Vector2(76.0, size.y * 0.5 - 1.0), entry["name"],
			HORIZONTAL_ALIGNMENT_LEFT, size.x - 116.0, 10, Color("#C8B8E8"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(76.0, size.y * 0.5 + 12.0),
			"%.1fs cast" % entry["cast"], HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#5A4080"))


## Dot + label toggle (`One Cycle`).
class CycleToggle extends Control:
	signal toggled(active: bool)

	var active := false:
		set(v):
			active = v
			queue_redraw()

	func _ready() -> void:
		custom_minimum_size = Vector2(76.0, 22.0)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var dot_color := UIPalette.CYAN if active else Color(UIPalette.PURPLE_STRUCTURE, 0.33)
		draw_circle(Vector2(6.0, size.y * 0.5), 3.0, dot_color)
		if active:
			draw_circle(Vector2(6.0, size.y * 0.5), 5.0, Color(UIPalette.CYAN, 0.15))
		draw_string(UIFonts.rajdhani_bold(), Vector2(14.0, size.y * 0.5 + 3.5), "One Cycle",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, UIPalette.CYAN if active else Color("#5A4080"))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			active = not active
			toggled.emit(active)
		elif event is InputEventScreenTouch and not event.is_pressed():
			active = not active
			toggled.emit(active)


## Full-width action bar (RESET / CANCEL / APPLY).
class ActionBtn extends Control:
	signal pressed

	var label := ""
	var accent := UIPalette.CYAN
	var highlighted := false

	func setup(text: String, color: Color, is_highlighted: bool) -> void:
		label = text
		accent = color
		highlighted = is_highlighted

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, 34.0)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var shape := UIDraw.clipped_rect(size, 6.0, 0.0, 6.0, 0.0)
		if highlighted:
			draw_set_transform(size * 0.5, 0.0, Vector2(1.04, 1.2))
			var glow := UIDraw.clipped_rect(size, 6.0, 0.0, 6.0, 0.0)
			for i in range(glow.size()):
				glow[i] -= size * 0.5
			draw_colored_polygon(glow, Color(accent, 0.12))
			draw_set_transform(Vector2.ZERO)
			UIDraw.draw_poly_h_gradient(self, shape, size, [
				[0.0, Color("#0A1535")], [0.5, Color("#0D1A40")], [1.0, Color("#0A1535")],
			])
		else:
			draw_colored_polygon(shape, Color("#0A0720"))
		shape.append(shape[0])
		draw_polyline(shape, accent if highlighted else Color(accent, 0.4), 1.0, true)
		var font := UIFonts.rajdhani_bold()
		var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		draw_string(font, Vector2((size.x - text_size.x) * 0.5, size.y * 0.5 + text_size.y * 0.35),
			label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, accent)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


var _order: Array[Dictionary] = []
var _delay := "0.5"
var _if_unavailable := "Skip"
var _one_cycle := false
var _snapshot := {}

var _rows: VBoxContainer
var _delay_edit: LineEdit
var _unavailable_btn: HeroPillBtn
var _cycle_toggle: CycleToggle


func _build() -> void:
	panel.setup("AUTO-CAST SETUP")
	_order = HeroData.cast_order()
	_take_snapshot()

	panel.body.add_child(_section_label("CAST ORDER"))
	panel.body.add_child(_spacer(6))
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 8)
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.body.add_child(_rows)
	_rebuild_rows()

	panel.body.add_child(_spacer(16))
	panel.body.add_child(_build_settings_row())
	panel.body.add_child(_spacer(14))
	panel.body.add_child(_build_action_row())


func _build_settings_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(UIFonts.make_label("Cast Delay", UIFonts.rajdhani_semibold(), 9, Color("#5A4080")))

	_delay_edit = LineEdit.new()
	_delay_edit.text = _delay
	_delay_edit.custom_minimum_size = Vector2(40.0, 22.0)
	_delay_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_delay_edit.max_length = 4
	_delay_edit.add_theme_font_override("font", UIFonts.rajdhani_bold())
	_delay_edit.add_theme_font_size_override("font_size", 9)
	_delay_edit.add_theme_color_override("font_color", Color("#C8B8E8"))
	_delay_edit.add_theme_color_override("caret_color", UIPalette.CYAN)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0A0720")
	style.set_border_width_all(1)
	style.border_color = Color(UIPalette.PURPLE_STRUCTURE, 0.47)
	style.content_margin_left = 2.0
	style.content_margin_right = 2.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	_delay_edit.add_theme_stylebox_override("normal", style)
	_delay_edit.add_theme_stylebox_override("focus", style)
	_delay_edit.text_changed.connect(func(t: String) -> void: _delay = t)
	row.add_child(_delay_edit)

	var unavailable_label := UIFonts.make_label("If Unavailable", UIFonts.rajdhani_semibold(), 9, Color("#5A4080"))
	row.add_child(unavailable_label)
	_unavailable_btn = HeroPillBtn.new()
	_unavailable_btn.setup(_if_unavailable, UIPalette.CYAN, 22.0, true, 9)
	_unavailable_btn.pressed.connect(_toggle_unavailable)
	row.add_child(_unavailable_btn)

	var spring := Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spring)

	_cycle_toggle = CycleToggle.new()
	_cycle_toggle.toggled.connect(func(active: bool) -> void: _one_cycle = active)
	row.add_child(_cycle_toggle)
	return row


func _build_action_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var reset := ActionBtn.new()
	reset.setup("RESET", Color("#5A4080"), false)
	reset.pressed.connect(_on_reset)
	row.add_child(reset)
	var cancel := ActionBtn.new()
	cancel.setup("CANCEL", Color("#AA77FF"), false)
	cancel.pressed.connect(_on_cancel)
	row.add_child(cancel)
	var apply := ActionBtn.new()
	apply.setup("APPLY", UIPalette.CYAN, true)
	apply.pressed.connect(_on_apply)
	row.add_child(apply)
	return row


func _rebuild_rows() -> void:
	for child in _rows.get_children():
		child.queue_free()
	for i in range(_order.size()):
		var row := CastRow.new()
		row.entry = _order[i]
		row.move_requested.connect(func(direction: int) -> void: _move(i, direction))
		_rows.add_child(row)
		row.refresh(i, _order.size())


func _move(index: int, direction: int) -> void:
	var target := index - direction # direction +1 means move up.
	if target < 0 or target >= _order.size():
		return
	var tmp: Dictionary = _order[index]
	_order[index] = _order[target]
	_order[target] = tmp
	_rebuild_rows()


func _toggle_unavailable() -> void:
	_if_unavailable = "Wait" if _if_unavailable == "Skip" else "Skip"
	_unavailable_btn.setup(_if_unavailable, UIPalette.CYAN, 22.0, true, 9)


func _current_settings() -> Dictionary:
	var ids: Array[StringName] = []
	for entry in _order:
		ids.append(entry["id"])
	return {
		"order": ids,
		"delay": _delay,
		"if_unavailable": _if_unavailable,
		"one_cycle": _one_cycle,
	}


func _take_snapshot() -> void:
	_snapshot = _current_settings()


func _restore(settings: Dictionary) -> void:
	var by_id := {}
	for entry in HeroData.cast_order():
		by_id[entry["id"]] = entry
	_order.clear()
	for id in settings["order"]:
		_order.append(by_id[id])
	_delay = settings["delay"]
	_if_unavailable = settings["if_unavailable"]
	_one_cycle = settings["one_cycle"]
	_delay_edit.text = _delay
	_unavailable_btn.setup(_if_unavailable, UIPalette.CYAN, 22.0, true, 9)
	_cycle_toggle.active = _one_cycle
	_rebuild_rows()


func _on_apply() -> void:
	_take_snapshot()
	settings_applied.emit(_snapshot)


func _on_cancel() -> void:
	_restore(_snapshot)


func _on_reset() -> void:
	var defaults := {}
	var ids: Array[StringName] = []
	for entry in HeroData.cast_order():
		ids.append(entry["id"])
	defaults["order"] = ids
	defaults["delay"] = "0.5"
	defaults["if_unavailable"] = "Skip"
	defaults["one_cycle"] = false
	_restore(defaults)
