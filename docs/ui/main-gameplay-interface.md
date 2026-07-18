# Main Gameplay Interface — UI Architecture

Version: 1.0  
Engine: Godot 4.7.1  
Language: Typed GDScript  
Canonical reference: `references/InterfaceRedesign/src/app/App.tsx`, `references/InterfaceRedesign/src/assets/*.svg`, `references/game-ui-reference.png`, `docs/art-direction/interface-design.md`.

---

## 1. Goal

Define a modular, scene-based UI architecture for the portrait-mobile main gameplay screen. Every visual region from the reference screenshot becomes an independent, reusable Godot scene. The document is intentionally implementation-free: it specifies scenes, responsibilities, data flow, and asset boundaries so that subsequent coding sprints can build each component in isolation.

---

## 2. Reference Analysis

### 2.1 Visual Hierarchy

The reference composition is a single vertical stack framing a central combat stage:

| # | Region | Reference Height | Role |
| --- | --- | ---: | --- |
| 1 | Top HUD | 74 px | Player identity, vital stats, map/reward shortcuts |
| 2 | Stage Plaque | ~16 px | Current stage name and difficulty stars |
| 3 | Combat View | Flexible | Background, ground, player, enemies, floating text |
| 4 | Skill Dock | ~64 px | Auto combat toggle + six skill slots |
| 5 | Chat Strip | 26 px | Latest chat line and chat shortcut |
| 6 | Bottom Navigation | 72 px | Home / Heroes / Battle / Guild / Shop |

Two ornamental divider lines separate the Skill Dock from the Combat View and from the Bottom Navigation. They are pure decoration, but they are reused with different gem counts and must be a standalone scene.

### 2.2 Logical Regions

From left-to-right and top-to-bottom, the screenshot decomposes into these logical control groups:

1. **Player Identity Block** — clipped-corner portrait, class glow ring, level badge.
2. **Player Info Block** — hero name, activity/timer badge.
3. **Vital Stat Block** — HP bar and MP bar with numeric readouts.
4. **Top-Right Actions** — Map button, Cap Reward button.
5. **Stage Badge** — central stage name with star ornaments.
6. **Game World** — parallax-friendly background layer, ground platform, character/enemy layer, VFX/particle layer, floating combat text layer.
7. **Auto Toggle** — octagonal auto-combat button.
8. **Skill Slots** — six octagonal buttons: three active with rune icons, three locked with level requirements.
9. **Chat Feed** — channel label, message preview, Chat entry button.
10. **Navigation Bar** — five tab destinations with a raised center Battle pedestal.

Every group maps to exactly one reusable scene.

---

## 3. Scene Tree Architecture

```
MainGameplayInterface (Control)
├── SafeAreaContainer (MarginContainer)
│   └── MainColumn (VBoxContainer)
│       ├── TopHud (TopHud scene)
│       ├── StagePlaque (StagePlaque scene)
│       ├── CombatView (CombatView scene)
│       │   └── (size_flags_vertical = EXPAND)
│       ├── OrnamentalDivider (OrnamentalDivider scene)
│       ├── SkillDock (SkillDock scene)
│       ├── ChatStrip (ChatStrip scene)
│       ├── OrnamentalDivider (OrnamentalDivider scene)
│       └── BottomNav (BottomNav scene)
```

### Layout rules

- `MainColumn` is a `VBoxContainer` with zero separation; all spacing is owned by the child scenes so that art-authored offsets are preserved.
- `CombatView` uses `size_flags_vertical = Control.SIZE_EXPAND_FILL` so it absorbs all available vertical space on taller devices.
- `SafeAreaContainer` adds left/right/bottom margins based on `DisplayServer.get_display_safe_area()` so the HUD and nav bar never overlap notches or system gestures.
- The design target is `390 × 844` logical pixels. Scenes scale via `stretch_mode = viewport` / `canvas_items` project setting and internal `Control` anchors; individual scenes do not hard-code absolute viewport coordinates.

---

## 4. Component Inventory

All scene files live under `scenes/ui/gameplay/` and all scripts under `scripts/ui/gameplay/`. Shared UI primitives live under `scenes/ui/common/` and `scripts/ui/common/`.

