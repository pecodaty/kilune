class_name TalentsTab
extends SubTabPage
## TALENT CONSTELLATION: 3-column grid of talent nodes. Invested nodes glow
## in their talent color. Tapping a node opens its detail modal.
## Reference: App.tsx `TalentsTab`.

signal modal_requested(payload: Dictionary)

## One talent node: octagon icon, name, progress dots, invested count.
class TalentCell extends Control:
	signal pressed

	const HEIGHT := 92.0

	var talent: Dictionary

	func _ready() -> void:
		custom_minimum_size = Vector2(0.0, HEIGHT)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var accent: Color = talent["color"]
		var invested: bool = talent["current"] > 0
		draw_rect(Rect2(Vector2.ZERO, size), Color(accent, 0.067) if invested else Color("#0A0720"))
		draw_rect(Rect2(Vector2.ZERO, size),
			Color(accent, 0.27) if invested else Color(UIPalette.BORDER_DARK, 0.33), false, 1.0)
		if invested:
			UIDraw.draw_h_gradient_line(self, 1.0, size.x, [
				[0.0, Color(accent, 0.0)], [0.5, Color(accent, 0.7)], [1.0, Color(accent, 0.0)],
			], 2.0, 16)
		# Octagon icon.
		var icon_rect := Rect2((size.x - 28.0) * 0.5, 10.0, 28.0, 28.0)
		var frame := UIDraw.octagon(icon_rect.size, 7.0)
		draw_set_transform(icon_rect.position)
		draw_colored_polygon(frame, Color("#0D0825"))
		frame.append(frame[0])
		draw_polyline(frame, accent if invested else UIPalette.BORDER_DARK, 1.0, true)
		draw_set_transform(Vector2.ZERO)
		IconDraw.draw_item_icon(self, talent["icon"], icon_rect.grow(-6.0),
			accent if invested else Color("#4A3870"))
		# Name.
		draw_string(UIFonts.rajdhani_bold(), Vector2(0.0, 52.0), talent["name"],
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, accent if invested else Color("#4A3870"))
		# Progress dots.
		var dot_y := 66.0
		var gap := 9.0
		var start_x := (size.x - gap * 4.0) * 0.5
		for i in range(5):
			var filled: bool = i < talent["current"]
			draw_circle(Vector2(start_x + i * gap, dot_y), 2.5,
				accent if filled else Color(UIPalette.BORDER_DARK, 0.4))
		# Invested count.
		draw_string(UIFonts.rajdhani_semibold(), Vector2(0.0, 82.0),
			"%d/%d" % [talent["current"], talent["max"]],
			HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, Color("#5A4080"))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			pressed.emit()
		elif event is InputEventScreenTouch and not event.is_pressed():
			pressed.emit()


func _build() -> void:
	panel.setup("TALENT CONSTELLATION", "Reset Talents", Color("#FF7733"))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for talent in HeroData.talents():
		var cell := TalentCell.new()
		cell.talent = talent
		cell.pressed.connect(func() -> void:
			modal_requested.emit({"type": &"talent", "data": cell.talent}))
		grid.add_child(cell)
	panel.body.add_child(grid)
