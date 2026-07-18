class_name FloatingText
extends Control
## Floating combat number: rises, fades, then frees itself.

var _label: Label


static func spawn(parent: Node, text: String, color: Color, at_position: Vector2) -> FloatingText:
	var instance := FloatingText.new()
	parent.add_child(instance)
	instance.setup(text, color, at_position)
	return instance


func setup(text: String, color: Color, at_position: Vector2) -> void:
	position = at_position
	_label = UIFonts.make_label(text, UIFonts.rajdhani_bold(), 11, color, HORIZONTAL_ALIGNMENT_CENTER)
	_label.custom_minimum_size = Vector2(60.0, 14.0)
	_label.position = Vector2(-30.0, -7.0)
	_label.add_theme_color_override("font_outline_color", Color("#000000", 0.6))
	_label.add_theme_constant_override("outline_size", 2)
	add_child(_label)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 34.0, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 1.2).set_delay(0.35)
	tween.chain().tween_callback(queue_free)
