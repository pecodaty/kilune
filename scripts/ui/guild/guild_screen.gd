class_name GuildScreen
extends Control
## Shared-shell Guild hub and owner of its internal pages.

var _page: Control


func _ready() -> void:
	clip_contents = true
	resized.connect(_rebuild)
	_build_hub()


func open() -> void:
	_close_page()


func _rebuild() -> void:
	if is_node_ready() and size.x > 0.0:
		_build_hub()


func _clear() -> void:
	_page = null
	for child in get_children(): child.queue_free()


func _build_hub() -> void:
	_clear()
	queue_redraw()
	var header := ColorRect.new()
	header.color = Color("#0D0825", 0.94)
	header.position = Vector2.ZERO
	header.size = Vector2(size.x, 64)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	var mini_emblem := GuildEmblem.new()
	mini_emblem.position = Vector2(12, 10)
	mini_emblem.size = Vector2(44, 44)
	header.add_child(mini_emblem)
	var name := GuildUI.label("IRON PACT", true, 15, UIPalette.GOLD)
	name.position = Vector2(64, 9); name.size = Vector2(190, 24); header.add_child(name)
	var status := GuildUI.label("Lv.10 · 72/90 Members", false, 9, Color("#6050A0"))
	status.position = Vector2(64, 31); status.size = Vector2(190, 18); header.add_child(status)
	var coins := GuildUI.label("◉ 48,360", false, 9, UIPalette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	coins.position = Vector2(size.x - 76, 6); coins.size = Vector2(64, 20); header.add_child(coins)
	var hall := GuildHallCard.new()
	hall.position = Vector2(16, 76)
	hall.size = Vector2(size.x - 32, 190)
	hall.pressed.connect(func() -> void: _open_page(GuildHallPage.new()))
	add_child(hall)
	var hall_emblem := GuildEmblem.new()
	hall_emblem.position = Vector2((hall.size.x - 78) * 0.5, 25); hall_emblem.size = Vector2(78,78); hall.add_child(hall_emblem)
	var hall_name := GuildUI.label("IRON PACT", true, 16, UIPalette.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	hall_name.position = Vector2(30, 120); hall_name.size = Vector2(hall.size.x - 60, 28); hall.add_child(hall_name)
	var hall_meta := GuildUI.label("Members 72/90    |    Level 10    |    View Details  ›", false, 9, Color("#7060A0"), HORIZONTAL_ALIGNMENT_CENTER)
	hall_meta.position = Vector2(20, 148); hall_meta.size = Vector2(hall.size.x - 40, 22); hall.add_child(hall_meta)

	var section := GuildUI.label("GUILD AREAS", true, 9, Color("#4A3870"), HORIZONTAL_ALIGNMENT_CENTER)
	section.position = Vector2(100, 274); section.size = Vector2(size.x - 200, 18); add_child(section)
	draw_connecting_lines.call_deferred()
	var areas := [
		[&"fire", "GUILD BOSS", "Lava Behemoth", Color("#FF4422"), GuildBossPage],
		[&"cart", "GUILD SHOP", "4 items listed", UIPalette.GOLD, GuildShopPage],
		[&"books", "GUILD ACADEMY", "4 researches", Color("#448AFF"), GuildAcademyPage],
		[&"calendar", "GUILD SCHEDULE", "2 events today", Color("#AA44FF"), GuildSchedulePage],
	]
	var gap := 10.0
	var tile_w := (size.x - 32.0 - gap) * 0.5
	for i in range(areas.size()):
		var col := i % 2
		var row := i / 2
		_add_area_tile(areas[i], Vector2(16 + col * (tile_w + gap), 300 + row * 118), Vector2(tile_w,108))


func draw_connecting_lines() -> void:
	queue_redraw()


func _add_area_tile(data: Array, at: Vector2, tile_size: Vector2) -> void:
	var color: Color = data[3]
	var tile := GuildUI.button("", 10, color, color)
	tile.fill_top = Color(color, 0.08); tile.fill_bottom = Color(color, 0.02); tile.cut = 8
	tile.position = at; tile.size = tile_size
	var page_class: GDScript = data[4]
	tile.pressed.connect(func() -> void: _open_page(page_class.new()))
	add_child(tile)
	var icon := GuildIcon.new(); icon.icon_id = data[0]; icon.accent = color
	icon.position = Vector2((tile_size.x - 44) * 0.5, 14); icon.size = Vector2(44,44); tile.add_child(icon)
	var label := GuildUI.label(data[1], true, 11, Color("#D0C0F0"), HORIZONTAL_ALIGNMENT_CENTER)
	label.position = Vector2(6, 62); label.size = Vector2(tile_size.x - 12, 20); tile.add_child(label)
	var sub := GuildUI.label(data[2], false, 9, color, HORIZONTAL_ALIGNMENT_CENTER)
	sub.position = Vector2(6, 81); sub.size = Vector2(tile_size.x - 12, 18); tile.add_child(sub)


func _open_page(page: Control) -> void:
	if is_instance_valid(_page): _page.queue_free()
	_page = page
	_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	_page.closed.connect(_close_page)
	add_child(_page)


func _close_page() -> void:
	if is_instance_valid(_page): _page.queue_free()
	_page = null


func _draw() -> void:
	UIDraw.draw_v_gradient_rect(self, Rect2(Vector2.ZERO,size), Color("#030110"), Color("#130828"))
	# Guild hall walls, torches, banners, and stone floor.
	for x in [0.0, size.x - 64.0]:
		draw_rect(Rect2(x, 90, 64, size.y - 220), Color("#09061C"))
		for y in range(110, int(size.y - 130), 22): draw_line(Vector2(x,y),Vector2(x+64,y),Color("#14103A",0.55),0.7)
	var floor_y := size.y - 130.0
	draw_rect(Rect2(0,floor_y,size.x,130),Color("#080520"))
	for y in range(int(floor_y), int(size.y), 22):
		var row_offset := 24 if (y / 22) % 2 != 0 else 0
		for x in range(-20, int(size.x), 48):
			draw_rect(Rect2(x + row_offset,y,45,19),Color("#221855",0.45),false,0.7)
	for x in [56.0,size.x-56.0]:
		draw_circle(Vector2(x,220),26,Color("#FF8800",0.08));draw_circle(Vector2(x,212),6,Color("#FF9922"));draw_circle(Vector2(x,209),3.5,Color("#FFEE44",0.8))
	# Section divider.
	draw_line(Vector2(16,283),Vector2(100,283),Color("#3D2060"),1.0)
	draw_line(Vector2(size.x-100,283),Vector2(size.x-16,283),Color("#3D2060"),1.0)
