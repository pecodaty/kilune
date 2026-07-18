class_name StagePlaque
extends Control
## Central stage badge hanging below the HUD: ★ 2F · Forest Path 2 ★

@export var stage_name := "2F · Forest Path 2":
	set(v):
		stage_name = v
		_refresh()

var _label: Label

const PAD_X := 14.0
const STAR_GAP := 16.0


func _ready() -> void:
	custom_minimum_size = Vector2(120.0, 18.0)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label = UIFonts.make_label(stage_name, UIFonts.rajdhani_bold(), 9, UIPalette.TEXT_LAVENDER, HORIZONTAL_ALIGNMENT_CENTER)
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_label)
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	_label.text = stage_name
	var text_width := _label.get_theme_font("font").get_string_size(
		stage_name, HORIZONTAL_ALIGNMENT_LEFT, -1, _label.get_theme_font_size("font_size")).x
	custom_minimum_size.x = text_width + PAD_X * 2.0 + STAR_GAP * 2.0
	queue_redraw()


func _draw() -> void:
	# Inverted trapezoid: narrower at top, hangs from the HUD edge
	var slant := 8.0
	var plaque := PackedVector2Array([
		Vector2(slant, 0.0), Vector2(size.x - slant, 0.0),
		Vector2(size.x, size.y), Vector2(0.0, size.y),
	])
	draw_colored_polygon(plaque, Color(UIPalette.DEEP_PANEL, 0.8))
	# Border (no top edge — hangs from the HUD)
	draw_line(plaque[0], plaque[3], Color(UIPalette.PURPLE_STRUCTURE, 0.4), 1.0, true)
	draw_line(plaque[3], plaque[2], Color(UIPalette.PURPLE_STRUCTURE, 0.4), 1.0, true)
	draw_line(plaque[2], plaque[1], Color(UIPalette.PURPLE_STRUCTURE, 0.4), 1.0, true)
	# Flanking stars
	var cy := size.y * 0.5
	draw_colored_polygon(UIDraw.star(Vector2(PAD_X, cy), 4.5, 1.9), UIPalette.GOLD)
	draw_colored_polygon(UIDraw.star(Vector2(size.x - PAD_X, cy), 4.5, 1.9), UIPalette.GOLD)
