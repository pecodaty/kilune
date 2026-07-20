class_name DungeonFlow
extends Control
## Full-screen Dungeon state machine: list -> level pick -> combat -> leave modal.

signal closed

const COMBAT_VIEW_SCENE := preload("res://scenes/ui/gameplay/combat_view.tscn")
const SKILL_DOCK_SCENE := preload("res://scenes/ui/gameplay/skill_dock.tscn")

enum View { LIST, LEVEL, COMBAT }

var _view := View.LIST
var _dungeons: Array[Dictionary] = []
var _selected: Dictionary = {}
var _activity_state: ActivityState
var _profile: PlayerProfile
var _level := 1
var _phase := 1
var _enemy_hp := 100
var _combat_timer: Timer
var _enemy_fill: ColorRect
var _enemy_hp_label: Label
var _phase_label: Label
var _phase_bars: Array[ColorRect] = []
var _modal: Control


func _ready() -> void:
	clip_contents = true
	_dungeons = GameCatalog.dungeon_snapshots()
	_selected = _dungeons[0]
	resized.connect(_rebuild)
	_show_list()


func bind_activity_state(activity_state: ActivityState) -> void:
	if _activity_state != null and _activity_state.changed.is_connected(_on_activity_changed):
		_activity_state.changed.disconnect(_on_activity_changed)
	_activity_state = activity_state
	_activity_state.changed.connect(_on_activity_changed)
	if is_node_ready() and visible:
		_rebuild()


func bind_profile(profile: PlayerProfile) -> void:
	_profile = profile
	bind_activity_state(profile.activity)


func _on_activity_changed(_change_kind: StringName) -> void:
	if visible and _view != View.COMBAT:
		_rebuild()


func _attempts(activity_id: StringName) -> int:
	return _activity_state.attempts(activity_id) if _activity_state != null else ActivityState.DEFAULT_ATTEMPTS


func open() -> void:
	_show_list()


func _clear_view() -> void:
	if is_instance_valid(_combat_timer):
		_combat_timer.stop()
		_combat_timer.queue_free()
	_combat_timer = null
	_modal = null
	_phase_bars.clear()
	for child in get_children():
		child.queue_free()


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0.0 or size.y <= 0.0:
		return
	match _view:
		View.LIST:
			_show_list()
		View.LEVEL:
			_show_level_pick()
		View.COMBAT:
			_show_combat()


func _new_frame(title_text: String, subtitle_text := "") -> DungeonFrame:
	var frame := DungeonFrame.new()
	frame.title = title_text
	frame.subtitle = subtitle_text
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(frame)
	return frame


func _label(text: String, title_font: bool, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	return UIFonts.make_label(
		text,
		UIFonts.cinzel_bold() if title_font else UIFonts.rajdhani_semibold(),
		font_size,
		color,
		align
	)


func _button(text: String, font_size: int, color: Color) -> ArcaneButton:
	var button := ArcaneButton.new()
	button.text = text
	button.add_theme_font_override("font", UIFonts.cinzel_bold() if font_size >= 12 else UIFonts.rajdhani_bold())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", color)
	return button


# Dungeon list ---------------------------------------------------------------

func _show_list() -> void:
	_view = View.LIST
	_clear_view()
	_new_frame("DUNGEONS")
	var close := _button("Close", 10, Color("#6050A0"))
	close.position = Vector2(size.x - 74, 61)
	close.size = Vector2(58, 28)
	close.pressed.connect(func() -> void: closed.emit())
	add_child(close)

	var card_x := 16.0
	var card_w := size.x - card_x * 2.0
	var card_h := minf(116.0, (size.y - 152.0) / 4.25)
	var gap := 8.0
	for i in range(_dungeons.size()):
		_add_dungeon_card(_dungeons[i], Vector2(card_x, 108.0 + i * (card_h + gap)), Vector2(card_w, card_h))


func _add_dungeon_card(data: Dictionary, at: Vector2, card_size: Vector2) -> void:
	var card := ArcaneButton.new()
	card.fill_top = Color("#140734")
	card.fill_bottom = Color("#0C021A")
	card.border_color = Color("#2A1499", 0.42)
	card.position = at
	card.size = card_size
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)

	var accent := ColorRect.new()
	accent.color = data["color"]
	accent.position = Vector2(0, 0)
	accent.size = Vector2(card_size.x, 2)
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(accent)

	var icon := DungeonIcon.new()
	icon.icon_id = data["icon"]
	icon.accent = data["color"]
	icon.position = Vector2(14, 12)
	icon.size = Vector2(36, 36)
	card.add_child(icon)

	var name_label := _label(data["name"], true, 12, Color("#D0C0F0"))
	name_label.position = Vector2(62, 9)
	name_label.size = Vector2(card_size.x - 76, 20)
	card.add_child(name_label)
	var desc := _label(data["description"], false, 10, Color("#5A4888"))
	desc.position = Vector2(62, 27)
	desc.size = Vector2(card_size.x - 76, 24)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(desc)

	var reward := _label("Reward: %s" % data["reward"], false, 9, data["color"])
	reward.position = Vector2(14, card_size.y - 61)
	reward.size = Vector2(card_size.x * 0.68, 18)
	card.add_child(reward)
	var attempts := _label("Attempts: %d/3" % _attempts(data["id"]), false, 9, Color("#5A4888"), HORIZONTAL_ALIGNMENT_RIGHT)
	attempts.position = Vector2(card_size.x - 115, card_size.y - 61)
	attempts.size = Vector2(100, 18)
	card.add_child(attempts)

	var enter := _button("ENTER", 11, Color("#001A22"))
	enter.fill_top = Color("#00BCD4")
	enter.fill_bottom = Color("#006070")
	enter.border_color = Color("#00BCD4", 0.4)
	enter.cut = 8.0
	enter.position = Vector2(0, card_size.y - 36)
	enter.size = Vector2(card_size.x, 36)
	enter.pressed.connect(func() -> void:
		_selected = data
		_level = 1
		_show_level_pick()
	)
	card.add_child(enter)


