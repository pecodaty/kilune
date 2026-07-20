class_name SubTabBar
extends Control
## Six-destination sub-tab bar pinned below the Heroes content. The active
## destination gets a cyan top shimmer, icon, and pale-cyan label.
## Reference: App.tsx `HeroTabBar`.

signal sub_tab_selected(tab_id: StringName)

const HEIGHT := 54.0
const TABS: Array[Array] = [
	[&"stats", "STATS"],
	[&"skills", "SKILLS"],
	[&"talents", "TALENTS"],
	[&"equipment", "EQUIPMENT"],
	[&"cards", "CARDS"],
	[&"pets", "PETS"],
]

@export var active: StringName = &"stats":
	set(v):
		active = v
		_refresh()


## One sub-tab destination cell.
class Cell extends Control:
	signal pressed

	var tab_id: StringName
	var label_text := ""
	var is_active := false

	func _ready() -> void:
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var icon_color := UIPalette.CYAN if is_active else UIPalette.PURPLE_STRUCTURE
		var label_color := UIPalette.TEXT_PALE_CYAN if is_active else UIPalette.INACTIVE_DIM
		if is_active:
			UIDraw.draw_h_gradient_line(self, 0.75, size.x, [
				[0.0, Color(UIPalette.CYAN, 0.0)],
				[0.5, Color(UIPalette.CYAN, 0.9)],
				[1.0, Color(UIPalette.CYAN, 0.0)],
			], 1.5, 16)
		IconDraw.draw_sub_icon(self, tab_id, Rect2((size.x - 18.0) * 0.5, 8.0, 18.0, 18.0), icon_color)
		var font := UIFonts.rajdhani_bold()
		draw_string(font, Vector2(0.0, size.y - 8.0), label_text,
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, label_color)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


var _cells: Array[Cell] = []


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	for tab in TABS:
		var cell := Cell.new()
		cell.tab_id = tab[0]
		cell.label_text = tab[1]
		cell.pressed.connect(func() -> void: sub_tab_selected.emit(cell.tab_id))
		row.add_child(cell)
		_cells.append(cell)
	_refresh()


func _refresh() -> void:
	for cell in _cells:
		cell.is_active = cell.tab_id == active
		cell.queue_redraw()


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), UIPalette.HUD_TOP, UIPalette.NAV_BOTTOM)
	draw_line(Vector2(0.0, 0.5), Vector2(size.x, 0.5), Color(UIPalette.PURPLE_STRUCTURE, 0.33), 1.0)
