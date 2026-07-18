class_name HeroPillBtn
extends Control
## Small corner-cut pill action used by Heroes section headers and empty
## states (`Forge`, `Reset Talents`, `Visit Stables`, header pills).
## Reference: App.tsx `HeroPillBtn`.

signal pressed

const CLIP := 5.0

var _text := ""
var _color := UIPalette.CYAN
var _height := 26.0
var _chevron := false
var _font_size := 9


func setup(text: String, color: Color, height := 26.0, chevron := false, font_size := 9) -> void:
	_text = text
	_color = color
	_height = height
	_chevron = chevron
	_font_size = font_size
	if is_node_ready():
		_measure()
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_measure()


func _measure() -> void:
	var font := UIFonts.rajdhani_bold()
	var w := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size).x + 18.0
	if _chevron:
		w += 10.0
	custom_minimum_size = Vector2(w, _height)
	size = custom_minimum_size


func _draw() -> void:
	var shape := UIDraw.clipped_rect(size, CLIP, 0.0, CLIP, 0.0)
	draw_colored_polygon(shape, Color("#0A0820"))
	shape.append(shape[0])
	draw_polyline(shape, Color(_color, 0.33), 1.0, true)
	var font := UIFonts.rajdhani_bold()
	var text_size := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size)
	var x := (size.x - text_size.x - (10.0 if _chevron else 0.0)) * 0.5
	draw_string(font, Vector2(x, size.y * 0.5 + text_size.y * 0.35), _text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, _color)
	if _chevron:
		IconDraw.chevron_down(self, Rect2(x + text_size.x + 4.0, size.y * 0.5 - 4.0, 8.0, 8.0),
			UIPalette.TEXT_CHAT)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		pressed.emit()
	elif event is InputEventScreenTouch and not event.is_pressed():
		pressed.emit()
