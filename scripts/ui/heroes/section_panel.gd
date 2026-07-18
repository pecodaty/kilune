class_name SectionPanel
extends MarginContainer
## Gradient content panel with a Cinzel section title, an optional pill
## action, thin gold corner brackets, and a `body` VBox for content.
## Shared by the Heroes sub-tabs. Reference: App.tsx `SectionPanel`.

signal action_pressed

var body: VBoxContainer
var _stack: VBoxContainer


func setup(title_text: String, action_text := "", action_color := UIPalette.CYAN) -> void:
	if not is_node_ready():
		await ready
	var title_row := HBoxContainer.new()
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stack.add_child(title_row)
	_stack.move_child(title_row, 0)
	var title := UIFonts.make_label(title_text, UIFonts.cinzel_tracked(700, 1), 13, UIPalette.GOLD_MUTED)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	if not action_text.is_empty():
		var action := HeroPillBtn.new()
		action.mouse_filter = Control.MOUSE_FILTER_STOP
		action.setup(action_text, action_color)
		action.pressed.connect(func() -> void: action_pressed.emit())
		title_row.add_child(action)


func _ready() -> void:
	clip_contents = true
	add_theme_constant_override("margin_left", 12)
	add_theme_constant_override("margin_right", 12)
	add_theme_constant_override("margin_top", 12)
	add_theme_constant_override("margin_bottom", 16)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)
	_stack = stack
	body = VBoxContainer.new()
	body.add_theme_constant_override("separation", 0)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(body)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#0E0A28"), Color("#080418"))
	draw_rect(Rect2(Vector2.ZERO, size), Color(UIPalette.PURPLE_STRUCTURE, 0.33), false, 1.0)
	var c := Color(UIPalette.GOLD_MUTED, 0.45)
	var w := size.x
	var h := size.y
	for pts in [
		[Vector2(0.5, 14), Vector2(0.5, 0.5), Vector2(14, 0.5)],
		[Vector2(w - 14, 0.5), Vector2(w - 0.5, 0.5), Vector2(w - 0.5, 14)],
		[Vector2(0.5, h - 14), Vector2(0.5, h - 0.5), Vector2(14, h - 0.5)],
		[Vector2(w - 14, h - 0.5), Vector2(w - 0.5, h - 0.5), Vector2(w - 0.5, h - 14)],
	]:
		draw_polyline(PackedVector2Array(pts), c, 1.0, true)
