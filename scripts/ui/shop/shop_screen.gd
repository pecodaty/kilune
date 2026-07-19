class_name ShopScreen
extends Control
## Shared-shell storefront. Purchase actions are signals; economy state lives elsewhere.
signal purchase_requested(item_id: StringName)
signal outfit_equipped(outfit_id: StringName)
signal summon_requested(kind: StringName, offer_id: StringName)

const TABS := [
	{ "id": &"supply", "label": "SUPPLY", "icon": &"gem", "title": "SUPPLY STORE" },
	{ "id": &"limited", "label": "LIMITED", "icon": &"clock", "title": "LIMITED-TIME SHOP" },
	{ "id": &"outfit", "label": "OUTFIT", "icon": &"dress", "title": "OUTFIT SHOP" },
	{ "id": &"bundle", "label": "BUNDLE", "icon": &"box", "title": "PACK SHOP" },
	{ "id": &"gacha", "label": "GACHA", "icon": &"gacha", "title": "PET GACHA" },
]
const SUPPLIES := [
	[&"diamonds_200", "200", "$0.99", ""], [&"diamonds_1050", "1,050", "$4.99", "BEST VALUE"],
	[&"diamonds_2200", "2,200", "$9.99", "POPULAR"], [&"diamonds_4600", "4,600", "$19.99", ""],
	[&"diamonds_12000", "12,000", "$49.99", ""], [&"diamonds_25000", "25,000", "$99.99", "MOST VALUE"],
]
const LIMITED := [
	[&"free_pack", "FREE PACK", "Free", "0/1", &"gift", Color("#22DD6E")],
	[&"dungeon_kit", "DUNGEON PACK KIT", "$0.99", "SALE", &"key", Color("#FF9922")],
	[&"magic_lamp", "MAGIC LAMP PACK", "$4.99", "HOT", &"lamp", Color("#FF4488")],
	[&"train_ticket", "TRAIN TICKET PACK", "$0.99", "NEW", &"ticket", Color("#448AFF")],
]
const OUTFITS := [
	[&"default", "Default", &"avatar", Color("#6050A0")], [&"fire_knight", "Fire Knight", &"bolt", Color("#FF5533")],
	[&"ocean_mage", "Ocean Mage", &"wave", Color("#448AFF")], [&"forest_druid", "Forest Druid", &"leaf", Color("#22DD6E")],
	[&"shadow_rogue", "Shadow Rogue", &"gem", Color("#7744CC")], [&"gold_paladin", "Gold Paladin", &"swords", UIPalette.GOLD],
	[&"storm_caller", "Storm Caller", &"bolt", UIPalette.CYAN], [&"void_walker", "Void Walker", &"skull", Color("#AA66DD")],
]
const BUNDLES := [
	[&"pal_pack_3", "PAL PACK", "003/11", &"paw", Color("#AA44FF"), "Limited"],
	[&"skill_pack", "SKILL PACK", "001/05", &"star", UIPalette.GOLD, "Hot"],
	[&"pal_pack_10", "PAL PACK", "010/11", &"paw", Color("#FF4422"), "New"],
]

var _active_tab: StringName = &"supply"
var _selected_outfit: StringName
var _gacha_kind: StringName = &"skill"
var _countdown := 4835.0
var _clock_label: Label


func _ready() -> void:
	clip_contents = true
	resized.connect(_rebuild)
	_rebuild()


func open() -> void:
	_active_tab = &"supply"
	_rebuild()


func _process(delta: float) -> void:
	_countdown = maxf(0.0, _countdown - delta)
	if is_instance_valid(_clock_label):
		var seconds := int(_countdown)
		_clock_label.text = "RESETS IN   %02d : %02d : %02d" % [seconds / 3600, (seconds % 3600) / 60, seconds % 60]


func _rebuild() -> void:
	if not is_node_ready() or size.x <= 0.0: return
	_clock_label = null
	for child in get_children(): child.queue_free()
	queue_redraw()
	_build_header()
	_build_tabs()
	var content := Control.new()
	content.position = Vector2(0, 104)
	content.size = Vector2(size.x, maxf(0.0, size.y - 104.0))
	content.clip_contents = true
	add_child(content)
	match _active_tab:
		&"supply": _build_supply(content)
		&"limited": _build_limited(content)
		&"outfit": _build_outfit(content)
		&"bundle": _build_bundles(content)
		&"gacha": _build_gacha(content)


