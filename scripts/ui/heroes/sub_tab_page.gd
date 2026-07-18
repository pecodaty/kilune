class_name SubTabPage
extends ScrollContainer
## Base for the scrollable Heroes sub-tab pages: hidden scrollbar, 4px outer
## margins, and one SectionPanel that fills the visible height even when the
## content is short. Subclasses override `_build()`.

var panel: SectionPanel


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var sb := get_v_scroll_bar()
	sb.custom_minimum_size.x = 0 # Hide the visible scrollbar.
	sb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var outer := MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("margin_left", 4)
	outer.add_theme_constant_override("margin_right", 4)
	outer.add_theme_constant_override("margin_top", 4)
	outer.add_theme_constant_override("margin_bottom", 0)
	add_child(outer)

	panel = SectionPanel.new()
	outer.add_child(panel)
	# Keep the panel surface filling the visible area even when content is short.
	resized.connect(func() -> void: outer.custom_minimum_size.y = size.y)
	_build()


## Pages sit on the bare canvas behind their panel (visible in gaps and on
## panel-less pages such as Pets).
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIPalette.CANVAS)


## Override: set the panel title and add content to `panel.body`.
func _build() -> void:
	pass


func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _section_label(text: String) -> Label:
	return UIFonts.make_label(text, UIFonts.cinzel_bold(), 9, UIPalette.TEXT_LAVENDER_DIM)
