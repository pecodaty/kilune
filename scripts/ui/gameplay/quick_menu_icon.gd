class_name QuickMenuIcon
extends Control

@export var icon_id: StringName = &"bag":
	set(value): icon_id=value; queue_redraw()
@export var accent := UIPalette.CYAN:
	set(value): accent=value; queue_redraw()


func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var rect:=Rect2(size*0.12,size*0.76); var c:=rect.get_center(); var u:=rect.size.x/24.0
	match icon_id:
		&"bag":
			draw_rect(Rect2(c+Vector2(-8,-5)*u,Vector2(16,14)*u),Color(accent,0.35)); draw_arc(c+Vector2(0,-5)*u,5*u,PI,TAU,16,accent,2*u,true)
		&"mail":
			draw_rect(Rect2(c+Vector2(-10,-7)*u,Vector2(20,14)*u),Color(accent,0.25)); draw_rect(Rect2(c+Vector2(-10,-7)*u,Vector2(20,14)*u),accent,false,1.4*u)
			draw_line(c+Vector2(-10,-7)*u,c,accent,1.2*u,true); draw_line(c,c+Vector2(10,-7)*u,accent,1.2*u,true)
		&"map":
			var p:=PackedVector2Array([c+Vector2(-10,-8)*u,c+Vector2(-3,-5)*u,c+Vector2(3,-8)*u,c+Vector2(10,-5)*u,c+Vector2(10,8)*u,c+Vector2(3,5)*u,c+Vector2(-3,8)*u,c+Vector2(-10,5)*u])
			draw_colored_polygon(p,Color(accent,0.28))
			var loop:=p.duplicate()
			loop.append(p[0])
			for i in range(loop.size()-1):draw_line(loop[i],loop[i+1],accent,1.1*u,true)
		&"config":
			for i in range(8):
				var a:=TAU*i/8.0; draw_line(c+Vector2(cos(a),sin(a))*6*u,c+Vector2(cos(a),sin(a))*10*u,accent,3*u,true)
			draw_arc(c,7*u,0,TAU,24,accent,3*u,true); draw_circle(c,2.5*u,Color("#0D0825"))
