class_name UIDraw
extends RefCounted
## Static geometry and gradient drawing helpers for the faceted arcane UI.
## All components draw their frames procedurally so authored textures stay
## free of state, text and gradients (docs/art-direction/interface-design.md).

## Clipped-corner rectangle (regular octagon when cut is symmetric).
static func octagon(oct_size: Vector2, cut: float) -> PackedVector2Array:
	var w := oct_size.x
	var h := oct_size.y
	return PackedVector2Array([
		Vector2(cut, 0.0), Vector2(w - cut, 0.0),
		Vector2(w, cut), Vector2(w, h - cut),
		Vector2(w - cut, h), Vector2(cut, h),
		Vector2(0.0, h - cut), Vector2(0.0, cut),
	])

## Rectangle with independently clipped corners (clockwise from top-left).
static func clipped_rect(area_size: Vector2, tl := 0.0, tr := 0.0, br := 0.0, bl := 0.0) -> PackedVector2Array:
	var w := area_size.x
	var h := area_size.y
	var out := PackedVector2Array()
	for p in [
		Vector2(tl, 0.0), Vector2(w - tr, 0.0),
		Vector2(w, tr), Vector2(w, h - br),
		Vector2(w - br, h), Vector2(bl, h),
		Vector2(0.0, h - bl), Vector2(0.0, tl),
	]:
		if out.is_empty() or not p.is_equal_approx(out[out.size() - 1]):
			out.append(p)
	return out


## Diamond (rhombus) centered at `center`.
static func diamond(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0.0, -ry),
		center + Vector2(rx, 0.0),
		center + Vector2(0.0, ry),
		center + Vector2(-rx, 0.0),
	])

## Regular star polygon centered at `center`, pointing up.
static func star(center: Vector2, r_out: float, r_in: float, points := 5) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(points * 2):
		var r := r_out if i % 2 == 0 else r_in
		var a := -PI / 2.0 + float(i) * PI / float(points)
		pts.append(center + Vector2(cos(a), sin(a)) * r)
	return pts

## Sample a stop list like [[0.0, Color], [0.5, Color], ...] at t in 0..1.
static func sample_stops(t: float, stops: Array) -> Color:
	if stops.is_empty():
		return Color.WHITE
	if t <= stops[0][0]:
		return stops[0][1]
	for i in range(stops.size() - 1):
		var a: Array = stops[i]
		var b: Array = stops[i + 1]
		if t <= b[0]:
			var span: float = b[0] - a[0]
			var f: float = 0.0 if span <= 0.0 else (t - a[0]) / span
			return (a[1] as Color).lerp(b[1], f)
	return stops[stops.size() - 1][1]

## Diagonal gradient parameter for a point inside a rect of `area_size`.
static func diag_t(p: Vector2, area_size: Vector2) -> float:
	var tx := 0.0 if area_size.x <= 0.0 else p.x / area_size.x
	var ty := 0.0 if area_size.y <= 0.0 else p.y / area_size.y
	return clampf((tx + ty) * 0.5, 0.0, 1.0)

## Filled polygon with a diagonal vertex-color gradient.
static func draw_poly_diag(ci: CanvasItem, points: PackedVector2Array, area_size: Vector2, stops: Array) -> void:
	var colors := PackedColorArray()
	for p in points:
		colors.append(sample_stops(diag_t(p, area_size), stops))
	ci.draw_polygon(points, colors)


## Filled polygon with a horizontal vertex-color gradient.
static func draw_poly_h_gradient(ci: CanvasItem, points: PackedVector2Array, area_size: Vector2, stops: Array) -> void:
	var colors := PackedColorArray()
	for p in points:
		var t := 0.0 if area_size.x <= 0.0 else clampf(p.x / area_size.x, 0.0, 1.0)
		colors.append(sample_stops(t, stops))
	ci.draw_polygon(points, colors)

## Polygon outline with a diagonal gradient, drawn edge by edge.
static func draw_outline_diag(ci: CanvasItem, points: PackedVector2Array, area_size: Vector2, stops: Array, width := 1.0) -> void:
	var n := points.size()
	for i in range(n):
		var a := points[i]
		var b := points[(i + 1) % n]
		var mid := (a + b) * 0.5
		ci.draw_line(a, b, sample_stops(diag_t(mid, area_size), stops), width, true)

## Vertical two-stop gradient rect fill.
static func draw_v_gradient_rect(ci: CanvasItem, rect: Rect2, top: Color, bottom: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y),
	])
	var colors := PackedColorArray([top, top, bottom, bottom])
	ci.draw_polygon(points, colors)

## Horizontal gradient line sampled from stops, drawn as segments.
static func draw_h_gradient_line(ci: CanvasItem, y: float, width: float, stops: Array, thickness := 1.0, segments := 48) -> void:
	var prev := Vector2(0.0, y)
	for i in range(1, segments + 1):
		var t := float(i) / float(segments)
		var cur := Vector2(width * t, y)
		ci.draw_line(prev, cur, sample_stops(t - 0.5 / float(segments), stops), thickness, false)
		prev = cur

## Flatten a cubic bezier into a polyline (open, includes both ends).
static func flatten_cubic(p0: Vector2, c1: Vector2, c2: Vector2, p1: Vector2, steps := 12) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var mt := 1.0 - t
		pts.append(mt * mt * mt * p0 + 3.0 * mt * mt * t * c1 + 3.0 * mt * t * t * c2 + t * t * t * p1)
	return pts

## Flatten a quadratic bezier into a polyline (open, includes both ends).
static func flatten_quadratic(p0: Vector2, c: Vector2, p1: Vector2, steps := 10) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var mt := 1.0 - t
		pts.append(mt * mt * p0 + 2.0 * mt * t * c + t * t * p1)
	return pts

## Chain cubic segments: each entry is [c1, c2, p1] continuing from previous end.
static func flatten_cubic_chain(start: Vector2, segments: Array, steps := 10) -> PackedVector2Array:
	var pts := PackedVector2Array([start])
	var cursor := start
	for seg in segments:
		var part := flatten_cubic(cursor, seg[0], seg[1], seg[2], steps)
		for i in range(1, part.size()):
			pts.append(part[i])
		cursor = seg[2]
	return pts

## Chain quadratic segments: each entry is [c, p1].
static func flatten_quadratic_chain(start: Vector2, segments: Array, steps := 8) -> PackedVector2Array:
	var pts := PackedVector2Array([start])
	var cursor := start
	for seg in segments:
		var part := flatten_quadratic(cursor, seg[0], seg[1], steps)
		for i in range(1, part.size()):
			pts.append(part[i])
		cursor = seg[1]
	return pts
