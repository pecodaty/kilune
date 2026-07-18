class_name MapButton
extends Control
## Small map shortcut button (top-right of the HUD).

signal map_open_requested()

func _ready() -> void:
	custom_minimum_size = Vector2(48.0, 22.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var label := UIFonts.make_label("MAP", UIFonts.rajdhani_bold(), 7, UIPalette.TEXT_MUTED)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 17.0
	add_child(label)


func _draw() -> void:
	var rect := Rect2(Vector2(0.5, 0.5), size - Vector2(1.0, 1.0))
	draw_rect(rect, UIPalette.DEEP_PANEL, true)
	draw_rect(rect, Color(UIPalette.PURPLE_STRUCTURE, 0.6), false, 1.0)
	# Gold corner accents
	draw_line(Vector2(1.0, 1.0), Vector2(6.0, 6.0), Color(UIPalette.GOLD_MUTED, 0.45), 0.8, true)
	draw_line(Vector2(size.x - 1.0, 1.0), Vector2(size.x - 6.0, 6.0), Color(UIPalette.GOLD_MUTED, 0.45), 0.8, true)
	IconDraw.map_pin_icon(self, Rect2(Vector2(6.0, 5.0), Vector2(12.0, 12.0)), UIPalette.TEXT_MUTED)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_press_feedback()
		else:
			map_open_requested.emit()
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			_press_feedback()
		else:
			map_open_requested.emit()


func _press_feedback() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
