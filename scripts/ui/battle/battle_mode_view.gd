class_name BattleModeView
extends Control
## Battle-mode lobby shown inside the shared HUD/navigation shell.

signal dungeons_requested
signal home_requested

var _frame: DungeonFrame
var _dungeon_button: ArcaneButton


func _ready() -> void:
	clip_contents = true
	_frame = DungeonFrame.new()
	_frame.title = "BATTLE"
	_frame.subtitle = "Choose a battle mode."
	_frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_frame)

	var home := _make_button("Home", 10)
	home.custom_minimum_size = Vector2(58, 28)
	home.position = Vector2(size.x - 74, 61)
	home.pressed.connect(func() -> void: home_requested.emit())
	add_child(home)

	_dungeon_button = ArcaneButton.new()
	_dungeon_button.fill_top = Color("#180936")
	_dungeon_button.fill_bottom = Color("#0C041E")
	_dungeon_button.border_color = Color("#3A1A99", 0.45)
	_dungeon_button.position = Vector2(16, 116)
	_dungeon_button.size = Vector2(size.x - 32, 80)
	_dungeon_button.pressed.connect(func() -> void: dungeons_requested.emit())
	add_child(_dungeon_button)

	var marker := ColorRect.new()
	marker.color = UIPalette.CYAN
	marker.position = Vector2.ZERO
	marker.size = Vector2(3, 80)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dungeon_button.add_child(marker)

	var icon := DungeonIcon.new()
	icon.icon_id = &"key"
	icon.accent = UIPalette.GOLD
	icon.ornate = true
	icon.position = Vector2(18, 15)
	icon.size = Vector2(50, 50)
	_dungeon_button.add_child(icon)
	var title_label := UIFonts.make_label("DUNGEONS", UIFonts.cinzel_bold(), 16, Color("#D0C0F0"))
	title_label.position = Vector2(84, 15)
	title_label.size = Vector2(220, 24)
	_dungeon_button.add_child(title_label)
	var sub := UIFonts.make_label("Fixed Encounters · Daily Rewards", UIFonts.rajdhani_medium(), 11, Color("#5A4888"))
	sub.position = Vector2(84, 38)
	sub.size = Vector2(230, 22)
	_dungeon_button.add_child(sub)
	var arrow := UIFonts.make_label("›", UIFonts.rajdhani_bold(), 28, Color("#4A22AA"), HORIZONTAL_ALIGNMENT_CENTER)
	arrow.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	arrow.position = Vector2(-42, -18)
	arrow.size = Vector2(30, 36)
	_dungeon_button.add_child(arrow)
	resized.connect(_layout)
	_layout()


func _make_button(label_text: String, font_size: int) -> ArcaneButton:
	var button := ArcaneButton.new()
	button.text = label_text
	button.add_theme_font_override("font", UIFonts.rajdhani_bold())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color("#6050A0"))
	return button


func _layout() -> void:
	if not is_node_ready():
		return
	for child in get_children():
		if child is ArcaneButton and child != _dungeon_button:
			child.position.x = size.x - 74.0
	_dungeon_button.size.x = size.x - 32.0
