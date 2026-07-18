class_name ClassRunes
extends RefCounted
## Procedural class runes (rail tabs) and large class emblems (portrait arch).
## Runes are ported 1:1 from the canonical 18x18 SVGs in
## references/reference-code/src/app/App.tsx. Emblems are interim vector
## placeholders matching the silhouettes in docs/art-direction/
## interface-heroes-screen.md; authored emblem art replaces them later
## without changing scene structure.

static func _p(rect: Rect2, x: float, y: float) -> Vector2:
	return rect.position + Vector2(x / 18.0 * rect.size.x, y / 18.0 * rect.size.y)


static func _u(rect: Rect2) -> float:
	return rect.size.x / 18.0


static func _stroke(ci: CanvasItem, pts: PackedVector2Array, color: Color, width: float) -> void:
	if pts.size() < 2:
		return
	for i in range(pts.size() - 1):
		ci.draw_line(pts[i], pts[i + 1], color, width, true)


# ─── Rail runes (18x18 space) ────────────────────────────────────────────────

static func draw_rune(ci: CanvasItem, class_id: StringName, rect: Rect2, color: Color) -> void:
	match class_id:
		&"druid":
			_druid_rune(ci, rect, color)
		&"mage":
			_mage_rune(ci, rect, color)
		&"warrior":
			_warrior_rune(ci, rect, color)
		&"assassin":
			_assassin_rune(ci, rect, color)
		&"hunter":
			_hunter_rune(ci, rect, color)


