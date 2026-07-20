class_name StatsTab
extends SubTabPage
## Scrollable live character sheet. One stat breakdown can be open at a time.

class IdentityCard extends Control:
	var identity: Dictionary
	var skill_spent := 0
	var talent_spent := 0

	func _ready() -> void:
		custom_minimum_size.y = 126
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var shape := UIDraw.clipped_rect(size, 8, 0, 8, 0)
		draw_colored_polygon(shape, Color("#0A1228"))
		var loop := shape.duplicate(); loop.append(shape[0])
		draw_polyline(loop, Color("#22DD6E", 0.38), 1.0, true)
		IconDraw.draw_item_icon(self, &"leaf", Rect2(14, 14, 36, 36), Color("#22DD6E"))
		IconDraw.draw_item_icon(self, &"star", Rect2(36, 34, 19, 19), Color("#66DDFF"))
		draw_string(UIFonts.cinzel_bold(), Vector2(64, 25), identity["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UIPalette.GOLD)
		draw_string(UIFonts.rajdhani_bold(), Vector2(64, 43), "LEVEL %d · %s" % [identity["level"], identity["title"]], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, UIPalette.TEXT_PALE_CYAN)
		draw_string(UIFonts.cinzel_bold(), Vector2(14, 71), "%s  →  %s" % [identity["path"], identity["specialization"]], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, 12, Color("#66DDFF"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(14, 91), "SKILL POINTS %d/%d   ·   TALENT POINTS %d/%d" % [skill_spent, TraitRules.points_for_level(identity["level"]), talent_spent, TraitRules.points_for_level(identity["level"])], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, 8, Color("#A090C0"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(14, 113), identity["milestone"], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, 8, UIPalette.GOLD_MUTED)


class StatRow extends Control:
	signal pressed(stat_id: StringName)
	var stat: Dictionary
	var expanded := false
	var _press_position := Vector2.ZERO
	var _dragged := false

	func _ready() -> void:
		custom_minimum_size.y = 92 if expanded else 42
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#09061A"))
		draw_rect(Rect2(Vector2.ZERO, size), Color(UIPalette.PURPLE_STRUCTURE, 0.26), false, 1.0)
		draw_rect(Rect2(0, 6, 2, 30), Color(UIPalette.CYAN, 0.72))
		draw_string(UIFonts.rajdhani_bold(), Vector2(12, 25), stat["label"], HORIZONTAL_ALIGNMENT_LEFT, size.x - 120, 10, Color("#C8B8E8"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 112, 25), _format(stat["final"]), HORIZONTAL_ALIGNMENT_RIGHT, 92, 12, UIPalette.TEXT_PALE_CYAN)
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 15, 24), "−" if expanded else "+", HORIZONTAL_ALIGNMENT_CENTER, 10, 11, UIPalette.GOLD_MUTED)
		if expanded:
			draw_line(Vector2(12, 40), Vector2(size.x - 12, 40), Color(UIPalette.PURPLE_STRUCTURE, 0.24), 1)
			_draw_source("Base", stat["base"], 55, Color("#7A6A9A"))
			_draw_source("Equipment", stat["equipment"], 70, UIPalette.CYAN)
			var talent_label := "Talent (%+.1f%%)" % stat["talent_percent"]
			_draw_source(talent_label, stat["talent"], 85, Color("#AA77EE"))

	func _draw_source(label_text: String, value: float, y: float, color: Color) -> void:
		draw_string(UIFonts.rajdhani_semibold(), Vector2(18, y), label_text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 120, 8, Color("#6050A0"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 106, y), _format(value, true), HORIZONTAL_ALIGNMENT_RIGHT, 86, 8, color)

	func _format(value: float, signed := false) -> String:
		var prefix := "+" if signed and value > 0.001 else ""
		if stat["percent"]:
			return "%s%.1f%%" % [prefix, value]
		return "%s%d" % [prefix, roundi(value)]

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: _press_position = event.position; _dragged = false
			elif not _dragged: pressed.emit(stat["id"])
		elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_dragged = _dragged or event.position.distance_to(_press_position) > 6
		elif event is InputEventScreenTouch:
			if event.pressed: _press_position = event.position; _dragged = false
			elif not _dragged: pressed.emit(stat["id"])
		elif event is InputEventScreenDrag:
			_dragged = _dragged or event.position.distance_to(_press_position) > 6


var _state: HeroProgressionState
var _expanded_id: StringName = &""


func _build() -> void:
	panel.setup("CHARACTER STATS", "LIVE", UIPalette.CYAN)
	_populate()


func bind_state(state: HeroProgressionState) -> void:
	if _state != null and _state.changed.is_connected(_on_state_changed):
		_state.changed.disconnect(_on_state_changed)
	_state = state
	_state.changed.connect(_on_state_changed)
	_populate()


func _on_state_changed(_change_kind: StringName) -> void:
	_populate()


func _populate() -> void:
	if _state == null or panel == null:
		return
	var scroll := scroll_vertical
	for child in panel.body.get_children():
		panel.body.remove_child(child)
		child.queue_free()
	var identity := IdentityCard.new()
	identity.identity = _state.identity_snapshot()
	identity.skill_spent = _state.skill_points_spent()
	identity.talent_spent = _state.talent_points_spent()
	panel.body.add_child(identity)
	panel.body.add_child(_spacer(12))
	var current_group := ""
	for stat in _state.stats_snapshot():
		if stat["group"] != current_group:
			current_group = stat["group"]
			panel.body.add_child(_section_label(current_group))
			panel.body.add_child(_spacer(5))
		var row := StatRow.new()
		row.stat = stat
		row.expanded = stat["id"] == _expanded_id
		row.pressed.connect(_toggle_stat)
		panel.body.add_child(row)
		panel.body.add_child(_spacer(4))
	set_deferred("scroll_vertical", scroll)


func _toggle_stat(stat_id: StringName) -> void:
	_expanded_id = &"" if _expanded_id == stat_id else stat_id
	_populate()
