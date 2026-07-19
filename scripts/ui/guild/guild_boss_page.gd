class_name GuildBossPage
extends Control
## Lava Behemoth guild-boss preview and challenge actions.

signal closed
signal challenge_requested
signal sweep_requested


func _ready() -> void:
	resized.connect(_build)
	_build()


func _build() -> void:
	if size.x<=0:return
	for child in get_children():child.queue_free()
	queue_redraw()
	GuildUI.add_page_header(self,"GUILD BOSS","",Color("#FF663F"),func()->void:closed.emit())
	var callout:=GuildUI.label("CONQUER THE LAVA BEHEMOTH",true,14,Color("#FF8A62"),HORIZONTAL_ALIGNMENT_CENTER);callout.position=Vector2(20,64);callout.size=Vector2(size.x-40,38);add_child(callout)
	var boss:=GuildIcon.new();boss.icon_id=&"fire";boss.accent=Color("#FF4422");boss.framed=false;boss.position=Vector2((size.x-96)*0.5,260);boss.size=Vector2(96,96);add_child(boss)
	var hp_title:=GuildUI.label("BOSS HP",false,9,Color("#FF7755"));hp_title.position=Vector2(24,430);hp_title.size=Vector2(100,20);add_child(hp_title)
	var hp_value:=GuildUI.label("1,240,000 / 2,000,000",false,9,Color("#FF7755"),HORIZONTAL_ALIGNMENT_RIGHT);hp_value.position=Vector2(size.x-210,430);hp_value.size=Vector2(186,20);add_child(hp_value)
	GuildUI.add_progress(self,Vector2(24,451),Vector2(size.x-48,7),0.62,Color("#FF3300"))
	var rewards:=GuildUI.panel(Color("#FF4422"),0.35);rewards.position=Vector2(24,478);rewards.size=Vector2(size.x-48,104);add_child(rewards)
	var rt:=GuildUI.label("CONQUEST REWARDS",true,10,UIPalette.GOLD_MUTED);rt.position=Vector2(14,9);rt.size=Vector2(rewards.size.x-28,20);rewards.add_child(rt)
	var desc:=GuildUI.label("According to Boss Level",false,9,Color("#705080"));desc.position=Vector2(14,32);desc.size=Vector2(200,18);rewards.add_child(desc)
	var reward:=GuildUI.label("◆  ×120       ▤  ×3       ★  ×5",false,11,Color("#C8B8E8"));reward.position=Vector2(16,58);reward.size=Vector2(rewards.size.x-32,24);rewards.add_child(reward)
	var note:=GuildUI.label("Sweep rewards based on highest DMG achieved",false,9,Color("#4A2858"),HORIZONTAL_ALIGNMENT_CENTER);note.position=Vector2(20,595);note.size=Vector2(size.x-40,24);add_child(note)
	var sweep:=GuildUI.button("SWEEP",12,Color("#5A3040"),Color("#FF4422"));sweep.position=Vector2(18,size.y-68);sweep.size=Vector2((size.x-48)*0.5,46);sweep.pressed.connect(func()->void:sweep_requested.emit());add_child(sweep)
	var challenge:=GuildUI.button("CHALLENGE",12,Color("#FFB098"),Color("#FF4422"));challenge.fill_top=Color("#AA1100");challenge.fill_bottom=Color("#6A0A0A");challenge.position=Vector2(30+(size.x-48)*0.5,size.y-68);challenge.size=Vector2((size.x-48)*0.5,46);challenge.pressed.connect(func()->void:challenge_requested.emit());add_child(challenge)


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self,Rect2(Vector2.ZERO,size),Color("#120109"),Color("#08020A"))
	draw_rect(Rect2(0,56,size.x,46),Color("#300707"))
	draw_line(Vector2(0,102),Vector2(size.x,102),Color("#FF4422",0.25),1)
	draw_circle(Vector2(size.x*0.5,310),90,Color("#FF2200",0.06))