# Level pick -----------------------------------------------------------------

func _show_level_pick() -> void:
	_view = View.LEVEL
	_clear_view()
	_new_frame(String(_selected["name"]).to_upper(), "Enemy & Boss Preview")
	var icon := DungeonIcon.new()
	icon.icon_id = _selected["icon"]
	icon.accent = _selected["color"]
	icon.ornate = true
	icon.position = Vector2((size.x - 64.0) * 0.5, 120)
	icon.size = Vector2(64, 64)
	add_child(icon)

	var left := _button("◄", 14, Color("#8066C0") if _level > 1 else Color("#2A1845"))
	left.position = Vector2(size.x * 0.5 - 98, 206)
	left.size = Vector2(32, 32)
	left.disabled = _level <= 1
	left.pressed.connect(func() -> void:
		_level = maxi(1, _level - 1)
		_show_level_pick()
	)
	add_child(left)
	var level_label := _label("LEVEL %d" % _level, true, 20, Color("#D0C0F0"), HORIZONTAL_ALIGNMENT_CENTER)
	level_label.position = Vector2(size.x * 0.5 - 58, 202)
	level_label.size = Vector2(116, 40)
	add_child(level_label)
	var right := _button("►", 14, Color("#8066C0") if _level < 5 else Color("#2A1845"))
	right.position = Vector2(size.x * 0.5 + 66, 206)
	right.size = Vector2(32, 32)
	right.disabled = _level >= 5
	right.pressed.connect(func() -> void:
		_level = mini(5, _level + 1)
		_show_level_pick()
	)
	add_child(right)

	var info := Panel.new()
	var info_style := StyleBoxFlat.new()
	info_style.bg_color = Color("#0A0628", 0.55)
	info_style.border_color = Color("#2A18AA", 0.22)
	info_style.set_border_width_all(1)
	info.add_theme_stylebox_override("panel", info_style)
	info.position = Vector2(32, 258)
	info.size = Vector2(size.x - 64, 104)
	add_child(info)
	var rows := [
		["Attempts Remaining", "%d / 3" % _attempts(_selected["id"])],
		["Recommended Power", str(int(_selected["power"]) * _level)],
		["Rewards", _selected["reward_description"]],
	]
	for i in range(rows.size()):
		var key := _label(rows[i][0], false, 11, Color("#5A4888"))
		key.position = Vector2(20, 12 + i * 28)
		key.size = Vector2(170, 20)
		info.add_child(key)
		var value := _label(rows[i][1], false, 11, Color("#C0B0E0"), HORIZONTAL_ALIGNMENT_RIGHT)
		value.position = Vector2(info.size.x - 150, 12 + i * 28)
		value.size = Vector2(130, 20)
		info.add_child(value)

	var challenge := _button("CHALLENGE", 14, Color("#E0D0FF"))
	challenge.fill_top = Color("#5533CC")
	challenge.fill_bottom = Color("#2A0A6A")
	challenge.border_color = Color("#8855FF", 0.65)
	challenge.cut = 10
	challenge.position = Vector2(32, 382)
	challenge.size = Vector2(size.x - 64, 46)
	challenge.pressed.connect(_show_combat)
	add_child(challenge)
	var back := _button("BACK", 12, Color("#5040A0"))
	back.position = Vector2(32, 450)
	back.size = Vector2(size.x - 64, 38)
	back.cut = 10
	back.pressed.connect(_show_list)
	add_child(back)


