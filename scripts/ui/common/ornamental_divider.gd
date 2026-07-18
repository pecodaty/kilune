class_name OrnamentalDivider
extends Control
## Horizontal fading gold line with diamond markers.
## Pure decoration, reused between combat view / skill dock / bottom nav.

## Marker positions as fractions of width (0..1). Center marker is gold,
## the rest are violet, matching the canonical divider.
@export var marker_positions: PackedFloat32Array = PackedFloat32Array([0.256, 0.5, 0.744]):
	set(v):
		marker_positions = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 10.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	UIDraw.draw_h_gradient_line(self, size.y * 0.5, size.x, UIPalette.gold_line_stops(), 1.0)
	var center_index := marker_positions.size() / 2
	for i in range(marker_positions.size()):
		var x := marker_positions[i] * size.x
		var is_center := i == center_index
		var color := Color(UIPalette.GOLD, 0.95) if is_center else Color(UIPalette.PURPLE_ORNAMENT, 0.55)
		draw_colored_polygon(UIDraw.diamond(Vector2(x, size.y * 0.5), 3.5, 3.0), color)
