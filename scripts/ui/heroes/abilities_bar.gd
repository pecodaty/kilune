class_name AbilitiesBar
extends Control
## Full-width abilities entry (`Tier 0 · 8 Class Skills` + chevron).
## One interaction target that opens the class ability list.
## Spec: docs/art-direction/interface-heroes-screen.md, "Abilities Entry".

signal pressed

const HEIGHT := 34.0
const CLIP := 6.0

var _cls: Dictionary = HeroClassData.class_data(&"druid")


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP


func set_class(cls: Dictionary) -> void:
	_cls = cls
	queue_redraw()


func _draw() -> void:
	var color: Color = _cls["color"]
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	UIDraw.draw_poly_h_gradient(self, shape, size, [
		[0.0, Color(_cls["bg_tint"], 0.8)], [1.0, Color(UIPalette.HUD_TOP, 0.8)],
	])
	shape.append(shape[0])
	draw_polyline(shape, Color(color, 0.27), 1.0, true)
	var font := UIFonts.rajdhani_bold()
	var text: String = _cls["tier"]
	draw_string(font, Vector2(12.0, size.y * 0.5 + 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, color)
	# Right chevron.
	var cx := size.x - 14.0
	var cy := size.y * 0.5
	var chevron := Color(color, 0.7)
	draw_line(Vector2(cx - 3.0, cy - 5.0), Vector2(cx + 3.0, cy), chevron, 1.5, true)
	draw_line(Vector2(cx + 3.0, cy), Vector2(cx - 3.0, cy + 5.0), chevron, 1.5, true)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		pressed.emit()
	elif event is InputEventScreenTouch and not event.is_pressed():
		pressed.emit()
