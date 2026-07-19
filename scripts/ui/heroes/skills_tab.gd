class_name SkillsTab
extends ScrollContainer
## Skill progression and six-slot loadout from the revamped Heroes reference.

signal loadout_changed(skill_ids: Array[StringName])
signal skill_upgraded(skill_id: StringName, level: int, mastery: int)

const SECTION_ORDER: Array[StringName] = [&"path1", &"path2", &"spec1", &"spec2"]


class PointsHeader extends Control:
	var spent := 0
	var remaining := 0

	func _ready() -> void:
		custom_minimum_size.y = 48.0
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_string(UIFonts.cinzel_bold(), Vector2(12, 17), "SKILL POINTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, UIPalette.GOLD_MUTED)
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 170, 17), "%d remaining · %d/%d" % [remaining, spent, HeroData.SKILL_POINTS_TOTAL], HORIZONTAL_ALIGNMENT_RIGHT, 158, 9, UIPalette.CYAN if remaining > 0 else Color("#FF7733"))
		var track := Rect2(12, 24, size.x - 24, 4)
		draw_rect(track, Color("#120930")); draw_rect(track, Color(UIPalette.PURPLE_STRUCTURE, 0.27), false, 1.0)
		draw_rect(Rect2(track.position, Vector2(track.size.x * clampf(float(spent) / HeroData.SKILL_POINTS_TOTAL, 0, 1), track.size.y)), Color(UIPalette.CYAN, 0.85))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(12, 41), "6 Equipped · 16 Available · 15 SP per skill", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#3A2858"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(size.x - 110, 41), "Max 99 at Lv.99", HORIZONTAL_ALIGNMENT_RIGHT, 98, 7, Color("#3A2858"))


class LoadoutSlot extends Control:
	signal pressed(skill_id: StringName)
	var skill: Dictionary

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var occupied := not skill.is_empty()
		var color: Color = skill.get("color", Color("#2A1845"))
		var shape := UIDraw.clipped_rect(Vector2(size.x, 42), 7, 0, 7, 0)
		draw_colored_polygon(shape, Color(color, 0.10) if occupied else Color("#0A0720"))
		var loop := shape.duplicate(); loop.append(shape[0]); draw_polyline(loop, Color(color, 0.55) if occupied else Color("#2A1845", 0.25), 1.0, true)
		if occupied:
			IconDraw.draw_item_icon(self, skill["icon"], Rect2((size.x - 24) * 0.5, 9, 24, 24), color)
			draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 14, 39), str(skill["level"]), HORIZONTAL_ALIGNMENT_RIGHT, 10, 7, color)
		else:
			draw_arc(Vector2(size.x * 0.5, 21), 5, 0, TAU, 18, Color("#2A1845", 0.45), 1.0, true)
		var label := String(skill.get("name", "Empty")).get_slice(" ", 0)
		draw_string(UIFonts.rajdhani_bold(), Vector2(0, 55), label, HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, Color("#6050A0") if occupied else Color("#1E1438"))

	func _gui_input(event: InputEvent) -> void:
		if skill.is_empty(): return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			pressed.emit(skill["id"])
		elif event is InputEventScreenTouch and not event.pressed:
			pressed.emit(skill["id"])