# Combat ---------------------------------------------------------------------

func _show_combat() -> void:
	_view = View.COMBAT
	_clear_view()
	_phase = 1
	_enemy_hp = 100
	var backdrop := ColorRect.new()
	backdrop.color = UIPalette.CANVAS
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var combat: CombatView = COMBAT_VIEW_SCENE.instantiate()
	combat.position = Vector2(0, 48)
	combat.size = Vector2(size.x, size.y - 112)
	combat.auto_enabled = true
	add_child(combat)

	_add_combat_header()
	_add_enemy_ui()

	var leave := _button("Leave", 10, Color("#6050A0"))
	leave.position = Vector2(size.x - 68, size.y - 98)
	leave.size = Vector2(54, 28)
	leave.pressed.connect(_show_leave_modal)
	add_child(leave)

	var dock: SkillDock = SKILL_DOCK_SCENE.instantiate()
	if _profile != null:
		dock.bind_profile(_profile)
	dock.position = Vector2(0, size.y - 64)
	dock.size = Vector2(size.x, 64)
	dock.skill_pressed.connect(func(_slot: int) -> void: combat.play_attack())
	dock.auto_toggled.connect(func(active: bool) -> void:
		combat.auto_enabled = active
		if is_instance_valid(_combat_timer):
			_combat_timer.paused = not active
	)
	add_child(dock)

	_combat_timer = Timer.new()
	_combat_timer.wait_time = 0.28
	_combat_timer.timeout.connect(_on_combat_tick)
	add_child(_combat_timer)
	_combat_timer.start()


func _add_combat_header() -> void:
	var header := ColorRect.new()
	header.color = Color("#0C0822", 0.88)
	header.position = Vector2.ZERO
	header.size = Vector2(size.x, 48)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	var title_label := _label("%s · LEVEL %d" % [String(_selected["name"]).to_upper(), _level], true, 13, Color("#D0C0F0"), HORIZONTAL_ALIGNMENT_CENTER)
	title_label.position = Vector2(45, 5)
	title_label.size = Vector2(size.x - 90, 20)
	header.add_child(title_label)
	var bar_w := 22.0
	var start_x := size.x * 0.5 - 64.0
	for i in range(5):
		var bar := ColorRect.new()
		bar.color = _selected["color"] if i == 0 else Color("#1A0A3A")
		bar.position = Vector2(start_x + i * (bar_w + 8), 29)
		bar.size = Vector2(bar_w, 4)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		header.add_child(bar)
		_phase_bars.append(bar)
	_phase_label = _label("Phase 1/5", false, 9, Color("#6050A0"))
	_phase_label.position = Vector2(start_x + 5 * 30, 23)
	_phase_label.size = Vector2(64, 16)
	header.add_child(_phase_label)
	var count := _label("1 Enemy", false, 9, Color("#C0B0E0"), HORIZONTAL_ALIGNMENT_CENTER)
	count.position = Vector2(size.x - 62, 9)
	count.size = Vector2(52, 20)
	header.add_child(count)


func _add_enemy_ui() -> void:
	var enemy := Control.new()
	enemy.position = Vector2(size.x - 108, size.y - 230)
	enemy.size = Vector2(92, 110)
	add_child(enemy)
	var name_plate := _label(_selected["enemy"], true, 9, Color("#FF9966"), HORIZONTAL_ALIGNMENT_CENTER)
	name_plate.position = Vector2(0, 0)
	name_plate.size = Vector2(92, 28)
	var plate_style := StyleBoxFlat.new()
	plate_style.bg_color = Color("#1A0505", 0.75)
	plate_style.border_color = Color("#FF6633", 0.55)
	plate_style.set_border_width_all(1)
	name_plate.add_theme_stylebox_override("normal", plate_style)
	enemy.add_child(name_plate)
	var icon := DungeonIcon.new()
	icon.icon_id = _selected["enemy_icon"]
	icon.accent = _selected["color"]
	icon.position = Vector2(24, 32)
	icon.size = Vector2(44, 44)
	enemy.add_child(icon)
	var hp_bg := ColorRect.new()
	hp_bg.color = Color("#0A0820")
	hp_bg.position = Vector2(0, 82)
	hp_bg.size = Vector2(92, 4)
	enemy.add_child(hp_bg)
	_enemy_fill = ColorRect.new()
	_enemy_fill.color = Color("#FF4444")
	_enemy_fill.position = Vector2.ZERO
	_enemy_fill.size = hp_bg.size
	hp_bg.add_child(_enemy_fill)
	_enemy_hp_label = _label("100/100", false, 8, Color("#FF7755"))
	_enemy_hp_label.position = Vector2(0, 89)
	_enemy_hp_label.size = Vector2(92, 16)
	enemy.add_child(_enemy_hp_label)


