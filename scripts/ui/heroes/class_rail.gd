class_name ClassRail
extends Control
## Fixed 90px left rail of the Heroes tab: hero identity header plus the
## five class tabs. Never scrolls. Spec: docs/art-direction/
## interface-heroes-screen.md, "Class Rail".

signal class_browsed(class_id: StringName)

const CLASS_TAB_SCENE := preload("res://scenes/ui/heroes/class_tab.tscn")

@export var hero_name := "FERO":
	set(v):
		hero_name = v
		if is_node_ready():
			_name_label.text = hero_name
@export var hero_index := 1

var _name_label: Label
var _tabs: Dictionary = {} # class_id -> ClassTab


func _ready() -> void:
	custom_minimum_size = Vector2(90.0, 0.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.add_theme_constant_override("separation", 0)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(column)

	column.add_child(_build_header())

	var tabs_margin := MarginContainer.new()
	tabs_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs_margin.add_theme_constant_override("margin_left", 6)
	tabs_margin.add_theme_constant_override("margin_right", 6)
	tabs_margin.add_theme_constant_override("margin_top", 4)
	tabs_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(tabs_margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tabs_margin.add_child(stack)

	for class_id in HeroClassData.ORDER:
		var tab: ClassTab = CLASS_TAB_SCENE.instantiate()
		tab.class_id = class_id
		tab.pressed.connect(_on_tab_pressed)
		stack.add_child(tab)
		_tabs[class_id] = tab


func set_browsed(class_id: StringName) -> void:
	for id in _tabs:
		_tabs[id].browsed = id == class_id


func set_current(class_id: StringName) -> void:
	for id in _tabs:
		_tabs[id].is_current = id == class_id


func _on_tab_pressed(class_id: StringName) -> void:
	class_browsed.emit(class_id)


func _build_header() -> Control:
	var header := Control.new()
	header.custom_minimum_size = Vector2(0.0, 52.0)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_name_label = UIFonts.make_label(hero_name, UIFonts.cinzel_bold(), 11, UIPalette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_name_label.offset_top = 12.0
	_name_label.offset_bottom = 26.0
	header.add_child(_name_label)

	var subtitle := UIFonts.make_label("Hero · %d" % hero_index, UIFonts.rajdhani_semibold(), 8, UIPalette.TEXT_CHAT, HORIZONTAL_ALIGNMENT_CENTER)
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 27.0
	subtitle.offset_bottom = 39.0
	header.add_child(subtitle)

	var rule := Control.new()
	rule.custom_minimum_size = Vector2(60.0, 1.0)
	rule.set_anchors_preset(Control.PRESET_CENTER_TOP)
	rule.offset_left = -30.0
	rule.offset_right = 30.0
	rule.offset_top = 45.0
	rule.offset_bottom = 46.0
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.draw.connect(func() -> void:
		UIDraw.draw_h_gradient_line(rule, 0.5, 60.0, [
			[0.0, Color(UIPalette.GOLD_MUTED, 0.0)],
			[0.5, UIPalette.GOLD_MUTED],
			[1.0, Color(UIPalette.GOLD_MUTED, 0.0)],
		], 1.0, 12))
	header.add_child(rule)
	return header


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), UIPalette.HUD_TOP, UIPalette.HUD_BOTTOM)
	draw_line(Vector2(size.x - 0.5, 0.0), Vector2(size.x - 0.5, size.y), Color(UIPalette.PURPLE_STRUCTURE, 0.27), 1.0)
