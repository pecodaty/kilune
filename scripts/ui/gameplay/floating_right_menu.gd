class_name FloatingRightMenu
extends Control
## Collapsible quick-action rail shown over the main Battle content.

signal backpack_requested
signal mail_requested
signal map_requested
signal config_requested

const ACTIONS := [
	["BAG", &"bag", Color("#00E5C8")],
	["MAIL", &"mail", UIPalette.GOLD],
	["MAP", &"map", Color("#22DD6E")],
	["CONFIG", &"config", Color("#AA44FF")],
]

var _open := false
var _toggle: ArcaneButton
var _rows: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_rebuild)
	_rebuild()


func close() -> void:
	_open = false
	_apply_state(false)


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0.0: return
	for child in get_children(): child.queue_free()
	_rows.clear()
	var top := size.y * 0.28
	_toggle = _button("◀", UIPalette.CYAN, UIPalette.CYAN)
	_toggle.position = Vector2(size.x - 20, top); _toggle.size = Vector2(20,44); _toggle.cut = 6
	_toggle.pressed.connect(_toggle_open); add_child(_toggle)
	for i in range(ACTIONS.size()):
		var action: Array = ACTIONS[i]; var row := Control.new()
		row.position = Vector2(size.x + 2, top + 50 + i*44); row.size = Vector2(82,36); row.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(row); _rows.append(row)
		var label := _button(action[0], action[2], action[2]); label.position=Vector2(0,5); label.size=Vector2(42,26); label.mouse_filter=Control.MOUSE_FILTER_IGNORE; row.add_child(label)
		var icon_button := _button("", action[2], action[2]); icon_button.position=Vector2(46,0); icon_button.size=Vector2(36,36); row.add_child(icon_button)
		var icon := QuickMenuIcon.new(); icon.icon_id=action[1]; icon.accent=action[2]; icon.position=Vector2(7,7); icon.size=Vector2(22,22); icon_button.add_child(icon)
		var action_id: StringName = action[1]
		icon_button.pressed.connect(func() -> void: _activate(action_id))
	_apply_state(false)


func _toggle_open() -> void:
	_open = not _open
	_apply_state(true)


func _apply_state(animated: bool) -> void:
	if not is_instance_valid(_toggle): return
	_toggle.text = "▶" if _open else "◀"
	for i in range(_rows.size()):
		var row := _rows[i]
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var destination := size.x - 82.0 if _open else size.x + 2.0
		if animated:
			var tween := create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tween.tween_property(row,"position:x",destination,0.12 + i*0.045)
		else: row.position.x = destination
		row.modulate.a = 1.0 if _open else 0.0
		for child in row.get_children(): child.mouse_filter = Control.MOUSE_FILTER_STOP if _open and child is BaseButton and child.text.is_empty() else Control.MOUSE_FILTER_IGNORE


func _activate(action_id: StringName) -> void:
	match action_id:
		&"bag": backpack_requested.emit()
		&"mail": mail_requested.emit()
		&"map": map_requested.emit()
		&"config": config_requested.emit()


func _button(text: String, color: Color, accent: Color) -> ArcaneButton:
	var out:=ArcaneButton.new(); out.text=text; out.fill_top=Color("#0D0825"); out.fill_bottom=Color("#160E3A"); out.border_color=Color(accent,0.45); out.add_theme_font_override("font",UIFonts.rajdhani_bold()); out.add_theme_font_size_override("font_size",8); out.add_theme_color_override("font_color",color); return out
