class_name MainGameplayInterface
extends Control
## Top-level composition of the main gameplay screen.
## Owns no visuals: wires child signals to game systems and applies safe areas.

@onready var _safe_area: MarginContainer = $SafeAreaContainer
@onready var _top_hud: TopHud = $SafeAreaContainer/MainColumn/TopHud
@onready var _stage_plaque: StagePlaque = $SafeAreaContainer/MainColumn/StagePlaque
@onready var _heroes_tab: HeroesTab = $SafeAreaContainer/MainColumn/HeroesTab
@onready var _combat_view: CombatView = $SafeAreaContainer/MainColumn/CombatView
@onready var _dock_divider: Control = $SafeAreaContainer/MainColumn/DockDivider
@onready var _skill_dock: SkillDock = $SafeAreaContainer/MainColumn/SkillDock
@onready var _chat_strip: ChatStrip = $SafeAreaContainer/MainColumn/ChatStrip
@onready var _bottom_nav: BottomNav = $SafeAreaContainer/MainColumn/BottomNav

const HEROES_PLAQUE := "Heroes · Class Selection"

var _battle_plaque := ""


func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

	_skill_dock.skill_pressed.connect(_on_skill_pressed)
	_skill_dock.auto_toggled.connect(_on_auto_toggled)
	_bottom_nav.tab_selected.connect(_on_tab_selected)
	_chat_strip.chat_open_requested.connect(_on_chat_open_requested)
	_top_hud.map_open_requested.connect(_on_map_open_requested)
	_top_hud.rewards_open_requested.connect(_on_rewards_open_requested)
	_heroes_tab.back_requested.connect(_on_heroes_back_requested)


func _apply_safe_area() -> void:
	var window_size := Vector2(DisplayServer.window_get_size())
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		return
	var safe := Rect2(DisplayServer.get_display_safe_area())
	# Safe-area coordinates are global on desktop, so make them window-local.
	safe.position -= Vector2(DisplayServer.window_get_position())
	var viewport_size := get_viewport_rect().size
	var factor := viewport_size / window_size
	_safe_area.add_theme_constant_override("margin_left", maxi(0, int(safe.position.x * factor.x)))
	_safe_area.add_theme_constant_override("margin_top", maxi(0, int(safe.position.y * factor.y)))
	_safe_area.add_theme_constant_override("margin_right", maxi(0, int((window_size.x - safe.end.x) * factor.x)))
	_safe_area.add_theme_constant_override("margin_bottom", maxi(0, int((window_size.y - safe.end.y) * factor.y)))


# ─── Signal routing (delegate to game systems as they come online) ───────────

func _on_skill_pressed(slot_index: int) -> void:
	# Until a CombatSystem exists, a skill press drives the hero's attack swing.
	_combat_view.play_attack()
	_skill_dock.set_cooldown(slot_index, 0.0)


func _on_auto_toggled(active: bool) -> void:
	_combat_view.auto_enabled = active


func _on_tab_selected(tab_id: StringName) -> void:
	show_tab(tab_id)


## Visibility routing between in-screen destinations. Heroes keeps the shared
## shell (HUD, plaque, divider, nav) and swaps the combat bands; battle state
## is preserved because nodes are only hidden.
func show_tab(tab_id: StringName) -> void:
	var heroes := tab_id == &"heroes"
	if heroes == _heroes_tab.visible:
		return
	_heroes_tab.visible = heroes
	_combat_view.visible = not heroes
	_dock_divider.visible = not heroes
	_skill_dock.visible = not heroes
	_chat_strip.visible = not heroes
	if heroes:
		_battle_plaque = _stage_plaque.stage_name
		_stage_plaque.stage_name = HEROES_PLAQUE
	elif not _battle_plaque.is_empty():
		_stage_plaque.stage_name = _battle_plaque


func _on_chat_open_requested() -> void:
	# ChatSystem hook.
	pass


## The Heroes header's Back button returns to battle like the nav destination.
func _on_heroes_back_requested() -> void:
	_bottom_nav.active_tab = &"battle"
	show_tab(&"battle")


func _on_map_open_requested() -> void:
	# WorldMapSystem hook.
	pass


func _on_rewards_open_requested() -> void:
	# RewardSystem hook.
	pass
