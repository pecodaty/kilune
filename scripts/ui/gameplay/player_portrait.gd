class_name PlayerPortrait
extends Control
## Clipped-corner portrait medallion with class glow ring and level badge.

@export var portrait_texture: Texture2D:
	set(v):
		portrait_texture = v
		_apply_texture()
@export var level := 1:
	set(v):
		level = v
		_refresh_badge()

const CUT := 12.0

var _portrait: TextureRect
var _badge_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(52.0, 52.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false

	_portrait = TextureRect.new()
	_portrait.set_anchors_preset(Control.PRESET_FULL_RECT)
	_portrait.offset_left = 3.0
	_portrait.offset_top = 3.0
	_portrait.offset_right = -3.0
	_portrait.offset_bottom = -3.0
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader_material := ShaderMaterial.new()
	shader_material.shader = load("res://assets/ui/shaders/octagon_clip.gdshader")
	_portrait.material = shader_material
	add_child(_portrait)
	_apply_texture()

	_badge_label = UIFonts.make_label("", UIFonts.rajdhani_bold(), 7, UIPalette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_badge_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_badge_label.anchor_left = 0.5
	_badge_label.anchor_right = 0.5
	_badge_label.offset_top = -3.0
	_badge_label.offset_bottom = 9.0
	_badge_label.offset_left = -20.0
	_badge_label.offset_right = 20.0
	add_child(_badge_label)
	_refresh_badge()


func _apply_texture() -> void:
	if is_node_ready():
		_portrait.texture = portrait_texture


func _refresh_badge() -> void:
	if is_node_ready():
		_badge_label.text = "Lv.%d" % level


func _draw() -> void:
	var frame := UIDraw.octagon(size, CUT)
	# Class glow ring (outer, purple, soft)
	draw_polyline(frame + PackedVector2Array([frame[0]]), Color(UIPalette.CLASS_GLOW, 0.28), 3.0, true)
	# Medallion fill + gold gradient border
	draw_colored_polygon(frame, Color("#1A0A3A"))
	UIDraw.draw_outline_diag(self, frame, size, UIPalette.gold_border_stops(), 1.5)

	# Level badge (slanted trapezoid under the frame)
	var bw := 34.0
	var bh := 12.0
	var bx := (size.x - bw) * 0.5
	var by := size.y - 2.0
	var badge := PackedVector2Array([
		Vector2(bx + 4.0, by), Vector2(bx + bw - 4.0, by),
		Vector2(bx + bw, by + bh), Vector2(bx, by + bh),
	])
	draw_colored_polygon(badge, UIPalette.DEEP_PANEL)
	draw_polyline(badge + PackedVector2Array([badge[0]]), Color(UIPalette.GOLD_MUTED, 0.6), 0.7, true)
