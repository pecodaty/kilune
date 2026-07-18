class_name NavTab
extends Control
## One bottom-navigation destination: icon (with optional gem frame) + label.

signal tab_pressed(tab_id: StringName)

@export var tab_id: StringName = &"home"
@export var label_text := "HOME":
	set(v):
		label_text = v
		_refresh_label()
@export var is_battle := false:
	set(v):
		is_battle = v
		queue_redraw()
@export var selected := false:
	set(v):
		selected = v
		_refresh_label()
		queue_redraw()

var _label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 72.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	_label = UIFonts.make_label(label_text, UIFonts.rajdhani_bold(), 7, UIPalette.INACTIVE_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_label.offset_top = -16.0
	_label.offset_bottom = -5.0
	add_child(_label)
	_refresh_label()


func _refresh_label() -> void:
	if not is_node_ready():
		return
	_label.text = label_text.to_upper()
	_label.add_theme_font_size_override("font_size", 8 if is_battle else 7)
	_label.add_theme_color_override("font_color", _content_color(true))


func _content_color(for_label: bool) -> Color:
	if selected:
		return UIPalette.TEXT_PALE_CYAN if for_label else UIPalette.CYAN
	if is_battle:
		return UIPalette.GOLD_MUTED
	return UIPalette.INACTIVE_DIM if for_label else UIPalette.INACTIVE


func _icon_rect() -> Rect2:
	var side := 36.0 if is_battle else 30.0
	var top := 0.0 if is_battle else 8.0
	return Rect2(Vector2((size.x - side) * 0.5, top), Vector2(side, side))


func _draw() -> void:
	var icon_rect := _icon_rect()
	if selected or is_battle:
		var frame := UIDraw.octagon(icon_rect.size, 8.0 if is_battle else 6.0)
		frame = _offset(frame, icon_rect.position)
		var fill := UIPalette.CANVAS
		if selected and is_battle:
			fill = Color("#0A1A35")
		elif selected:
			fill = Color("#0A1228")
		elif is_battle:
			fill = Color("#0A0F1E")
		draw_colored_polygon(frame, fill)
		UIDraw.draw_outline_diag(self, frame, size, UIPalette.gold_border_stops(), 1.5 if is_battle else 1.0)
		if is_battle:
			var inner := UIDraw.octagon(icon_rect.size - Vector2(8, 8), 5.0)
			inner = _offset(inner, icon_rect.position + Vector2(4, 4))
			var ring := Color(UIPalette.CYAN, 0.6) if selected else Color(UIPalette.GOLD, 0.27)
			draw_polyline(inner + PackedVector2Array([inner[0]]), ring, 0.6, true)
	IconDraw.draw_nav_icon(self, tab_id, icon_rect.grow(-5.0), _content_color(false))


func _offset(points: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(p + by)
	return out


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		tab_pressed.emit(tab_id)
	elif event is InputEventScreenTouch and not event.is_pressed():
		tab_pressed.emit(tab_id)
