class_name StatBar
extends HBoxContainer
## Label + slanted bar + numeric readout, e.g. "HP [====>-] 69/158".

@export var label_text := "HP":
	set(v):
		label_text = v
		_refresh()
@export var value := 69.0:
	set(v):
		value = v
		_refresh()
@export var max_value := 158.0:
	set(v):
		max_value = v
		_refresh()
@export var bar_color := UIPalette.HP:
	set(v):
		bar_color = v
		_refresh()

const BAR_SCENE := preload("res://scenes/ui/common/slanted_progress_bar.tscn")

var _label: Label
var _bar: SlantedProgressBar
var _value_label: Label


func _ready() -> void:
	add_theme_constant_override("separation", 5)
	_label = UIFonts.make_label(label_text, UIFonts.rajdhani_bold(), 8, bar_color)
	_label.custom_minimum_size = Vector2(14.0, 0.0)
	add_child(_label)

	_bar = BAR_SCENE.instantiate()
	_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_bar)

	_value_label = UIFonts.make_label("", UIFonts.rajdhani_semibold(), 8, UIPalette.TEXT_LAVENDER_DIM, HORIZONTAL_ALIGNMENT_RIGHT)
	_value_label.custom_minimum_size = Vector2(32.0, 0.0)
	add_child(_value_label)
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	_label.text = label_text
	_label.add_theme_color_override("font_color", bar_color)
	_bar.value = value
	_bar.max_value = max_value
	_bar.fill_color = bar_color
	_value_label.text = "%d/%d" % [int(value), int(max_value)]
