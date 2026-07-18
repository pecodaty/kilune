class_name PortraitArch
extends Control
## Fixed-height selected-class portrait region: ambient class tint, thin gold
## gothic arch, central class emblem, and a class-name watermark.
## Arch geometry ported 1:1 from references/reference-code/src/app/App.tsx.
## Spec: docs/art-direction/interface-heroes-screen.md, "Portrait Arch".

const ARCH_SIZE := Vector2(302.0, 220.0)
const EMBLEM_CENTER := Vector2(151.0, 112.0)
const EMBLEM_SIZE := 90.0

var _cls: Dictionary = HeroClassData.class_data(&"druid")
var _watermark: Label


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, ARCH_SIZE.y)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_watermark = UIFonts.make_label("", UIFonts.cinzel_tracked(900, 3), 11, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_watermark.set_anchors_preset(Control.PRESET_TOP_WIDE)
	add_child(_watermark)
	resized.connect(_layout_watermark)
	set_class(HeroClassData.class_data(&"druid"))


func set_class(cls: Dictionary) -> void:
	_cls = cls
	if is_node_ready():
		_watermark.text = String(cls["name"]).to_upper()
		_watermark.add_theme_color_override("font_color", Color(cls["color"], 0.35))
		_layout_watermark()
	queue_redraw()


func _arch_scale() -> float:
	return minf(size.x / ARCH_SIZE.x, size.y / ARCH_SIZE.y)


func _arch_origin() -> Vector2:
	var s := _arch_scale()
	return (size - ARCH_SIZE * s) * 0.5


func _a(p: Vector2) -> Vector2:
	return _arch_origin() + p * _arch_scale()


func _layout_watermark() -> void:
	var y := _arch_origin().y + 188.0 * _arch_scale()
	_watermark.offset_top = y
	_watermark.offset_bottom = y + 20.0


func _outer_arch() -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2(24, 215), Vector2(24, 100)])
	var curve := UIDraw.flatten_quadratic_chain(Vector2(24, 100), [
		[Vector2(24, 18), Vector2(151, 10)],
		[Vector2(278, 18), Vector2(278, 100)],
	], 14)
	for i in range(1, curve.size()):
		pts.append(curve[i])
	pts.append(Vector2(278, 215))
	return pts


func _inner_arch() -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2(38, 215), Vector2(38, 105)])
	var curve := UIDraw.flatten_quadratic_chain(Vector2(38, 105), [
		[Vector2(38, 32), Vector2(151, 26)],
		[Vector2(264, 32), Vector2(264, 105)],
	], 14)
	for i in range(1, curve.size()):
		pts.append(curve[i])
	pts.append(Vector2(264, 215))
	return pts


func _draw() -> void:
	var color: Color = _cls["color"]
	# Base + soft class-tinted radial gradient (ellipse 70%x80% at 50%/60%).
	draw_rect(Rect2(Vector2.ZERO, size), UIPalette.CANVAS)
	var center := Vector2(size.x * 0.5, size.y * 0.6)
	var rx := size.x * 0.35
	var ry := size.y * 0.4
	for i in range(10, 0, -1):
		var f := float(i) / 10.0
		var c := UIPalette.CANVAS.lerp(_cls["bg_tint"], clampf((0.75 - f) / 0.75, 0.0, 1.0))
		draw_set_transform(center, 0.0, Vector2(rx * f, ry * f))
		draw_circle(Vector2.ZERO, 1.0, c)
	draw_set_transform(Vector2.ZERO)

	var s := _arch_scale()
	# Outer arch: vertical class wash fill + diagonal gold stroke.
	var outer := _outer_arch()
	var outer_xf := _xf(outer)
	var fill_colors := PackedColorArray()
	for p in outer:
		var t := clampf((p.y - 10.0) / 205.0, 0.0, 1.0)
		fill_colors.append(Color(color, lerpf(0.12, 0.03, t)))
	draw_polygon(outer_xf, fill_colors)
	UIDraw.draw_outline_diag(self, outer_xf + PackedVector2Array([outer_xf[0]]), size, UIPalette.gold_border_stops(), 1.5)
	# Inner arch.
	draw_polyline(_xf(_inner_arch()), Color(color, 0.35), 0.8, true)

	# Base glow pool + base line.
	for i in range(6, 0, -1):
		var f := float(i) / 6.0
		draw_set_transform(_a(Vector2(151, 212)), 0.0, Vector2(100.0 * s * f, 16.0 * s * f))
		draw_circle(Vector2.ZERO, 1.0, Color(color, 0.35 * (1.0 - f)))
	draw_set_transform(Vector2.ZERO)
	draw_line(_a(Vector2(24, 212)), _a(Vector2(278, 212)), Color(color, 0.3), 0.8, true)

	# Nodes: gold base corners, class spring points, gold apex gem.
	draw_circle(_a(Vector2(24, 215)), 3.5 * s, Color(UIPalette.GOLD, 0.6))
	draw_circle(_a(Vector2(278, 215)), 3.5 * s, Color(UIPalette.GOLD, 0.6))
	draw_circle(_a(Vector2(24, 100)), 2.5 * s, Color(color, 0.5))
	draw_circle(_a(Vector2(278, 100)), 2.5 * s, Color(color, 0.5))
	draw_colored_polygon(PackedVector2Array([
		_a(Vector2(151, 8)), _a(Vector2(155, 14)), _a(Vector2(151, 11)), _a(Vector2(147, 14)),
	]), Color(UIPalette.GOLD, 0.8))
	# Nine subtle side ticks per side.
	for y in range(40, 201, 20):
		draw_line(_a(Vector2(30, y)), _a(Vector2(34, y)), Color(UIPalette.GOLD, 0.3), 0.5)
		draw_line(_a(Vector2(268, y)), _a(Vector2(272, y)), Color(UIPalette.GOLD, 0.3), 0.5)

	# Central emblem.
	var emblem_rect := Rect2(_a(EMBLEM_CENTER - Vector2(EMBLEM_SIZE, EMBLEM_SIZE) * 0.5), Vector2(EMBLEM_SIZE, EMBLEM_SIZE) * s)
	ClassRunes.draw_emblem(self, _cls["id"], emblem_rect, color)


func _xf(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in points:
		out.append(_a(p))
	return out
