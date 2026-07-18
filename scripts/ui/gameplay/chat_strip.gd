class_name ChatStrip
extends Control
## Slim chat feed: icon, gold channel prefix, latest message, Chat entry.

signal chat_open_requested()

@export var channel := "World":
	set(v):
		channel = v
		_refresh()
@export var sender := "SilverArrow":
	set(v):
		sender = v
		_refresh()
@export var message := "Forest Path 2 is wild tonight":
	set(v):
		message = v
		_refresh()

var _channel_label: Label
var _message_label: Label
var _open_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 26.0)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 28.0
	row.offset_right = -10.0
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	_channel_label = UIFonts.make_label("", UIFonts.rajdhani_bold(), 9, UIPalette.GOLD_MUTED)
	row.add_child(_channel_label)

	_message_label = UIFonts.make_label("", UIFonts.rajdhani_medium(), 9, UIPalette.TEXT_CHAT)
	_message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_message_label.clip_text = true
	row.add_child(_message_label)

	_open_label = UIFonts.make_label("Chat ▸", UIFonts.rajdhani_bold(), 8, UIPalette.GOLD_MUTED, HORIZONTAL_ALIGNMENT_RIGHT)
	row.add_child(_open_label)
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	_channel_label.text = "[%s]" % channel
	_message_label.text = "%s: %s" % [sender, message]


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#070315", 0.45))
	draw_line(Vector2(0, 0.5), Vector2(size.x, 0.5), Color(UIPalette.BORDER_DARK, 0.5), 0.8)
	draw_line(Vector2(0, size.y - 0.5), Vector2(size.x, size.y - 0.5), Color("#1A1030", 0.5), 0.8)
	IconDraw.chat_icon(self, Rect2(Vector2(7, 5), Vector2(16, 16)), UIPalette.TEXT_CHAT)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		chat_open_requested.emit()
	elif event is InputEventScreenTouch and not event.is_pressed():
		chat_open_requested.emit()
