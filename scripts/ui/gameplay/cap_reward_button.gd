class_name CapRewardButton
extends Control
## Cap reward shortcut with pulsing gift icon (top-right of the HUD).

signal rewards_open_requested()

@export var pulse_enabled := true:
	set(v):
		pulse_enabled = v
		_update_pulse()

var _gift_color := UIPalette.GOLD
var _pulse_tween: Tween


func _ready() -> void:
	custom_minimum_size = Vector2(48.0, 30.0)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 21.0
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	vbox.add_child(UIFonts.make_label("Cap.", UIFonts.cinzel_bold(), 6, UIPalette.GOLD_MUTED))
	vbox.add_child(UIFonts.make_label("Reward", UIFonts.cinzel_bold(), 6, UIPalette.GOLD))

	_update_pulse()


func _update_pulse() -> void:
	if not is_node_ready():
		return
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	if pulse_enabled:
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(self, "_gift_color", UIPalette.GOLD_MUTED, 0.9)
		_pulse_tween.tween_property(self, "_gift_color", UIPalette.GOLD, 0.9)
		_pulse_tween.tween_interval(0.4)
		_pulse_tween.tween_callback(queue_redraw)


func _process(_delta: float) -> void:
	if pulse_enabled:
		queue_redraw()


func _draw() -> void:
	var frame := UIDraw.octagon(size, 7.0)
	draw_colored_polygon(frame, UIPalette.DEEP_PANEL)
	UIDraw.draw_outline_diag(self, frame, size, UIPalette.gold_border_stops(), 1.2)
	IconDraw.gift_icon(self, Rect2(Vector2(3.0, 6.0), Vector2(18.0, 18.0)), _gift_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_press_feedback()
		else:
			rewards_open_requested.emit()
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			_press_feedback()
		else:
			rewards_open_requested.emit()


func _press_feedback() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(self, "scale", Vector2.ONE, 0.08)
