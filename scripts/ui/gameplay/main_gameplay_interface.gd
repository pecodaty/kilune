class_name MainGameplayInterface
extends Control
## Top-level composition of the main gameplay screen.
## Owns no visuals: wires child signals to game systems and applies safe areas.

signal quick_action_requested(action_id: StringName)

@onready var _safe_area: MarginContainer = $SafeAreaContainer
@onready var _game_session: GameSession = $GameSession
@onready var _top_hud: TopHud = $SafeAreaContainer/MainColumn/TopHud
@onready var _stage_plaque: StagePlaque = $SafeAreaContainer/MainColumn/StagePlaque
@onready var _heroes_tab: HeroesTab = $SafeAreaContainer/MainColumn/HeroesTab
@onready var _battle_mode_view: BattleModeView = $SafeAreaContainer/MainColumn/BattleModeView
@onready var _combat_view: CombatView = $SafeAreaContainer/MainColumn/CombatView
@onready var _dock_divider: Control = $SafeAreaContainer/MainColumn/DockDivider
@onready var _skill_dock: SkillDock = $SafeAreaContainer/MainColumn/SkillDock
@onready var _chat_strip: ChatStrip = $SafeAreaContainer/MainColumn/ChatStrip
@onready var _bottom_nav: BottomNav = $SafeAreaContainer/MainColumn/BottomNav
@onready var _dungeon_flow: DungeonFlow = $DungeonFlow
@onready var _guild_screen: GuildScreen = $SafeAreaContainer/MainColumn/GuildScreen
@onready var _shop_screen: ShopScreen = $SafeAreaContainer/MainColumn/ShopScreen
@onready var _floating_menu: FloatingRightMenu = $FloatingRightMenu
@onready var _backpack_screen: BackpackScreen = $SafeAreaContainer/MainColumn/BackpackScreen
@onready var _mailbox_screen: MailboxScreen = $SafeAreaContainer/MainColumn/MailboxScreen

const HEROES_PLAQUE := "Heroes · Character Stats"
const BATTLE_MODES_PLAQUE := "Battle Modes"

var _battle_plaque := ""


func _ready() -> void:
	_bind_profile(_game_session.profile)
	_game_session.profile_replaced.connect(_bind_profile)
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)

	_skill_dock.skill_pressed.connect(_on_skill_pressed)
	_skill_dock.auto_toggled.connect(_on_auto_toggled)
	_bottom_nav.tab_selected.connect(_on_tab_selected)
	_chat_strip.chat_open_requested.connect(_on_chat_open_requested)
	_battle_mode_view.dungeons_requested.connect(_on_dungeons_requested)
	_battle_mode_view.home_requested.connect(_show_farming)
	_dungeon_flow.closed.connect(_show_battle_lobby)
	_floating_menu.backpack_requested.connect(_open_backpack)
	_floating_menu.mail_requested.connect(_open_mailbox)
	_floating_menu.map_requested.connect(_on_map_open_requested)
	_floating_menu.config_requested.connect(func() -> void: quick_action_requested.emit(&"config"))
	queue_redraw()


func _bind_profile(profile: PlayerProfile) -> void:
	_top_hud.bind_profile(profile)
	_skill_dock.bind_profile(profile)
	_heroes_tab.bind_profile(profile)
	_backpack_screen.bind_inventory_state(profile.inventory)
	_shop_screen.bind_wallet_state(profile.wallet)
	_dungeon_flow.bind_profile(profile)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), UIPalette.CANVAS)


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
	if _backpack_screen.visible or _mailbox_screen.visible:
		if tab_id == &"battle": _show_farming()
		else: show_tab(tab_id)
		return
	if tab_id == &"battle":
		if _heroes_tab.visible:
			_show_battle_lobby()
		elif _battle_mode_view.visible:
			_show_farming()
		else:
			_show_battle_lobby()
	else:
		show_tab(tab_id)


## Visibility routing between in-screen destinations. Heroes keeps the shared
## shell (HUD, plaque, divider, nav) and swaps the combat bands; battle state
## is preserved because nodes are only hidden.
func show_tab(tab_id: StringName) -> void:
	if tab_id == &"heroes":
		_show_heroes()
	elif tab_id == &"guild":
		_show_guild()
	elif tab_id == &"shop":
		_show_shop()
	else:
		_show_farming()


func _show_heroes() -> void:
	_capture_battle_plaque()
	_set_shell_visibility(false, false, true, false, false, false, false)
	_stage_plaque.stage_name = HEROES_PLAQUE


func _show_farming() -> void:
	_set_shell_visibility(true, false, false, false, false, false, false)
	if not _battle_plaque.is_empty():
		_stage_plaque.stage_name = _battle_plaque


func _show_battle_lobby() -> void:
	_capture_battle_plaque()
	_bottom_nav.active_tab = &"battle"
	_set_shell_visibility(false, true, false, false, false, false, false)
	_stage_plaque.stage_name = BATTLE_MODES_PLAQUE


func _set_shell_visibility(farming: bool, lobby: bool, heroes: bool, guild: bool, shop: bool, backpack: bool, mailbox: bool) -> void:
	_safe_area.visible = true
	_dungeon_flow.visible = false
	_top_hud.visible = not guild and not shop and not backpack and not mailbox
	_stage_plaque.visible = not guild and not shop and not backpack and not mailbox
	_guild_screen.visible = guild
	_shop_screen.visible = shop
	_backpack_screen.visible = backpack
	_mailbox_screen.visible = mailbox
	_combat_view.visible = farming
	_battle_mode_view.visible = lobby
	_heroes_tab.visible = heroes
	_dock_divider.visible = farming
	_skill_dock.visible = farming
	_chat_strip.visible = farming
	$SafeAreaContainer/MainColumn/NavDivider.visible = farming or heroes or guild or shop or backpack or mailbox
	_bottom_nav.visible = true
	_floating_menu.visible = farming or lobby
	if not _floating_menu.visible: _floating_menu.close()


func _capture_battle_plaque() -> void:
	if _battle_plaque.is_empty() and _stage_plaque.stage_name != HEROES_PLAQUE and _stage_plaque.stage_name != BATTLE_MODES_PLAQUE:
		_battle_plaque = _stage_plaque.stage_name


func _on_dungeons_requested() -> void:
	_safe_area.visible = false
	_guild_screen.visible = false
	_mailbox_screen.visible = false
	_floating_menu.visible = false
	_dungeon_flow.visible = true
	_dungeon_flow.open()


func _show_guild() -> void:
	_bottom_nav.active_tab = &"guild"
	_set_shell_visibility(false, false, false, true, false, false, false)
	_guild_screen.open()


func _show_shop() -> void:
	_bottom_nav.active_tab = &"shop"
	_set_shell_visibility(false, false, false, false, true, false, false)
	_shop_screen.open()


func _open_backpack() -> void:
	_set_shell_visibility(false, false, false, false, false, true, false)
	_backpack_screen.open()


func _open_mailbox() -> void:
	_set_shell_visibility(false, false, false, false, false, false, true)
	_mailbox_screen.open()


func _on_chat_open_requested() -> void:
	# ChatSystem hook.
	pass


func _on_map_open_requested() -> void:
	# WorldMapSystem hook.
	pass
