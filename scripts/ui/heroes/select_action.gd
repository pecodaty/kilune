class_name SelectAction
extends Control
## Primary select/current-class action. Cyan `SELECT CLASS` equips the browsed
## class; a class-colored `CURRENT CLASS` is inert.
## Spec: docs/art-direction/interface-heroes-screen.md, "Select/Current Action".

signal pressed

const HEIGHT := 40.0
const CLIP := 8.0

var _cls: Dictionary = HeroClassData.class_data(&"druid")
var _is_current := false


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_state(cls: Dictionary, is_current: bool) -> void:
	_cls = cls
	_is_current = is_current
	queue_redraw()


func _draw() -> void:
	var accent: Color = _cls["color"] if _is_current else UIPalette.CYAN
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	# Restrained matching glow behind the bar.
	draw_set_transform(size * 0.5, 0.0, Vector2(1.03, 1.25))
	var glow_shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	for i in range(glow_shape.size()):
		glow_shape[i] -= size * 0.5
	draw_colored_polygon(glow_shape, Color(accent, 0.12))
	draw_set_transform(Vector2.ZERO)
	UIDraw.draw_poly_h_gradient(self, shape, size, _bg_stops())
	shape.append(shape[0])
	draw_polyline(shape, accent, 1.5, true)
	# Label between two diamond markers.
	var label := "CURRENT CLASS" if _is_current else "SELECT CLASS"
	var font := UIFonts.cinzel_tracked(700, 1)
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)
	var gap := 10.0
	var total := 5.0 + gap + text_size.x + gap + 5.0
	var x := (size.x - total) * 0.5
	var cy := size.y * 0.5
	draw_colored_polygon(UIDraw.diamond(Vector2(x + 2.5, cy), 2.5, 2.5), accent)
	draw_string(font, Vector2(x + 5.0 + gap, cy + 4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, accent)
	draw_colored_polygon(UIDraw.diamond(Vector2(x + total - 2.5, cy), 2.5, 2.5), accent)


func _bg_stops() -> Array:
	if _is_current:
		return [[0.0, _cls["bg_tint"]], [0.5, Color("#0D1535")], [1.0, _cls["bg_tint"]]]
	return [[0.0, Color("#0A1535")], [0.5, Color("#0D1A40")], [1.0, Color("#0A1535")]]


func _gui_input(event: InputEvent) -> void:
	if _is_current:
		return # Never perform a redundant class change.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		pressed.emit()
	elif event is InputEventScreenTouch and not event.is_pressed():
		pressed.emit()