static func _druid_rune(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var leaf := UIDraw.flatten_cubic_chain(_p(rect, 9, 14), [
		[_p(rect, 9, 14), _p(rect, 4, 10), _p(rect, 4, 6)],
		[_p(rect, 4, 3), _p(rect, 6.5, 1.5), _p(rect, 9, 1.5)],
		[_p(rect, 11.5, 1.5), _p(rect, 14, 3), _p(rect, 14, 6)],
		[_p(rect, 14, 10), _p(rect, 9, 14), _p(rect, 9, 14)],
	])
	ci.draw_colored_polygon(leaf, Color(color, 0.2))
	leaf.append(leaf[0])
	_stroke(ci, leaf, color, 1.2 * u)
	ci.draw_line(_p(rect, 9, 14), _p(rect, 9, 17), color, 1.2 * u, true)


static func _mage_rune(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var star := PackedVector2Array([
		_p(rect, 9, 1.5), _p(rect, 10.4, 6.2), _p(rect, 15.5, 7), _p(rect, 11.5, 10.5),
		_p(rect, 12.6, 16), _p(rect, 9, 13.5), _p(rect, 5.4, 16), _p(rect, 6.5, 10.5),
		_p(rect, 2.5, 7), _p(rect, 7.6, 6.2),
	])
	ci.draw_colored_polygon(star, Color(color, 0.2))
	star.append(star[0])
	_stroke(ci, star, color, 1.0 * u)


static func _warrior_rune(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_line(_p(rect, 4, 4), _p(rect, 14, 14), color, 1.5 * u, true)
	ci.draw_line(_p(rect, 14, 4), _p(rect, 4, 14), color, 1.5 * u, true)
	ci.draw_arc(_p(rect, 9, 9), 3.5 * u, 0.0, TAU, 20, Color(color, 0.5), 0.8 * u, true)


static func _assassin_rune(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, PackedVector2Array([_p(rect, 4, 14), _p(rect, 14, 4), _p(rect, 10, 4)]), color, 1.4 * u)
	_stroke(ci, PackedVector2Array([_p(rect, 14, 4), _p(rect, 14, 8)]), color, 1.4 * u)
	ci.draw_line(_p(rect, 6, 12), _p(rect, 3, 15.5), Color(color, 0.6), 1.2 * u, true)
	ci.draw_line(_p(rect, 4, 12), _p(rect, 7.5, 15), Color(color, 0.6), 1.2 * u, true)


static func _hunter_rune(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 3, 15), _p(rect, 3, 3), _p(rect, 15, 3), 12), color, 1.4 * u)
	ci.draw_line(_p(rect, 3, 3), _p(rect, 3, 15), Color(color, 0.4), 0.8 * u, true)
	ci.draw_line(_p(rect, 6, 9), _p(rect, 17, 9), color, 1.2 * u, true)
	ci.draw_colored_polygon(PackedVector2Array([_p(rect, 15, 7), _p(rect, 17, 9), _p(rect, 15, 11)]), color)


# ─── Portrait emblems (~90px box) ────────────────────────────────────────────
## Interim vector emblems. All drawn centered in `rect`; `color` is the class
## accent. Kept as strong silhouettes with low internal detail per spec.

static func draw_emblem(ci: CanvasItem, class_id: StringName, rect: Rect2, color: Color) -> void:
	# Soft class glow behind the emblem.
	var glow := rect.grow(rect.size.x * 0.08)
	for i in range(6, 0, -1):
		var f := float(i) / 6.0
		ci.draw_circle(glow.get_center(), glow.size.x * 0.5 * f, Color(color, 0.05 * (1.0 - f) + 0.01))
	# Dark downward shadow.
	var shadow := rect
	shadow.position += Vector2(0.0, rect.size.y * 0.05)
	_draw_emblem_shape(ci, class_id, shadow, Color(0, 0, 0, 0.4))
	_draw_emblem_shape(ci, class_id, rect, color)


static func _draw_emblem_shape(ci: CanvasItem, class_id: StringName, rect: Rect2, color: Color) -> void:
	match class_id:
		&"druid":
			_druid_emblem(ci, rect, color)
		&"mage":
			_mage_emblem(ci, rect, color)
		&"warrior":
			_warrior_emblem(ci, rect, color)
		&"assassin":
			_assassin_emblem(ci, rect, color)
		&"hunter":
			_hunter_emblem(ci, rect, color)


static func _e(rect: Rect2, x: float, y: float) -> Vector2:
	# Emblem-local helper: -50..50 coordinate space mapped onto rect.
	return rect.get_center() + Vector2(x, y) * (rect.size.x / 100.0)


static func _leaf_poly(center: Vector2, length: float, width: float, angle: float) -> PackedVector2Array:
	var dir := Vector2.RIGHT.rotated(angle)
	var side := dir.orthogonal()
	var tip := center + dir * length
	return PackedVector2Array([
		center, center + dir * length * 0.5 + side * width, tip, center + dir * length * 0.5 - side * width,
	])


static func _druid_emblem(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var stem := UIDraw.flatten_quadratic_chain(_e(rect, -14, 40), [
		[_e(rect, -12, 10), _e(rect, -4, -12)],
		[_e(rect, 2, -26), _e(rect, 4, -40)],
	], 8)
	ci.draw_polyline(stem, color.darkened(0.25), 3.0, true)
	# Leaf pairs along the stem, top leaf at the tip.
	var leaves := [
		[_e(rect, -11, 16), -2.6, 16.0], [_e(rect, -8, 4), -0.5, 16.0],
		[_e(rect, -5, -8), -2.7, 15.0], [_e(rect, -1, -18), -0.4, 15.0],
		[_e(rect, 4, -40), -1.45, 17.0],
	]
	for leaf in leaves:
		var poly := _leaf_poly(leaf[0], leaf[2], leaf[2] * 0.42, leaf[1])
		ci.draw_colored_polygon(poly, color)
		ci.draw_line(leaf[0], leaf[0] + Vector2.RIGHT.rotated(leaf[1]) * leaf[2] * 0.8, color.lightened(0.45), 1.0, true)


static func _mage_emblem(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var hi := color.lightened(0.55)
	var center := _e(rect, 0, 2)
	var star := UIDraw.star(center, rect.size.x * 0.4, rect.size.x * 0.17)
	ci.draw_colored_polygon(star, Color(color, 0.85))
	star.append(star[0])
	ci.draw_polyline(star, hi, 1.5, true)
	ci.draw_circle(center, rect.size.x * 0.09, hi)
	# Satellite sparkles.
	for spark in [[_e(rect, -30, -26), 7.0], [_e(rect, 30, -18), 5.5], [_e(rect, 22, 30), 6.5]]:
		var small := UIDraw.star(spark[0], spark[1], spark[1] * 0.35, 4)
		ci.draw_colored_polygon(small, Color(hi, 0.9))
	for dot in [_e(rect, -22, 28), _e(rect, 34, 8), _e(rect, -34, 2)]:
		ci.draw_circle(dot, 1.6, hi)


static func _sword_poly(center: Vector2, angle: float, length: float, blade_w: float) -> Dictionary:
	# Returns blade/guard/grip polygons for a sword pointing along `angle`.
	var dir := Vector2.UP.rotated(angle)
	var side := dir.orthogonal()
	var blade_tip := center + dir * length * 0.5
	var guard_y := center + dir * length * -0.12
	var blade := PackedVector2Array([
		guard_y + side * blade_w * 0.5, blade_tip, guard_y - side * blade_w * 0.5,
	])
	var guard := PackedVector2Array([
		guard_y + side * blade_w * 1.8, guard_y + side * blade_w * 1.8 + dir * 3.0,
		guard_y - side * blade_w * 1.8 + dir * 3.0, guard_y - side * blade_w * 1.8,
	])
	var grip := PackedVector2Array([
		guard_y + side * blade_w * 0.35, center - dir * length * 0.42 + side * blade_w * 0.35,
		center - dir * length * 0.42 - side * blade_w * 0.35, guard_y - side * blade_w * 0.35,
	])
	var pommel := center - dir * length * 0.46
	return {"blade": blade, "guard": guard, "grip": grip, "pommel": pommel}


static func _warrior_emblem(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var center := _e(rect, 0, 2)
	var blade_col := Color("#D8DCE8")
	var hilt_col := Color("#7B2FF7")
	for angle in [-0.5, 0.5]:
		var parts := _sword_poly(center, angle, rect.size.x * 0.98, rect.size.x * 0.065)
		ci.draw_colored_polygon(parts["blade"], blade_col)
		ci.draw_colored_polygon(parts["guard"], hilt_col)
		ci.draw_colored_polygon(parts["grip"], hilt_col.darkened(0.35))
		ci.draw_circle(parts["pommel"], rect.size.x * 0.045, hilt_col.lightened(0.2))


static func _assassin_emblem(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	# Diagonal dagger, tip up-right.
	var parts := _sword_poly(_e(rect, 4, 8), 0.8, rect.size.x * 0.78, rect.size.x * 0.12)
	ci.draw_colored_polygon(parts["blade"], Color("#D8DCE8"))
	ci.draw_colored_polygon(parts["guard"], UIPalette.GOLD)
	ci.draw_colored_polygon(parts["grip"], Color("#3A2455"))
	ci.draw_circle(parts["pommel"], rect.size.x * 0.05, Color("#FF3355"))
	ci.draw_circle(_e(rect, 12, -6), rect.size.x * 0.04, color)


static func _hunter_emblem(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var wood := Color("#A8733D")
	var center := _e(rect, 0, 0)
	# Bow arc opening to the right.
	var arc := UIDraw.flatten_cubic_chain(_e(rect, -6, -36), [
		[_e(rect, 26, -22), _e(rect, 26, 22), _e(rect, -6, 36)],
	], 16)
	ci.draw_polyline(arc, wood, 5.0, true)
	ci.draw_polyline(arc, wood.lightened(0.35), 1.5, true)
	ci.draw_line(_e(rect, -6, -36), _e(rect, -6, 36), Color("#E8E0D0"), 1.4, true)
	# Nocked arrow pointing right through the center.
	ci.draw_line(_e(rect, -34, 0), _e(rect, 36, 0), Color("#C8B890"), 2.4, true)
	ci.draw_colored_polygon(PackedVector2Array([
		_e(rect, 36, -5), _e(rect, 44, 0), _e(rect, 36, 5),
	]), Color("#D8DCE8"))
	ci.draw_colored_polygon(PackedVector2Array([
		_e(rect, -34, 0), _e(rect, -26, -5), _e(rect, -28, 0), _e(rect, -26, 5),
	]), color.darkened(0.1))
	ci.draw_circle(center + Vector2(rect.size.x * 0.1, 0.0), 1.5, wood.lightened(0.3))
