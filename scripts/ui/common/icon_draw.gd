class_name IconDraw
extends RefCounted
## Procedural outlined rune / navigation icons, ported from the canonical SVG
## specifications (references/reference-code/src/assets/*.svg and App.tsx).
## All icons are drawn in a normalized 24x24 space mapped onto the given rect.

static func _p(rect: Rect2, x: float, y: float) -> Vector2:
	return rect.position + Vector2(x / 24.0 * rect.size.x, y / 24.0 * rect.size.y)


static func _u(rect: Rect2) -> float:
	return rect.size.x / 24.0


static func _stroke(ci: CanvasItem, pts: PackedVector2Array, color: Color, width: float) -> void:
	if pts.size() < 2:
		return
	for i in range(pts.size() - 1):
		ci.draw_line(pts[i], pts[i + 1], color, width, true)


# ─── Skill runes ─────────────────────────────────────────────────────────────

static func fire_rune(ci: CanvasItem, rect: Rect2) -> void:
	var u := _u(rect)
	var main := UIDraw.flatten_cubic_chain(_p(rect, 12, 3), [
		[_p(rect, 12, 3), _p(rect, 17, 9), _p(rect, 15.5, 14.5)],
		[_p(rect, 14.5, 18), _p(rect, 10, 19), _p(rect, 8.5, 15.5)],
		[_p(rect, 7.5, 13), _p(rect, 9.5, 11), _p(rect, 11, 13)],
		[_p(rect, 11.8, 14.2), _p(rect, 11, 16), _p(rect, 9.5, 16)],
	])
	_stroke(ci, main, UIPalette.RUNE_FIRE, 1.4 * u)
	var echo := UIDraw.flatten_cubic_chain(_p(rect, 12, 3), [
		[_p(rect, 12, 3), _p(rect, 19, 10), _p(rect, 17, 16)],
		[_p(rect, 15.5, 20.5), _p(rect, 9, 21), _p(rect, 7, 17)],
		[_p(rect, 6, 14.5), _p(rect, 8, 12), _p(rect, 10, 14)],
	])
	_stroke(ci, echo, Color(UIPalette.RUNE_FIRE_HI, 0.6), 1.0 * u)
	ci.draw_circle(_p(rect, 12, 17.5), 2.0 * u, Color(UIPalette.RUNE_FIRE, 0.5))
	ci.draw_line(_p(rect, 9, 6), _p(rect, 10.5, 8), Color(UIPalette.RUNE_FIRE_HI, 0.7), 0.8 * u, true)
	ci.draw_line(_p(rect, 14, 5), _p(rect, 13, 7.5), Color(UIPalette.RUNE_FIRE_HI, 0.7), 0.8 * u, true)


static func ice_rune(ci: CanvasItem, rect: Rect2) -> void:
	var u := _u(rect)
	var c := UIPalette.RUNE_ICE
	ci.draw_line(_p(rect, 12, 3), _p(rect, 12, 21), c, 1.4 * u, true)
	ci.draw_line(_p(rect, 3, 12), _p(rect, 21, 12), c, 1.4 * u, true)
	ci.draw_line(_p(rect, 5.6, 5.6), _p(rect, 18.4, 18.4), c, 1.2 * u, true)
	ci.draw_line(_p(rect, 18.4, 5.6), _p(rect, 5.6, 18.4), c, 1.2 * u, true)
	var hi := UIPalette.RUNE_ICE_HI
	ci.draw_colored_polygon(PackedVector2Array([_p(rect, 12, 4.5), _p(rect, 13.2, 6.8), _p(rect, 12, 6.2), _p(rect, 10.8, 6.8)]), hi)
	ci.draw_colored_polygon(PackedVector2Array([_p(rect, 12, 19.5), _p(rect, 13.2, 17.2), _p(rect, 12, 17.8), _p(rect, 10.8, 17.2)]), hi)
	ci.draw_colored_polygon(PackedVector2Array([_p(rect, 4.5, 12), _p(rect, 6.8, 10.8), _p(rect, 6.2, 12), _p(rect, 6.8, 13.2)]), hi)
	ci.draw_colored_polygon(PackedVector2Array([_p(rect, 19.5, 12), _p(rect, 17.2, 10.8), _p(rect, 17.8, 12), _p(rect, 16.8, 13.2)]), hi)
	ci.draw_circle(_p(rect, 12, 12), 2.2 * u, Color(c, 0.25))
	ci.draw_arc(_p(rect, 12, 12), 2.2 * u, 0.0, TAU, 16, hi, 0.8 * u, true)


