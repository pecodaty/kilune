class_name ShopIcon
extends Control
## Compact procedural storefront glyphs. Keeps prototype emoji out of runtime UI.

@export var icon_id: StringName = &"gem":
	set(value): icon_id = value; queue_redraw()
@export var accent := UIPalette.GOLD:
	set(value): accent = value; queue_redraw()
@export var framed := false:
	set(value): framed = value; queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	if framed:
		var frame := UIDraw.clipped_rect(size - Vector2.ONE * 2.0, 7.0, 0.0, 7.0, 0.0)
		for i in range(frame.size()): frame[i] += Vector2.ONE
		draw_colored_polygon(frame, Color(accent, 0.08))
		var loop := frame.duplicate(); loop.append(frame[0])
		for i in range(loop.size() - 1): draw_line(loop[i], loop[i + 1], Color(accent, 0.45), 1.0, true)
	_draw_glyph(Rect2(size * 0.18, size * 0.64))


func _draw_glyph(rect: Rect2) -> void:
	var c := rect.get_center()
	var u := rect.size.x / 24.0
	match icon_id:
		&"gem":
			var p := PackedVector2Array([c+Vector2(-9,-5)*u,c+Vector2(-4,-10)*u,c+Vector2(5,-10)*u,c+Vector2(10,-4)*u,c+Vector2(0,10)*u])
			draw_colored_polygon(p, accent); draw_line(p[0],c,Color.WHITE,1.0*u,true); draw_line(p[3],c,Color.WHITE,1.0*u,true)
		&"clock":
			draw_circle(c,9*u,Color(accent,0.18)); draw_arc(c,8*u,0,TAU,28,accent,1.8*u,true)
			draw_line(c,c+Vector2(0,-5)*u,accent,1.7*u,true); draw_line(c,c+Vector2(4,2)*u,accent,1.7*u,true)
		&"coin":
			draw_circle(c,9*u,accent); draw_circle(c,6*u,Color("#FFCC55")); draw_arc(c,4*u,0,TAU,20,Color("#B56818"),1.0*u,true)
		&"dress":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-5,-9)*u,c+Vector2(5,-9)*u,c+Vector2(3,-2)*u,c+Vector2(9,9)*u,c+Vector2(-9,9)*u,c+Vector2(-3,-2)*u]),accent)
		&"box":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-9,-5)*u,c+Vector2(0,-10)*u,c+Vector2(9,-5)*u,c+Vector2(0,0)*u]),Color(accent,0.8))
			draw_colored_polygon(PackedVector2Array([c+Vector2(-9,-5)*u,c,c+Vector2(0,10)*u,c+Vector2(-9,5)*u]),Color(accent,0.5))
			draw_colored_polygon(PackedVector2Array([c,c+Vector2(9,-5)*u,c+Vector2(9,5)*u,c+Vector2(0,10)*u]),accent)
		&"gacha":
			draw_rect(Rect2(c+Vector2(-10,-7)*u,Vector2(20,14)*u),Color(accent,0.16)); draw_rect(Rect2(c+Vector2(-10,-7)*u,Vector2(20,14)*u),accent,false,1.3*u)
			for x in [-6.0,0.0,6.0]: draw_colored_polygon(UIDraw.star(c+Vector2(x,0)*u,2.6*u,1.1*u,5),accent)
		&"gift":
			draw_rect(Rect2(c+Vector2(-9,-3)*u,Vector2(18,12)*u),accent); draw_rect(Rect2(c+Vector2(-10,-7)*u,Vector2(20,5)*u),Color(accent,0.8))
			draw_rect(Rect2(c+Vector2(-2,-7)*u,Vector2(4,16)*u),Color("#FF4477")); draw_arc(c+Vector2(-4,-8)*u,4*u,PI,TAU,12,accent,2*u,true); draw_arc(c+Vector2(4,-8)*u,4*u,PI,TAU,12,accent,2*u,true)
		&"key":
			draw_arc(c+Vector2(4,-4)*u,5*u,0,TAU,20,accent,2*u,true); draw_line(c+Vector2(0,0)*u,c+Vector2(-9,9)*u,accent,3*u,true); draw_line(c+Vector2(-6,6)*u,c+Vector2(-3,9)*u,accent,2*u,true)
		&"lamp":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-9,4)*u,c+Vector2(3,-5)*u,c+Vector2(9,-2)*u,c+Vector2(4,6)*u,c+Vector2(-4,8)*u]),accent); draw_circle(c+Vector2(4,-6)*u,2*u,Color("#FF4477"))
		&"ticket":
			draw_rect(Rect2(c+Vector2(-10,-6)*u,Vector2(20,12)*u),accent); draw_line(c+Vector2(2,-4)*u,c+Vector2(2,4)*u,Color("#8B6200"),1.0*u,true)
			for y in [-3.0,0.0,3.0]: draw_line(c+Vector2(-7,y)*u,c+Vector2(-1,y)*u,Color("#8B6200"),0.8*u,true)
		&"paw":
			draw_circle(c+Vector2(0,4)*u,6*u,accent)
			for p in [Vector2(-7,-4),Vector2(-2,-8),Vector2(4,-8),Vector2(8,-3)]: draw_circle(c+p*u,2.7*u,accent)
		&"star": draw_colored_polygon(UIDraw.star(c,10*u,4.2*u,5),accent)
		&"swords": IconDraw.item_swords(self, rect, accent)
		&"avatar": IconDraw.nav_heroes(self, rect, accent)
		&"leaf":
			draw_colored_polygon(PackedVector2Array([c+Vector2(-8,7)*u,c+Vector2(-5,-5)*u,c+Vector2(8,-9)*u,c+Vector2(5,5)*u]),accent); draw_line(c+Vector2(-7,8)*u,c+Vector2(6,-6)*u,Color("#081008"),1.1*u,true)
		&"wave":
			for y in [-5.0,1.0,7.0]: draw_arc(c+Vector2(0,y)*u,8*u,PI*0.1,PI*0.9,14,accent,2*u,true)
		&"bolt": IconDraw.sub_zap(self, rect, accent)
		&"skull":
			draw_circle(c+Vector2(0,-2)*u,8*u,accent); draw_rect(Rect2(c+Vector2(-5,4)*u,Vector2(10,6)*u),accent)
			draw_circle(c+Vector2(-3,-2)*u,2*u,Color("#0A0612")); draw_circle(c+Vector2(3,-2)*u,2*u,Color("#0A0612"))
		&"dragon":
			draw_arc(c,8*u,-PI*0.7,PI*0.8,20,accent,4*u,true); draw_colored_polygon(PackedVector2Array([c+Vector2(3,-9)*u,c+Vector2(10,-5)*u,c+Vector2(4,-2)*u]),accent)
		_:
			IconDraw.draw_item_icon(self, icon_id, rect, accent)
