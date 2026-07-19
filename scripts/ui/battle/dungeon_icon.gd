class_name DungeonIcon
extends Control
## Production-safe procedural glyphs for dungeon categories and enemies.

@export var icon_id: StringName = &"key":
	set(v):
		icon_id = v
		queue_redraw()
@export var accent := UIPalette.GOLD:
	set(v):
		accent = v
		queue_redraw()
@export var ornate := false:
	set(v):
		ornate = v
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var cut := size.x * 0.24
	var frame := UIDraw.octagon(size - Vector2.ONE * 2.0, cut) as PackedVector2Array
	for i in range(frame.size()):
		frame[i] += Vector2.ONE
	draw_colored_polygon(frame, Color("#0D0525"))
	var border := frame.duplicate()
	border.append(frame[0])
	for i in range(border.size() - 1):
		draw_line(border[i], border[i + 1], accent, 1.4 if ornate else 1.0, true)
	if ornate:
		var inner_size := size - Vector2.ONE * 10.0
		var inner := UIDraw.octagon(inner_size, inner_size.x * 0.24)
		for i in range(inner.size()):
			inner[i] += Vector2.ONE * 5.0
		var loop := inner.duplicate()
		loop.append(inner[0])
		for i in range(loop.size() - 1):
			draw_line(loop[i], loop[i + 1], Color(accent, 0.35), 0.8, true)
	_draw_glyph(Rect2(size * 0.23, size * 0.54), accent)


func _draw_glyph(rect: Rect2, color: Color) -> void:
	var c := rect.get_center()
	var u := rect.size.x / 24.0
	match icon_id:
		&"key":
			draw_circle(c + Vector2(5.0, -5.0) * u, 4.0 * u, color)
			draw_circle(c + Vector2(5.0, -5.0) * u, 1.7 * u, Color("#0D0525"))
			draw_line(c + Vector2(2.0, -2.0) * u, c + Vector2(-7.0, 7.0) * u, color, 4.0 * u, true)
			draw_line(c + Vector2(-4.0, 4.0) * u, c + Vector2(-1.0, 7.0) * u, color, 2.2 * u, true)
		&"gem":
			var gem := UIDraw.diamond(c, 8.0 * u, 9.0 * u)
			draw_colored_polygon(gem, color)
			draw_line(gem[0], c, Color.WHITE, 1.0 * u, true)
			draw_line(gem[1], c, Color(color, 0.55), 1.0 * u, true)
		&"star":
			draw_colored_polygon(UIDraw.star(c, 9.0 * u, 4.2 * u), color)
		&"paw":
			draw_circle(c + Vector2(0, 4) * u, 4.3 * u, color)
			for p in [Vector2(-6, -3), Vector2(-2, -7), Vector2(3, -7), Vector2(7, -2)]:
				draw_circle(c + p * u, 2.2 * u, color)
		&"crown":
			var crown := PackedVector2Array([
				c + Vector2(-9, 5) * u, c + Vector2(-8, -5) * u,
				c + Vector2(-3, 0) * u, c + Vector2(0, -8) * u,
				c + Vector2(4, 0) * u, c + Vector2(9, -5) * u,
				c + Vector2(8, 5) * u,
			])
			draw_colored_polygon(crown, color)
			draw_rect(Rect2(c + Vector2(-9, 5) * u, Vector2(18, 3) * u), color)