func _build_header() -> void:
	var title_text := "SHOP"
	for tab in TABS:
		if tab["id"] == _active_tab: title_text = tab["title"]
	var title := _label(title_text, true, 15, UIPalette.GOLD)
	title.position = Vector2(14, 13); title.size = Vector2(maxf(120, size.x - 152), 30); add_child(title)
	_add_currency(Vector2(size.x - 138, 17), Vector2(66, 24), &"gem", "26,791", Color("#55C8FF"))
	_add_currency(Vector2(size.x - 68, 17), Vector2(64, 24), &"coin", "11,734", Color("#FFAA33"))


func _add_currency(at: Vector2, currency_size: Vector2, icon_id: StringName, value: String, color: Color) -> void:
	var panel := _panel(Color("#D4A017"), 0.25); panel.position = at; panel.size = currency_size; add_child(panel)
	var icon := ShopIcon.new(); icon.icon_id = icon_id; icon.accent = color
	icon.position = Vector2(5, 5); icon.size = Vector2(13, 13); panel.add_child(icon)
	var amount := _label(value, false, 8, color, HORIZONTAL_ALIGNMENT_CENTER)
	amount.position = Vector2(17, 3); amount.size = Vector2(currency_size.x - 19, 18); panel.add_child(amount)


func _build_tabs() -> void:
	var tab_w := size.x / float(TABS.size())
	for i in range(TABS.size()):
		var tab: Dictionary = TABS[i]
		var tab_id: StringName = tab["id"]
		var active := tab_id == _active_tab
		var button := Button.new(); button.flat = true; button.focus_mode = Control.FOCUS_NONE
		button.position = Vector2(i * tab_w, 58); button.size = Vector2(tab_w, 46)
		button.pressed.connect(func() -> void: _active_tab = tab_id; _rebuild()); add_child(button)
		var icon := ShopIcon.new(); icon.icon_id = tab["icon"]; icon.accent = UIPalette.GOLD if active else Color("#5A4020")
		icon.position = Vector2((tab_w - 20) * 0.5, 5); icon.size = Vector2(20, 20); button.add_child(icon)
		var label := _label(tab["label"], false, 7, UIPalette.GOLD if active else Color("#5A4020"), HORIZONTAL_ALIGNMENT_CENTER)
		label.position = Vector2(0, 27); label.size = Vector2(tab_w, 15); button.add_child(label)
		if active:
			var line := ColorRect.new(); line.color = UIPalette.GOLD; line.position = Vector2(tab_w*0.2, 0); line.size = Vector2(tab_w*0.6, 1.5); line.mouse_filter = Control.MOUSE_FILTER_IGNORE; button.add_child(line)


func _build_supply(parent: Control) -> void:
	_add_banner(parent, 0, 106, "SUPPLY STORE", "DIAMOND PACKAGES", UIPalette.GOLD)
	var scroll := _scroll(parent, 106)
	var canvas := Control.new(); canvas.custom_minimum_size = Vector2(parent.size.x - 12, 410); scroll.add_child(canvas)
	var gap := 8.0; var card_w := (parent.size.x - 32.0 - gap) * 0.5
	for i in range(SUPPLIES.size()):
		var item: Array = SUPPLIES[i]; var col := i % 2; var row := i / 2
		var card := _card(Vector2(card_w, 126), UIPalette.GOLD)
		card.position = Vector2(10 + col*(card_w+gap), 6 + row*134); card.pressed.connect(func() -> void: purchase_requested.emit(item[0])); canvas.add_child(card)
		_add_icon(card, &"star" if item[3] == "MOST VALUE" else &"gem", Color("#55C8FF"), Vector2((card_w-46)*0.5, 13), Vector2(46,46), true)
		_add_child_label(card, item[1], false, 15, Color("#C8E8FF"), Vector2(4,64), Vector2(card_w-8,22), HORIZONTAL_ALIGNMENT_CENTER)
		_add_price(card, item[2], Vector2(10,91), Vector2(card_w-20,27), Color("#CC6600"))
		if item[3] != "": _add_badge(card, item[3], Color("#FF7700") if item[3] == "BEST VALUE" else Color("#1A6644") if item[3] == "POPULAR" else Color("#AA22FF"))