### 4.1 Main Scene

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/main_gameplay_interface.tscn` | Scene | Top-level composition, wires signals, owns no visual details. |
| `scripts/ui/gameplay/main_gameplay_interface.gd` | Script | Binds child events to game systems; routes navigation, chat, and skill inputs. |

### 4.2 Top HUD

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/top_hud.tscn` | Scene | Full-width HUD band. |
| `scripts/ui/gameplay/top_hud.gd` | Script | Exports `hero_name`, `level`, `hp`, `mp`, `activity`, `timer_seconds`. |
| `scenes/ui/gameplay/player_portrait.tscn` | Scene | Clipped-corner portrait frame, glow ring, level badge. |
| `scripts/ui/gameplay/player_portrait.gd` | Script | Handles portrait texture and level badge text. |
| `scenes/ui/gameplay/stat_bar.tscn` | Scene | Slanted progress bar with label, fill, diamond marker, value text. |
| `scripts/ui/gameplay/stat_bar.gd` | Script | Exports `value`, `max_value`, `bar_color`. |
| `scenes/ui/gameplay/map_button.tscn` | Scene | Map shortcut button. |
| `scenes/ui/gameplay/cap_reward_button.tscn` | Scene | Cap reward shortcut button with pulsing gift icon. |

### 4.3 Stage Plaque

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/stage_plaque.tscn` | Scene | Trapezoid badge with two stars and stage label. |
| `scripts/ui/gameplay/stage_plaque.gd` | Script | Exports `stage_name` and `star_count`. |

### 4.4 Combat View

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/combat_view.tscn` | Scene | Holds background, ground, character, and VFX layers. |
| `scripts/ui/gameplay/combat_view.gd` | Script | Manages layer ordering, floating text spawn requests, camera/parallax hooks. |
| `scenes/ui/gameplay/floating_text.tscn` | Scene | Reusable floating damage/healing number. |
| `scripts/ui/gameplay/floating_text.gd` | Script | Animates opacity and vertical drift, then self-destructs. |

### 4.5 Skill Dock

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/skill_dock.tscn` | Scene | Auto button, divider, and skill slot row. |
| `scripts/ui/gameplay/skill_dock.gd` | Script | Holds skill data array; emits `skill_pressed(idx)` and `auto_toggled(active)`. |
| `scenes/ui/gameplay/auto_button.tscn` | Scene | Octagonal auto-combat toggle. |
| `scripts/ui/gameplay/auto_button.gd` | Script | Toggles active state, emits `toggled(active)`. |
| `scenes/ui/gameplay/skill_slot.tscn` | Scene | Octagonal skill/locked slot with icon, cooldown overlay, and lock label. |
| `scripts/ui/gameplay/skill_slot.gd` | Script | Exports `icon_texture`, `is_locked`, `level_required`, `cooldown_remaining`. |

### 4.6 Chat Strip

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/chat_strip.tscn` | Scene | Chat icon, channel label, scrolling message, Chat button. |
| `scripts/ui/gameplay/chat_strip.gd` | Script | Exports `channel`, `sender`, `message`; emits `chat_open_requested()`. |

### 4.7 Bottom Navigation

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/gameplay/bottom_nav.tscn` | Scene | Arched nav bar with five tab destinations. |
| `scripts/ui/gameplay/bottom_nav.gd` | Script | Exports `active_tab`; emits `tab_selected(id)`. |
| `scenes/ui/gameplay/nav_tab.tscn` | Scene | Individual nav item with icon, label, optional gem frame. |
| `scripts/ui/gameplay/nav_tab.gd` | Script | Exports `tab_id`, `label`, `icon`, `is_battle`, `selected`. |

### 4.8 Shared Primitives

| File | Type | Responsibility |
| --- | --- | --- |
| `scenes/ui/common/ornamental_divider.tscn` | Scene | Horizontal line with diamond markers. |
| `scripts/ui/common/ornamental_divider.gd` | Script | Exports `marker_positions` and `center_marker_gold`. |
| `scenes/ui/common/slanted_progress_bar.tscn` | Scene | Clipped-corner/slanted progress bar used by `StatBar`. |
| `scripts/ui/common/slanted_progress_bar.gd` | Script | Exports `value`, `max_value`, `fill_color`. |

Implementation note: the planned `OctagonalButton` primitive was folded into
`scripts/ui/common/ui_draw.gd` / `icon_draw.gd` (procedural octagon frames, gradients and
icons). Skill slots, Auto and nav gem frames draw through these helpers, so the visual
construction lives in one shared place instead of a dedicated scene.

---

## 5. Data Flow & Signals

Each component is responsible only for rendering and for emitting user input. No UI scene owns game logic.

```
TopHud
  └─ emits: none (pure display)

