class_name PetsTab
extends SubTabPage
## Pets sub-tab: centered empty state until companions are implemented.
## Reference: App.tsx `PetsTab`.

## Paw mark with a soft purple glow.
class PawMark extends Control:
	func _ready() -> void:
		custom_minimum_size = Vector2(48.0, 48.0)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		draw_circle(size * 0.5, 22.0, Color(UIPalette.PURPLE_ORNAMENT, 0.12))
		IconDraw.sub_paw(self, Rect2(Vector2.ZERO, size), Color(UIPalette.PURPLE_ORNAMENT, 0.8))


func _build() -> void:
	panel.visible = false # The reference empty state sits on the bare canvas.
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Share the page's margin wrapper so the state centers in the visible area.
	panel.get_parent().add_child(center)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(stack)

	var paw := PawMark.new()
	paw.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stack.add_child(paw)
	stack.add_child(_spacer(6))

	var title := UIFonts.make_label("NO PETS BONDED", UIFonts.cinzel_tracked(700, 1), 12, Color("#5A4080"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(title)

	var hint := UIFonts.make_label("Capture or summon a companion in battle to bond a pet to your hero.",
		UIFonts.rajdhani_medium(), 10, UIPalette.INACTIVE_DIM)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size.x = 260.0
	stack.add_child(hint)
	stack.add_child(_spacer(4))

	var stables := HeroPillBtn.new()
	stables.setup("Visit Stables", UIPalette.PURPLE_ORNAMENT)
	stables.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stack.add_child(stables)
