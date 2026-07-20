class_name ItemModal
extends Control
## Centered detail modal for equipment items and talent nodes, overlaying
## only the Heroes content area. Accent follows item rarity / talent color.
## Reference: App.tsx `ItemModal`.

signal closed
signal action_pressed(action: StringName, item_id: StringName)

## Item/talent glyph drawn in the accent color.
class IconGlyph extends Control:
	var icon_id: StringName
	var accent := UIPalette.CYAN

	func _ready() -> void:
		custom_minimum_size = Vector2(20.0, 20.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		IconDraw.draw_item_icon(self, icon_id, Rect2(Vector2.ZERO, size), accent)


## X close button.
class CloseBtn extends Control:
	signal pressed

	func _ready() -> void:
		custom_minimum_size = Vector2(28.0, 22.0)
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1E1040"))
		IconDraw.x_mark(self, Rect2(Vector2(7.0, 3.0), Vector2(14.0, 16.0)), UIPalette.TEXT_LAVENDER)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


## One-pixel accent gradient divider.
class AccentDivider extends Control:
	var accent := UIPalette.CYAN

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, 2.0)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		UIDraw.draw_h_gradient_line(self, 1.0, size.x, [
			[0.0, Color(accent, 0.0)], [0.5, Color(accent, 0.5)], [1.0, Color(accent, 0.0)],
		], 1.0, 24)


## Modal surface: gradient, accent border, gold corner brackets.
class ModalPanel extends MarginContainer:
	var accent := UIPalette.CYAN

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size).grow(6.0), Color(accent, 0.08))
		UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#0E0A28"), Color("#060418"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(accent, 0.27), false, 1.0)
		var c := Color(UIPalette.GOLD_MUTED, 0.6)
		var w := size.x
		var h := size.y
		for pts in [
			[Vector2(0.5, 12), Vector2(0.5, 0.5), Vector2(12, 0.5)],
			[Vector2(w - 12, 0.5), Vector2(w - 0.5, 0.5), Vector2(w - 0.5, 12)],
			[Vector2(0.5, h - 12), Vector2(0.5, h - 0.5), Vector2(12, h - 0.5)],
			[Vector2(w - 12, h - 0.5), Vector2(w - 0.5, h - 0.5), Vector2(w - 0.5, h - 12)],
		]:
			draw_polyline(PackedVector2Array(pts), c, 1.0, true)


var _panel: ModalPanel
var _stack: VBoxContainer


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_panel = ModalPanel.new()
	_panel.custom_minimum_size.x = 340.0
	_panel.add_theme_constant_override("margin_left", 16)
	_panel.add_theme_constant_override("margin_right", 16)
	_panel.add_theme_constant_override("margin_top", 14)
	_panel.add_theme_constant_override("margin_bottom", 14)
	center.add_child(_panel)
	_stack = VBoxContainer.new()
	_stack.add_theme_constant_override("separation", 8)
	_stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(_stack)


## Open the modal for {type: &"item"|&"talent", data: Dictionary}.
func show_payload(payload: Dictionary) -> void:
	if not is_node_ready():
		await ready
	_rebuild(StringName(payload["type"]), payload["data"], StringName(payload.get("action", &"")))
	visible = true


func close() -> void:
	visible = false
	closed.emit()


func _rebuild(type: StringName, data: Dictionary, action: StringName) -> void:
	for child in _stack.get_children():
		child.queue_free()
	var accent: Color = HeroData.rarity_color(data["rarity"]) if type == &"item" else data["color"]
	_panel.accent = accent
	_panel.queue_redraw()

	_build_title_row(type, data, accent)
	_stack.add_child(_divider(accent))
	_stack.add_child(_paragraph(data["desc"]))
	if type == &"item":
		_build_item_rows(data, accent, action)
	else:
		_build_talent_rows(data, accent)