func _on_combat_tick() -> void:
	_enemy_hp = maxi(0, _enemy_hp - 8)
	_enemy_fill.size.x = 92.0 * float(_enemy_hp) / 100.0
	_enemy_hp_label.text = "%d/100" % _enemy_hp
	if _enemy_hp > 0:
		return
	if _phase < 5:
		_phase += 1
		_enemy_hp = 100
		_phase_label.text = "Phase %d/5" % _phase
		for i in range(_phase_bars.size()):
			_phase_bars[i].color = _selected["color"] if i < _phase else Color("#1A0A3A")
	else:
		_combat_timer.stop()
		_show_victory()


func _show_victory() -> void:
	var panel := Panel.new()
	panel.position = Vector2(55, size.y * 0.38)
	panel.size = Vector2(size.x - 110, 150)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0D0822", 0.92)
	style.border_color = Color(UIPalette.GOLD, 0.4)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var clear := _label("DUNGEON CLEAR!", true, 15, UIPalette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	clear.position = Vector2(10, 24)
	clear.size = Vector2(panel.size.x - 20, 28)
	panel.add_child(clear)
	var reward := _label("Rewards: %s" % _selected["reward_description"], false, 10, Color("#8066C0"), HORIZONTAL_ALIGNMENT_CENTER)
	reward.position = Vector2(10, 55)
	reward.size = Vector2(panel.size.x - 20, 24)
	panel.add_child(reward)
	var collect := _button("COLLECT", 11, Color("#E0D0FF"))
	collect.fill_top = Color("#5533CC")
	collect.fill_bottom = Color("#2A0A6A")
	collect.position = Vector2((panel.size.x - 110) * 0.5, 92)
	collect.size = Vector2(110, 34)
	collect.pressed.connect(_show_list)
	panel.add_child(collect)


# Leave modal ----------------------------------------------------------------

func _show_leave_modal() -> void:
	if is_instance_valid(_modal):
		return
	if is_instance_valid(_combat_timer):
		_combat_timer.paused = true
	_modal = Control.new()
	_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_modal)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.55)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_modal.add_child(shade)
	var panel := Panel.new()
	panel.position = Vector2((size.x - 290) * 0.5, (size.y - 190) * 0.5)
	panel.size = Vector2(290, 190)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0E0A2A")
	style.border_color = Color("#4422AA", 0.6)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	_modal.add_child(panel)
	var gem := DungeonIcon.new()
	gem.icon_id = &"gem"
	gem.accent = UIPalette.CYAN
	gem.position = Vector2(129, -16)
	gem.size = Vector2(32, 32)
	panel.add_child(gem)
	var divider := ColorRect.new()
	divider.color = Color("#4422AA", 0.45)
	divider.position = Vector2(22, 28)
	divider.size = Vector2(246, 1)
	panel.add_child(divider)
	var title_label := _label("LEAVE DUNGEON?", true, 15, Color("#D0C0F0"), HORIZONTAL_ALIGNMENT_CENTER)
	title_label.position = Vector2(16, 43)
	title_label.size = Vector2(258, 26)
	panel.add_child(title_label)
	var body := _label("This attempt has already been used.\nLeave without claiming rewards?", false, 10, Color("#5A4888"), HORIZONTAL_ALIGNMENT_CENTER)
	body.position = Vector2(20, 76)
	body.size = Vector2(250, 42)
	panel.add_child(body)
	var confirm := _button("LEAVE", 12, Color("#E0D0FF"))
	confirm.fill_top = Color("#5533CC")
	confirm.fill_bottom = Color("#2A0A6A")
	confirm.border_color = Color("#8855FF", 0.55)
	confirm.position = Vector2(22, 132)
	confirm.size = Vector2(119, 38)
	confirm.pressed.connect(_show_list)
	panel.add_child(confirm)
	var cancel := _button("CANCEL", 12, Color("#5040A0"))
	cancel.position = Vector2(153, 132)
	cancel.size = Vector2(115, 38)
	cancel.pressed.connect(_close_leave_modal)
	panel.add_child(cancel)


func _close_leave_modal() -> void:
	if is_instance_valid(_modal):
		_modal.queue_free()
	_modal = null
	if is_instance_valid(_combat_timer):
		_combat_timer.paused = false
