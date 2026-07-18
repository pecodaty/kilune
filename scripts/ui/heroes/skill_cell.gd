class_name SkillCell
extends Control
## One skill entry in the two-column skill pool grid.
## Spec: docs/art-direction/interface-heroes-screen.md, "Skill Pool".

const HEIGHT := 26.0
const CLIP := 5.0

var _skill_name := ""
var _color := UIPalette.GOLD


func setup(skill_name: String, color: Color) -> void:
	_skill_name = skill_name
	_color = color
	if is_node_ready():
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	draw_colored_polygon(shape, UIPalette.HUD_TOP)
	shape.append(shape[0])
	draw_polyline(shape, Color(UIPalette.PURPLE_STRUCTURE, 0.33), 1.0, true)
	draw_circle(Vector2(12.0, size.y * 0.5), 4.0, Color(_color, 0.7))
	draw_string(UIFonts.rajdhani_semibold(), Vector2(22.0, size.y * 0.5 + 3.5), _skill_name,
		HORIZONTAL_ALIGNMENT_LEFT, size.x - 26.0, 9, Color("#9080B0"))
