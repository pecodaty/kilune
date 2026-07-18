class_name ClassTab
extends Control
## One class entry in the Heroes rail. Browsed (details shown) and current
## (equipped) are independent states; only current shows the gold marker.
## Spec: docs/art-direction/interface-heroes-screen.md, "Class Rail".

signal pressed(class_id: StringName)

@export var class_id: StringName = &"druid":
	set(v):
		class_id = v
		_cls = HeroClassData.class_data(class_id)
		_refresh()
@export var browsed := false:
	set(v):
		browsed = v
		_refresh()
@export var is_current := false:
	set(v):
		is_current = v
		_refresh()

var _cls: Dictionary = HeroClassData.class_data(&"druid")
var _name_label: Label
var _current_label: Label

const HEIGHT := 52.0
const CLIP := 8.0
const PAD_X := 10.0
const ICON := 18.0
const ICON_GAP := 8.0


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", int(PAD_X + ICON + ICON_GAP))
	margin.add_theme_constant_override("margin_right", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 2)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(stack)

	_name_label = UIFonts.make_label(_cls["name"], UIFonts.cinzel(600), 10, Color("#5A4080"))
	stack.add_child(_name_label)

	_current_label = UIFonts.make_label("CURRENT", UIFonts.rajdhani_bold(), 7, UIPalette.GOLD)
	stack.add_child(_current_label)
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	_name_label.text = _cls["name"]
	_name_label.add_theme_font_override("font", UIFonts.cinzel(700 if browsed else 600))
	_name_label.add_theme_color_override("font_color", _cls["color"] if browsed else Color("#5A4080"))
	_current_label.visible = is_current
	queue_redraw()


func _draw() -> void:
	var color: Color = _cls["color"]
	var shape := UIDraw.clipped_rect(size, 0.0, CLIP, CLIP, 0.0)
	if browsed:
		# Restrained class glow behind the tab.
		draw_set_transform(Vector2(size.x * 0.5, size.y * 0.5), 0.0, Vector2(1.1, 1.15))
		draw_colored_polygon(_offset(shape, size * -0.5), Color(color, 0.08))
		draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(shape, Color(_cls["bg_tint"], 0.87) if browsed else Color(UIPalette.HUD_TOP, 0.67))
	var border := Color(color, 0.4) if browsed else Color(UIPalette.PURPLE_STRUCTURE, 0.27)
	shape.append(shape[0])
	draw_polyline(shape, border, 1.0, true)
	# Left accent bar, inset 6px vertically.
	var accent := color if browsed else Color(UIPalette.PURPLE_STRUCTURE, 0.3)
	draw_rect(Rect2(0.0, 6.0, 3.0, size.y - 12.0), accent)
	if browsed:
		# One-pixel shimmer across the upper interior.
		UIDraw.draw_h_gradient_line(self, 0.5, size.x - 24.0, [
			[0.0, Color(color, 0.0)], [0.5, Color(color, 0.27)], [1.0, Color(color, 0.0)],
		], 1.0, 12)
	ClassRunes.draw_rune(self, class_id, Rect2(PAD_X, (size.y - ICON) * 0.5, ICON, ICON),
		color if browsed else Color(color, 0.45))


func _offset(points: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(p + by)
	return out


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		pressed.emit(class_id)
	elif event is InputEventScreenTouch and not event.is_pressed():
		pressed.emit(class_id)
