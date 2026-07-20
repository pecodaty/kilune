class_name SkillDock
extends Control
## Skill dock: Auto toggle, separator, then six octagonal skill slots.

signal skill_pressed(slot_index: int)
signal auto_toggled(active: bool)

const AUTO_BUTTON_SCENE := preload("res://scenes/ui/gameplay/auto_button.tscn")
const SKILL_SLOT_SCENE := preload("res://scenes/ui/gameplay/skill_slot.tscn")

## Presentation fallback used before a PlayerProfile is bound.
@export var skills: Array = [
	{"rune": &"leaf", "locked": false, "level_required": 0},
	{"rune": &"globe", "locked": false, "level_required": 0},
	{"rune": &"wave", "locked": false, "level_required": 0},
	{"rune": &"drop", "locked": false, "level_required": 0},
	{"rune": &"orb", "locked": false, "level_required": 0},
	{"rune": &"", "locked": false, "level_required": 0},
]

var _auto_button: AutoButton
var _slots: Array[SkillSlot] = []
var _profile: PlayerProfile


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 64.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 8.0
	row.offset_top = 7.0
	row.offset_right = -8.0
	row.offset_bottom = -7.0
	row.add_theme_constant_override("separation", 3)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	_auto_button = AUTO_BUTTON_SCENE.instantiate()
	_auto_button.active = true
	_auto_button.toggled.connect(func(on: bool) -> void: auto_toggled.emit(on))
	row.add_child(_auto_button)

	var separator := VSeparator.new()
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = Color(UIPalette.PURPLE_STRUCTURE, 0.7)
	sep_style.content_margin_left = 0.0
	sep_style.content_margin_right = 0.0
	separator.add_theme_stylebox_override("separator", sep_style)
	separator.add_theme_constant_override("separation", 1)
	row.add_child(separator)

	for i in range(skills.size()):
		var slot: SkillSlot = SKILL_SLOT_SCENE.instantiate()
		var def: Dictionary = skills[i]
		slot.slot_index = i
		slot.rune_id = def.get("rune", &"")
		slot.is_locked = def.get("locked", false)
		slot.level_required = def.get("level_required", 0)
		slot.skill_pressed.connect(func(idx: int) -> void: skill_pressed.emit(idx))
		row.add_child(slot)
		_slots.append(slot)
	_refresh_profile()


func bind_profile(profile: PlayerProfile) -> void:
	if _profile != null and _profile.changed.is_connected(_on_profile_changed):
		_profile.changed.disconnect(_on_profile_changed)
	_profile = profile
	_profile.changed.connect(_on_profile_changed)
	_refresh_profile()


func _on_profile_changed(domain: StringName, change_kind: StringName) -> void:
	if domain == &"hero" and (change_kind == &"loadout" or change_kind == &"restored"):
		_refresh_profile()


func _refresh_profile() -> void:
	if _profile == null or not is_node_ready() or _slots.is_empty():
		return
	var loadout: Array = _profile.combat_snapshot()["loadout"]
	for i in range(_slots.size()):
		var skill: Dictionary = loadout[i] if i < loadout.size() else {}
		_slots[i].rune_id = skill.get("icon", &"")
		_slots[i].is_locked = false
		_slots[i].level_required = 0


func set_auto(active: bool) -> void:
	_auto_button.active = active


func set_cooldown(slot_index: int, fraction: float) -> void:
	if slot_index >= 0 and slot_index < _slots.size():
		_slots[slot_index].cooldown_fraction = fraction


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), UIPalette.DOCK_TOP, UIPalette.DOCK_BOTTOM)
