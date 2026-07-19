class_name DungeonFrame
extends Control
## Shared full-panel dungeon ornament, header, and background.

@export var title := "DUNGEONS":
	set(v):
		title = v
		_refresh()
@export var subtitle := "":
	set(v):
		subtitle = v
		_refresh()

var _title_label: Label
var _subtitle_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label = UIFonts.make_label(title, UIFonts.cinzel_tracked(700, 1), 15, Color("#D0C0F0"))
	_title_label.position = Vector2(30, 57)
	_title_label.size = Vector2(size.x - 120, 22)
	add_child(_title_label)
	_subtitle_label = UIFonts.make_label(subtitle, UIFonts.rajdhani_semibold(), 9, Color("#5A4888"))
	_subtitle_label.position = Vector2(30, 75)
	_subtitle_label.size = Vector2(size.x - 120, 16)
	add_child(_subtitle_label)
	resized.connect(_layout)
	_layout()


func content_rect() -> Rect2:
	return Rect2(14.0, 102.0, size.x - 28.0, maxf(0.0, size.y - 146.0))


func _refresh() -> void:
	if not is_node_ready():
		return
	_title_label.text = title
	_subtitle_label.text = subtitle
	_subtitle_label.visible = not subtitle.is_empty()


func _layout() -> void:
	if not is_node_ready():
		return
	_title_label.size.x = size.x - 120.0
	_subtitle_label.size.x = size.x - 120.0
	queue_redraw()


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#04021A"), Color("#08042E"))
	# Side rails.
	draw_line(Vector2(14, 32), Vector2(14, size.y - 24), Color("#00BCD4", 0.3), 1.0)
	draw_line(Vector2(size.x - 14, 32), Vector2(size.x - 14, size.y - 24), Color("#00BCD4", 0.3), 1.0)
	# Top crystal and bowed lines.
	var top_center := Vector2(size.x * 0.5, 14)
	draw_colored_polygon(UIDraw.diamond(top_center, 8, 13), Color("#3311AA"))
	var top_diamond := UIDraw.diamond(top_center, 8, 13)
	for i in range(4):
		draw_line(top_diamond[i], top_diamond[(i + 1) % 4], Color("#00E5C8", 0.85), 1.2, true)
	var left := UIDraw.flatten_quadratic_chain(top_center - Vector2(8, 0), [
		[Vector2(size.x * 0.39, 14), Vector2(size.x * 0.33, 24)],
		[Vector2(size.x * 0.22, 36), Vector2(14, 32)],
	], 12)
	var right := PackedVector2Array()
	for i in range(left.size() - 1, -1, -1):
		right.append(Vector2(size.x - left[i].x, left[i].y))
	for curve in [left, right]:
		for i in range(curve.size() - 1):
			draw_line(curve[i], curve[i + 1], Color("#00BCD4", 0.55), 1.2, true)
	# Header band and cyan title marker.
	draw_rect(Rect2(0, 54, size.x, 42), Color("#0A0628", 0.78))
	draw_line(Vector2(0, 54), Vector2(size.x, 54), Color("#2A18AA", 0.2), 1.0)
	draw_line(Vector2(0, 96), Vector2(size.x, 96), Color("#2A18AA", 0.2), 1.0)
	UIDraw.draw_v_gradient_rect(self, Rect2(16, 64, 3, 22), UIPalette.CYAN, Color("#4422AA"))
	# Bottom ornament.
	var bottom_y := size.y - 20.0
	var bottom := UIDraw.flatten_quadratic_chain(Vector2(14, bottom_y - 8), [
		[Vector2(size.x * 0.34, bottom_y - 8), Vector2(size.x * 0.5, bottom_y + 10)],
		[Vector2(size.x * 0.66, bottom_y - 8), Vector2(size.x - 14, bottom_y - 8)],
	], 16)
	for i in range(bottom.size() - 1):
		draw_line(bottom[i], bottom[i + 1], Color("#00BCD4", 0.4), 1.1, true)
	draw_colored_polygon(UIDraw.diamond(Vector2(size.x * 0.5, bottom_y + 6), 7, 12), Color("#3311AA"))

