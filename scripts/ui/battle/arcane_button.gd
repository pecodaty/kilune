class_name ArcaneButton
extends Button
## Clipped-corner button used by the Battle and Dungeon flow.

@export var fill_top := Color("#0D0828")
@export var fill_bottom := Color("#080420")
@export var border_color := Color("#4422AA66")
@export var cut := 6.0


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(queue_redraw)


func _draw() -> void:
	var points := UIDraw.clipped_rect(size, cut, 0.0, cut, 0.0)
	UIDraw.draw_poly_diag(self, points, size, [[0.0, fill_top], [1.0, fill_bottom]])
	var outline := points.duplicate()
	outline.append(points[0])
	for i in range(outline.size() - 1):
		draw_line(outline[i], outline[i + 1], border_color, 1.0, true)
	if button_pressed:
		draw_colored_polygon(points, Color(0.0, 0.0, 0.0, 0.18))
	if not text.is_empty():
		var font := get_theme_font("font")
		var font_size := get_theme_font_size("font_size")
		var color := get_theme_color("font_disabled_color" if disabled else "font_color")
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var baseline := Vector2(
			(size.x - text_size.x) * 0.5,
			(size.y - text_size.y) * 0.5 + font.get_ascent(font_size)
		)
		draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