static func wind_rune(ci: CanvasItem, rect: Rect2) -> void:
	var u := _u(rect)
	var hi := UIPalette.RUNE_WIND_HI
	var base := UIPalette.RUNE_WIND
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 4, 8), [
		[_p(rect, 10, 6), _p(rect, 14, 8)],
		[_p(rect, 18, 10), _p(rect, 20, 8)],
		[_p(rect, 21, 7), _p(rect, 20.5, 6)],
	]), hi, 1.4 * u)
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 3, 12), [
		[_p(rect, 9, 10), _p(rect, 13, 12)],
		[_p(rect, 17, 14), _p(rect, 19, 12)],
	]), base, 1.4 * u)
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 4, 16), [
		[_p(rect, 8, 14), _p(rect, 11, 16)],
		[_p(rect, 14, 18), _p(rect, 16, 16)],
		[_p(rect, 17, 15), _p(rect, 16.5, 14)],
	]), hi, 1.4 * u)
	ci.draw_circle(_p(rect, 20.5, 6), 1.2 * u, Color(hi, 0.7))
	ci.draw_circle(_p(rect, 16.5, 14), 1.2 * u, Color(hi, 0.7))


static func shadow_rune(ci: CanvasItem, rect: Rect2) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 12), 7.0 * u, 0.0, TAU, 32, Color("#8855CC", 0.5), 1.2 * u, true)
	var star := PackedVector2Array([
		_p(rect, 12, 5), _p(rect, 13.5, 9), _p(rect, 17, 9), _p(rect, 14.2, 11.3),
		_p(rect, 15.3, 15), _p(rect, 12, 12.8), _p(rect, 8.7, 15), _p(rect, 9.8, 11.3),
		_p(rect, 7, 9), _p(rect, 10.5, 9),
	])
	ci.draw_colored_polygon(star, Color(UIPalette.RUNE_SHADOW, 0.3))
	star.append(star[0])
	_stroke(ci, star, UIPalette.RUNE_SHADOW_HI, 1.0 * u)


static func draw_rune(ci: CanvasItem, rune_id: StringName, rect: Rect2) -> void:
	match rune_id:
		&"fire":
			fire_rune(ci, rect)
		&"ice":
			ice_rune(ci, rect)
		&"wind":
			wind_rune(ci, rect)
		&"shadow":
			shadow_rune(ci, rect)


# ─── Small HUD icons ─────────────────────────────────────────────────────────

static func lock_icon(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var body := PackedVector2Array([
		_p(rect, 8.5, 11), _p(rect, 15.5, 11), _p(rect, 15.5, 17.5), _p(rect, 8.5, 17.5),
	])
	body.append(body[0])
	_stroke(ci, body, color, 1.2 * u)
	var shackle := UIDraw.flatten_quadratic_chain(_p(rect, 9.5, 11), [
		[_p(rect, 9.5, 7.5), _p(rect, 12, 6.5)],
		[_p(rect, 14.5, 7.5), _p(rect, 14.5, 11)],
	])
	_stroke(ci, shackle, color, 1.2 * u)


static func gift_icon(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var box := PackedVector2Array([
		_p(rect, 7, 10), _p(rect, 17, 10), _p(rect, 17, 18), _p(rect, 7, 18),
	])
	box.append(box[0])
	_stroke(ci, box, color, 1.1 * u)
	ci.draw_line(_p(rect, 12, 6.5), _p(rect, 12, 10), color, 1.0 * u, true)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 8, 7), _p(rect, 11.5, 4), _p(rect, 12, 7)), color, 0.9 * u)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 16, 7), _p(rect, 12.5, 4), _p(rect, 12, 7)), color, 0.9 * u)


