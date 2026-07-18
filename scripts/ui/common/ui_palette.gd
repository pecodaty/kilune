class_name UIPalette
extends RefCounted
## Canonical interface palette.
## Source of truth: docs/art-direction/interface-design.md

# Foundations
const BG_OUTER := Color("#020108")
const CANVAS := Color("#06040F")
const HUD_TOP := Color("#0D0825")
const HUD_BOTTOM := Color("#08041A")
const DEEP_PANEL := Color("#0D0520")
const DOCK_TOP := Color("#0D0825")
const DOCK_BOTTOM := Color("#060210")
const NAV_TOP := Color("#0F0C28")
const NAV_BOTTOM := Color("#07040F")
const BORDER_DARK := Color("#2A1845")
const PURPLE_STRUCTURE := Color("#3D2060")

# Structural / active accents
const GOLD := Color("#FFD700")
const GOLD_BRIGHT := Color("#FFE066")
const GOLD_MUTED := Color("#D4A017")
const GOLD_DEEP := Color("#8B6200")
const GOLD_DEEP_2 := Color("#9A6400")
const CYAN := Color("#00E5C8")
const AUTO_GREEN := Color("#00E580")
const PURPLE_ORNAMENT := Color("#7B2FF7")
const CLASS_GLOW := Color("#8844FF")

# Information / skill accents
const HP := Color("#22DD6E")
const MP := Color("#448AFF")
const RUNE_FIRE := Color("#FF7733")
const RUNE_FIRE_HI := Color("#FFAA44")
const RUNE_ICE := Color("#66DDFF")
const RUNE_ICE_HI := Color("#AAEEFF")
const RUNE_WIND := Color("#88CCBB")
const RUNE_WIND_HI := Color("#AADDCC")
const RUNE_SHADOW := Color("#6633AA")
const RUNE_SHADOW_HI := Color("#AA77EE")

# Text
const TEXT_PALE_CYAN := Color("#A0F8E8")
const TEXT_LAVENDER := Color("#C8A0E0")
const TEXT_LAVENDER_DIM := Color("#A090C0")
const TEXT_MUTED := Color("#7060A0")
const TEXT_CHAT := Color("#6050A0")
const INACTIVE := Color("#4A3068")
const INACTIVE_DIM := Color("#3A2858")
const LOCK := Color("#3A2455")

# Skill slot interiors
const SLOT_BG_TOP := Color("#131840")
const SLOT_BG_BOTTOM := Color("#0A1028")
const SLOT_LOCKED_TOP := Color("#110820")
const SLOT_LOCKED_BOTTOM := Color("#0A0515")

# Gold border gradient stops (diagonal), shared by octagonal frames.
static func gold_border_stops() -> Array:
	return [[0.0, GOLD_BRIGHT], [0.45, GOLD_DEEP_2], [1.0, GOLD]]

# Desaturated purple border stops for locked slots.
static func locked_border_stops() -> Array:
	return [[0.0, Color("#4A3060")], [0.45, BORDER_DARK], [1.0, Color("#4A3060")]]

# Fading gold line stops (horizontal), used by dividers and HUD edges.
static func gold_line_stops() -> Array:
	return [
		[0.0, Color(PURPLE_STRUCTURE, 0.0)],
		[0.2, Color(GOLD_MUTED, 0.5)],
		[0.5, Color(GOLD, 0.9)],
		[0.8, Color(GOLD_MUTED, 0.5)],
		[1.0, Color(PURPLE_STRUCTURE, 0.0)],
	]
