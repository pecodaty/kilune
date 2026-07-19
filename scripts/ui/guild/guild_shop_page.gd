class_name GuildShopPage
extends Control
## Guild-coin store grid.

signal closed
signal purchase_requested(item_id: StringName)

const ITEMS:Array[Dictionary]=[
	{"id":&"awaken","name":"Awakening Scroll","icon":&"scroll","price":"4,000","color":Color("#FFD700")},
	{"id":&"enhance","name":"Enhancement Gear","icon":&"gear","price":"4,000","color":Color("#448AFF")},
	{"id":&"summon","name":"Summoning Essence","icon":&"sparkle","price":"10,000","color":Color("#AA44FF")},
	{"id":&"soul","name":"Soul Crystal","icon":&"gem","price":"10,000","color":Color("#00E5C8")},
]


func _ready()->void:
	resized.connect(_build);_build()


func _build()->void:
	if size.x<=0:return
	for child in get_children():child.queue_free()
	queue_redraw();GuildUI.add_page_header(self,"GUILD SHOP","Guild Coins:   48,360",UIPalette.GOLD,func()->void:closed.emit())
	var limit:=GuildUI.label("DAILY LIMIT - RESETS MIDNIGHT",false,9,UIPalette.GOLD_MUTED,HORIZONTAL_ALIGNMENT_CENTER);limit.position=Vector2(20,64);limit.size=Vector2(size.x-40,24);add_child(limit)
	var gap:=10.0;var card_w:=(size.x-34-gap)*0.5
	for i in range(ITEMS.size()):
		var col:=i%2;var row:=i/2
		_add_item(ITEMS[i],Vector2(12+col*(card_w+gap),104+row*190),Vector2(card_w,178))


func _add_item(data:Dictionary,at:Vector2,card_size:Vector2)->void:
	var color:Color=data["color"];var card:=GuildUI.panel(color,0.45);card.position=at;card.size=card_size;add_child(card)
	var icon:=GuildIcon.new();icon.icon_id=data["icon"];icon.accent=color;icon.position=Vector2((card_size.x-54)*0.5,18);icon.size=Vector2(54,54);card.add_child(icon)
	var name:=GuildUI.label(data["name"],false,10,Color("#C8B8E8"),HORIZONTAL_ALIGNMENT_CENTER);name.position=Vector2(6,78);name.size=Vector2(card_size.x-12,24);card.add_child(name)
	var price:=GuildUI.label("◉  %s"%data["price"],false,12,color,HORIZONTAL_ALIGNMENT_CENTER);price.position=Vector2(6,104);price.size=Vector2(card_size.x-12,24);card.add_child(price)
	var buy:=GuildUI.button("PURCHASE",10,color,color);buy.position=Vector2(12,136);buy.size=Vector2(card_size.x-24,32);var id:StringName=data["id"];buy.pressed.connect(func()->void:purchase_requested.emit(id));card.add_child(buy)


func _draw()->void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#04020F"),Color("#08031A"))
	draw_rect(Rect2(0,56,size.x,40),Color(UIPalette.GOLD,0.025));draw_line(Vector2(0,96),Vector2(size.x,96),Color(UIPalette.GOLD,0.14),1)