static func map_pin_icon(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 12), 5.5 * u, 0.0, TAU, 24, color, 1.1 * u, true)
	ci.draw_circle(_p(rect, 12, 12), 1.4 * u, color)


static func chat_icon(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 12), 7.5 * u, 0.0, TAU, 28, color, 1.0 * u, true)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 8, 14), _p(rect, 12, 17.5), _p(rect, 16, 14)), color, 0.9 * u)
	ci.draw_circle(_p(rect, 9.5, 12), 0.8 * u, color)
	ci.draw_circle(_p(rect, 12, 12), 0.8 * u, color)
	ci.draw_circle(_p(rect, 14.5, 12), 0.8 * u, color)


static func auto_star_icon(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var star := UIDraw.star(rect.get_center(), rect.size.x * 0.42, rect.size.x * 0.18)
	ci.draw_colored_polygon(star, Color(color, 0.2))
	star.append(star[0])
	_stroke(ci, star, color, 1.0 * _u(rect))


# ─── Navigation icons ────────────────────────────────────────────────────────

static func nav_home(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, PackedVector2Array([_p(rect, 4, 9), _p(rect, 4, 20), _p(rect, 9.5, 20), _p(rect, 9.5, 14), _p(rect, 14.5, 14), _p(rect, 14.5, 20), _p(rect, 20, 20), _p(rect, 20, 9)]), color, 1.6 * u)
	_stroke(ci, PackedVector2Array([_p(rect, 1.5, 11), _p(rect, 12, 3), _p(rect, 22.5, 11)]), color, 1.6 * u)


static func nav_heroes(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 8.5, 8.5), 3.2 * u, 0.0, TAU, 20, color, 1.4 * u, true)
	ci.draw_arc(_p(rect, 16, 8.5), 3.2 * u, 0.0, TAU, 20, color, 1.4 * u, true)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 2, 20), _p(rect, 5.5, 14.5), _p(rect, 12.5, 19.5), 10), color, 1.4 * u)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 11.5, 19.5), _p(rect, 18.5, 14.5), _p(rect, 22, 20), 10), color, 1.4 * u)


static func nav_battle(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_line(_p(rect, 5, 5), _p(rect, 19, 19), color, 1.9 * u, true)
	ci.draw_line(_p(rect, 19, 5), _p(rect, 5, 19), color, 1.9 * u, true)
	ci.draw_line(_p(rect, 3, 7), _p(rect, 5, 5), color, 1.5 * u, true)
	ci.draw_line(_p(rect, 21, 7), _p(rect, 19, 5), color, 1.5 * u, true)
	ci.draw_line(_p(rect, 3, 17), _p(rect, 5, 19), color, 1.5 * u, true)
	ci.draw_line(_p(rect, 21, 17), _p(rect, 19, 19), color, 1.5 * u, true)


static func nav_guild(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var shield := UIDraw.flatten_quadratic_chain(_p(rect, 12, 3), [
		[_p(rect, 15.5, 4.2), _p(rect, 18.5, 5.5)],
		[_p(rect, 18.5, 8.5), _p(rect, 18.5, 12)],
		[_p(rect, 18.5, 17), _p(rect, 12, 20.5)],
		[_p(rect, 5.5, 17), _p(rect, 5.5, 12)],
		[_p(rect, 5.5, 8.5), _p(rect, 5.5, 5.5)],
		[_p(rect, 8.5, 4.2), _p(rect, 12, 3)],
	])
	_stroke(ci, shield, color, 1.5 * u)


static func nav_shop(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var bag := PackedVector2Array([
		_p(rect, 5.5, 10), _p(rect, 18.5, 10), _p(rect, 18.5, 20), _p(rect, 5.5, 20),
	])
	bag.append(bag[0])
	_stroke(ci, bag, color, 1.5 * u)
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 9, 10), [
		[_p(rect, 9, 7.5), _p(rect, 9, 7)],
		[_p(rect, 12, 4), _p(rect, 15, 7)],
		[_p(rect, 15, 7.5), _p(rect, 15, 10)],
	]), color, 1.5 * u)


