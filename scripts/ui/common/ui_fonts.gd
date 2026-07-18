class_name UIFonts
extends RefCounted
## Central font cache. Fonts are bundled locally per interface-design.md:
## Cinzel for titles / premium labels, Rajdhani for stats and compact labels.

const CINCEL_PATH := "res://assets/fonts/Cinzel-Bold.ttf"
const RAJDHANI_BOLD_PATH := "res://assets/fonts/Rajdhani-Bold.ttf"
const RAJDHANI_SEMIBOLD_PATH := "res://assets/fonts/Rajdhani-SemiBold.ttf"
const RAJDHANI_MEDIUM_PATH := "res://assets/fonts/Rajdhani-Medium.ttf"

static var _cache: Dictionary = {}


static func _load(path: String) -> Font:
	if not _cache.has(path):
		_cache[path] = load(path) as Font
	return _cache[path]


## Cinzel variable font pinned to the Bold instance.
static func cinzel_bold() -> Font:
	return cinzel(700)


## Cinzel variable font pinned to an arbitrary weight (400-900).
static func cinzel(weight: int) -> Font:
	var key := "cinzel_%d" % weight
	if not _cache.has(key):
		var variation := FontVariation.new()
		variation.base_font = _load(CINCEL_PATH)
		variation.variation_opentype = {0x77676874: weight} # "wght"
		_cache[key] = variation
	return _cache[key]


## Cinzel with glyph tracking (letter-spacing), e.g. for the arch watermark.
static func cinzel_tracked(weight: int, spacing: int) -> Font:
	var key := "cinzel_%d_sp%d" % [weight, spacing]
	if not _cache.has(key):
		var variation := FontVariation.new()
		variation.base_font = cinzel(weight)
		variation.spacing_glyph = spacing
		_cache[key] = variation
	return _cache[key]


static func rajdhani_bold() -> Font:
	return _load(RAJDHANI_BOLD_PATH)


static func rajdhani_semibold() -> Font:
	return _load(RAJDHANI_SEMIBOLD_PATH)


static func rajdhani_medium() -> Font:
	return _load(RAJDHANI_MEDIUM_PATH)


## Create a themed label in one call (used by components that build children in code).
static func make_label(text: String, font: Font, font_size: int, color: Color, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
