class_name AutoButton
extends Control
## Octagonal auto-combat toggle with star icon and AUTO label.

signal toggled(active: bool)

@export var active := false:
	set(v):
		active = v
		_refresh_label()
		queue_redraw()

var _label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(44.0, 50.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_label = UIFonts.make_label("AUTO", UIFonts.cinzel_bold(), 7, UIPalette.INACTIVE, HORIZONTAL_ALIGNMENT_CENTER)
	_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_label.offset_top = -13.0
	_label.offset_bottom = -4.0
	add_child(_label)
	_refresh_label()


func _refresh_label() -> void:
	if not is_node_ready():
		return
	_label.add_theme_color_override("font_color", UIPalette.AUTO_GREEN if active else Color("#5A4080"))


func _draw() -> void:
	var frame := UIDraw.octagon(size, 9.0)
	var bg_stops: Array
	if active:
		bg_stops = [[0.0, Color("#0A2818")], [1.0, Color("#061510")]]
	else:
		bg_stops = [[0.0, Color("#0F0C25")], [1.0, Color("#080618")]]
	UIDraw.draw_poly_diag(self, frame, size, bg_stops)
	UIDraw.draw_outline_diag(self, frame, size, UIPalette.gold_border_stops(), 1.5)

	var inner := UIDraw.octagon(size - Vector2(8.0, 10.0), 6.0)
	var shifted := PackedVector2Array()
	for p in inner:
		shifted.append(p + Vector2(4.0, 5.0))
	var ring_color := Color(UIPalette.AUTO_GREEN, 0.6) if active else Color(UIPalette.PURPLE_STRUCTURE, 0.35)
	draw_polyline(shifted + PackedVector2Array([shifted[0]]), ring_color, 0.7, true)

	# Shimmer
	draw_line(Vector2(11, 7) * size / Vector2(44, 50), Vector2(17, 13) * size / Vector2(44, 50), Color(1, 1, 1, 0.18), 0.6, true)

	var icon_color := UIPalette.AUTO_GREEN if active else Color("#5A4080")
	IconDraw.auto_star_icon(self, Rect2(Vector2(15, 8) * size / Vector2(44, 50), Vector2(14, 14) * size / Vector2(44, 50)), icon_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_press_feedback()
		else:
			_toggle()
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			_press_feedback()
		else:
			_toggle()


func _toggle() -> void:
	active = not active
	toggled.emit(active)


func _press_feedback() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.91, 0.91), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
