class_name GuildHallCard
extends Button
## Large central Guild Hall destination card.


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	resized.connect(queue_redraw)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO, size), Color("#0E0830"), Color("#120830"))
	var border := Color("#3D2060", 0.65)
	draw_rect(Rect2(Vector2.ZERO, size), border, false, 1.0)
	for x in [18.0, size.x - 46.0]:
		draw_rect(Rect2(x, 25, 28, size.y - 50), Color("#100838"))
		draw_rect(Rect2(x, 25, 28, size.y - 50), Color("#3D2060"), false, 0.8)
	var arch := UIDraw.flatten_quadratic(Vector2(46,size.y*0.36),Vector2(size.x*0.5,5),Vector2(size.x-46,size.y*0.36),24)
	for i in range(arch.size()-1): draw_line(arch[i],arch[i+1],Color("#00E5C8",0.7),2.0,true)
	for corner in [[Vector2.ZERO,Vector2(14,0),Vector2(0,14)],[Vector2(size.x,0),Vector2(size.x-14,0),Vector2(size.x,14)],[Vector2(0,size.y),Vector2(14,size.y),Vector2(0,size.y-14)],[size,Vector2(size.x-14,size.y),Vector2(size.x,size.y-14)]]:
		draw_line(corner[0],corner[1],UIPalette.GOLD,1.2);draw_line(corner[0],corner[2],UIPalette.GOLD,1.2)

