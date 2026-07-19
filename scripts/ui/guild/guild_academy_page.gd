class_name GuildAcademyPage
extends Control
## Shared Guild research/buff list.

signal closed
signal upgrade_requested(research_id:StringName)

const RESEARCH:Array[Dictionary]=[
	{"id":&"atk","name":"BATTLE MASTERY","desc":"Increases all members ATK by 1% per level.","level":3,"icon":&"swords","color":Color("#FF7733")},
	{"id":&"hp","name":"VITALITY WARD","desc":"Increases all members Max HP by 1.5% per level.","level":5,"icon":&"heart","color":Color("#22DD6E")},
	{"id":&"def","name":"IRON BASTION","desc":"Reduces damage taken by 0.5% per level.","level":2,"icon":&"shield","color":Color("#448AFF")},
	{"id":&"spd","name":"SWIFT PURSUIT","desc":"Increases Move Speed by 1% per level.","level":1,"icon":&"bolt","color":Color("#FFD700")},
]


func _ready()->void:
	resized.connect(_build);_build()


func _build()->void:
	if size.x<=0:return
	for child in get_children():child.queue_free()
	queue_redraw();GuildUI.add_page_header(self,"GUILD ACADEMY","Shared buffs for all members",Color("#88AAFF"),func()->void:closed.emit())
	for i in range(RESEARCH.size()):_add_research(RESEARCH[i],Vector2(12,70+i*94),Vector2(size.x-24,82))


func _add_research(data:Dictionary,at:Vector2,card_size:Vector2)->void:
	var color:Color=data["color"];var panel:=GuildUI.panel(color,0.35);panel.position=at;panel.size=card_size;add_child(panel)
	var icon:=GuildIcon.new();icon.icon_id=data["icon"];icon.accent=color;icon.position=Vector2(12,16);icon.size=Vector2(44,44);panel.add_child(icon)
	var title:=GuildUI.label(data["name"],true,11,Color("#D0C0F0"));title.position=Vector2(70,10);title.size=Vector2(card_size.x-154,22);panel.add_child(title)
	var level:=GuildUI.label("Lv.%d/10"%data["level"],false,9,color,HORIZONTAL_ALIGNMENT_RIGHT);level.position=Vector2(card_size.x-150,10);level.size=Vector2(60,22);panel.add_child(level)
	var desc:=GuildUI.label(data["desc"],false,9,Color("#5A4080"));desc.position=Vector2(70,34);desc.size=Vector2(card_size.x-160,20);panel.add_child(desc)
	GuildUI.add_progress(panel,Vector2(70,60),Vector2(card_size.x-160,4),float(data["level"])/10.0,color)
	var upgrade:=GuildUI.button("UPGRADE",9,color,color);upgrade.position=Vector2(card_size.x-84,20);upgrade.size=Vector2(72,38);var id:StringName=data["id"];upgrade.pressed.connect(func()->void:upgrade_requested.emit(id));panel.add_child(upgrade)


func _draw()->void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#04020F"),Color("#08031A"))
