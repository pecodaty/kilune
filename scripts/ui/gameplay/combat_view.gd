class_name CombatView
extends Control
## The combat stage: background, ground shadow, hero sprite and floating text.
## Visual only — combat logic lives outside and drives this view through its API.

signal attack_landed()

const WARRIOR_IDLE: Texture2D = preload("res://assets/heroes/warrior/idle.png")
const WARRIOR_ATTACK: Texture2D = preload("res://assets/heroes/warrior/attack.png")
const BACKGROUND: Texture2D = preload("res://assets/backgrounds/forest/first_stage_background.png")

const GRID := 4
const FRAME_SIZE := 512
const IDLE_FPS := 8.0
const ATTACK_FPS := 14.0
## Vertical crop bias for the background (0 = show top, 1 = show bottom/ground).
const BACKGROUND_BIAS := 0.72

var _background: TextureRect
var _hero: AnimatedSprite2D
var _shadow: Control
var _auto_timer: Timer

var auto_enabled := true:
	set(v):
		auto_enabled = v
		_update_auto_timer()


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_background = TextureRect.new()
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_SCALE
	_background.texture = BACKGROUND
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	_shadow = Control.new()
	_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shadow.draw.connect(_draw_shadow)
	add_child(_shadow)

	_hero = AnimatedSprite2D.new()
	_hero.sprite_frames = _build_sprite_frames()
	_hero.animation_finished.connect(_on_animation_finished)
	add_child(_hero)
	_hero.play(&"idle")

	_auto_timer = Timer.new()
	_auto_timer.wait_time = 2.6
	_auto_timer.timeout.connect(_on_auto_tick)
	add_child(_auto_timer)
	_update_auto_timer()

	resized.connect(_layout_world)
	_layout_world.call_deferred()


func _build_sprite_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_sheet(frames, &"idle", WARRIOR_IDLE, IDLE_FPS, true)
	_add_sheet(frames, &"attack", WARRIOR_ATTACK, ATTACK_FPS, false)
	return frames


func _add_sheet(frames: SpriteFrames, name: StringName, sheet: Texture2D, fps: float, loops: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, fps)
	frames.set_animation_loop(name, loops)
	for row in range(GRID):
		for col in range(GRID):
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = Rect2(col * FRAME_SIZE, row * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
			frames.add_frame(name, frame)


func _layout_world() -> void:
	if not is_node_ready():
		return
	# Background: cover the view, biased so the painted ground stays visible.
	var tex_size := BACKGROUND.get_size()
	var scale_factor := maxf(size.x / tex_size.x, size.y / tex_size.y)
	var scaled := tex_size * scale_factor
	_background.position = Vector2((size.x - scaled.x) * 0.5, (size.y - scaled.y) * BACKGROUND_BIAS)
	_background.size = scaled

	# Hero placement: left side, feet slightly above the view bottom.
	var hero_scale := size.x * 0.0011
	_hero.scale = Vector2(hero_scale, hero_scale)
	var feet_y := size.y * 0.92
	_hero.position = Vector2(size.x * 0.28, feet_y - FRAME_SIZE * hero_scale * 0.42)
	_shadow.position = Vector2(size.x * 0.28, feet_y)
	_shadow.queue_redraw()


func _draw_shadow() -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var a := TAU * float(i) / 24.0
		points.append(Vector2(cos(a) * 23.0, sin(a) * 3.5))
	_shadow.draw_colored_polygon(points, Color(0.0, 0.0, 0.0, 0.35))


## Public API -----------------------------------------------------------------

func play_attack() -> void:
	if _hero.animation == &"attack" and _hero.is_playing():
		return
	_hero.play(&"attack")
	# Damage number lands mid-swing.
	get_tree().create_timer(0.45).timeout.connect(_on_attack_impact, CONNECT_ONE_SHOT)


func spawn_floating_text(text: String, color: Color, at_position: Vector2) -> void:
	FloatingText.spawn(self, text, color, at_position)


func _on_attack_impact() -> void:
	spawn_floating_text("+%d" % (180 + randi() % 120), Color("#FFDD44"), Vector2(size.x * 0.42, size.y * 0.62))
	attack_landed.emit()


func _on_auto_tick() -> void:
	play_attack()


func _on_animation_finished() -> void:
	if _hero.animation == &"attack":
		_hero.play(&"idle")


func _update_auto_timer() -> void:
	if not is_node_ready():
		return
	if auto_enabled:
		_auto_timer.start()
	else:
		_auto_timer.stop()
