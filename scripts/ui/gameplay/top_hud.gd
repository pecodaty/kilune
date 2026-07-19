class_name TopHud
extends Control
## Full-width HUD band: portrait, name + activity timer, and HP/MP bars.

@export var hero_name := "FERO":
	set(v):
		hero_name = v
		_refresh_text()
@export var level := 32:
	set(v):
		level = v
		_refresh_text()
@export var hp := 69.0:
	set(v):
		hp = v
		_refresh_stats()
@export var hp_max := 158.0:
	set(v):
		hp_max = v
		_refresh_stats()
@export var mp := 48.0:
	set(v):
		mp = v
		_refresh_stats()
@export var mp_max := 80.0:
	set(v):
		mp_max = v
		_refresh_stats()
@export var activity_text := "Elite · Farming":
	set(v):
		activity_text = v
		_refresh_text()
@export var timer_seconds := 0:
	set(v):
		timer_seconds = v
		_refresh_timer()

const PORTRAIT_SCENE := preload("res://scenes/ui/gameplay/player_portrait.tscn")
const STAT_BAR_SCENE := preload("res://scenes/ui/gameplay/stat_bar.tscn")

var _portrait: PlayerPortrait
var _name_label: Label
var _activity_label: Label
var _timer_label: Label
var _hp_bar: StatBar
var _mp_bar: StatBar
var _timer: Timer


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 74.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 8.0
	row.offset_top = 6.0
	row.offset_right = -8.0
	row.offset_bottom = -8.0
	row.add_theme_constant_override("separation", 8)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	_portrait = PORTRAIT_SCENE.instantiate()
	_portrait.level = level
	_portrait.portrait_texture = _make_portrait_texture()
	row.add_child(_portrait)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 3)
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(info)

	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	name_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(name_row)

	_name_label = UIFonts.make_label(hero_name, UIFonts.cinzel_bold(), 15, UIPalette.GOLD)
	name_row.add_child(_name_label)

	var badge := PanelContainer.new()
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(UIPalette.DEEP_PANEL, 0.8)
	badge_style.border_color = Color(UIPalette.PURPLE_STRUCTURE, 0.47)
	badge_style.set_border_width_all(1)
	badge_style.content_margin_left = 5.0
	badge_style.content_margin_right = 5.0
	badge.add_theme_stylebox_override("panel", badge_style)
	name_row.add_child(badge)

	var badge_row := HBoxContainer.new()
	badge_row.add_theme_constant_override("separation", 4)
	badge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(badge_row)
	_activity_label = UIFonts.make_label(activity_text, UIFonts.rajdhani_semibold(), 7, Color("#8060A0"))
	badge_row.add_child(_activity_label)
	_timer_label = UIFonts.make_label("00:00", UIFonts.rajdhani_bold(), 8, UIPalette.GOLD)
	badge_row.add_child(_timer_label)

	_hp_bar = STAT_BAR_SCENE.instantiate()
	_hp_bar.label_text = "HP"
	_hp_bar.bar_color = UIPalette.HP
	info.add_child(_hp_bar)
	_mp_bar = STAT_BAR_SCENE.instantiate()
	_mp_bar.label_text = "MP"
	_mp_bar.bar_color = UIPalette.MP
	info.add_child(_mp_bar)

	_timer = Timer.new()
	_timer.wait_time = 1.0
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_tick)
	add_child(_timer)

	_refresh_text()
	_refresh_stats()
	_refresh_timer()


func _make_portrait_texture() -> AtlasTexture:
	var sheet: Texture2D = load("res://assets/heroes/warrior/idle.png")
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = Rect2(0.0, 0.0, 512.0, 512.0)
	return atlas


func _on_timer_tick() -> void:
	timer_seconds += 1


func _refresh_text() -> void:
	if not is_node_ready():
		return
	_name_label.text = hero_name
	_activity_label.text = activity_text
	_portrait.level = level


func _refresh_stats() -> void:
	if not is_node_ready():
		return
	_hp_bar.value = hp
	_hp_bar.max_value = hp_max
	_mp_bar.value = mp
	_mp_bar.max_value = mp_max


func _refresh_timer() -> void:
	if not is_node_ready():
		return
	_timer_label.text = "%02d:%02d" % [timer_seconds / 60, timer_seconds % 60]


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color(UIPalette.HUD_TOP, 0.97), Color(UIPalette.HUD_BOTTOM, 0.75))
	# Bottom gold edge
	UIDraw.draw_h_gradient_line(self, size.y - 0.5, size.x, UIPalette.gold_line_stops(), 1.0)
	# Corner brackets
	var bracket := Color(UIPalette.GOLD_MUTED, 0.55)
	var l := 18.0
	draw_polyline(PackedVector2Array([Vector2(0, l), Vector2(0, 1), Vector2(l, 1)]), bracket, 1.0, true)
	draw_polyline(PackedVector2Array([Vector2(size.x - l, 1), Vector2(size.x, 1), Vector2(size.x, l)]), bracket, 1.0, true)
	draw_polyline(PackedVector2Array([Vector2(0, size.y - l), Vector2(0, size.y - 1), Vector2(l, size.y - 1)]), bracket, 1.0, true)
	draw_polyline(PackedVector2Array([Vector2(size.x - l, size.y - 1), Vector2(size.x, size.y - 1), Vector2(size.x, size.y - l)]), bracket, 1.0, true)