static func draw_nav_icon(ci: CanvasItem, tab_id: StringName, rect: Rect2, color: Color) -> void:
	match tab_id:
		&"home":
			nav_home(ci, rect, color)
		&"heroes":
			nav_heroes(ci, rect, color)
		&"battle":
			nav_battle(ci, rect, color)
		&"guild":
			nav_guild(ci, rect, color)
		&"shop":
			nav_shop(ci, rect, color)


# ─── Heroes sub-tab icons ────────────────────────────────────────────────────

static func sub_zap(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, PackedVector2Array([
		_p(rect, 13, 2.5), _p(rect, 4, 13.5), _p(rect, 11.5, 13.5), _p(rect, 10.5, 21.5),
		_p(rect, 20, 10), _p(rect, 12, 10), _p(rect, 13, 2.5),
	]), color, 1.5 * u)


static func sub_book(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	# Open book: two page outlines meeting at the spine.
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 12, 6), _p(rect, 9, 4.2), _p(rect, 4, 4.5)), color, 1.4 * u)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 12, 6), _p(rect, 15, 4.2), _p(rect, 20, 4.5)), color, 1.4 * u)
	ci.draw_line(_p(rect, 4, 4.5), _p(rect, 4, 18.5), color, 1.4 * u, true)
	ci.draw_line(_p(rect, 20, 4.5), _p(rect, 20, 18.5), color, 1.4 * u, true)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 4, 18.5), _p(rect, 9, 18.0), _p(rect, 12, 20)), color, 1.4 * u)
	_stroke(ci, UIDraw.flatten_quadratic(_p(rect, 20, 18.5), _p(rect, 15, 18.0), _p(rect, 12, 20)), color, 1.4 * u)
	ci.draw_line(_p(rect, 12, 6), _p(rect, 12, 20), color, 1.2 * u, true)


static func sub_paw(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	# Main pad plus three toes, drawn as small outlined circles.
	ci.draw_arc(_p(rect, 12, 15.5), 3.6 * u, 0.0, TAU, 20, color, 1.4 * u, true)
	for toe in [Vector2(6.5, 9.5), Vector2(12, 7.6), Vector2(17.5, 9.5)]:
		ci.draw_arc(_p(rect, toe.x, toe.y), 1.7 * u, 0.0, TAU, 14, color, 1.3 * u, true)


static func draw_sub_icon(ci: CanvasItem, tab_id: StringName, rect: Rect2, color: Color) -> void:
	match tab_id:
		&"class":
			nav_heroes(ci, rect, color)
		&"skills":
			sub_zap(ci, rect, color)
		&"talents":
			auto_star_icon(ci, rect, color)
		&"equipment":
			nav_guild(ci, rect, color)
		&"cards":
			sub_book(ci, rect, color)
		&"pets":
			sub_paw(ci, rect, color)


# ─── Item / talent glyphs ────────────────────────────────────────────────────

static func item_boot(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, PackedVector2Array([
		_p(rect, 7, 4), _p(rect, 7, 12), _p(rect, 18, 12), _p(rect, 18, 17.5),
		_p(rect, 4.5, 17.5), _p(rect, 4.5, 14), _p(rect, 7, 14), _p(rect, 7, 4),
	]), color, 1.3 * u)
	ci.draw_line(_p(rect, 4.5, 15.5), _p(rect, 18, 15.5), Color(color, 0.5), 0.9 * u, true)


static func item_ring(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 14.5), 5.5 * u, 0.0, TAU, 28, color, 1.3 * u, true)
	var gem := UIDraw.diamond(_p(rect, 12, 6), 2.2 * u, 2.6 * u)
	ci.draw_colored_polygon(gem, Color(color, 0.35))
	gem.append(gem[0])
	_stroke(ci, gem, color, 1.1 * u)
	ci.draw_line(_p(rect, 9.8, 8.2), _p(rect, 8.6, 10.4), color, 1.0 * u, true)
	ci.draw_line(_p(rect, 14.2, 8.2), _p(rect, 15.4, 10.4), color, 1.0 * u, true)


