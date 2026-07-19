class_name MailboxScreen
extends Control
## Shared-shell Mailbox destination opened by the floating quick menu.

signal reward_claimed(mail_id: StringName, reward_id: StringName, quantity: int)

const ROW_SCENE := preload("res://scenes/ui/mailbox/mailbox_message_row.tscn")
const MAIL_DATA := [
	{"id":&"m1", "title":"UNCLAIMED EVENT REWARDS", "body":"You have unclaimed rewards from the Starfall Event. Collect before they expire!", "date":"2026/7/19  00:00 (UTC-4)", "new":true, "read":false, "reward":{"id":&"gems", "icon":&"gem", "quantity":150, "color":Color("#448AFF")}},
	{"id":&"m2", "title":"LEADER AUTO-TRANSFER NOTICE", "body":"Your guild leadership has been auto-transferred after 14 days of inactivity.", "date":"2026/7/18  00:00 (UTC-4)", "new":true, "read":false},
	{"id":&"m3", "title":"UNCLAIMED BATTLE PASS REWARDS", "body":"Battle Pass Season 3 rewards are waiting. Claim your premium track bonuses now.", "date":"2026/7/18  18:47 (UTC-4)", "new":true, "read":false, "reward":{"id":&"gems", "icon":&"gem", "quantity":200, "color":Color("#448AFF")}},
	{"id":&"m4", "title":"CHRONO TOWER WEEK REWARDS", "body":"Congratulations! You ranked in the top 500 this week. Here are your tower rewards.", "date":"2026/7/18  18:47 (UTC-4)", "new":true, "read":false, "reward":{"id":&"talent_materials", "icon":&"star", "quantity":5, "color":Color("#FFD700")}},
	{"id":&"m5", "title":"CLOUD ASCENSION REWARDS", "body":"Your Cloud Ascension run rewards for this period have been distributed. Well done!", "date":"2026/7/18  18:47 (UTC-4)", "new":true, "read":false, "reward":{"id":&"scrolls", "icon":&"ticket", "quantity":3, "color":Color("#AA44FF")}},
	{"id":&"m6", "title":"MAINTENANCE COMPENSATION", "body":"Thank you for your patience during scheduled maintenance. Here is a small gift from us.", "date":"2026/7/17  09:00 (UTC-4)", "new":false, "read":true, "reward":{"id":&"gold", "icon":&"coin", "quantity":5000, "color":Color("#FF9922")}},
	{"id":&"m7", "title":"GUILD DONATION BONUS", "body":"Your guild reached Donation Level 5 this week. Bonus rewards have been issued to all members.", "date":"2026/7/16  12:00 (UTC-4)", "new":false, "read":true},
]

var _mails: Array[Dictionary] = []
var _expanded: StringName = &""
var _list_scroll: ScrollContainer
var _list: VBoxContainer
var _drag_active := false
var _drag_started := false
var _drag_pointer := -1
var _drag_origin := Vector2.ZERO
var _drag_scroll_origin := 0


func _ready() -> void:
	clip_contents = true
	for mail in MAIL_DATA: _mails.append(mail.duplicate(true))
	resized.connect(_rebuild)
	_rebuild()


func open() -> void:
	show()
	_rebuild()


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0.0 or size.y <= 0.0: return
	for child in get_children(): child.queue_free()
	queue_redraw()
	_build_header()
	_build_list()
	_build_actions()


func _build_header() -> void:
	var icon := QuickMenuIcon.new(); icon.icon_id = &"mail"; icon.accent = UIPalette.GOLD
	icon.position = Vector2(14, 12); icon.size = Vector2(34, 34); add_child(icon)
	var title := _label("MAILBOX", true, 16, UIPalette.GOLD)
	title.position = Vector2(54, 10); title.size = Vector2(190, 26); add_child(title)
	var unread := _unread_count()
	if unread > 0:
		var count := _label("%d unread" % unread, false, 8, Color("#FF9922"))
		count.position = Vector2(54, 34); count.size = Vector2(100, 16); add_child(count)


func _build_list() -> void:
	_list_scroll = ScrollContainer.new(); _list_scroll.position = Vector2(0, 58); _list_scroll.size = Vector2(size.x, maxf(0.0, size.y - 116.0))
	_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; _list_scroll.scroll_deadzone = 4; add_child(_list_scroll)
	var bar := _list_scroll.get_v_scroll_bar(); bar.custom_minimum_size.x = 0; bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_list = VBoxContainer.new(); _list.custom_minimum_size.x = size.x; _list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 0); _list_scroll.add_child(_list)
	if _mails.is_empty():
		_build_empty_state()
		return
	for mail in _mails:
		var row: MailboxMessageRow = ROW_SCENE.instantiate()
		row.setup(mail, mail["id"] == _expanded)
		row.toggle_requested.connect(_toggle_mail)
		row.claim_requested.connect(_claim_mail)
		_list.add_child(row)


func _build_empty_state() -> void:
	var empty := Control.new(); empty.custom_minimum_size = Vector2(size.x, maxf(220.0, _list_scroll.size.y)); _list.add_child(empty)
	var icon := QuickMenuIcon.new(); icon.icon_id = &"mail"; icon.accent = Color("#4A3068")
	icon.position = Vector2((size.x - 56) * 0.5, 64); icon.size = Vector2(56, 56); empty.add_child(icon)
	var text := _label("NO MAIL", true, 11, Color("#2A1845"), HORIZONTAL_ALIGNMENT_CENTER)
	text.position = Vector2(30, 125); text.size = Vector2(size.x - 60, 24); empty.add_child(text)


