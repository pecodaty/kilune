class_name MailboxMessageRow
extends Control
## Expandable mailbox entry. Visual state is driven by the supplied mail data.

signal toggle_requested(mail_id: StringName)
signal claim_requested(mail_id: StringName)

const COLLAPSED_HEIGHT := 64.0
const EXPANDED_HEIGHT := 170.0

var _mail: Dictionary
var _expanded := false


func setup(mail: Dictionary, expanded: bool) -> void:
	_mail = mail
	_expanded = expanded
	custom_minimum_size.y = EXPANDED_HEIGHT if expanded else COLLAPSED_HEIGHT
	if is_node_ready(): _rebuild()


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	resized.connect(_layout)
	_rebuild()


func _rebuild() -> void:
	for child in get_children(): child.queue_free()
	if _mail.is_empty(): return
	queue_redraw()

	var header := Button.new()
	header.flat = true
	header.focus_mode = Control.FOCUS_NONE
	header.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	header.position = Vector2.ZERO
	header.size = Vector2(size.x, COLLAPSED_HEIGHT)
	header.pressed.connect(func() -> void: toggle_requested.emit(_mail["id"]))
	add_child(header)

	var title_color := Color("#4A3870") if _mail["read"] else Color("#D0C0F0")
	var title := UIFonts.make_label(_mail["title"], UIFonts.cinzel_bold(), 10, title_color)
	title.position = Vector2(96, 15); title.size = Vector2(maxf(80.0, size.x - 174.0), 20)
	title.clip_text = true; title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(title)
	var date := UIFonts.make_label(_mail["date"], UIFonts.rajdhani_medium(), 8, Color("#3A2858"))
	date.position = Vector2(96, 35); date.size = Vector2(maxf(80.0, size.x - 145.0), 16); add_child(date)

	if _mail.has("reward"):
		var reward: Dictionary = _mail["reward"]
		var icon := ShopIcon.new(); icon.icon_id = reward["icon"]; icon.accent = reward["color"]; icon.framed = true
		icon.position = Vector2(size.x - 66, 10); icon.size = Vector2(42, 42); add_child(icon)
		var qty := UIFonts.make_label(_quantity(reward["quantity"]), UIFonts.rajdhani_bold(), 7, reward["color"], HORIZONTAL_ALIGNMENT_RIGHT)
		qty.position = Vector2(size.x - 51, 39); qty.size = Vector2(25, 12); add_child(qty)

	if not _expanded: return
	var body := UIFonts.make_label(_mail["body"], UIFonts.rajdhani_medium(), 9, Color("#7060A0"))
	body.position = Vector2(18, 72); body.size = Vector2(size.x - 36, 32)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; body.vertical_alignment = VERTICAL_ALIGNMENT_TOP; add_child(body)
	if _mail.has("reward"):
		_build_reward_card(_mail["reward"])


func _build_reward_card(reward: Dictionary) -> void:
	var icon := ShopIcon.new(); icon.icon_id = reward["icon"]; icon.accent = reward["color"]
	icon.position = Vector2(22, 116); icon.size = Vector2(34, 34); add_child(icon)
	var caption := UIFonts.make_label("Attached Reward", UIFonts.rajdhani_semibold(), 8, Color("#5A4080"))
	caption.position = Vector2(68, 113); caption.size = Vector2(110, 16); add_child(caption)
	var qty := UIFonts.make_label("×%s" % _quantity_full(reward["quantity"]), UIFonts.rajdhani_bold(), 11, reward["color"])
	qty.position = Vector2(68, 130); qty.size = Vector2(90, 20); add_child(qty)
	var claim := ArcaneButton.new(); claim.text = "CLAIMED" if _mail.get("claimed", false) else "CLAIM"
	claim.position = Vector2(size.x - 92, 117); claim.size = Vector2(72, 32); claim.cut = 5
	claim.fill_top = Color(reward["color"], 0.24); claim.fill_bottom = Color(reward["color"], 0.12)
	claim.border_color = Color(reward["color"], 0.55); claim.disabled = _mail.get("claimed", false)
	claim.add_theme_font_override("font", UIFonts.cinzel_bold()); claim.add_theme_font_size_override("font_size", 8)
	claim.add_theme_color_override("font_color", reward["color"]); claim.add_theme_color_override("font_disabled_color", Color(reward["color"], 0.35))
	claim.pressed.connect(func() -> void: claim_requested.emit(_mail["id"])); add_child(claim)


func _layout() -> void:
	if not is_node_ready() or _mail.is_empty(): return
	_rebuild()


func _draw() -> void:
	if _mail.is_empty(): return
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, COLLAPSED_HEIGHT)), Color("#0A0614") if get_index() % 2 == 0 else Color("#080410"))
	draw_line(Vector2(0, COLLAPSED_HEIGHT - 0.5), Vector2(size.x, COLLAPSED_HEIGHT - 0.5), Color("#1E1433", 0.2), 1.0)
	var unread_color := UIPalette.GOLD if not _mail["read"] else Color("#3D2060")
	var envelope := Rect2(52, 18, 34, 24)
	draw_rect(envelope, Color(unread_color, 0.08)); draw_rect(envelope, unread_color, false, 1.2)
	draw_line(envelope.position, envelope.get_center() + Vector2(0, 2), unread_color, 1.2, true)
	draw_line(envelope.get_center() + Vector2(0, 2), Vector2(envelope.end.x, envelope.position.y), unread_color, 1.2, true)
	if _mail["new"]:
		var badge := UIDraw.clipped_rect(Vector2(28, 30), 3, 0, 3, 0)
		for i in range(badge.size()): badge[i] += Vector2(12, 17)
		draw_colored_polygon(badge, Color("#CC2200"))
		draw_string(UIFonts.cinzel_bold(), Vector2(16, 36), "NEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color.WHITE)
		draw_circle(Vector2(82, 19), 4, Color("#CC2200"))
	draw_string(UIFonts.rajdhani_bold(), Vector2(size.x - 15, 36), "▲" if _expanded else "▼", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#4A3068"))
	if _expanded:
		draw_rect(Rect2(0, COLLAPSED_HEIGHT, size.x, size.y - COLLAPSED_HEIGHT), Color("#09030F"))
		draw_line(Vector2(0, size.y - 0.5), Vector2(size.x, size.y - 0.5), Color("#1E1433", 0.35), 1.0)
		if _mail.has("reward"):
			var reward: Dictionary = _mail["reward"]
			var points := UIDraw.clipped_rect(Vector2(size.x - 32, 48), 6, 0, 6, 0)
			for i in range(points.size()): points[i] += Vector2(16, 108)
			draw_colored_polygon(points, Color(reward["color"], 0.055))
			var loop := points.duplicate(); loop.append(points[0]); draw_polyline(loop, Color(reward["color"], 0.22), 1.0, true)


func _quantity(value: int) -> String:
	return "%.1fk" % (value / 1000.0) if value >= 1000 else str(value)


func _quantity_full(value: int) -> String:
	var text := str(value)
	var result := ""
	while text.length() > 3:
		result = "," + text.right(3) + result
		text = text.left(text.length() - 3)
	return text + result
