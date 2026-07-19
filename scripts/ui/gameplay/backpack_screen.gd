class_name BackpackScreen
extends Control
## Full-screen inventory overlay opened by the floating quick menu.

signal closed

const FILTERS := [[&"all","ALL"],[&"materials","MATERIALS"],[&"equipment","EQUIPMENT"],[&"blueprints","BLUEPRINTS"],[&"consumables","CONSUMABLES"],[&"quest","QUEST"],[&"misc","MISC"]]
const ITEMS := [
	[&"thread_ancient","Ancient Thread",&"materials",5,&"common",&"ticket",false,0],
	[&"arcane_dust","Arcane Dust",&"materials",909,&"uncommon",&"star",false,0],
	[&"beast_leather","Beast Leather",&"materials",8,&"common",&"leaf",false,0],
	[&"celestial_dust","Celestial Dust",&"materials",99,&"rare",&"star",false,0],
	[&"hardwood","Hardwood",&"materials",12,&"common",&"box",false,0],
	[&"iron_ore","Iron Ore",&"materials",20,&"common",&"key",false,0],
	[&"moonsteel","Moonsteel",&"materials",99,&"rare",&"gem",false,0],
	[&"royal_leather","Royal Leather",&"materials",4,&"uncommon",&"dress",false,0],
	[&"spirit_gem","Spirit Gem",&"materials",3,&"epic",&"gem",false,0],
	[&"star_crystal","Star Crystal",&"materials",2,&"legendary",&"star",false,0],
	[&"thread","Thread",&"materials",12,&"common",&"ticket",false,0],
	[&"bulwark_band","Bulwark Band",&"equipment",1,&"rare",&"gem",true,1],
	[&"ember_signet","Ember Signet",&"equipment",1,&"epic",&"gem",true,1],
	[&"sunstep_shoes","Sunstep Shoes",&"equipment",1,&"uncommon",&"bolt",false,2],
	[&"trailguard","Trailguard Armor",&"equipment",1,&"rare",&"dress",true,3],
	[&"ember_bp","Ember Signet BP",&"blueprints",1,&"uncommon",&"ticket",false,0],
	[&"moonveil_bp","Moonveil Cap BP",&"blueprints",1,&"uncommon",&"ticket",false,0],
	[&"oracle_bp","Oracle Necklace BP",&"blueprints",1,&"rare",&"ticket",false,0],
	[&"cleaver_bp","Vanguard Cleaver BP",&"blueprints",1,&"epic",&"ticket",false,0],
	[&"health_potion","Health Potion",&"consumables",14,&"common",&"lamp",false,0],
	[&"mana_crystal","Mana Crystal",&"consumables",6,&"uncommon",&"gem",false,0],
	[&"lost_seal","Lost Seal",&"quest",1,&"rare",&"key",false,0],
	[&"valor_token","Token of Valor",&"misc",3,&"uncommon",&"star",false,0],
]

var _filter: StringName = &"all"
var _sort: StringName = &"type"
var _sort_open := false
var _dropdown: Control
var _filter_scroll_offset := 0


func _ready() -> void:
	clip_contents=true; resized.connect(_rebuild); _rebuild()


func open() -> void:
	_filter=&"all"; _sort=&"type"; _sort_open=false; _filter_scroll_offset=0; show(); _rebuild()


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0.0:return
	for child in get_children():child.queue_free()
	queue_redraw(); _build_header(); _build_filters(); _build_sort(); _build_grid()
	if _sort_open:_build_dropdown()


func _build_header() -> void:
	_add_label(self,"BACKPACK",true,16,UIPalette.CYAN,Vector2(16,14),Vector2(180,30))
	_add_label(self,"Capacity %d/100" % ITEMS.size(),false,9,Color("#5A4080"),Vector2(size.x-190,18),Vector2(100,22),HORIZONTAL_ALIGNMENT_RIGHT)
	var close:=_button("CLOSE",UIPalette.CYAN,UIPalette.CYAN);close.position=Vector2(size.x-82,14);close.size=Vector2(68,30);close.pressed.connect(func()->void:hide();closed.emit());add_child(close)