func _build_actions() -> void:
	var y := size.y - 52.0
	var gap := 12.0; var width := (size.x - 44.0) * 0.5
	var delete := _button("DELETE READ", Color("#CC4422"), Color("#CC2200"), Color("#2A0A0A"))
	delete.position = Vector2(16, y); delete.size = Vector2(width, 40); delete.disabled = not _has_read_mail()
	delete.pressed.connect(_delete_read); add_child(delete)
	var claim := _button("CLAIM ALL", Color("#22DD6E"), Color("#22DD6E"), Color("#0F3D18"))
	claim.position = Vector2(16 + width + gap, y); claim.size = Vector2(width, 40); claim.disabled = not _has_claimable_reward()
	claim.pressed.connect(_claim_all); add_child(claim)


func _toggle_mail(mail_id: StringName) -> void:
	var mail := _find_mail(mail_id)
	if mail.is_empty(): return
	mail["new"] = false; mail["read"] = true
	_expanded = &"" if _expanded == mail_id else mail_id
	_rebuild()


func _claim_mail(mail_id: StringName) -> void:
	var mail := _find_mail(mail_id)
	if mail.is_empty() or not mail.has("reward") or mail.get("claimed", false): return
	mail["claimed"] = true; mail["new"] = false; mail["read"] = true
	var reward: Dictionary = mail["reward"]
	reward_claimed.emit(mail_id, reward["id"], reward["quantity"])
	_rebuild()


func _claim_all() -> void:
	for mail in _mails:
		if mail.has("reward") and not mail.get("claimed", false):
			mail["claimed"] = true
			var reward: Dictionary = mail["reward"]
			reward_claimed.emit(mail["id"], reward["id"], reward["quantity"])
		mail["new"] = false; mail["read"] = true
	_rebuild()


func _delete_read() -> void:
	for index in range(_mails.size() - 1, -1, -1):
		if _mails[index]["read"]: _mails.remove_at(index)
	_expanded = &""
	_rebuild()


func _find_mail(mail_id: StringName) -> Dictionary:
	for mail in _mails:
		if mail["id"] == mail_id: return mail
	return {}


func _unread_count() -> int:
	var count := 0
	for mail in _mails:
		if mail["new"]: count += 1
	return count


func _has_read_mail() -> bool:
	for mail in _mails:
		if mail["read"]: return true
	return false


func _has_claimable_reward() -> bool:
	for mail in _mails:
		if mail.has("reward") and not mail.get("claimed", false): return true
	return false


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not is_instance_valid(_list_scroll): return
	if event is InputEventScreenTouch:
		if event.pressed and not _drag_active and _list_scroll.get_global_rect().has_point(event.position): _begin_drag(event.position, event.index)
		elif not event.pressed and _drag_active and event.index == _drag_pointer: _end_drag()
	elif event is InputEventScreenDrag and _drag_active and event.index == _drag_pointer: _update_drag(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not _drag_active and _list_scroll.get_global_rect().has_point(event.position): _begin_drag(event.position, -1)
		elif not event.pressed and _drag_active and _drag_pointer == -1: _end_drag()
	elif event is InputEventMouseMotion and _drag_active and _drag_pointer == -1: _update_drag(event.position)


func _begin_drag(position: Vector2, pointer: int) -> void:
	_drag_active = true; _drag_started = false; _drag_pointer = pointer
	_drag_origin = position; _drag_scroll_origin = _list_scroll.scroll_vertical


func _update_drag(position: Vector2) -> void:
	var distance := position.y - _drag_origin.y
	if absf(distance) > 6.0: _drag_started = true
	if _drag_started:
		_list_scroll.scroll_vertical = _drag_scroll_origin - int(distance)
		get_viewport().set_input_as_handled()


func _end_drag() -> void:
	if _drag_started: get_viewport().set_input_as_handled()
	_drag_active = false; _drag_started = false; _drag_pointer = -1


func _button(text: String, color: Color, border: Color, fill: Color) -> ArcaneButton:
	var button := ArcaneButton.new(); button.text = text; button.cut = 8
	button.fill_top = fill; button.fill_bottom = Color(fill, 0.72); button.border_color = Color(border, 0.45)
	button.add_theme_font_override("font", UIFonts.cinzel_bold()); button.add_theme_font_size_override("font_size", 9)
	button.add_theme_color_override("font_color", color); button.add_theme_color_override("font_disabled_color", Color(color, 0.28))
	return button


func _label(text: String, title: bool, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	return UIFonts.make_label(text, UIFonts.cinzel_bold() if title else UIFonts.rajdhani_bold(), font_size, color, align)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#07030E"), Color("#0A0418"))
	draw_rect(Rect2(0, 0, size.x, 58), Color("#100A04", 0.42))
	draw_line(Vector2(0, 57.5), Vector2(size.x, 57.5), Color(UIPalette.GOLD_MUTED, 0.24), 1.0)
	draw_line(Vector2(0, size.y - 58.5), Vector2(size.x, size.y - 58.5), Color("#1E1433", 0.3), 1.0)
	var c := Color(UIPalette.GOLD, 0.65)
	for points in [[Vector2(0,30),Vector2(0,2),Vector2(30,2)],[Vector2(size.x-30,2),Vector2(size.x,2),Vector2(size.x,30)],[Vector2(0,size.y-30),Vector2(0,size.y-2),Vector2(30,size.y-2)],[Vector2(size.x-30,size.y-2),Vector2(size.x,size.y-2),Vector2(size.x,size.y-30)]]:
		draw_polyline(PackedVector2Array(points), c, 1.5, true)
