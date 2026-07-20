class_name HeroHeader
extends Control
## Live Fern identity header shared by every Heroes sub-tab.

const HEIGHT := 66.0

class Avatar extends Control:
	func _draw() -> void:
		var shape := UIDraw.octagon(size, size.x * 0.22)
		draw_colored_polygon(shape, Color("#180D38"))
		UIDraw.draw_outline_diag(self, shape, size, UIPalette.gold_border_stops(), 1.5)
		IconDraw.draw_item_icon(self, &"leaf", Rect2(size * 0.20, size * 0.58), Color("#22DD6E"))
		IconDraw.draw_item_icon(self, &"star", Rect2(size * 0.52, size * 0.25), Color("#66DDFF"))


var _state: HeroProgressionState
var _name_label: Label
var _stats_label: Label
var _identity_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)
	var avatar := Avatar.new()
	avatar.custom_minimum_size = Vector2(46.0, 46.0)
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(avatar)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 1)
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(text_col)
	_name_label = UIFonts.make_label("FERN", UIFonts.cinzel_bold(), 15, UIPalette.GOLD)
	_stats_label = UIFonts.make_label("Lv.32", UIFonts.rajdhani_semibold(), 9, UIPalette.TEXT_CHAT)
	_identity_label = UIFonts.make_label("ADVENTURER · HARMONY → ORACLE", UIFonts.cinzel(600), 8, Color("#66DDFF"))
	text_col.add_child(_name_label)
	text_col.add_child(_stats_label)
	text_col.add_child(_identity_label)


func bind_state(state: HeroProgressionState) -> void:
	if _state != null and _state.changed.is_connected(_on_state_changed):
		_state.changed.disconnect(_on_state_changed)
	_state = state
	_state.changed.connect(_on_state_changed)
	_refresh()


func _on_state_changed(_change_kind: StringName) -> void:
	_refresh()


func _refresh() -> void:
	if _state == null or not is_node_ready():
		return
	var identity := _state.identity_snapshot()
	var stats := _state.stats_snapshot()
	var power := 0
	var max_hp := 0
	for stat in stats:
		if stat["id"] == &"power": power = roundi(stat["final"])
		elif stat["id"] == &"max_hp": max_hp = roundi(stat["final"])
	_name_label.text = identity["name"]
	_stats_label.text = "Lv.%d · HP %d · Power %d" % [identity["level"], max_hp, power]
	_identity_label.text = "%s · %s → %s" % [identity["title"], identity["path"].to_upper(), identity["specialization"].to_upper()]


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), UIPalette.HUD_TOP, UIPalette.HUD_BOTTOM)
	draw_line(Vector2(0.0, size.y - 0.5), Vector2(size.x, size.y - 0.5), Color(UIPalette.PURPLE_STRUCTURE, 0.33), 1.0)
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