static func item_band(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	# Strand of beads.
	for i in range(8):
		var a := TAU * float(i) / 8.0 - PI / 2.0
		var c := _p(rect, 12, 12) + Vector2(cos(a), sin(a)) * 6.2 * u
		ci.draw_arc(c, 1.5 * u, 0.0, TAU, 10, color, 1.1 * u, true)


static func item_leaf(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, UIDraw.flatten_cubic(_p(rect, 12, 17), _p(rect, 5.5, 14.5), _p(rect, 5.5, 7.5), _p(rect, 12, 4.5)), color, 1.3 * u)
	_stroke(ci, UIDraw.flatten_cubic(_p(rect, 12, 4.5), _p(rect, 18.5, 7.5), _p(rect, 18.5, 14.5), _p(rect, 12, 17)), color, 1.3 * u)
	ci.draw_line(_p(rect, 12, 17), _p(rect, 12, 20.5), color, 1.2 * u, true)
	ci.draw_line(_p(rect, 12, 6.5), _p(rect, 12, 15), Color(color, 0.6), 0.9 * u, true)


static func item_drop(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 14), 5.2 * u, 0.0, TAU, 24, color, 1.3 * u, true)
	ci.draw_line(_p(rect, 12, 3.5), _p(rect, 7.9, 10.6), color, 1.3 * u, true)
	ci.draw_line(_p(rect, 12, 3.5), _p(rect, 16.1, 10.6), color, 1.3 * u, true)


static func item_wave(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 3, 10), [
		[_p(rect, 7.5, 6.5), _p(rect, 12, 10)],
		[_p(rect, 16.5, 13.5), _p(rect, 21, 10)],
	]), color, 1.3 * u)
	_stroke(ci, UIDraw.flatten_quadratic_chain(_p(rect, 3, 16.5), [
		[_p(rect, 7.5, 13), _p(rect, 12, 16.5)],
		[_p(rect, 16.5, 20), _p(rect, 21, 16.5)],
	]), color, 1.3 * u)