class EquippedPanel extends Control:
	signal unequip_requested(skill_id: StringName)
	var slots: Array[Dictionary] = []
	var _controls: Array[LoadoutSlot] = []

	func _ready() -> void:
		custom_minimum_size.y = 110
		resized.connect(_layout)
		for skill in slots:
			var slot := LoadoutSlot.new(); slot.skill = skill; slot.pressed.connect(func(id: StringName) -> void: unequip_requested.emit(id))
			add_child(slot); _controls.append(slot)
		_layout()

	func _layout() -> void:
		if _controls.is_empty(): return
		var gap := 5.0; var width := (size.x - 36.0 - gap * 5.0) / 6.0
		for i in range(_controls.size()):
			_controls[i].position = Vector2(18 + i * (width + gap), 34); _controls[i].size = Vector2(width, 60)

	func _draw() -> void:
		draw_rect(Rect2(4, 2, size.x - 8, size.y - 4), Color("#0D0825", 0.72)); draw_rect(Rect2(4, 2, size.x - 8, size.y - 4), Color(UIPalette.PURPLE_STRUCTURE, 0.35), false, 1.0)
		draw_string(UIFonts.cinzel_bold(), Vector2(18, 25), "EQUIPPED SKILLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, UIPalette.GOLD_MUTED)
		draw_string(UIFonts.rajdhani_semibold(), Vector2(18, 103), "Tap an equipped skill to unequip · Tap a learned skill below to equip", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#3A2858"))


class SkillRow extends Control:
	signal equip_requested(skill_id: StringName)
	signal level_requested(skill_id: StringName)
	signal mastery_requested(skill_id: StringName)
	var skill: Dictionary
	var locked := false
	var equipped := false
	var can_level := false
	var can_mastery := false
	var section_color := Color.WHITE

	func _ready() -> void:
		custom_minimum_size.y = 66
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		var icon_hit := Button.new(); icon_hit.flat = true; icon_hit.focus_mode = Control.FOCUS_NONE
		icon_hit.position = Vector2(8, 10); icon_hit.size = Vector2(42, 42); icon_hit.disabled = locked
		icon_hit.pressed.connect(func() -> void: equip_requested.emit(skill["id"])); add_child(icon_hit)
		var level := _action("+Lv", UIPalette.CYAN, can_level); level.anchor_left = 1; level.anchor_right = 1; level.offset_left = -44; level.offset_right = -8; level.offset_top = 10; level.offset_bottom = 32
		level.pressed.connect(func() -> void: level_requested.emit(skill["id"])); add_child(level)
		var mastery := _action("+Mst", UIPalette.GOLD, can_mastery); mastery.anchor_left = 1; mastery.anchor_right = 1; mastery.offset_left = -44; mastery.offset_right = -8; mastery.offset_top = 36; mastery.offset_bottom = 58
		mastery.pressed.connect(func() -> void: mastery_requested.emit(skill["id"])); add_child(mastery)

	func _action(text: String, color: Color, enabled: bool) -> ArcaneButton:
		var out := ArcaneButton.new(); out.text = text; out.cut = 3; out.disabled = not enabled
		out.fill_top = Color("#0A1535") if enabled else Color("#0A0820"); out.fill_bottom = Color("#0D1E44") if enabled else Color("#080618")
		out.border_color = Color(color, 0.45) if enabled else Color("#1E1433", 0.25)
		out.add_theme_font_override("font", UIFonts.rajdhani_bold()); out.add_theme_font_size_override("font_size", 8)
		out.add_theme_color_override("font_color", color); out.add_theme_color_override("font_disabled_color", Color("#3A2858", 0.45)); return out

	func _draw() -> void:
		var alpha := 0.45 if locked else 1.0
		draw_rect(Rect2(Vector2.ZERO, size), Color("#070514") if locked else (Color(section_color, 0.055) if equipped else Color("#0A0720")))
		draw_rect(Rect2(Vector2.ZERO, size), Color("#1A1022", 0.28) if locked else (Color(section_color, 0.28) if equipped else Color("#2A1845", 0.20)), false, 1.0)
		var icon_shape := UIDraw.clipped_rect(Vector2(42, 42), 6, 0, 6, 0)
		for i in range(icon_shape.size()): icon_shape[i] += Vector2(8, 10)
		draw_colored_polygon(icon_shape, Color("#0D0825")); var icon_loop := icon_shape.duplicate(); icon_loop.append(icon_shape[0]); draw_polyline(icon_loop, Color(section_color, 0.4) if equipped else Color("#2A1845", 0.3), 1.0, true)
		IconDraw.draw_item_icon(self, skill["icon"], Rect2(17, 19, 24, 24), Color(section_color, alpha))
		if equipped: draw_circle(Vector2(46, 14), 3, section_color)
		var text_color := Color("#3A2858") if locked else (section_color if equipped else Color("#C8B8E8"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(60, 20), skill["name"], HORIZONTAL_ALIGNMENT_LEFT, size.x - 120, 10, text_color)
		if equipped: draw_string(UIFonts.rajdhani_bold(), Vector2(60 + minf(120, UIFonts.rajdhani_bold().get_string_size(skill["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 6), 20), "EQ", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, section_color)
		var bar_x := 80.0; var bar_w := maxf(30, size.x - bar_x - 82)
		draw_string(UIFonts.rajdhani_bold(), Vector2(60, 39), "Lv", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#4A3870"))
		draw_rect(Rect2(bar_x, 34, bar_w, 3), Color("#120930")); draw_rect(Rect2(bar_x, 34, bar_w * skill["level"] / 10.0, 3), Color(section_color, alpha))
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 78, 39), "%d/10" % skill["level"], HORIZONTAL_ALIGNMENT_RIGHT, 28, 7, section_color if skill["level"] > 0 and not locked else Color("#2A1845"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(60, 56), "Mst", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#4A3870"))
		for i in range(5): draw_circle(Vector2(83 + i * 9, 51), 3, UIPalette.GOLD if i < skill["mastery"] else Color("#1E1438"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 78, 56), "%d/5" % skill["mastery"], HORIZONTAL_ALIGNMENT_RIGHT, 28, 7, UIPalette.GOLD if skill["mastery"] > 0 else Color("#2A1845"))


class SkillSection extends VBoxContainer:
	var section_id: StringName
	var meta: Dictionary
	var skills: Array[Dictionary]
	var equipped: Array[StringName]
	var remaining := 0
	signal equip_requested(skill_id: StringName)
	signal level_requested(skill_id: StringName)
	signal mastery_requested(skill_id: StringName)

	func _ready() -> void:
		add_theme_constant_override("separation", 8); mouse_filter = Control.MOUSE_FILTER_IGNORE
		var header := Control.new(); header.custom_minimum_size.y = 32; header.mouse_filter = Control.MOUSE_FILTER_IGNORE; header.draw.connect(_draw_header.bind(header)); add_child(header)
		var unlocked: bool = HeroData.PROGRESSION_LEVEL >= meta["unlock"]
		for skill in skills:
			var row := SkillRow.new(); row.skill = skill; row.locked = not unlocked; row.equipped = equipped.has(skill["id"]); row.section_color = meta["color"]
			var next_req := HeroData.skill_level_requirement(skill["level"] + 1)
			row.can_level = unlocked and skill["level"] < 10 and remaining > 0 and next_req <= HeroData.PROGRESSION_LEVEL
			row.can_mastery = unlocked and skill["level"] == 10 and skill["mastery"] < 5 and remaining > 0 and HeroData.PROGRESSION_LEVEL >= 90
			row.equip_requested.connect(func(id: StringName) -> void: equip_requested.emit(id)); row.level_requested.connect(func(id: StringName) -> void: level_requested.emit(id)); row.mastery_requested.connect(func(id: StringName) -> void: mastery_requested.emit(id)); add_child(row)

	func _draw_header(header: Control) -> void:
		var unlocked: bool = HeroData.PROGRESSION_LEVEL >= meta["unlock"]; var color: Color = meta["color"] if unlocked else Color("#3A2858")
		header.draw_rect(Rect2(4, 0, header.size.x - 8, header.size.y), Color("#0D0825", 0.62)); header.draw_rect(Rect2(4, 0, header.size.x - 8, header.size.y), Color(UIPalette.PURPLE_STRUCTURE, 0.25), false, 1.0)
		header.draw_rect(Rect2(12, 7, 3, 18), color)
		header.draw_string(UIFonts.cinzel_bold(), Vector2(24, 21), meta["label"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, color)
		var status := "Lv.%d ✓ · 4 Skills" % meta["unlock"] if unlocked else "LOCKED · Requires Lv.%d" % meta["unlock"]
		header.draw_string(UIFonts.rajdhani_bold(), Vector2(header.size.x - 150, 21), status, HORIZONTAL_ALIGNMENT_RIGHT, 138, 7, Color(color, 0.7))


var _skills: Array[Dictionary] = []
var _equipped: Array[StringName] = []
var _content: VBoxContainer
var _drag_active := false
var _drag_started := false
var _drag_pointer := -1
var _drag_origin := Vector2.ZERO
var _drag_scroll_origin := 0


func _ready() -> void:
	size_flags_vertical = Control.SIZE_EXPAND_FILL; size_flags_horizontal = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; scroll_deadzone = 4
	get_v_scroll_bar().custom_minimum_size.x = 0; get_v_scroll_bar().mouse_filter = Control.MOUSE_FILTER_IGNORE
	for skill in HeroData.active_skills(): _skills.append(skill.duplicate(true))
	_equipped = HeroData.equipped_skills()
	visibility_changed.connect(_on_visibility_changed)
	call_deferred("_rebuild")


func _on_visibility_changed() -> void:
	if visible: call_deferred("_rebuild")


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0: return
	var scroll := scroll_vertical
	if is_instance_valid(_content): remove_child(_content); _content.queue_free()
	_content = VBoxContainer.new(); _content.custom_minimum_size.x = size.x; _content.add_theme_constant_override("separation", 8); _content.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(_content)
	var points := PointsHeader.new(); points.spent = _spent(); points.remaining = HeroData.SKILL_POINTS_TOTAL - points.spent; _content.add_child(points)
	var equipped_panel := EquippedPanel.new(); equipped_panel.slots = _equipped_data(); equipped_panel.unequip_requested.connect(_toggle_equip); _content.add_child(equipped_panel)
	for section_id in SECTION_ORDER:
		var section := SkillSection.new(); section.section_id = section_id; section.meta = HeroData.skill_sections()[section_id]; section.skills = _section_skills(section_id); section.equipped = _equipped; section.remaining = HeroData.SKILL_POINTS_TOTAL - _spent()
		section.equip_requested.connect(_toggle_equip); section.level_requested.connect(_upgrade_level); section.mastery_requested.connect(_upgrade_mastery); _content.add_child(section)
	_content.add_child(_spacer(8)); set_deferred("scroll_vertical", scroll)


func _section_skills(section_id: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for skill in _skills:
		if skill["section"] == section_id: out.append(skill)
	return out


func _equipped_data() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in _equipped:
		var skill := _find_skill(id); if not skill.is_empty(): skill = skill.duplicate(); skill["color"] = HeroData.skill_sections()[skill["section"]]["color"]
		out.append(skill)
	return out


func _find_skill(skill_id: StringName) -> Dictionary:
	for skill in _skills:
		if skill["id"] == skill_id: return skill
	return {}


func _spent() -> int:
	var total := 0
	for skill in _skills: total += skill["level"] + skill["mastery"]
	return total


func _toggle_equip(skill_id: StringName) -> void:
	var skill := _find_skill(skill_id)
	if skill.is_empty() or skill["level"] <= 0: return
	var index := _equipped.find(skill_id)
	if index >= 0: _equipped[index] = &""
	else:
		index = _equipped.find(&"")
		if index < 0: return
		_equipped[index] = skill_id
	loadout_changed.emit(_equipped.duplicate()); _rebuild()


func _upgrade_level(skill_id: StringName) -> void:
	var skill := _find_skill(skill_id)
	if skill.is_empty() or _spent() >= HeroData.SKILL_POINTS_TOTAL or skill["level"] >= 10: return
	if HeroData.PROGRESSION_LEVEL < HeroData.skill_level_requirement(skill["level"] + 1): return
	skill["level"] += 1; skill_upgraded.emit(skill_id, skill["level"], skill["mastery"]); _rebuild()


func _upgrade_mastery(skill_id: StringName) -> void:
	var skill := _find_skill(skill_id)
	if skill.is_empty() or skill["level"] < 10 or skill["mastery"] >= 5 or _spent() >= HeroData.SKILL_POINTS_TOTAL or HeroData.PROGRESSION_LEVEL < 90: return
	skill["mastery"] += 1; skill_upgraded.emit(skill_id, skill["level"], skill["mastery"]); _rebuild()


func _spacer(height: float) -> Control:
	var out := Control.new(); out.custom_minimum_size.y = height; out.mouse_filter = Control.MOUSE_FILTER_IGNORE; return out


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree(): return
	if event is InputEventScreenTouch:
		if event.pressed and not _drag_active and get_global_rect().has_point(event.position): _begin_drag(event.position, event.index)
		elif not event.pressed and _drag_active and event.index == _drag_pointer: _end_drag()
	elif event is InputEventScreenDrag and _drag_active and event.index == _drag_pointer: _update_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _drag_active and get_global_rect().has_point(event.position): _begin_drag(event.position, -1)
		elif not event.pressed and _drag_active and _drag_pointer == -1: _end_drag()
	elif event is InputEventMouseMotion and _drag_active and _drag_pointer == -1: _update_drag(event.position)


func _begin_drag(position: Vector2, pointer: int) -> void:
	_drag_active = true; _drag_started = false; _drag_pointer = pointer; _drag_origin = position; _drag_scroll_origin = scroll_vertical


func _update_drag(position: Vector2) -> void:
	var distance := position.y - _drag_origin.y
	if absf(distance) > 6: _drag_started = true
	if _drag_started: scroll_vertical = _drag_scroll_origin - int(distance); get_viewport().set_input_as_handled()


func _end_drag() -> void:
	if _drag_started: get_viewport().set_input_as_handled()
	_drag_active = false; _drag_started = false; _drag_pointer = -1


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIPalette.CANVAS)
