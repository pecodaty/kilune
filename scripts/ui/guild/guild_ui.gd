class_name GuildUI
extends RefCounted
## Small construction helpers shared by Guild pages.


static func label(text: String, title: bool, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	return UIFonts.make_label(
		text,
		UIFonts.cinzel_bold() if title else UIFonts.rajdhani_semibold(),
		font_size,
		color,
		align
	)


static func button(text: String, font_size: int, color: Color, accent := Color("#3D2060")) -> ArcaneButton:
	var out := ArcaneButton.new()
	out.text = text
	out.fill_top = Color("#0D0828")
	out.fill_bottom = Color("#080420")
	out.border_color = Color(accent, 0.58)
	out.add_theme_font_override("font", UIFonts.cinzel_bold() if font_size >= 10 else UIFonts.rajdhani_bold())
	out.add_theme_font_size_override("font_size", font_size)
	out.add_theme_color_override("font_color", color)
	out.add_theme_color_override("font_disabled_color", Color(color, 0.35))
	return out


static func panel(color := Color("#3D2060"), alpha := 0.25) -> Panel:
	var out := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0A0720")
	style.border_color = Color(color, alpha)
	style.set_border_width_all(1)
	out.add_theme_stylebox_override("panel", style)
	return out


static func add_close_button(parent: Control, accent: Color, callback: Callable) -> ArcaneButton:
	var close := button("×", 16, Color(accent, 0.75), accent)
	close.position = Vector2(parent.size.x - 42, 16)
	close.size = Vector2(28, 24)
	close.pressed.connect(callback)
	parent.add_child(close)
	return close


static func add_page_header(parent: Control, title_text: String, subtitle: String, accent: Color, callback: Callable) -> void:
	var band := ColorRect.new()
	band.color = Color("#060414")
	band.position = Vector2.ZERO
	band.size = Vector2(parent.size.x, 56)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(band)
	var marker := ColorRect.new()
	marker.color = accent
	marker.position = Vector2(16, 17)
	marker.size = Vector2(3, 22)
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band.add_child(marker)
	var title_label := label(title_text, true, 14, accent)
	title_label.position = Vector2(30, 8 if not subtitle.is_empty() else 4)
	title_label.size = Vector2(parent.size.x - 86, 24)
	band.add_child(title_label)
	if not subtitle.is_empty():
		var sub := label(subtitle, false, 9, Color(accent, 0.6))
		sub.position = Vector2(30, 27)
		sub.size = Vector2(parent.size.x - 86, 18)
		band.add_child(sub)
	add_close_button(parent, accent, callback)


static func add_progress(parent: Control, at: Vector2, progress_size: Vector2, fraction: float, color: Color) -> void:
	var bg := ColorRect.new()
	bg.color = Color("#120930")
	bg.position = at
	bg.size = progress_size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	var fill := ColorRect.new()
	fill.color = color
	fill.size = Vector2(progress_size.x * clampf(fraction, 0.0, 1.0), progress_size.y)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(fill)

