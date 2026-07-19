class_name GuildEmblem
extends Control
## Iron Pact's radial scarab emblem, drawn from the reference SVG.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var c := size * 0.5
	var r := minf(size.x, size.y) * 0.47
	draw_circle(c, r, Color("#080318"))
	draw_arc(c, r, 0, TAU, 48, UIPalette.GOLD, 1.8, true)
	draw_arc(c, r * 0.77, 0, TAU, 48, Color("#00BCD4", 0.7), 0.9, true)
	for i in range(8):
		var a := TAU * float(i) / 8.0
		draw_line(c + Vector2(cos(a), sin(a)) * r * 0.78, c + Vector2(cos(a), sin(a)) * r * 0.94, Color(UIPalette.GOLD, 0.38), 0.8, true)
	var red := Color("#CC2200")
	# Scarab body, head, wings, and tail.
	draw_circle(c + Vector2(0, -r * 0.28), r * 0.13, Color("#E33A08"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -r * 0.24), c + Vector2(r * 0.23, -r * 0.04),
		c + Vector2(r * 0.14, r * 0.29), c + Vector2(0, r * 0.38),
		c + Vector2(-r * 0.14, r * 0.29), c + Vector2(-r * 0.23, -r * 0.04),
	]), red)
	draw_arc(c + Vector2(-r * 0.2, 0), r * 0.22, PI * 0.65, PI * 1.5, 16, Color("#AA1100"), r * 0.1, true)
	draw_arc(c + Vector2(r * 0.2, 0), r * 0.22, PI * 1.5, PI * 2.35, 16, Color("#AA1100"), r * 0.1, true)
	draw_circle(c + Vector2(-r * 0.09, -r * 0.3), r * 0.035, Color("#FFB020"))
	draw_circle(c + Vector2(r * 0.09, -r * 0.3), r * 0.035, Color("#FFB020"))
	for value in [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]:
		var direction: Vector2 = value
		var tip: Vector2 = c + direction * (r + 1.0)
		draw_colored_polygon(UIDraw.diamond(tip, 2.5, 4.0), UIPalette.GOLD)
