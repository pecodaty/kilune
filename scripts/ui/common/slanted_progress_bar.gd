class_name SlantedProgressBar
extends Control
## Slim stat bar with slanted ends, gradient fill and a diamond terminal marker.

@export var value := 100.0:
	set(v):
		value = v
		queue_redraw()
@export var max_value := 100.0:
	set(v):
		max_value = v
		queue_redraw()
@export var fill_color := UIPalette.HP:
	set(v):
		fill_color = v
		queue_redraw()

const SLANT := 5.0


func _ready() -> void:
	custom_minimum_size = Vector2(80.0, 7.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _slanted_rect(width: float) -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(SLANT, 0.0), Vector2(width, 0.0),
		Vector2(width - SLANT, size.y), Vector2(0.0, size.y),
	])


func _draw() -> void:
	# Track
	var track := _slanted_rect(size.x)
	draw_colored_polygon(track, UIPalette.HUD_BOTTOM)
	draw_polyline(track + PackedVector2Array([track[0]]), UIPalette.BORDER_DARK, 1.0, true)

	# Fill
	var pct := clampf(value / max_value, 0.0, 1.0) if max_value > 0.0 else 0.0
	if pct <= 0.0:
		return
	var fill_width := maxf(size.x * pct, SLANT + 2.0)
	var fill := _slanted_rect(fill_width)
	var fill_stops := [[0.0, Color(fill_color, 0.4)], [1.0, fill_color]]
	UIDraw.draw_poly_diag(self, fill, Vector2(size.x, size.y), fill_stops)

	# Diamond terminal marker
	var marker_x := minf(fill_width - 1.0, size.x - 3.0)
	if pct > 0.02:
		draw_colored_polygon(
			UIDraw.diamond(Vector2(marker_x, size.y * 0.5), 2.0, 2.0),
			Color(fill_color, 0.8)
		)
