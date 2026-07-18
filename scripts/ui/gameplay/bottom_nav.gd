class_name BottomNav
extends Control
## Arched bottom navigation with a raised center Battle pedestal.

signal tab_selected(tab_id: StringName)

const NAV_TAB_SCENE := preload("res://scenes/ui/gameplay/nav_tab.tscn")

@export var active_tab: StringName = &"battle":
	set(v):
		active_tab = v
		_apply_selection()

const TABS: Array = [
	{"id": &"home", "label": "Home"},
	{"id": &"heroes", "label": "Heroes"},
	{"id": &"battle", "label": "Battle"},
	{"id": &"guild", "label": "Guild"},
	{"id": &"shop", "label": "Shop"},
]

var _tabs: Array[NavTab] = []


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 72.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	for def in TABS:
		var tab: NavTab = NAV_TAB_SCENE.instantiate()
		tab.tab_id = def["id"]
		tab.label_text = def["label"]
		tab.is_battle = def["id"] == &"battle"
		tab.tab_pressed.connect(_on_tab_pressed)
		row.add_child(tab)
		_tabs.append(tab)
	_apply_selection()


func _on_tab_pressed(tab_id: StringName) -> void:
	active_tab = tab_id
	tab_selected.emit(tab_id)


func _apply_selection() -> void:
	if not is_node_ready():
		return
	for tab in _tabs:
		tab.selected = tab.tab_id == active_tab
	queue_redraw()


## Arch top edge sampled from the canonical 390x72 path.
func _arch_curve() -> PackedVector2Array:
	var sx := size.x / 390.0
	var sy := size.y / 72.0
	var curve := UIDraw.flatten_quadratic_chain(Vector2(0, 22) * Vector2(sx, sy), [
		[Vector2(90, 22) * Vector2(sx, sy), Vector2(148, 14) * Vector2(sx, sy)],
		[Vector2(170, 8) * Vector2(sx, sy), Vector2(195, 4) * Vector2(sx, sy)],
		[Vector2(220, 8) * Vector2(sx, sy), Vector2(242, 14) * Vector2(sx, sy)],
		[Vector2(300, 22) * Vector2(sx, sy), Vector2(390, 22) * Vector2(sx, sy)],
	], 12)
	return curve


func _draw() -> void:
	var curve := _arch_curve()
	# Bar fill under the arch
	var fill := curve + PackedVector2Array([Vector2(size.x, size.y), Vector2(0.0, size.y)])
	var colors := PackedColorArray()
	for p in curve:
		colors.append(UIPalette.NAV_TOP)
	colors.append(UIPalette.NAV_BOTTOM)
	colors.append(UIPalette.NAV_BOTTOM)
	draw_polygon(fill, colors)

	# Gold arch edge (horizontal gradient along the curve)
	var stops := [
		[0.0, Color(UIPalette.PURPLE_STRUCTURE, 0.2)],
		[0.4, Color(UIPalette.GOLD_MUTED, 0.7)],
		[0.5, UIPalette.GOLD],
		[0.6, Color(UIPalette.GOLD_MUTED, 0.7)],
		[1.0, Color(UIPalette.PURPLE_STRUCTURE, 0.2)],
	]
	for i in range(curve.size() - 1):
		var t := float(i) / float(curve.size() - 1)
		draw_line(curve[i], curve[i + 1], UIDraw.sample_stops(t, stops), 1.2, true)

	# Vertical dividers between destinations
	for x_frac in [0.2, 0.4, 0.6, 0.8]:
		var x: float = x_frac * size.x
		draw_line(Vector2(x, size.y * 0.34), Vector2(x, size.y - 6.0), Color(UIPalette.BORDER_DARK, 0.5), 0.5)

	# Cyan shimmer over the selected destination
	var index := TABS.find_custom(func(def: Dictionary) -> bool: return def["id"] == active_tab)
	if index >= 0:
		var tab_w := size.x / float(TABS.size())
		var x0 := tab_w * index + tab_w * 0.15
		var x1 := tab_w * (index + 1) - tab_w * 0.15
		var steps := 16
		for i in range(steps):
			var a := x0 + (x1 - x0) * float(i) / float(steps)
			var b := x0 + (x1 - x0) * float(i + 1) / float(steps)
			var c := Color(UIPalette.CYAN, sin(float(i + 1) / float(steps + 1) * PI))
			draw_line(Vector2(a, 0.5), Vector2(b, 0.5), c, 1.0)
