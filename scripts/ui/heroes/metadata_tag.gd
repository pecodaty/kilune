class_name MetadataTag
extends Control
## Small parallelogram tag under the class title (`Weapon: X` / `Role: Y`).
## Spec: docs/art-direction/interface-heroes-screen.md, "Metadata Tags".

const CLIP := 4.0
const PAD_X := 8.0

var _text := ""
var _text_color := UIPalette.TEXT_LAVENDER
var _surface := Color(UIPalette.BORDER_DARK, 0.67)
var _border := Color(UIPalette.PURPLE_STRUCTURE, 0.47)


## style is &"weapon" or &"role".
func setup(text: String, style: StringName, cls: Dictionary) -> void:
	_text = text
	if style == &"role":
		_text_color = cls["color"]
		_surface = Color(cls["bg_tint"], 0.8)
		_border = Color(cls["color"], 0.27)
	if is_node_ready():
		_apply()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply()


func _apply() -> void:
	var text_size := UIFonts.rajdhani_bold().get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8)
	custom_minimum_size = Vector2(text_size.x + PAD_X * 2.0 + CLIP, text_size.y + 4.0)
	queue_redraw()


func _draw() -> void:
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	draw_colored_polygon(shape, _surface)
	shape.append(shape[0])
	draw_polyline(shape, _border, 1.0, true)
	var text_size := UIFonts.rajdhani_bold().get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8)
	var pos := Vector2((size.x - text_size.x) * 0.5, (size.y - text_size.y) * 0.5 + text_size.y * 0.8)
	draw_string(UIFonts.rajdhani_bold(), pos, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, _text_color)
