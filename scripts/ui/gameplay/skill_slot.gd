class_name SkillSlot
extends Control
## Octagonal skill slot: rune icon, cooldown wipe, or locked state.

signal skill_pressed(slot_index: int)

@export var slot_index := 0
@export var rune_id: StringName = &"":
	set(v):
		rune_id = v
		queue_redraw()
@export var icon_texture: Texture2D:
	set(v):
		icon_texture = v
		queue_redraw()
@export var is_locked := false:
	set(v):
		is_locked = v
		queue_redraw()
@export var level_required := 0:
	set(v):
		level_required = v
		_refresh_lock_label()
@export_range(0.0, 1.0) var cooldown_fraction := 0.0:
	set(v):
		cooldown_fraction = clampf(v, 0.0, 1.0)
		queue_redraw()

const CUT := 12.0

var _lock_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(50.0, 50.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_lock_label = UIFonts.make_label("", UIFonts.rajdhani_bold(), 6, UIPalette.LOCK, HORIZONTAL_ALIGNMENT_CENTER)
	_lock_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_lock_label.offset_top = -12.0
	_lock_label.offset_bottom = -3.0
	add_child(_lock_label)
	_refresh_lock_label()


func _refresh_lock_label() -> void:
	if not is_node_ready():
		return
	_lock_label.visible = is_locked and level_required > 0
	_lock_label.text = "Lv.%d" % level_required


func _draw() -> void:
	var frame := UIDraw.octagon(size, CUT)
	if is_locked:
		UIDraw.draw_poly_diag(self, frame, size, [[0.0, UIPalette.SLOT_LOCKED_TOP], [1.0, UIPalette.SLOT_LOCKED_BOTTOM]])
		UIDraw.draw_outline_diag(self, frame, size, UIPalette.locked_border_stops(), 1.5)
		var inner := UIDraw.octagon(size - Vector2(10.0, 10.0), CUT - 7.0)
		inner = _offset_points(inner, Vector2(5.0, 5.0))
		draw_polyline(inner + PackedVector2Array([inner[0]]), Color(UIPalette.BORDER_DARK, 0.2), 0.8, true)
		for corner in [Vector2(13, 13), Vector2(37, 13), Vector2(37, 37), Vector2(13, 37)]:
			draw_circle(corner * size / 50.0, 2.0, Color(UIPalette.BORDER_DARK, 0.2))
		# Cross-hatch
		draw_line(Vector2(18, 18) * size / 50.0, Vector2(32, 32) * size / 50.0, Color(UIPalette.BORDER_DARK, 0.5), 0.5, true)
		draw_line(Vector2(32, 18) * size / 50.0, Vector2(18, 32) * size / 50.0, Color(UIPalette.BORDER_DARK, 0.5), 0.5, true)
		IconDraw.lock_icon(self, Rect2(Vector2(14, 12) * size / 50.0, Vector2(22, 22) * size / 50.0), UIPalette.LOCK)
		return

	# Active slot
	UIDraw.draw_poly_diag(self, frame, size, [[0.0, UIPalette.SLOT_BG_TOP], [1.0, UIPalette.SLOT_BG_BOTTOM]])
	UIDraw.draw_outline_diag(self, frame, size, UIPalette.gold_border_stops(), 1.5)
	var inner := UIDraw.octagon(size - Vector2(10.0, 10.0), CUT - 7.0)
	inner = _offset_points(inner, Vector2(5.0, 5.0))
	draw_polyline(inner + PackedVector2Array([inner[0]]), Color(UIPalette.CYAN, 0.45), 0.7, true)
	for corner in [Vector2(13, 13), Vector2(37, 13), Vector2(37, 37), Vector2(13, 37)]:
		draw_circle(corner * size / 50.0, 2.0, Color(UIPalette.GOLD, 0.9))
	# Shimmer
	draw_line(Vector2(12, 7) * size / 50.0, Vector2(19, 14) * size / 50.0, Color(1, 1, 1, 0.2), 0.7, true)

	var icon_rect := Rect2(Vector2(13, 13) * size / 50.0, Vector2(24, 24) * size / 50.0)
	if icon_texture != null:
		draw_texture_rect(icon_texture, icon_rect, false)
	elif rune_id != &"":
		IconDraw.draw_item_icon(self, rune_id, icon_rect, UIPalette.CYAN)

	# Cooldown wipe (radial, dark) — Godot-driven, never baked into art.
	if cooldown_fraction > 0.0:
		var center := size * 0.5
		var radius := size.x * 0.52
		var points := PackedVector2Array([center])
		var start := -PI / 2.0
		var end := start + TAU * cooldown_fraction
		var steps := 24
		for i in range(steps + 1):
			var a := start + (end - start) * float(i) / float(steps)
			points.append(center + Vector2(cos(a), sin(a)) * radius)
		draw_colored_polygon(points, Color(0.0, 0.0, 0.0, 0.55))


func _offset_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(p + offset)
	return out


func _gui_input(event: InputEvent) -> void:
	if is_locked:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_press_feedback()
		else:
			skill_pressed.emit(slot_index)
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			_press_feedback()
		else:
			skill_pressed.emit(slot_index)


func _press_feedback() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.91, 0.91), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
