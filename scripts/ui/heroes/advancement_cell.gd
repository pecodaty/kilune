class_name AdvancementCell
extends Control
## One subdued future-path entry. Intentionally low contrast to communicate
## unavailable progression. Spec: docs/art-direction/
## interface-heroes-screen.md, "Future Paths".

const HEIGHT := 28.0
const CLIP := 6.0

var _path_name := ""


func setup(path_name: String) -> void:
	_path_name = path_name
	if is_node_ready():
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	draw_colored_polygon(shape, Color("#0A0720"))
	shape.append(shape[0])
	draw_polyline(shape, Color(UIPalette.PURPLE_STRUCTURE, 0.47), 1.0, true)
	var font := UIFonts.rajdhani_bold()
	var text_size := font.get_string_size(_path_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 8)
	draw_string(font, Vector2((size.x - text_size.x) * 0.5, size.y * 0.5 + 3.0), _path_name,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 8, UIPalette.TEXT_CHAT)