func _build_filters() -> void:
	var scroll:=ScrollContainer.new();scroll.position=Vector2(12,58);scroll.size=Vector2(size.x-24,56);scroll.clip_contents=true;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_SHOW_ALWAYS;scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.scroll_deadzone=4;add_child(scroll)
	var row:=HBoxContainer.new();row.add_theme_constant_override("separation",6);row.custom_minimum_size=Vector2(570,40);scroll.add_child(row)
	for data in FILTERS:
		var id:StringName=data[0];var active:=id==_filter;var button:=_button(data[1],Color("#88BBFF") if active else Color("#4A3068"),Color("#448AFF") if active else Color("#2A1845"));button.custom_minimum_size=Vector2(maxf(58,String(data[1]).length()*7+18),28);button.pressed.connect(func()->void:_filter=id;_sort_open=false;_rebuild());row.add_child(button)
	_style_filter_scrollbar(scroll.get_h_scroll_bar())
	scroll.get_h_scroll_bar().value_changed.connect(func(value: float) -> void: _filter_scroll_offset=int(value))
	scroll.set_deferred("scroll_horizontal",_filter_scroll_offset)


func _build_sort() -> void:
	_add_label(self,"Sort",false,9,Color("#3A2858"),Vector2(14,122),Vector2(34,22))
	var sort:=_button(String(_sort).capitalize()+("  ▲" if _sort_open else "  ▼"),Color("#6050A0"),Color("#3A2060"));sort.position=Vector2(48,119);sort.size=Vector2(92,28);sort.pressed.connect(func()->void:_sort_open=not _sort_open;_rebuild());add_child(sort)
	_add_label(self,"%d items" % _items().size(),false,9,Color("#3A2858"),Vector2(size.x-80,122),Vector2(64,22),HORIZONTAL_ALIGNMENT_RIGHT)


func _build_dropdown() -> void:
	_dropdown=Control.new();_dropdown.position=Vector2(48,147);_dropdown.size=Vector2(100,96);_dropdown.z_index=50;add_child(_dropdown)
	var bg:=ColorRect.new();bg.color=Color("#0D0825");bg.size=_dropdown.size;bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;_dropdown.add_child(bg)
	for i in range(3):
		var id:StringName=[&"type",&"rarity",&"name"][i];var button:=_button(String(id).capitalize(),UIPalette.CYAN if id==_sort else Color("#6050A0"),Color("#3D2060"));button.position=Vector2(0,i*32);button.size=Vector2(100,32);button.pressed.connect(func()->void:_sort=id;_sort_open=false;_rebuild());_dropdown.add_child(button)


func _build_grid() -> void:
	var scroll:=ScrollContainer.new();scroll.position=Vector2(0,154);scroll.size=Vector2(size.x,size.y-154);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(scroll)
	var items:=_items();var card_w:=(size.x-34.0)/3.0;var rows:=ceili(items.size()/3.0);var canvas:=Control.new();canvas.custom_minimum_size=Vector2(size.x-12,rows*108+12);scroll.add_child(canvas)
	for i in range(items.size()):
		var item:Array=items[i];var border:=_rarity_border(item[4]);var card:=_button("",Color.WHITE,border);card.position=Vector2(8+(i%3)*(card_w+5),8+(i/3)*108);card.size=Vector2(card_w,100);card.fill_top=_rarity_fill(item[4]);card.fill_bottom=Color(_rarity_fill(item[4]),0.72);canvas.add_child(card)
		var icon:=ShopIcon.new();icon.icon_id=item[5];icon.accent=border;icon.framed=true;icon.position=Vector2((card_w-42)*0.5,10);icon.size=Vector2(42,42);card.add_child(icon)
		if item[3]>1:_add_label(card,"×%d"%item[3],false,7,border,Vector2(card_w-32,42),Vector2(28,14),HORIZONTAL_ALIGNMENT_RIGHT)
		_add_label(card,item[1],false,8,Color("#C8B8E8"),Vector2(3,55),Vector2(card_w-6,24),HORIZONTAL_ALIGNMENT_CENTER)
		if item[6]:
			_add_label(card,"EQ",false,6,UIPalette.CYAN,Vector2(card_w-24,3),Vector2(20,13),HORIZONTAL_ALIGNMENT_CENTER)
			_add_label(card,"Lv.%d · Equipped"%item[7],false,7,UIPalette.CYAN,Vector2(2,80),Vector2(card_w-4,16),HORIZONTAL_ALIGNMENT_CENTER)
		elif item[2]==&"equipment":_add_label(card,"Lv.%d"%item[7],false,7,Color("#5A4080"),Vector2(2,80),Vector2(card_w-4,16),HORIZONTAL_ALIGNMENT_CENTER)