func _build_title_row(type: StringName, data: Dictionary, accent: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack.add_child(row)

	var icon := IconGlyph.new()
	icon.icon_id = data["icon"]
	icon.accent = accent
	row.add_child(icon)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 0)
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	text_col.add_child(UIFonts.make_label(String(data["name"]).to_upper(), UIFonts.cinzel_bold(), 14, Color("#E8D8FF")))
	if type == &"item":
		text_col.add_child(UIFonts.make_label(
			"%s · Lv.%d" % [String(data["rarity"]).to_upper(), data["lv"]],
			UIFonts.rajdhani_bold(), 9, accent))

	var close_btn := CloseBtn.new()
	close_btn.pressed.connect(close)
	row.add_child(close_btn)


func _build_item_rows(item: Dictionary, accent: Color, action: StringName) -> void:
	_stack.add_child(_stat_row("Standard", String(item["rarity"]).capitalize(), accent))
	_stack.add_child(_stat_row("Enhancement", item["enhance"], Color("#E8D8FF")))
	_stack.add_child(_stat_row("Success Chance", item["success"], UIPalette.HP))
	for stat in item["stats"]:
		_stack.add_child(_stat_row(stat[0], stat[1], UIPalette.CYAN))
	var slot_label := ""
	for slot in HeroData.gear_slots():
		if slot["id"] == item["slot"]:
			slot_label = slot["label"]
	_stack.add_child(_stat_row("Equipped", slot_label, UIPalette.TEXT_LAVENDER_DIM))

	if not item["locked"].is_empty():
		_stack.add_child(_divider(accent))
		for tier in item["locked"]:
			_stack.add_child(_stat_row("Locked %s" % tier[0], tier[1], UIPalette.TEXT_MUTED, true))
	_stack.add_child(_divider(accent))
	if not action.is_empty():
		_build_actions([action], accent, item["id"])


func _build_talent_rows(talent: Dictionary, accent: Color) -> void:
	_stack.add_child(_stat_row("Points Invested", "%d / %d" % [talent["current"], talent["max"]], accent))
	var effect := String(talent["desc"]).trim_prefix("Increases ")
	_stack.add_child(_stat_row("Effect", effect, UIPalette.CYAN))
	_stack.add_child(_divider(accent))
	_build_actions([], accent, &"")


func _build_actions(actions: Array, accent: Color, item_id: StringName) -> void:
	if actions.is_empty():
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack.add_child(row)
	for i in range(actions.size()):
		var action := StringName(actions[i])
		var btn := ArcaneButton.new()
		btn.text = String(action).to_upper()
		btn.fill_top = Color("#0A1535") if i == 0 else Color("#0A0720")
		btn.fill_bottom = Color("#0D1A40") if i == 0 else Color("#080618")
		btn.border_color = Color(accent, 0.55 if i == 0 else 0.3)
		btn.add_theme_font_override("font", UIFonts.rajdhani_bold())
		btn.add_theme_font_size_override("font_size", 9)
		btn.add_theme_color_override("font_color", accent if i == 0 else UIPalette.TEXT_CHAT)
		btn.pressed.connect(_emit_action.bind(action, item_id))
		row.add_child(btn)
		btn.custom_minimum_size.y = 30.0


func _emit_action(action: StringName, item_id: StringName) -> void:
	action_pressed.emit(action, item_id)
	close()


func _stat_row(label_text: String, value_text: String, value_color: Color, muted := false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(UIFonts.make_label(label_text, UIFonts.rajdhani_semibold(), 9, Color("#5A4878")))
	var value := UIFonts.make_label(value_text, UIFonts.rajdhani_bold(), 9,
		UIPalette.TEXT_MUTED if muted else value_color, HORIZONTAL_ALIGNMENT_RIGHT)
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(value)
	return row


func _paragraph(text: String) -> Label:
	var label := UIFonts.make_label(text, UIFonts.rajdhani_medium(), 10, Color("#7A6A9A"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _divider(accent: Color) -> AccentDivider:
	var divider := AccentDivider.new()
	divider.accent = accent
	return divider


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.0, 0.0, 0.53))
