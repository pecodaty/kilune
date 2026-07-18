class_name ClassInfoPanel
extends ScrollContainer
## Scrollable class information panel below the portrait arch. Only this
## panel scrolls; the scrollbar is hidden. Rebuilds its sections from the
## browsed class data. Spec: docs/art-direction/
## interface-heroes-screen.md, "Class Information Panel".

signal abilities_pressed
signal class_selected

const OUTER_MARGIN := 4

var _cls: Dictionary = HeroClassData.class_data(&"druid")
var _is_current := false
var _sections: VBoxContainer
var _action: SelectAction


## Panel surface: gradient, 1px border, thin gold corner brackets.
class InfoBody extends MarginContainer:
	func _draw() -> void:
		UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#0E0A28"), Color("#080418"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(UIPalette.PURPLE_STRUCTURE, 0.33), false, 1.0)
		var c := Color(UIPalette.GOLD_MUTED, 0.5)
		var w := size.x
		var h := size.y
		for pts in [
			[Vector2(0.5, 12), Vector2(0.5, 0.5), Vector2(12, 0.5)],
			[Vector2(w - 12, 0.5), Vector2(w - 0.5, 0.5), Vector2(w - 0.5, 12)],
			[Vector2(0.5, h - 12), Vector2(0.5, h - 0.5), Vector2(12, h - 0.5)],
			[Vector2(w - 12, h - 0.5), Vector2(w - 0.5, h - 0.5), Vector2(w - 0.5, h - 12)],
		]:
			draw_polyline(PackedVector2Array(pts), c, 1.0, true)


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var sb := get_v_scroll_bar()
	sb.custom_minimum_size.x = 0 # Hide the visible scrollbar.
	sb.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var outer := MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("margin_left", OUTER_MARGIN)
	outer.add_theme_constant_override("margin_right", OUTER_MARGIN)
	outer.add_theme_constant_override("margin_top", OUTER_MARGIN)
	outer.add_theme_constant_override("margin_bottom", 0)
	add_child(outer)

	var body := InfoBody.new()
	body.add_theme_constant_override("margin_left", 12)
	body.add_theme_constant_override("margin_right", 12)
	body.add_theme_constant_override("margin_top", 12)
	body.add_theme_constant_override("margin_bottom", 16)
	outer.add_child(body)

	_sections = VBoxContainer.new()
	_sections.add_theme_constant_override("separation", 0)
	body.add_child(_sections)
	# Keep the panel surface filling the visible area even when content is short.
	resized.connect(func() -> void: outer.custom_minimum_size.y = size.y)
	_rebuild()


func set_class(cls: Dictionary, is_current: bool) -> void:
	_cls = cls
	_is_current = is_current
	if is_node_ready():
		_rebuild()
		scroll_vertical = 0 # Default to the top for a newly browsed class.


func _rebuild() -> void:
	for child in _sections.get_children():
		child.queue_free()
	_action = null

	var title := UIFonts.make_label(String(_cls["name"]).to_upper(), UIFonts.cinzel_tracked(700, 1), 18, _cls["color"])
	_sections.add_child(title)
	_sections.add_child(_spacer(6))

	var tags := HBoxContainer.new()
	tags.add_theme_constant_override("separation", 8)
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var weapon_tag := MetadataTag.new()
	weapon_tag.setup("Weapon: %s" % _cls["weapon"], &"weapon", _cls)
	tags.add_child(weapon_tag)
	var role_tag := MetadataTag.new()
	role_tag.setup("Role: %s" % _cls["role"], &"role", _cls)
	tags.add_child(role_tag)
	_sections.add_child(tags)
	_sections.add_child(_spacer(10))

	var description := UIFonts.make_label(_cls["description"], UIFonts.rajdhani_medium(), 10, Color("#8070A0"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_constant_override("line_spacing", 6)
	_sections.add_child(description)
	_sections.add_child(_spacer(14))

	_sections.add_child(_section_label("ABILITIES"))
	_sections.add_child(_spacer(6))
	var abilities := AbilitiesBar.new()
	abilities.set_class(_cls)
	abilities.pressed.connect(func() -> void: abilities_pressed.emit())
	_sections.add_child(abilities)
	_sections.add_child(_spacer(12))

	_sections.add_child(_section_label("SKILL POOL"))
	_sections.add_child(_spacer(6))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 5)
	grid.add_theme_constant_override("v_separation", 5)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for skill in _cls["skills"]:
		var cell := SkillCell.new()
		cell.setup(skill, _cls["color"])
		grid.add_child(cell)
	_sections.add_child(grid)
	_sections.add_child(_spacer(16))

	_sections.add_child(_section_label("ADVANCEMENTS · FUTURE PATHS"))
	_sections.add_child(_spacer(6))
	var paths := HBoxContainer.new()
	paths.add_theme_constant_override("separation", 8)
	paths.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for path_name in _cls["advancements"]:
		var cell := AdvancementCell.new()
		cell.setup(path_name)
		paths.add_child(cell)
	_sections.add_child(paths)
	_sections.add_child(_spacer(16))

	_action = SelectAction.new()
	_action.set_state(_cls, _is_current)
	_action.pressed.connect(func() -> void: class_selected.emit())
	_sections.add_child(_action)


func _section_label(text: String) -> Label:
	return UIFonts.make_label(text, UIFonts.cinzel_bold(), 9, UIPalette.TEXT_LAVENDER_DIM)


func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer
