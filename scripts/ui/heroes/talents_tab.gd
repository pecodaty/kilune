class_name TalentsTab
extends Control
## Four-section interactive talent constellation from the revamped reference.

signal talent_rank_changed(talent_id: StringName, rank: int)

const SECTION_ORDER: Array[StringName] = [&"path1", &"path2", &"spec1", &"spec2"]
const PATH_ORDER := {
	&"path1":[&"t_apex",&"t_pow",&"t_vit",&"t_arc",&"t_bh",&"t_swift",&"t_crit",&"t_mind",&"t_cd",&"t_dodge",&"t_res",&"t_life"],
	&"path2":[&"t2_ks",&"t2_atk",&"t2_jdg",&"t2_rge",&"t2_hlth",&"t2_sp",&"t2_smte",&"t2_wrd",&"t2_mntr",&"t2_lgt",&"t2_flk",&"t2_spd"],
	&"spec1":[&"s1_ks",&"s1_am",&"s1_ms",&"s1_cs",&"s1_pl",&"s1_es",&"s1_ae",&"s1_rw"],
	&"spec2":[&"s2_ks",&"s2_sr",&"s2_rs",&"s2_bp",&"s2_nz",&"s2_dk",&"s2_vp",&"s2_cs2"],
}
const PATH_POS := [Vector2(155,132),Vector2(155,68),Vector2(216,112),Vector2(193,184),Vector2(117,184),Vector2(94,112),Vector2(213,31),Vector2(272,132),Vector2(213,233),Vector2(97,233),Vector2(38,132),Vector2(97,31)]
const SPEC_POS := [Vector2(155,132),Vector2(155,66),Vector2(212,165),Vector2(98,165),Vector2(238,49),Vector2(238,215),Vector2(72,215),Vector2(72,49)]
const PATH_EDGES := [[0,1],[0,2],[0,3],[0,4],[0,5],[1,6],[1,11],[2,6],[2,7],[3,7],[3,8],[4,8],[4,9],[5,10],[5,11],[6,7],[7,8],[8,9],[9,10],[10,11],[11,6]]
const SPEC_EDGES := [[0,1],[0,2],[0,3],[1,4],[1,7],[2,4],[2,5],[3,5],[3,6],[4,5],[5,6],[6,7],[7,4]]


class PointsHeader extends Control:
	var spent := 0
	var remaining := 0
	var budget := 0

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_string(UIFonts.cinzel_bold(), Vector2(12, 17), "TALENT POINTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, UIPalette.GOLD_MUTED)
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 170, 17), "%d remaining · %d/%d" % [remaining, spent, budget], HORIZONTAL_ALIGNMENT_RIGHT, 158, 9, Color("#AA44FF") if remaining > 0 else Color("#FF7733"))
		var track := Rect2(12, 24, size.x - 24, 4); draw_rect(track, Color("#120930")); draw_rect(track, Color(UIPalette.PURPLE_STRUCTURE, 0.27), false, 1)
		draw_rect(Rect2(track.position, Vector2(track.size.x * clampf(float(spent) / maxf(1.0, budget), 0, 1), track.size.y)), Color("#AA44FF"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(12, 41), "Ranks: %d/100 · 20 active nodes · Tap to inspect" % spent, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#3A2858"))
		draw_string(UIFonts.rajdhani_semibold(), Vector2(size.x - 110, 41), "Max %d TP at Lv.%d" % [TraitRules.MAX_TALENT_POINTS, TraitRules.MAX_CHARACTER_LEVEL], HORIZONTAL_ALIGNMENT_RIGHT, 98, 7, Color("#3A2858"))


class SectionButton extends Control:
	signal pressed(section_id: StringName)
	var section_id: StringName
	var meta: Dictionary
	var active := false
	var points := 0
	var character_level := 1

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _draw() -> void:
		var unlocked: bool = character_level >= meta["unlock"] and meta.get("chosen", false)
		var color: Color = meta["color"]
		var shape := UIDraw.clipped_rect(size, 4, 0, 4, 0); draw_colored_polygon(shape, Color(color, 0.09) if active else Color("#0A0720"))
		var loop := shape.duplicate(); loop.append(shape[0]); draw_polyline(loop, Color(color, 0.45) if active else Color("#2A1845", 0.22), 1, true)
		var title_color := color if active else (Color("#4A3870") if unlocked else Color("#2A1845"))
		draw_string(UIFonts.cinzel_bold(), Vector2(0, 16), meta["short"], HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, title_color)
		var status := "%d pts" % points if unlocked else "UNCHOSEN · Lv.%d" % meta["unlock"]
		draw_string(UIFonts.rajdhani_bold(), Vector2(0, 30), status, HORIZONTAL_ALIGNMENT_CENTER, size.x, 7, Color(color, 0.7) if active else Color("#2A1845"))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed: pressed.emit(section_id)
		elif event is InputEventScreenTouch and not event.pressed: pressed.emit(section_id)


class ConstellationGraph extends Control:
	signal node_pressed(talent_id: StringName)
	var talents: Array[Dictionary]
	var positions: Array
	var edges: Array
	var meta: Dictionary
	var selected_id: StringName
	var available_ids: Array[StringName] = []

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP

	func _fit() -> Transform2D:
		var scale_value := minf(size.x / 310.0, size.y / 268.0)
		return Transform2D(0, Vector2.ONE * scale_value, 0, (size - Vector2(310,268) * scale_value) * 0.5)

	func _point(index: int) -> Vector2:
		return _fit() * positions[index]

	func _draw() -> void:
		var scale_value := minf(size.x / 310.0, size.y / 268.0); var section_color: Color = meta["color"]
		for gx in range(-4,5):
			for gy in range(-3,4): draw_circle(_fit() * Vector2(155 + gx*36,132 + gy*36), maxf(0.7, scale_value * 0.55), Color(section_color, 0.11))
		for edge in edges:
			var active: bool = talents[edge[0]]["rank"] > 0 and talents[edge[1]]["rank"] > 0
			draw_line(_point(edge[0]), _point(edge[1]), Color(section_color, 0.82) if active else Color("#1E1438", 0.32), (1.6 if active else 0.8) * scale_value, true)
		for i in range(talents.size()): _draw_node(i, scale_value)

	func _draw_node(index: int, scale_value: float) -> void:
		var talent := talents[index]; var center := _point(index); var keystone: bool = talent["type"] == &"keystone"
		var radius := (21.0 if keystone else 14.0) * scale_value; var has_rank: bool = talent["rank"] > 0; var available := available_ids.has(talent["id"])
		var color: Color = UIPalette.GOLD if keystone else meta["color"]
		if has_rank: draw_circle(center, radius + 7 * scale_value, Color(color, 0.07))
		elif available: draw_circle(center, radius + 5 * scale_value, Color(color, 0.035))
		if talent["rank"] >= talent["max"]: draw_arc(center, radius + 4 * scale_value, 0, TAU, 28, Color(UIPalette.GOLD, 0.65), 0.9 * scale_value, true)
		if selected_id == talent["id"]: draw_arc(center, radius + 8 * scale_value, 0, TAU, 28, Color(color, 0.8), 1.2 * scale_value, true)
		draw_circle(center, radius, Color(color, 0.15) if has_rank else Color("#0D0825"))
		draw_arc(center, radius, 0, TAU, 28, color if has_rank else (Color(color, 0.55) if available else Color("#2A1845", 0.45)), (1.6 if keystone else 1.1) * scale_value, true)
		IconDraw.draw_item_icon(self, talent["icon"], Rect2(center - Vector2.ONE * radius * 0.45, Vector2.ONE * radius * 0.9), color if has_rank or available else Color("#4A3870"))
		if keystone: draw_string(UIFonts.rajdhani_bold(), center + Vector2(-45 * scale_value, -radius - 6 * scale_value), "✦ KEYSTONE ✦", HORIZONTAL_ALIGNMENT_CENTER, 90 * scale_value, maxi(6, int(6 * scale_value)), UIPalette.GOLD)
		if has_rank:
			var badge := center + Vector2(radius * 0.78, -radius * 0.78); draw_circle(badge, 5.5 * scale_value, Color("#0A0820")); draw_arc(badge, 5.5 * scale_value, 0, TAU, 20, UIPalette.GOLD if talent["rank"] >= talent["max"] else color, 0.9 * scale_value, true)
			draw_string(UIFonts.rajdhani_bold(), badge + Vector2(-5 * scale_value, 2 * scale_value), str(talent["rank"]), HORIZONTAL_ALIGNMENT_CENTER, 10 * scale_value, maxi(6, int(6 * scale_value)), color)
		var short_name := String(talent["name"]).get_slice(" ",0) + (" " + String(talent["name"]).get_slice(" ",1) if String(talent["name"]).get_slice_count(" ") > 1 else "")
		draw_string(UIFonts.rajdhani_bold(), center + Vector2(-45 * scale_value, radius + 10 * scale_value), short_name, HORIZONTAL_ALIGNMENT_CENTER, 90 * scale_value, maxi(6, int(7 * scale_value)), color if has_rank or available else Color("#3A2858"))

	func _gui_input(event: InputEvent) -> void:
		var released: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed
		released = released or (event is InputEventScreenTouch and not event.pressed)
		if not released: return
		var at: Vector2 = event.position
		var scale_value := minf(size.x / 310.0, size.y / 268.0)
		for i in range(positions.size()):
			var radius := (29 if talents[i]["type"] == &"keystone" else 22) * scale_value
			if at.distance_to(_point(i)) <= radius: node_pressed.emit(talents[i]["id"]); accept_event(); return


class LockedView extends Control:
	var meta: Dictionary

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var center := size * 0.5
		IconDraw.lock_icon(self, Rect2(center - Vector2(28,42), Vector2(56,56)), Color("#2A1845"))
		draw_string(UIFonts.cinzel_bold(), center + Vector2(-110, 42), "%s · LV.%d" % [meta["label"], meta["unlock"]], HORIZONTAL_ALIGNMENT_CENTER, 220, 11, Color("#2A1845"))
		draw_string(UIFonts.rajdhani_medium(), center + Vector2(-110, 70), "Choose this milestone before its talents are revealed.", HORIZONTAL_ALIGNMENT_CENTER, 220, 8, Color("#1E1438"))


class DetailPanel extends Control:
	signal decrease_requested(talent_id: StringName)
	signal increase_requested(talent_id: StringName)
	var talent: Dictionary
	var color: Color
	var can_increase := false
	var can_decrease := false
	var status_text := ""

	func _ready() -> void:
		var minus := _button("−", Color("#FF7733"), can_decrease); minus.anchor_left = 1; minus.anchor_right = 1; minus.offset_left = -72; minus.offset_right = -42; minus.offset_top = 56; minus.offset_bottom = 82; minus.pressed.connect(func() -> void: decrease_requested.emit(talent["id"])); add_child(minus)
		var plus := _button("+", color, can_increase); plus.anchor_left = 1; plus.anchor_right = 1; plus.offset_left = -38; plus.offset_right = -8; plus.offset_top = 56; plus.offset_bottom = 82; plus.pressed.connect(func() -> void: increase_requested.emit(talent["id"])); add_child(plus)

	func _button(text: String, accent: Color, enabled: bool) -> ArcaneButton:
		var out := ArcaneButton.new(); out.text = text; out.cut = 3; out.disabled = not enabled; out.fill_top = Color("#0A0E35") if enabled else Color("#0A0820"); out.fill_bottom = Color("#0D1540") if enabled else Color("#080618"); out.border_color = Color(accent, 0.45); out.add_theme_font_override("font", UIFonts.rajdhani_bold()); out.add_theme_font_size_override("font_size", 14); out.add_theme_color_override("font_color", accent); out.add_theme_color_override("font_disabled_color", Color("#3A2858", 0.4)); return out

	func _draw() -> void:
		var shape := UIDraw.clipped_rect(size, 6, 0, 6, 0); draw_colored_polygon(shape, Color("#160E00") if talent["type"] == &"keystone" else Color("#080618")); var loop := shape.duplicate(); loop.append(shape[0]); draw_polyline(loop, Color(color, 0.45), 1.2, true)
		draw_circle(Vector2(30, 30), 18, Color(color, 0.12)); draw_arc(Vector2(30,30),18,0,TAU,24,Color(color,0.45),1.2,true); IconDraw.draw_item_icon(self, talent["icon"], Rect2(20,20,20,20), color)
		draw_string(UIFonts.cinzel_bold(), Vector2(56, 23), talent["name"], HORIZONTAL_ALIGNMENT_LEFT, size.x - 70, 10, color)
		draw_string(UIFonts.rajdhani_medium(), Vector2(56, 40), talent["bonus"], HORIZONTAL_ALIGNMENT_LEFT, size.x - 70, 8, Color("#6050A0"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(12, 53), status_text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 92, 7, color if can_increase else Color("#4A3870"))
		var bar_w := maxf(80, size.x - 110); var segment: float = (bar_w - 8) / talent["max"]
		for i in range(talent["max"]): draw_rect(Rect2(12 + i * (segment + 2), 66, segment, 5), color if i < talent["rank"] else Color("#1E1438"))
		draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 108, 73), "%d/%d" % [talent["rank"], talent["max"]], HORIZONTAL_ALIGNMENT_CENTER, 32, 9, color if talent["rank"] > 0 else Color("#3A2858"))


var _talents: Array[Dictionary] = []
var _state: HeroProgressionState
var _active_section: StringName = &"path1"
var _selected_id: StringName = &""
var _built: Array[Control] = []


func _ready() -> void:
	clip_contents = true
	resized.connect(_rebuild); _rebuild()


func bind_state(state: HeroProgressionState) -> void:
	if _state != null and _state.changed.is_connected(_on_state_changed):
		_state.changed.disconnect(_on_state_changed)
	_state = state
	_state.changed.connect(_on_state_changed)
	_talents = _state.talents_snapshot()
	_rebuild()


func _on_state_changed(change_kind: StringName) -> void:
	if change_kind == &"talents":
		_talents = _state.talents_snapshot()
		_rebuild()


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0 or size.y <= 0 or _state == null: return
	for child in get_children(): remove_child(child); child.queue_free()
	queue_redraw()
	var level: int = _state.identity_snapshot()["level"]
	var budget := TraitRules.points_for_level(level)
	var points := PointsHeader.new(); points.position = Vector2.ZERO; points.size = Vector2(size.x,48); points.spent = _spent(); points.budget = budget; points.remaining = budget - points.spent; add_child(points)
	var gap := 6.0; var tab_w := (size.x - 16 - gap*3) / 4.0
	for i in range(SECTION_ORDER.size()):
		var id := SECTION_ORDER[i]; var button := SectionButton.new(); button.section_id = id; button.meta = HeroData.talent_sections()[id]; button.active = id == _active_section; button.points = _section_points(id); button.character_level = level
		button.position = Vector2(8 + i*(tab_w+gap),48); button.size = Vector2(tab_w,38); button.pressed.connect(_select_section); add_child(button)
	var meta: Dictionary = HeroData.talent_sections()[_active_section]
	var detail_height := 92.0 if not _selected_id.is_empty() else 0.0
	var graph_rect := Rect2(6,92,size.x-12,maxf(0,size.y-98-detail_height))
	if level < meta["unlock"] or not meta.get("chosen", false):
		var locked := LockedView.new(); locked.meta = meta; locked.position = graph_rect.position; locked.size = graph_rect.size; add_child(locked)
	else:
		var graph := ConstellationGraph.new(); graph.meta = meta; graph.talents = _section_talents(_active_section); graph.positions = PATH_POS if meta["nodes"] == 12 else SPEC_POS; graph.edges = PATH_EDGES if meta["nodes"] == 12 else SPEC_EDGES; graph.selected_id = _selected_id; graph.available_ids = _available_ids(graph.talents, meta); graph.position = graph_rect.position; graph.size = graph_rect.size; graph.node_pressed.connect(_select_node); add_child(graph)
	if not _selected_id.is_empty():
		var talent := _find_talent(_selected_id)
		if not talent.is_empty():
			var detail := DetailPanel.new(); detail.talent = talent; detail.color = UIPalette.GOLD if talent["type"] == &"keystone" else meta["color"]
			detail.can_increase = TraitRules.can_increase_talent(talent, _talents, level, meta["unlock"])
			detail.can_decrease = TraitRules.can_refund_talent(talent["id"], _talents, level, _section_unlocks())
			if talent["rank"] >= talent["max"]: detail.status_text = "Maximum rank"
			elif _spent() >= budget: detail.status_text = "No talent points remaining"
			elif not TraitRules.talent_available(talent, _talents, level, meta["unlock"]): detail.status_text = TraitRules.talent_requirement_text(talent, _talents)
			elif talent["rank"] > 0 and not detail.can_decrease: detail.status_text = "Connected · required by another node"
			else: detail.status_text = "Ready to learn"
			detail.position = Vector2(8,size.y-90); detail.size = Vector2(size.x-16,84); detail.decrease_requested.connect(_decrease_rank); detail.increase_requested.connect(_increase_rank); add_child(detail)


func _select_section(section_id: StringName) -> void:
	_active_section = section_id; _selected_id = &""; _rebuild()


func _select_node(talent_id: StringName) -> void:
	_selected_id = &"" if _selected_id == talent_id else talent_id; _rebuild()


func _increase_rank(talent_id: StringName) -> void:
	var talent := _find_talent(talent_id)
	if talent.is_empty() or _state == null: return
	if _state.set_talent_rank(talent_id, int(talent["rank"]) + 1).ok:
		talent_rank_changed.emit(talent_id, int(talent["rank"]) + 1)


func _decrease_rank(talent_id: StringName) -> void:
	var talent := _find_talent(talent_id)
	if talent.is_empty() or _state == null: return
	if _state.set_talent_rank(talent_id, int(talent["rank"]) - 1).ok:
		talent_rank_changed.emit(talent_id, int(talent["rank"]) - 1)


func _find_talent(talent_id: StringName) -> Dictionary:
	for talent in _talents:
		if talent["id"] == talent_id: return talent
	return {}


func _section_talents(section_id: StringName) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for id in PATH_ORDER[section_id]: out.append(_find_talent(id))
	return out


func _spent() -> int:
	var total := 0
	for talent in _talents: total += talent["rank"]
	return total


func _section_points(section_id: StringName) -> int:
	var total := 0
	for talent in _talents:
		if talent["section"] == section_id: total += talent["rank"]
	return total


func _available_ids(talents: Array[Dictionary], meta: Dictionary) -> Array[StringName]:
	var out: Array[StringName] = []
	for talent in talents:
		if _state != null and meta.get("chosen", false) and TraitRules.talent_available(talent, _talents, _state.identity_snapshot()["level"], meta["unlock"]): out.append(talent["id"])
	return out


func _section_unlocks() -> Dictionary:
	var out := {}
	for section_id in SECTION_ORDER: out[section_id] = HeroData.talent_sections()[section_id]["unlock"]
	return out


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size), UIPalette.CANVAS)