func _build_limited(parent: Control) -> void:
	_add_banner(parent, 0, 84, "LIMITED-TIME SHOP", "", Color("#FF9944"))
	_clock_label = _label("", false, 9, Color("#FFAA66"), HORIZONTAL_ALIGNMENT_CENTER)
	_clock_label.position = Vector2(parent.size.x*0.25, 51); _clock_label.size = Vector2(parent.size.x*0.5, 23); parent.add_child(_clock_label)
	_add_child_label(parent, "DAILY DEALS", true, 9, UIPalette.GOLD, Vector2(0,86), Vector2(parent.size.x,20), HORIZONTAL_ALIGNMENT_CENTER)
	var scroll := _scroll(parent, 106); var canvas := Control.new(); canvas.custom_minimum_size = Vector2(parent.size.x-12, 280); scroll.add_child(canvas)
	var gap := 8.0; var card_w := (parent.size.x - 32.0 - gap)*0.5
	for i in range(LIMITED.size()):
		var item: Array = LIMITED[i]; var card := _card(Vector2(card_w,126), item[5]); card.position = Vector2(10+(i%2)*(card_w+gap),6+(i/2)*134)
		card.pressed.connect(func() -> void: purchase_requested.emit(item[0])); canvas.add_child(card)
		_add_icon(card,item[4],item[5],Vector2((card_w-44)*0.5,17),Vector2(44,44),true)
		_add_child_label(card,item[1],true,9,Color("#D0B890"),Vector2(4,65),Vector2(card_w-8,20),HORIZONTAL_ALIGNMENT_CENTER)
		_add_price(card,item[2],Vector2(10,91),Vector2(card_w-20,27),Color("#0D5518") if item[2] == "Free" else Color("#993A00"))
		_add_badge(card,item[3],item[5],false)


func _build_outfit(parent: Control) -> void:
	var preview := ColorRect.new(); preview.color = Color("#0B0916"); preview.position = Vector2.ZERO; preview.size = Vector2(parent.size.x, 230); parent.add_child(preview)
	var chosen := _outfit_by_id(_selected_outfit); var chosen_name := "NOT SELECTED" if chosen.is_empty() else String(chosen[1]).to_upper()
	_add_child_label(preview,chosen_name,true,11,UIPalette.GOLD if not chosen.is_empty() else Color("#4A3870"),Vector2(0,25),Vector2(parent.size.x,28),HORIZONTAL_ALIGNMENT_CENTER)
	var preview_icon: StringName = &"avatar" if chosen.is_empty() else chosen[2]; var preview_color: Color = Color("#6050A0") if chosen.is_empty() else chosen[3]
	_add_icon(preview,preview_icon,preview_color,Vector2((parent.size.x-132)*0.5,62),Vector2(132,132),true)
	_add_child_label(parent,"OUTFITS",true,9,Color("#4A3870"),Vector2(0,232),Vector2(parent.size.x,22),HORIZONTAL_ALIGNMENT_CENTER)
	var tile_w := parent.size.x/4.0
	for i in range(OUTFITS.size()):
		var outfit: Array = OUTFITS[i]; var selected: bool = outfit[0] == _selected_outfit
		var tile := _card(Vector2(58,70),outfit[3] if selected else Color("#2A1845")); tile.position = Vector2(i%4*tile_w+(tile_w-58)*0.5,258+i/4*82)
		tile.pressed.connect(func() -> void: _selected_outfit = outfit[0] if _selected_outfit != outfit[0] else &""; _rebuild()); parent.add_child(tile)
		_add_icon(tile,outfit[2],outfit[3] if selected else Color(outfit[3],0.55),Vector2(11,6),Vector2(36,36),false)
		_add_child_label(tile,outfit[1],false,7,outfit[3] if selected else Color("#4A3068"),Vector2(1,44),Vector2(56,22),HORIZONTAL_ALIGNMENT_CENTER)
	var equip := _button("EQUIP OUTFIT" if not _selected_outfit.is_empty() else "SELECT AN OUTFIT",Color("#C888FF") if not _selected_outfit.is_empty() else Color("#2A1845"),Color("#AA44FF"))
	equip.position = Vector2(16,parent.size.y-48); equip.size = Vector2(parent.size.x-32,40); equip.disabled = _selected_outfit.is_empty()
	equip.pressed.connect(func() -> void: outfit_equipped.emit(_selected_outfit)); parent.add_child(equip)


