class_name GuildHallPage
extends Control
## Guild Hall modal with Family Hall, Members, and Donation tabs.

signal closed

const MEMBERS: Array[Dictionary] = [
	{"name":"Enki","position":"Member","activity":147,"status":"Online"},
	{"name":"ovi","position":"Leader","activity":820,"status":"1w ago"},
	{"name":"Kasuma","position":"Member","activity":310,"status":"2mo ago"},
	{"name":"Joseplay12","position":"Member","activity":0,"status":"2mo ago"},
	{"name":"Darkon","position":"Member","activity":0,"status":"3mo ago"},
	{"name":"Pimpolho","position":"Member","activity":0,"status":"3mo ago"},
	{"name":"Shadowwolfz5","position":"Member","activity":0,"status":"3mo ago"},
	{"name":"MEG","position":"Member","activity":0,"status":"3mo ago"},
]

var _tab: StringName = &"hall"


func _ready() -> void:
	resized.connect(_build)
	_build()


func _clear() -> void:
	for child in get_children(): child.queue_free()


func _build() -> void:
	if size.x <= 0: return
	_clear(); queue_redraw()
	GuildUI.add_close_button(self, Color("#8060B0"), func() -> void: closed.emit())
	match _tab:
		&"hall": _build_hall()
		&"members": _build_members()
		&"donation": _build_donation()
	_build_tabs()


func _build_tabs() -> void:
	var labels := [[&"hall","FAMILY HALL"],[&"members","MEMBERS"],[&"donation","DONATION"]]
	var w := size.x / 3.0
	for i in range(labels.size()):
		var active: bool = labels[i][0] == _tab
		var btn := GuildUI.button(labels[i][1], 10, UIPalette.GOLD if active else Color("#3A2858"), UIPalette.GOLD if active else Color("#2A1845"))
		btn.position = Vector2(i*w,size.y-54); btn.size = Vector2(w,54); btn.cut = 0
		var id: StringName = labels[i][0]
		btn.pressed.connect(func() -> void: _tab=id;_build())
		add_child(btn)


func _build_hall() -> void:
	var emblem := GuildEmblem.new(); emblem.position=Vector2((size.x-76)*0.5,78);emblem.size=Vector2(76,76);add_child(emblem)
	var name := GuildUI.label("IRON PACT",true,18,UIPalette.GOLD,HORIZONTAL_ALIGNMENT_CENTER);name.position=Vector2(30,165);name.size=Vector2(size.x-60,30);add_child(name)
	var meta := GuildUI.label("Members 72/90     |     Lv.10",false,10,Color("#6050A0"),HORIZONTAL_ALIGNMENT_CENTER);meta.position=Vector2(40,198);meta.size=Vector2(size.x-80,20);add_child(meta)
	var stats := GuildUI.panel(Color("#2A1845"),0.45);stats.position=Vector2(16,230);stats.size=Vector2(size.x-32,90);add_child(stats)
	_add_stat(stats,"Guild EXP","4,500/6,000",0.75,UIPalette.CYAN,12)
	_add_stat(stats,"Guild Funds","38,000/100,000",0.38,UIPalette.GOLD,50)
	var note := GuildUI.panel(Color("#3D2060"),0.45);note.position=Vector2(16,338);note.size=Vector2(size.x-32,82);add_child(note)
	var title := GuildUI.label("ANNOUNCEMENT",true,9,UIPalette.GOLD_MUTED);title.position=Vector2(14,8);title.size=Vector2(note.size.x-28,20);note.add_child(title)
	var body := GuildUI.label("chicos no se olviden de donar al clan cada reset y entrar al teatro magico",false,10,Color("#7060A0"));body.position=Vector2(14,30);body.size=Vector2(note.size.x-28,42);body.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;note.add_child(body)
	var list := GuildUI.button("FAMILY LIST",10,UIPalette.CYAN,UIPalette.CYAN);list.position=Vector2(16,438);list.size=Vector2((size.x-44)*0.5,38);add_child(list)
	var log := GuildUI.button("FAMILY LOG",10,Color("#4A3870"));log.position=Vector2(28+(size.x-44)*0.5,438);log.size=Vector2((size.x-44)*0.5,38);add_child(log)


func _add_stat(parent: Control, text: String, value: String, fraction: float, color: Color, y: float) -> void:
	var key:=GuildUI.label(text,false,9,Color("#6050A0"));key.position=Vector2(14,y);key.size=Vector2(130,18);parent.add_child(key)
	var val:=GuildUI.label(value,false,9,color,HORIZONTAL_ALIGNMENT_RIGHT);val.position=Vector2(parent.size.x-150,y);val.size=Vector2(136,18);parent.add_child(val)
	GuildUI.add_progress(parent,Vector2(14,y+20),Vector2(parent.size.x-28,5),fraction,color)


