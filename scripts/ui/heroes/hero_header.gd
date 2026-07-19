class_name HeroHeader
extends Control
## Hero identity header above the Heroes sub-tab content: class avatar, name,
## stats, and the Back action that returns to battle.
## Reference: App.tsx `HeroHeader`.

signal back_pressed

const HEIGHT := 66.0

## 46px octagon avatar with a gold gradient ring and the class rune.
class Avatar extends Control:
	func _draw() -> void:
		var shape := UIDraw.octagon(size, size.x * 0.22)
		draw_colored_polygon(shape, Color("#180D38"))
		UIDraw.draw_outline_diag(self, shape, size, UIPalette.gold_border_stops(), 1.5)
		ClassRunes.draw_rune(self, &"druid", Rect2(size * 0.22, size * 0.56), UIPalette.HP)


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, HEIGHT)
	var h: Dictionary = HeroData.hero()
	var cls: Dictionary = HeroClassData.class_data(h["class_id"])

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
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
	text_col.add_child(UIFonts.make_label(h["name"], UIFonts.cinzel_bold(), 15, UIPalette.GOLD))
	text_col.add_child(UIFonts.make_label(HeroData.stats_line(), UIFonts.rajdhani_semibold(), 9, UIPalette.TEXT_CHAT))
	text_col.add_child(UIFonts.make_label(String(cls["name"]).to_upper(), UIFonts.cinzel(600), 8, cls["color"]))

	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 5)
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(actions)

	var back := HeroPillBtn.new()
	back.setup("Back", UIPalette.TEXT_MUTED, 22.0, false, 8)
	back.pressed.connect(func() -> void: back_pressed.emit())
	actions.add_child(back)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), UIPalette.HUD_TOP, UIPalette.HUD_BOTTOM)
	draw_line(Vector2(0.0, size.y - 0.5), Vector2(size.x, size.y - 0.5),
		Color(UIPalette.PURPLE_STRUCTURE, 0.33), 1.0)
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