func _build_bundles(parent: Control) -> void:
	_add_banner(parent,0,72,"PACK SHOP","",UIPalette.GOLD)
	var scroll := _scroll(parent,72); var canvas := Control.new(); canvas.custom_minimum_size = Vector2(parent.size.x-12,360); scroll.add_child(canvas)
	for i in range(BUNDLES.size()):
		var bundle: Array = BUNDLES[i]; var card := _card(Vector2(parent.size.x-32,106),bundle[4]); card.position = Vector2(10,8+i*116)
		card.pressed.connect(func() -> void: purchase_requested.emit(bundle[0])); canvas.add_child(card)
		_add_icon(card,bundle[3],bundle[4],Vector2(14,18),Vector2(62,62),true)
		_add_child_label(card,bundle[1],true,12,Color("#D0B890"),Vector2(88,15),Vector2(130,22))
		_add_child_label(card,"◆ ×50    ▤ ×3    ✦ ×5",false,8,Color("#7567E5"),Vector2(88,40),Vector2(160,18))
		_add_price(card,"$99.99",Vector2(88,66),Vector2(card.size.x-100,28),Color("#994400")); _add_badge(card,bundle[5],bundle[4])
		_add_child_label(card,bundle[2],false,7,Color("#07040F"),Vector2(43,72),Vector2(42,16),HORIZONTAL_ALIGNMENT_CENTER)


func _build_gacha(parent: Control) -> void:
	var half := parent.size.x*0.5
	for i in range(2):
		var kind: StringName = &"skill" if i == 0 else &"pal"; var active := kind == _gacha_kind; var color := Color("#448AFF") if kind == &"skill" else Color("#22DD6E")
		var tab := _button(String(kind).to_upper(),color if active else Color("#2A3850"),color); tab.position=Vector2(i*half,0); tab.size=Vector2(half,38)
		tab.pressed.connect(func() -> void: _gacha_kind=kind; _rebuild()); parent.add_child(tab)
	var accent := Color("#448AFF") if _gacha_kind == &"skill" else Color("#22DD6E")
	_add_child_label(parent,"Lv.46 %s Summon" % String(_gacha_kind).capitalize(),false,9,accent,Vector2(0,52),Vector2(parent.size.x,20),HORIZONTAL_ALIGNMENT_CENTER)
	_add_icon(parent,&"dragon" if _gacha_kind == &"skill" else &"paw",accent,Vector2((parent.size.x-126)*0.5,74),Vector2(126,126),true)
	var offers := [[&"cash_35","DRAW×35","$51",Color("#FF9922")],[&"gem_35","DRAW×35","15",UIPalette.CYAN],[&"free_35","DRAW×35","FREE",Color("#22DD6E")],[&"cash_999","DRAW×999","$999",Color("#AA44FF")]]
	for i in range(offers.size()):
		var offer: Array=offers[i]; var button:=_card(Vector2(parent.size.x-28,48),offer[3]); button.position=Vector2(14,208+i*55)
		button.pressed.connect(func() -> void: summon_requested.emit(_gacha_kind,offer[0])); parent.add_child(button)
		_add_child_label(button,offer[1],true,12,Color("#D0C8E8"),Vector2(14,6),Vector2(150,20))
		_add_child_label(button,"%s cards guaranteed" % String(_gacha_kind).capitalize(),false,7,offer[3],Vector2(14,25),Vector2(180,16))
		_add_price(button,offer[2],Vector2(button.size.x-74,8),Vector2(62,32),Color(offer[3],0.18))


func _add_banner(parent: Control, y: float, height: float, title: String, subtitle: String, accent: Color) -> void:
	var band:=ColorRect.new(); band.color=Color("#291204") if _active_tab != &"gacha" else Color("#08101E"); band.position=Vector2(0,y); band.size=Vector2(parent.size.x,height); parent.add_child(band)
	_add_child_label(band,title,true,17,accent,Vector2(0,height*0.27),Vector2(parent.size.x,28),HORIZONTAL_ALIGNMENT_CENTER)
	if not subtitle.is_empty(): _add_child_label(band,subtitle,false,8,Color(accent,0.65),Vector2(0,height*0.56),Vector2(parent.size.x,18),HORIZONTAL_ALIGNMENT_CENTER)


