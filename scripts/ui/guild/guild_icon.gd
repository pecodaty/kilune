class_name GuildIcon
extends Control
## Procedural Guild-area and item glyphs; prototype emoji never reach production.

@export var icon_id: StringName = &"fire":
	set(v): icon_id = v; queue_redraw()
@export var accent := UIPalette.CYAN:
	set(v): accent = v; queue_redraw()
@export var framed := true:
	set(v): framed = v; queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	if framed:
		var frame := UIDraw.octagon(size - Vector2.ONE * 2.0, size.x * 0.24)
		for i in range(frame.size()): frame[i] += Vector2.ONE
		draw_colored_polygon(frame, Color("#0D0825"))
		var loop := frame.duplicate(); loop.append(frame[0])
		for i in range(loop.size() - 1): draw_line(loop[i], loop[i + 1], Color(accent, 0.8), 1.1, true)
	_draw_glyph(Rect2(size * 0.23, size * 0.54))


func _draw_glyph(rect: Rect2) -> void:
	var c := rect.get_center()
	var u := rect.size.x / 24.0
	match icon_id:
		&"fire":
			var flame := PackedVector2Array([c + Vector2(0,-10)*u,c + Vector2(6,-2)*u,c + Vector2(7,5)*u,c + Vector2(0,10)*u,c + Vector2(-7,5)*u,c + Vector2(-5,-2)*u])
			draw_colored_polygon(flame, accent); draw_circle(c + Vector2(0,4)*u, 3*u, Color("#FFD040"))
		&"cart":
			draw_rect(Rect2(c + Vector2(-8,-5)*u, Vector2(14,9)*u), Color(accent,0.25))
			draw_rect(Rect2(c + Vector2(-8,-5)*u, Vector2(14,9)*u), accent, false, 1.3*u)
			draw_line(c+Vector2(6,-5)*u,c+Vector2(9,-9)*u,accent,1.3*u,true); draw_circle(c+Vector2(-5,7)*u,2*u,accent); draw_circle(c+Vector2(5,7)*u,2*u,accent)
		&"books":
			for i in range(3): draw_rect(Rect2(c + Vector2(-8+i*3,-7+i*3)*u, Vector2(12,5)*u), Color(accent,0.35+0.18*i), true)
		&"calendar":
			draw_rect(Rect2(c+Vector2(-8,-7)*u,Vector2(16,15)*u),Color(accent,0.22))
			draw_rect(Rect2(c+Vector2(-8,-7)*u,Vector2(16,15)*u),accent,false,1.2*u)
			for y in range(2):
				for x in range(3): draw_circle(c+Vector2(-5+x*5,-1+y*5)*u,0.9*u,accent)
		&"scroll":
			draw_rect(Rect2(c+Vector2(-6,-8)*u,Vector2(12,16)*u),Color("#FFC080"));
			for y in [-3.0,1.0,5.0]: draw_line(c+Vector2(-3,y)*u,c+Vector2(4,y)*u,accent,0.8*u)
		&"gear":
			draw_arc(c,7*u,0,TAU,24,accent,3*u,true); draw_circle(c,2.5*u,Color("#0D0825"))
		&"sparkle":
			draw_colored_polygon(UIDraw.star(c,9*u,2.8*u,4),accent)
		&"gem":
			draw_colored_polygon(UIDraw.diamond(c,8*u,9*u),accent)
		&"map":
			var pts := PackedVector2Array([c+Vector2(-9,-7)*u,c+Vector2(-3,-5)*u,c+Vector2(3,-8)*u,c+Vector2(9,-5)*u,c+Vector2(9,7)*u,c+Vector2(3,5)*u,c+Vector2(-3,8)*u,c+Vector2(-9,5)*u])
			draw_colored_polygon(pts,Color(accent,0.3))
			var loop:=pts.duplicate()
			loop.append(pts[0])
			for i in range(loop.size()-1):
				draw_line(loop[i],loop[i+1],accent,1*u,true)
		&"portal":
			for i in range(3): draw_arc(c, (3+i*2.5)*u, i*0.8, TAU+i*0.8, 20, accent, 1.2*u, true)
		&"swords": IconDraw.item_swords(self, rect, accent)
		&"heart": IconDraw.item_heart(self, rect, accent)
		&"shield": IconDraw.nav_guild(self, rect, accent)
		&"bolt": IconDraw.sub_zap(self, rect, accent)
		&"avatar": IconDraw.nav_heroes(self, rect, accent)
		&"fish":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-7,0)*u,c+Vector2(-2,-6)*u,c+Vector2(7,0)*u,c+Vector2(-2,6)*u]),accent); draw_colored_polygon(PackedVector2Array([c+Vector2(-7,0)*u,c+Vector2(-11,-5)*u,c+Vector2(-11,5)*u]),Color(accent,0.7))
		&"butterfly":
			for sx in [-1.0,1.0]:
				draw_circle(c+Vector2(5*sx,-2)*u,4*u,Color(accent,0.65))
			draw_line(c+Vector2(0,-6)*u,c+Vector2(0,7)*u,accent,1.4*u,true)