SkillDock
  ├─ emits skill_pressed(slot_index: int)
  └─ emits auto_toggled(active: bool)

BottomNav
  └─ emits tab_selected(tab_id: StringName)

ChatStrip
  └─ emits chat_open_requested()

MapButton / CapRewardButton
  └─ emit map_open_requested() / rewards_open_requested()
```

`MainGameplayInterface` subscribes to all child signals and delegates to dedicated game systems:

- `CombatSystem` for skill casts and auto mode.
- `NavigationSystem` for tab changes.
- `ChatSystem` for chat open requests.
- `WorldMapSystem` and `RewardSystem` for map/reward shortcuts.

State updates travel downward through exported properties:

```gdscript
@export var hero_stats: HeroStatsResource:
    set(v):
        hero_stats = v
        _refresh_stats()
```

Data binding is explicit in the parent scene script; child scenes do not autonomously fetch global state.

---

## 6. Asset Boundaries

Following `docs/art-direction/interface-design.md`, art assets are decomposed into independent, reusable pieces. No bitmap contains text, numeric values, or state that will change at runtime.

### Required textures / SVGs

| Asset | Purpose | Notes |
| --- | --- | --- |
| `assets/ui/hud_panel_bg.png` | HUD background band | Nine-patch or full-width slice. |
| `assets/ui/hud_corner_bracket.png` | Corner bracket ornament | 4-way symmetric, tintable gold. |
| `assets/ui/portrait_frame.png` | Clipped-corner portrait frame | Mask-ready; inner content drawn under it. |
| `assets/ui/level_badge_bg.png` | Level badge background | Slanted trapezoid. |
| `assets/ui/stat_bar_track.png` | Empty stat bar | Slanted ends. |
| `assets/ui/stat_bar_fill_hp.png` | HP fill gradient | Tiled or stretched. |
| `assets/ui/stat_bar_fill_mp.png` | MP fill gradient | Tiled or stretched. |
| `assets/ui/map_button_bg.png` | Map button background | Rounded rectangle with corner accents. |
| `assets/ui/cap_reward_button_bg.png` | Cap reward button background | Octagonal gold frame. |
| `assets/ui/stage_plaque_bg.png` | Stage plaque background | Inverted trapezoid. |
| `assets/ui/star_icon.png` | Star ornament | Tint gold. |
| `assets/ui/auto_button_frame.png` | Auto button octagon | Active/inactive tint applied in Godot. |
| `assets/ui/skill_slot_frame.png` | Skill slot octagon | Active state. |
| `assets/ui/skill_slot_frame_locked.png` | Locked skill slot octagon | Desaturated purple. |
| `assets/ui/nav_bar_bg.png` | Arched navigation background | Full-width, stretchable horizontally. |
| `assets/ui/nav_gem_frame.png` | Active/battle gem frame | Octagonal; reused for Battle and active tab. |
| `assets/ui/nav_tab_icon_home.png` | Home icon | Outlined rune style. |
| `assets/ui/nav_tab_icon_heroes.png` | Heroes icon | Outlined rune style. |
| `assets/ui/nav_tab_icon_battle.png` | Battle icon | Crossed swords. |
| `assets/ui/nav_tab_icon_guild.png` | Guild icon | Shield. |
| `assets/ui/nav_tab_icon_shop.png` | Shop icon | Bag. |
| `assets/ui/chat_icon.png` | Chat bubble icon | Muted purple. |
| `assets/ui/rune_fire.png` | Fire skill rune | 22×22 icon. |
| `assets/ui/rune_ice.png` | Ice skill rune | 22×22 icon. |
| `assets/ui/rune_wind.png` | Wind skill rune | 22×22 icon. |
| `assets/ui/rune_shadow.png` | Shadow skill rune | 22×22 icon. |
| `assets/ui/lock_icon.png` | Lock icon | For locked slots. |

### Font requirements

- `assets/fonts/Cinzel-Bold.ttf` — player name, Auto label, Cap Reward labels.
- `assets/fonts/Rajdhani-Medium.ttf` / `Rajdhani-Bold.ttf` — stats, timers, navigation, chat.

All fonts are bundled locally.

### Prohibited in authored textures

- Hero name, level numbers, HP/MP values, stage name, timer, chat text, level requirements.
- Cooldown overlays, selection states, disabled states, glow intensity.
- Neighboring controls baked into one image.

These are all driven by Godot nodes, shaders, or modulation at runtime.

---

## 7. State & Interaction Specification

### 7.1 States per Component

| Component | States | Implementation Notes |
| --- | --- | --- |
| `NavTab` | idle, selected, disabled | Color modulate; cyan glow line when selected. |
| `SkillSlot` | ready, pressed, cooldown, locked | Pressed = brief `scale` tween; cooldown = radial mask over icon; locked = desaturated frame + lock icon + level label. |
| `AutoButton` | active, inactive | Active = green-tinted background and icon; inactive = muted purple. |
| `CapRewardButton` | available, pulsing | Gift icon color pulses via `modulate` tween. |
| `MapButton` | idle, pressed | Subtle scale feedback. |

### 7.2 Animation Intent

All motion is short and restrained, matching the reference:

- Button press compression: `0.1 s` scale to `0.91` via `Tween`.
- Active-state glow pulses: `2.0–2.5 s` loop, low opacity range.
- Floating combat text: `1.0–1.5 s` upward drift + fade.
- Cooldown radial wipe: driven by a `TextureProgressBar` with a radial fill texture or a `ShaderMaterial`.
- Reward icon pulse: `0.5 s` color modulation loop.

Avoid bounce, elastic overshoot, or full-screen flashes.

---

## 8. Responsiveness & Safe Areas

- Design at `390 × 844` logical px.
- Use Godot’s `ProjectSettings.display/window/stretch/mode = "canvas_items"` (or `"viewport"` if pixel-perfect scaling is required) with `stretch/aspect = "expand"`.
- The `SafeAreaContainer` adds margins equal to `DisplayServer.get_display_safe_area()`.
- On wider devices, the `CombatView` expands vertically; the HUD, Skill Dock, Chat Strip, and Bottom Nav keep their authored heights.
- On narrower devices, the Skill Dock row compresses slot spacing first; if insufficient, the rightmost locked slots may scale down, but the active slots must remain `44 × 44` touch minimum.

---

## 9. Type-Safety Conventions

- All scripts use `class_name` and typed exports:

```gdscript
class_name SkillSlot
extends TextureButton