func _scroll(parent: Control, top: float) -> ScrollContainer:
	var scroll:=ScrollContainer.new(); scroll.position=Vector2(0,top); scroll.size=Vector2(parent.size.x,parent.size.y-top); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; parent.add_child(scroll); return scroll


func _card(card_size: Vector2, accent: Color) -> ArcaneButton:
	var card:=_button("",Color.WHITE,accent); card.size=card_size; card.fill_top=Color("#1E1004") if _active_tab != &"outfit" and _active_tab != &"gacha" else Color("#0D0820"); card.fill_bottom=Color("#100804") if _active_tab != &"outfit" and _active_tab != &"gacha" else Color("#080612"); return card


func _button(text: String, color: Color, accent: Color) -> ArcaneButton:
	var out:=ArcaneButton.new(); out.text=text; out.fill_top=Color("#1A0C04"); out.fill_bottom=Color("#100808"); out.border_color=Color(accent,0.45); out.add_theme_font_override("font",UIFonts.rajdhani_bold()); out.add_theme_font_size_override("font_size",9); out.add_theme_color_override("font_color",color); out.add_theme_color_override("font_disabled_color",Color(color,0.4)); return out


func _panel(accent: Color, alpha: float) -> Panel:
	var panel:=Panel.new(); var style:=StyleBoxFlat.new(); style.bg_color=Color("#1A0C04"); style.border_color=Color(accent,alpha); style.set_border_width_all(1); panel.add_theme_stylebox_override("panel",style); return panel


func _label(text: String, title: bool, font_size: int, color: Color, align:=HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	return UIFonts.make_label(text,UIFonts.cinzel_bold() if title else UIFonts.rajdhani_bold(),font_size,color,align)


func _add_child_label(parent: Control,text:String,title:bool,font_size:int,color:Color,at:Vector2,label_size:Vector2,align:=HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label:=_label(text,title,font_size,color,align); label.position=at; label.size=label_size; parent.add_child(label); return label


func _add_icon(parent: Control,id:StringName,color:Color,at:Vector2,icon_size:Vector2,framed:bool) -> ShopIcon:
	var icon:=ShopIcon.new(); icon.icon_id=id; icon.accent=color; icon.framed=framed; icon.position=at; icon.size=icon_size; parent.add_child(icon); return icon


func _add_price(parent: Control,text:String,at:Vector2,price_size:Vector2,color:Color) -> void:
	var price:=_button(text,Color("#FFE088"),color); price.mouse_filter=Control.MOUSE_FILTER_IGNORE; price.position=at; price.size=price_size; parent.add_child(price)


func _add_badge(parent: Control,text:String,color:Color,right:=true) -> void:
	var badge:=ColorRect.new(); badge.color=color; badge.position=Vector2(parent.size.x-70 if right else 0,0); badge.size=Vector2(70,18); badge.mouse_filter=Control.MOUSE_FILTER_IGNORE; parent.add_child(badge)
	_add_child_label(badge,text,false,6,Color.WHITE,Vector2.ZERO,badge.size,HORIZONTAL_ALIGNMENT_CENTER)


func _outfit_by_id(id: StringName) -> Array:
	for outfit in OUTFITS:
		if outfit[0] == id: return outfit
	return []


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#0E0804"))
	draw_rect(Rect2(0,0,size.x,58),Color("#160A07"))
	draw_line(Vector2(0,57.5),Vector2(size.x,57.5),Color(UIPalette.GOLD_MUTED,0.5),1.0)
	draw_rect(Rect2(0,58,size.x,46),Color("#0A0604"))
	var c:=Color(UIPalette.GOLD_MUTED,0.55)
	for pts in [[Vector2(0,12),Vector2(0,1),Vector2(12,1)],[Vector2(size.x-12,1),Vector2(size.x,1),Vector2(size.x,12)]]:
		draw_polyline(PackedVector2Array(pts),c,1.0,true)
