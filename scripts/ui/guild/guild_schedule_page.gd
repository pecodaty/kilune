class_name GuildSchedulePage
extends Control
## Daily and weekly Guild event schedule.

signal closed
signal event_requested(event_id: StringName)

var _tab:StringName=&"daily"


func _ready()->void:
	resized.connect(_build);_build()


func _build()->void:
	if size.x<=0:return
	for child in get_children():child.queue_free()
	queue_redraw();GuildUI.add_page_header(self,"EVENT SCHEDULE","",Color("#B070FF"),func()->void:closed.emit())
	for i in range(2):
		var id:StringName=&"daily" if i==0 else &"weekly";var active:=id==_tab
		var tab:=GuildUI.button("DAILY" if i==0 else "WEEKLY",10,Color("#AA44FF") if active else Color("#3A2858"),Color("#AA44FF") if active else Color("#2A1845"));tab.cut=0;tab.position=Vector2(i*size.x*0.5,56);tab.size=Vector2(size.x*0.5,38);tab.pressed.connect(func()->void:_tab=id;_build());add_child(tab)
	if _tab==&"daily":
		_add_event(&"treasure","FAMILY TREASURE HUNT","Daily 19:00",&"map",true,Vector2(14,108))
		_add_event(&"abyssal","CROSS THE ABYSSAL PORTAL","Daily Next: 19:00",&"portal",false,Vector2(14,196))
	else:
		var icon:=GuildIcon.new();icon.icon_id=&"calendar";icon.accent=Color("#AA44FF");icon.position=Vector2((size.x-54)*0.5,140);icon.size=Vector2(54,54);add_child(icon)
		var none:=GuildUI.label("NO WEEKLY EVENTS",true,11,Color("#3A2858"),HORIZONTAL_ALIGNMENT_CENTER);none.position=Vector2(40,210);none.size=Vector2(size.x-80,24);add_child(none)
		var copy:=GuildUI.label("Check back each week for new events.",false,9,Color("#2A1845"),HORIZONTAL_ALIGNMENT_CENTER);copy.position=Vector2(30,236);copy.size=Vector2(size.x-60,20);add_child(copy)


func _add_event(id:StringName,title_text:String,subtitle:String,icon_id:StringName,available:bool,at:Vector2)->void:
	var color:=Color("#22DD6E") if available else Color("#3D2060")
	var panel:=GuildUI.panel(color,0.42);panel.position=at;panel.size=Vector2(size.x-28,74);add_child(panel)
	var icon:=GuildIcon.new();icon.icon_id=icon_id;icon.accent=color;icon.position=Vector2(14,14);icon.size=Vector2(46,46);panel.add_child(icon)
	var title:=GuildUI.label(title_text,true,11,Color("#D0C0F0") if available else Color("#4A3870"));title.position=Vector2(72,12);title.size=Vector2(panel.size.x-155,24);panel.add_child(title)
	var sub:=GuildUI.label(subtitle,false,9,Color("#5A4080"));sub.position=Vector2(72,37);sub.size=Vector2(panel.size.x-155,18);panel.add_child(sub)
	if available:
		var go:=GuildUI.button("GO",11,Color("#22DD6E"),Color("#22DD6E"));go.fill_top=Color("#0D3A18");go.fill_bottom=Color("#0A2A10");go.position=Vector2(panel.size.x-72,20);go.size=Vector2(58,34);go.pressed.connect(func()->void:event_requested.emit(id));panel.add_child(go)
	else:
		var soon:=GuildUI.label("Coming soon",false,8,Color("#3A2858"),HORIZONTAL_ALIGNMENT_CENTER);soon.position=Vector2(panel.size.x-82,20);soon.size=Vector2(68,34);panel.add_child(soon)


func _draw()->void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#04020F"),Color("#08031A"))