func _build_members() -> void:
	var headers := [["Name",16.0,210.0,HORIZONTAL_ALIGNMENT_LEFT],["Weekly Act.",size.x-145.0,78.0,HORIZONTAL_ALIGNMENT_CENTER],["Position",size.x-66.0,54.0,HORIZONTAL_ALIGNMENT_RIGHT]]
	for h in headers:
		var label:=GuildUI.label(h[0],false,9,Color("#4A3870"),h[3]);label.position=Vector2(h[1],58);label.size=Vector2(h[2],26);add_child(label)
	for i in range(MEMBERS.size()):
		var data:=MEMBERS[i]
		var row:=ColorRect.new();row.color=Color("#0A0720") if i%2==0 else Color("#090618");row.position=Vector2(0,84+i*50);row.size=Vector2(size.x,50);row.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(row)
		var icon:=GuildIcon.new();icon.icon_id=&"avatar";icon.accent=UIPalette.GOLD if data["position"]=="Leader" else Color("#8060B0");icon.position=Vector2(12,9);icon.size=Vector2(32,32);row.add_child(icon)
		var online: bool = data["status"]=="Online"
		var name:=GuildUI.label(data["name"],false,10,UIPalette.CYAN if online else Color("#C8B8E8"));name.position=Vector2(52,5);name.size=Vector2(170,20);row.add_child(name)
		var status:=GuildUI.label(data["status"],false,8,UIPalette.HP if online else Color("#3A2858"));status.position=Vector2(52,24);status.size=Vector2(120,16);row.add_child(status)
		var activity:=GuildUI.label(str(data["activity"]),false,10,Color("#7050B0"),HORIZONTAL_ALIGNMENT_CENTER);activity.position=Vector2(size.x-145,12);activity.size=Vector2(78,22);row.add_child(activity)
		var role_color:=UIPalette.GOLD if data["position"]=="Leader" else Color("#604080")
		var role:=GuildUI.label(data["position"],false,9,role_color,HORIZONTAL_ALIGNMENT_RIGHT);role.position=Vector2(size.x-66,12);role.size=Vector2(54,22);row.add_child(role)


func _build_donation() -> void:
	var title:=GuildUI.label("DONATION",true,16,UIPalette.GOLD,HORIZONTAL_ALIGNMENT_CENTER);title.position=Vector2(40,90);title.size=Vector2(size.x-80,30);add_child(title)
	var ids:=[&"fish",&"butterfly",&""]
	for i in range(3):
		var panel:=GuildUI.panel(Color("#5A3080"),0.65);panel.position=Vector2(size.x*0.5-108+i*80,138);panel.size=Vector2(62,72);add_child(panel)
		if not String(ids[i]).is_empty():
			var icon:=GuildIcon.new();icon.icon_id=ids[i];icon.accent=Color("#8060D0");icon.framed=false;icon.position=Vector2(13,10);icon.size=Vector2(36,36);panel.add_child(icon)
			var level:=GuildUI.label("Lv.%d"%(i+1),false,8,Color("#8060D0"),HORIZONTAL_ALIGNMENT_CENTER);level.position=Vector2(4,49);level.size=Vector2(54,16);panel.add_child(level)
	var free:=GuildUI.button("FREE",14,UIPalette.CYAN,UIPalette.CYAN);free.fill_top=Color("#0D3040");free.fill_bottom=Color("#082030");free.position=Vector2((size.x-100)*0.5,232);free.size=Vector2(100,44);add_child(free)
	var attempts:=GuildUI.label("Remaining attempts today: 5",false,10,Color("#7050A0"),HORIZONTAL_ALIGNMENT_CENTER);attempts.position=Vector2(40,292);attempts.size=Vector2(size.x-80,24);add_child(attempts)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#04020F"),Color("#020108"))
	draw_rect(Rect2(0,0,size.x,60),Color("#26105A"))
	var arch:=UIDraw.flatten_quadratic(Vector2(40,58),Vector2(size.x*0.5,28),Vector2(size.x-40,58),24)
	for i in range(arch.size()-1):draw_line(arch[i],arch[i+1],Color(UIPalette.GOLD,0.65),1.1,true)
	draw_colored_polygon(UIDraw.diamond(Vector2(size.x*0.5,31),4,6),UIPalette.GOLD)