@export var skill_data: SkillDataResource
@export var is_locked: bool = false
@export var level_required: int = 0

signal skill_pressed(slot_index: int)
```

- Enums are strongly typed where applicable:

```gdscript
enum TabId { HOME, HEROES, BATTLE, GUILD, SHOP }
```

- Avoid `get_node()` without type hints; prefer `@onready var` references and scene-unique node names.

---

## 10. Suggested Build Order

1. **Shared primitives**: `OrnamentalDivider`, `OctagonalButton`, `SlantedProgressBar`.
2. **Top HUD**: `StatBar`, `PlayerPortrait`, `MapButton`, `CapRewardButton`, then `TopHud`.
3. **Stage Plaque**.
4. **Combat View** placeholder with background/ground layers.
5. **Skill Dock**: `SkillSlot`, `AutoButton`, then `SkillDock`.
6. **Chat Strip**.
7. **Bottom Navigation**: `NavTab`, then `BottomNav`.
8. **Main composition**: `MainGameplayInterface` scene, signal wiring, safe-area handling.

---

## 11. Validation Criteria

Before considering the UI complete, verify that it:

- matches the reference hierarchy and proportions at `390 × 844`;
- uses the canonical dark-violet, gold, cyan, and purple palette from `interface-design.md`;
- preserves faceted octagonal skill slots and clipped-corner portrait frame;
- preserves the raised Battle navigation pedestal;
- keeps all dynamic text and values out of authored textures;
- is readable on a 6.1" portrait screen;
- keeps the combat view as the dominant visual area;
- uses subtle glow only;
- replaces prototype emoji and placeholder icons with production assets without changing their visual roles.