static func item_swords(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_line(_p(rect, 8, 4.5), _p(rect, 16, 18.3), color, 1.3 * u, true)
	ci.draw_line(_p(rect, 16, 4.5), _p(rect, 8, 18.3), color, 1.3 * u, true)
	# Guards near the hilts and pommel dots.
	ci.draw_line(_p(rect, 13.6, 18.0), _p(rect, 16.8, 16.2), color, 1.2 * u, true)
	ci.draw_line(_p(rect, 10.4, 18.0), _p(rect, 7.2, 16.2), color, 1.2 * u, true)
	ci.draw_circle(_p(rect, 16.6, 19.6), 0.9 * u, color)
	ci.draw_circle(_p(rect, 7.4, 19.6), 0.9 * u, color)


static func item_heart(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	_stroke(ci, UIDraw.flatten_cubic(_p(rect, 12, 19), _p(rect, 4.5, 14), _p(rect, 5.5, 6.5), _p(rect, 12, 9.5), 12), color, 1.3 * u)
	_stroke(ci, UIDraw.flatten_cubic(_p(rect, 12, 9.5), _p(rect, 18.5, 6.5), _p(rect, 19.5, 14), _p(rect, 12, 19), 12), color, 1.3 * u)


static func item_target(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_arc(_p(rect, 12, 12), 6.8 * u, 0.0, TAU, 28, color, 1.2 * u, true)
	ci.draw_arc(_p(rect, 12, 12), 3.2 * u, 0.0, TAU, 20, color, 1.1 * u, true)
	ci.draw_circle(_p(rect, 12, 12), 1.0 * u, color)


static func item_sparkle(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	var s := UIDraw.star(_p(rect, 12, 12), 7.5 * u, 2.2 * u, 4)
	ci.draw_colored_polygon(s, Color(color, 0.25))
	s.append(s[0])
	_stroke(ci, s, color, 1.1 * u)


static func draw_item_icon(ci: CanvasItem, icon_id: StringName, rect: Rect2, color: Color) -> void:
	match icon_id:
		&"fire":
			fire_rune(ci, rect)
		&"ice":
			ice_rune(ci, rect)
		&"wind":
			wind_rune(ci, rect)
		&"shadow":
			shadow_rune(ci, rect)
		&"shield":
			nav_guild(ci, rect, color)
		&"boot":
			item_boot(ci, rect, color)
		&"ring":
			item_ring(ci, rect, color)
		&"band":
			item_band(ci, rect, color)
		&"leaf":
			item_leaf(ci, rect, color)
		&"drop":
			item_drop(ci, rect, color)
		&"wave":
			item_wave(ci, rect, color)
		&"swords":
			item_swords(ci, rect, color)
		&"heart":
			item_heart(ci, rect, color)
		&"bolt":
			sub_zap(ci, rect, color)
		&"target":
			item_target(ci, rect, color)
		&"sparkle":
			item_sparkle(ci, rect, color)
		&"gem":
			var gem := UIDraw.diamond(rect.get_center(), rect.size.x * 0.38, rect.size.y * 0.45)
			ci.draw_colored_polygon(gem, Color(color, 0.35))
			gem.append(gem[0])
			_stroke(ci, gem, color, 1.2 * _u(rect))
		&"orb":
			ci.draw_circle(rect.get_center(), rect.size.x * 0.32, Color(color, 0.2))
			ci.draw_arc(rect.get_center(), rect.size.x * 0.32, 0.0, TAU, 24, color, 1.2 * _u(rect), true)
		&"globe":
			ci.draw_arc(rect.get_center(), rect.size.x * 0.34, 0.0, TAU, 24, color, 1.1 * _u(rect), true)
			ci.draw_arc(rect.get_center(), rect.size.x * 0.15, -PI * 0.5, PI * 0.5, 12, color, 0.9 * _u(rect), true)
			ci.draw_line(Vector2(rect.position.x, rect.get_center().y), Vector2(rect.end.x, rect.get_center().y), color, 0.9 * _u(rect), true)
		&"skull":
			ci.draw_circle(rect.get_center() + Vector2(0, -rect.size.y * 0.08), rect.size.x * 0.28, Color(color, 0.2))
			ci.draw_arc(rect.get_center() + Vector2(0, -rect.size.y * 0.08), rect.size.x * 0.28, 0.0, TAU, 24, color, 1.1 * _u(rect), true)
			ci.draw_circle(rect.get_center() + Vector2(-rect.size.x * 0.1, -rect.size.y * 0.08), rect.size.x * 0.045, color)
			ci.draw_circle(rect.get_center() + Vector2(rect.size.x * 0.1, -rect.size.y * 0.08), rect.size.x * 0.045, color)
		&"book":
			sub_book(ci, rect, color)


# ─── Small marks ─────────────────────────────────────────────────────────────

static func chevron_up(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	_stroke(ci, PackedVector2Array([_p(rect, 6, 15), _p(rect, 12, 9), _p(rect, 18, 15)]), color, 1.6 * _u(rect))


static func chevron_down(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	_stroke(ci, PackedVector2Array([_p(rect, 6, 9), _p(rect, 12, 15), _p(rect, 18, 9)]), color, 1.6 * _u(rect))


static func x_mark(ci: CanvasItem, rect: Rect2, color: Color) -> void:
	var u := _u(rect)
	ci.draw_line(_p(rect, 7, 7), _p(rect, 17, 17), color, 1.6 * u, true)
	ci.draw_line(_p(rect, 17, 7), _p(rect, 7, 17), color, 1.6 * u, true)