func _items() -> Array:
	var out:Array=[]
	for item in ITEMS:
		if _filter==&"all" or item[2]==_filter:out.append(item)
	var order:={&"legendary":0,&"epic":1,&"rare":2,&"uncommon":3,&"common":4}
	out.sort_custom(func(a:Array,b:Array)->bool:
		if _sort==&"name":return String(a[1])<String(b[1])
		if _sort==&"rarity":return order[a[4]]<order[b[4]]
		return String(a[2])<String(b[2]))
	return out


func _rarity_border(rarity:StringName)->Color:
	return {&"common":Color("#5A4080"),&"uncommon":Color("#22DD6E"),&"rare":Color("#448AFF"),&"epic":Color("#AA44FF"),&"legendary":UIPalette.GOLD}.get(rarity,Color("#5A4080"))


func _rarity_fill(rarity:StringName)->Color:
	return {&"common":Color("#261840"),&"uncommon":Color("#103522"),&"rare":Color("#102244"),&"epic":Color("#2A0E50"),&"legendary":Color("#2A1800")}.get(rarity,Color("#261840"))


func _style_filter_scrollbar(bar: HScrollBar) -> void:
	bar.custom_minimum_size.y=7
	var track:=StyleBoxFlat.new();track.bg_color=Color("#120A28");track.corner_radius_top_left=3;track.corner_radius_top_right=3;track.corner_radius_bottom_left=3;track.corner_radius_bottom_right=3
	var grabber:=StyleBoxFlat.new();grabber.bg_color=Color(UIPalette.CYAN,0.55);grabber.corner_radius_top_left=3;grabber.corner_radius_top_right=3;grabber.corner_radius_bottom_left=3;grabber.corner_radius_bottom_right=3
	bar.add_theme_stylebox_override("scroll",track);bar.add_theme_stylebox_override("grabber",grabber);bar.add_theme_stylebox_override("grabber_highlight",grabber);bar.add_theme_stylebox_override("grabber_pressed",grabber)


func _button(text:String,color:Color,accent:Color)->ArcaneButton:
	var out:=ArcaneButton.new();out.text=text;out.fill_top=Color("#0D0825");out.fill_bottom=Color("#080418");out.border_color=Color(accent,0.55);out.add_theme_font_override("font",UIFonts.rajdhani_bold());out.add_theme_font_size_override("font_size",9);out.add_theme_color_override("font_color",color);return out


func _add_label(parent:Control,text:String,title:bool,font_size:int,color:Color,at:Vector2,label_size:Vector2,align:=HORIZONTAL_ALIGNMENT_LEFT)->Label:
	var label:=UIFonts.make_label(text,UIFonts.cinzel_bold() if title else UIFonts.rajdhani_bold(),font_size,color,align);label.position=at;label.size=label_size;parent.add_child(label);return label


func _draw()->void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#06030F"),Color("#09041A"));draw_line(Vector2(0,57.5),Vector2(size.x,57.5),Color(UIPalette.CYAN,0.2),1.0);draw_line(Vector2(0,105.5),Vector2(size.x,105.5),Color("#1A0E33",0.45),1.0)
	var c:=Color(UIPalette.CYAN,0.75)
	for pts in [[Vector2(0,30),Vector2(0,2),Vector2(30,2)],[Vector2(size.x-30,2),Vector2(size.x,2),Vector2(size.x,30)],[Vector2(0,size.y-30),Vector2(0,size.y-2),Vector2(30,size.y-2)],[Vector2(size.x-30,size.y-2),Vector2(size.x,size.y-2),Vector2(size.x,size.y-30)]]:draw_polyline(PackedVector2Array(pts),c,1.5,true)
