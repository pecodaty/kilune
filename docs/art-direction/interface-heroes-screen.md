# Shroomer Heroes Screen Interface Directive

Version: 1.0  
Canonical reference date: 2026-07-17

## Purpose

This document defines the Heroes tab and its class-selection screen. It is an implementation
directive for reproducing the supplied Druid, Mage, Warrior, Assassin, and Hunter reference
screens in Godot. It specifies composition, visual states, content, responsive behavior, and
asset boundaries; it does not prescribe scene or script code.

Use this document together with `interface-design.md`. That guide remains authoritative for the
shared top HUD, screen plaque, ornamental divider, and bottom navigation. This document is
authoritative for the Heroes content between the screen plaque and bottom divider.

## Canonical References and Precedence

Use these sources in this order:

1. The five supplied rendered screenshots, one for each class-selection state.
2. `references/reference-code/reference-code/src/app/App.tsx` for exact dimensions, content,
   responsive layout, dynamic states, and vector construction.
3. `docs/art-direction/interface-design.md` for the shared interface system.
4. `docs/art-direction/visual-language.md` only where it does not conflict with interface rules.

When the screenshots and reference code appear to differ, match the screenshot visually and use
the code to resolve hidden behavior or state. Prototype emoji are compositional placeholders, not
approved production icons or character art.

## Screen Role and Visual Intent

The Heroes tab is a class browser for one selected hero. It must feel like an arcane character
archive embedded in the established dark-violet interface:

- the left rail provides persistent class navigation;
- the upper-right arch makes the selected class immediately recognizable;
- the lower-right panel explains the class and exposes its progression;
- the selected class color changes the local emphasis without recoloring the global shell;
- gold remains the structural and premium accent;
- cyan is reserved for the actionable `SELECT CLASS` state and the selected Heroes navigation
  destination;
- the current class uses its own class color and gold `CURRENT` markers.

The result must remain precise, graphic, symmetrical, and readable. Do not reinterpret this screen
as a character inventory, card carousel, rounded dashboard, parchment page, or full-screen portrait.

## Reference Coordinate System

- Design at 390 x 844 logical pixels in portrait orientation.
- Scale the complete interface proportionally and respect safe areas as defined in
  `interface-design.md`.
- The shared top HUD is 74 pixels high.
- The screen plaque hangs directly below the HUD and reads `Heroes · Class Selection` between two
  gold stars.
- The shared bottom region consists of a 10-pixel ornamental divider and a 72-pixel navigation bar.
- The Heroes content fills all remaining height between the plaque and bottom divider.
- The Heroes content clips at its outer bounds. Only the class information panel scrolls.

At the reference width, divide the Heroes content into:

| Region | Logical width | Behavior |
| --- | ---: | --- |
| Class rail | 90 px | Fixed width; never scrolls with the information panel |
| Detail column | 300 px | Fills remaining width |
| Portrait arch | 300 x 220 px region | Fixed above the information panel |
| Information panel | 300 px wide | Fills remaining height; vertical scrolling only |

Do not place a gutter between the rail and detail column. Separate them with a faint one-pixel
purple structural line.

## Shared Shell State

When the Heroes tab is active:

- retain the complete top HUD unchanged, including portrait, player name, activity/timer, HP, MP,
  Map, and Chapter Reward;
- replace the battle stage name with `Heroes · Class Selection` in the shared plaque;
- remove the battle scene, skill dock, and world chat strip from the layout;
- allow the Heroes content to consume the newly available vertical space;
- keep the raised gold Battle pedestal in the bottom navigation;
- highlight Heroes with a gold faceted frame, cyan icon, pale-cyan label, and thin cyan shimmer at
  the top of its navigation cell;
- keep Battle gold but inactive when Heroes is selected;
- render Home, Guild, and Shop in low-contrast violet.

The bottom navigation remains fixed while the information panel scrolls behind neither the divider
nor the navigation.

## Heroes Content Hierarchy

Build the screen from reusable visual sections with independent dynamic content:

1. Class rail
   - hero identity header;
   - five class tabs.
2. Detail column
   - selected-class portrait arch;
   - scrollable information panel;
   - class title and metadata;
   - description;
   - abilities entry;
   - skill pool;
   - future advancement paths;
   - select/current-class action.

Keep the visual representation separate from class-selection and progression data. Text, class
colors, current state, selection state, and scroll position must remain dynamic.

## Class Rail

### Rail Surface

- Width: 90 pixels.
- Background: vertical gradient from `#0D0825` to `#08041A`.
- Right divider: `#3D2060` at approximately 27% opacity.
- Keep the rail visually subordinate to the selected detail panel.

### Hero Identity Header

- Center the player name `FERO` near the top with 12 pixels of top padding.
- Name typography: Cinzel Bold, 11 px, `#FFD700`, tracking approximately `0.06em`.
- Place `Hero · 1` below it in Rajdhani SemiBold, 7.5 px, `#6050A0`, tracking `0.04em`.
- Add a 60 x 1 pixel horizontal rule below, fading from transparent through `#D4A017` and back to
  transparent.
- Use approximately 6 pixels between the subtitle and rule.

### Tab Stack

- Use five tabs in this order: Druid, Mage, Warrior, Assassin, Hunter.
- Horizontal rail padding: 6 pixels.
- Tab height: 52 pixels.
- Vertical gap: 6 pixels.
- Start the stack 4 pixels below the header area.
- Each tab clips both right corners by 8 pixels; its left edge remains square.
- Internal horizontal padding: 10 pixels.
- Arrange icon and label with an 8-pixel gap.
- Keep the tab touch target at least as large as its visible 52-pixel height.

### Inactive Tab

- Surface: `#0D0825` at approximately 67% opacity.
- Border: `#3D2060` at approximately 27% opacity.
- Left accent: 3 pixels wide, inset 6 pixels vertically, `#3D2060` at 30% opacity.
- Icon: class color at 45% opacity.
- Name: Cinzel SemiBold, 10 px, `#5A4080`, tracking `0.04em`.
- Do not show a glow or top shimmer.

### Browsed/Selected Tab

This is the class whose details are currently displayed. It is not necessarily the equipped class.

- Surface: the selected class background tint at approximately 87% opacity.
- Border: selected class color at approximately 40% opacity.
- Left accent: full-opacity selected class color.
- Add a restrained class-colored drop glow.
- Add a one-pixel, low-opacity shimmer across the upper interior from 14 pixels after the left edge
  to 10 pixels before the right edge.
- Icon: full-opacity class color.
- Name: Cinzel Bold, 10 px, full class color.

### Current-Class Marker

- Add `CURRENT` below the class name only on the equipped class tab.
- Typography: Rajdhani Bold, 6.5 px, `#FFD700`, tracking `0.06em`.
- The marker stays on the equipped class when the user browses another class.
- Initial reference state: Hunter is current in the supplied screenshots. The reference prototype
  may initialize another class; production must display the actual equipped class from game state.

### Rail Icons

Use simple 18 x 18 outlined class runes with consistent line weight and minimal internal detail:

| Class | Rune silhouette |
| --- | --- |
| Druid | Hanging leaf/seed form with a short stem |
| Mage | Angular five-point arcane star |
| Warrior | Crossed weapons with a faint central ring |
| Assassin | Up-right dagger/arrow silhouette with small guard strokes |
| Hunter | Drawn bow with a horizontal right-facing arrow |

Do not use emoji for rail icons.

## Selected-Class Portrait Arch

### Region and Background

- Reserve a fixed 220-pixel-high region at the top of the detail column.
- Fill it with `#06040F` and a soft class-tinted radial gradient centered around 50% horizontal and
  60% vertical.
- The tint ellipse should cover roughly 70% of the region width and 80% of its height, fading fully
  into the base by about 70% of its radius.
- The class tint must remain atmospheric; it must not become a bright solid panel.

### Arch Geometry

Construct the arch in a 302 x 220 local coordinate space and scale it to fit the detail column
without distortion.

- Outer base corners: approximately x 24 and x 278 at y 215.
- Vertical sides rise to approximately y 100.
- The upper curve converges into a shallow pointed apex around x 151, y 10.
- Gold outer stroke: 1.5 pixels using a diagonal `#FFE066` to `#9A6400` to `#FFD700` gradient.
- Outer fill: a vertical class-color wash from 12% opacity at the top to 3% at the bottom.
- Inner arch: inset to approximately x 38 and x 264, beginning at y 215 and cresting around y 26;
  stroke with class color at 35% opacity and 0.8-pixel width.
- Add small gold nodes at both base corners, class-colored nodes at the side spring points, and a
  small gold diamond/gem at the apex.
- Place nine subtle four-pixel gold tick marks down each outer side.
- Add a low class-colored elliptical glow pool near the base and a faint class-colored base line.

The arch must read as delicate arcane architecture, not a thick medieval doorway.

### Central Class Emblem

- Center one large class emblem within the arch, visually occupying approximately a 90 x 90 pixel
  box at reference scale.
- Apply a soft class-color glow and a subtle dark downward shadow.
- Preserve a clear silhouette and low internal detail at mobile size.
- Use production-authored emblems rather than emoji:
  - Druid: luminous green leafy branch;
  - Mage: blue/orange magical star cluster;
  - Warrior: crossed pale greatswords with violet hilts;
  - Assassin: compact diagonal dagger with gold guard and purple/red gems;
  - Hunter: brown longbow, taut pale string, and nocked arrow.
- Treat the screenshots as the authority for pose, proportions, and material treatment of these
  emblems. Do not import another game's icon language.

### Portrait Watermark

- Center the uppercase class name near the bottom, approximately 20 pixels above the region edge.
- Typography: Cinzel Black, 11 px, class color at 35% opacity.
- Tracking: approximately `0.3em`.
- The watermark must remain behind the information hierarchy and must not resemble a button.

## Scrollable Class Information Panel

### Container

- Begin immediately below the fixed portrait region.
- Allow only this panel to scroll vertically; hide the visible scrollbar.
- Add 4-pixel outer margins on the left, right, and top.
- Surface: vertical gradient from `#0E0A28` to `#080418`.
- Border: one pixel `#3D2060` at approximately 33% opacity.
- Use small, thin `#D4A017` corner brackets at approximately 50% opacity.
- Inner padding: 12 pixels horizontally, 12 pixels at top, and 16 pixels at bottom.
- Do not round the panel corners.

### Class Title

- Render the uppercase selected class name in Cinzel Bold, 18 px, selected class color.
- Use `0.08em` tracking and a tight single-line height.
- Keep the title left-aligned.

### Metadata Tags

- Place the Weapon and Role tags on one row about 6 pixels below the title, with an 8-pixel gap.
- Tags use a small parallelogram shape clipped by 4 pixels on opposing corners.
- Height should follow 8-pixel Rajdhani Bold text with one-pixel vertical and eight-pixel horizontal
  padding.
- Weapon tag: lavender text `#C8A0E0`, `#2A1845` translucent surface, faint `#3D2060` border.
- Role tag: class-colored text, class background tint, faint class-colored border.
- Copy formats are `Weapon: {weapon}` and `Role: {role}`.
- Preserve readability before decorative symmetry; do not truncate the reference strings at the
  target viewport.

### Description

- Place the description below the tags and above Abilities.
- Typography: Rajdhani Medium, 10 px, `#8070A0`, line height 1.6.
- Allow natural wrapping. Reference descriptions occupy one or two lines in the 300-pixel detail
  column.
- Use approximately 14 pixels of space after the description.

### Section Labels

Use the following labels exactly:

- `ABILITIES`
- `SKILL POOL`
- `ADVANCEMENTS · FUTURE PATHS`

Style all three with Cinzel Bold, 9 px, `#A090C0`, and `0.06em` tracking. Use approximately
6 pixels between a label and its content.

### Abilities Entry

- Use one full-width, 34-pixel-high clipped bar.
- Clip the top-left and bottom-right corners by 6 pixels.
- Background: horizontal gradient from the class background tint toward translucent `#0D0825`.
- Border: class color at approximately 27% opacity.
- Left/right content padding: 12 pixels.
- Label: `Tier 0 · 8 Class Skills`, Rajdhani Bold, 10 px, class color, `0.05em` tracking.
- Place a 14-pixel right chevron at the far right in class color at 70% opacity.
- The entire bar is one interaction target that opens the class ability list.

### Skill Pool

- Display eight skills in a two-column by four-row grid.
- Grid gap: 5 pixels both horizontally and vertically.
- Each cell is 26 pixels high and clips its top-left and bottom-right corners by 5 pixels.
- Cell surface: `#0D0825`.
- Border: `#3D2060` at approximately 33% opacity.
- Internal horizontal padding: 8 pixels; icon-to-label gap: 6 pixels.
- Use an 8-pixel circular class-color bullet at 70% opacity.
- Skill text: Rajdhani SemiBold, 8.5 px, `#9080B0`, tracking `0.02em`.
- Keep text on one line with ellipsis only if localization cannot fit.
- Fill the grid by rows, left then right, matching the tables below.

### Future Paths

- Display three equal-width path cells in one row with an 8-pixel gap.
- Cell height: 28 pixels.
- Surface: `#0A0720`.
- Border: `#3D2060` at approximately 47% opacity.
- Clip the top-left and bottom-right corners by 6 pixels.
- Center the label in Rajdhani Bold, 8 px, `#6050A0`, tracking `0.03em`.
- These paths are intentionally subdued and communicate unavailable future progression.

### Select/Current Action

- Place one full-width 40-pixel-high primary action after the future paths.
- Clip the top-left and bottom-right corners by 8 pixels.
- Use a 1.5-pixel border and restrained matching glow.
- Center a Cinzel Bold 11-pixel label with `0.1em` tracking between two 5 x 5 diamond markers.

If the browsed class is not current:

- label: `SELECT CLASS`;
- border, label, diamonds, and glow: `#00E5C8`;
- background: dark-blue horizontal gradient `#0A1535` to `#0D1A40` and back.

If the browsed class is current:

- label: `CURRENT CLASS`;
- border, label, diamonds, and glow: selected class color;
- background: class tint to `#0D1535` and back;
- pressing it must not perform a redundant class change.

Changing the current class must update the rail's `CURRENT` marker and both action states without
changing which class is being browsed.

## Canonical Class Data

### Druid

| Field | Value |
| --- | --- |
| Accent | `#22DD6E` |
| Background tint | `#0A2018` |
| Weapon | Growth Staff |
| Role | Sustain Support |
| Description | A sustaining nature channeler who restores allies and commands living magic. |
| Skill row 1 | Thorn Orb / Draw Barriers |
| Skill row 2 | Thorn Ball / Vine Web |
| Skill row 3 | Screaming Light / Send Companion |
| Skill row 4 | Canopy Wave / Barn Guard |
| Future paths | Thornweaver / Grove Warden / Lifebloom Sage |

### Mage

| Field | Value |
| --- | --- |
| Accent | `#448AFF` |
| Background tint | `#0A1428` |
| Weapon | Arcane Tome |
| Role | Burst Damage |
| Description | A master of forbidden arcane arts who channels raw magical energy into devastating spells. |
| Skill row 1 | Arcane Bolt / Mana Shield |
| Skill row 2 | Frost Nova / Blink |
| Skill row 3 | Arcane Surge / Ice Lance |
| Skill row 4 | Time Warp / Polymorph |
| Future paths | Archwizard / Spellbinder / Void Caller |

### Warrior

| Field | Value |
| --- | --- |
| Accent | `#FF7733` |
| Background tint | `#2A1408` |
| Weapon | Greatsword |
| Role | Tank / DPS |
| Description | An unyielding frontline fighter who absorbs punishment and retaliates with crushing force. |
| Skill row 1 | Shield Bash / Battle Cry |
| Skill row 2 | Whirlwind / Iron Skin |
| Skill row 3 | Charge / Rend |
| Skill row 4 | Rallying Cry / Bloodthirst |
| Future paths | Berserker / Paladin / Gladiator |

### Assassin

| Field | Value |
| --- | --- |
| Accent | `#AA44FF` |
| Background tint | `#180A2A` |
| Weapon | Twin Daggers |
| Role | Single Target DPS |
| Description | A shadow-walking predator who eliminates single targets with precision and deadly efficiency. |
| Skill row 1 | Backstab / Shadow Step |
| Skill row 2 | Smoke Screen / Poison Blade |
| Skill row 3 | Evasion / Fan of Knives |
| Skill row 4 | Death Mark / Shadowmeld |
| Future paths | Shadowblade / Nightstalker / Voidwalker |

### Hunter

| Field | Value |
| --- | --- |
| Accent | `#FFD700` |
| Background tint | `#2A2008` |
| Weapon | Longbow |
| Role | Ranged DPS |
| Description | A keen-eyed tracker who commands beast companions and strikes from range with deadly arrows. |
| Skill row 1 | Arrow Shot / Multi-Shot |
| Skill row 2 | Track Prey / Beast Bond |
| Skill row 3 | Camouflage / Explosive Trap |
| Skill row 4 | Eagle Eye / Volley |
| Future paths | Beastmaster / Ranger / Deadeye |

## Interaction and Motion

- Tapping a class tab changes the browsed class immediately but does not equip it.
- Tapping `SELECT CLASS` equips the browsed class and changes the action to `CURRENT CLASS`.
- Preserve the information panel scroll position only when intentional; default to the top when a
  newly browsed class would otherwise reveal mismatched lower content.
- Use approximately 0.2 seconds for tab surface, border, icon, and text color transitions.
- Use approximately 0.25 seconds for the primary action transition.
- A restrained class-color glow may pulse on selected emphasis, but must not obscure strokes or
  text.
- Press feedback may use the shared short compression language from `interface-design.md`.
- Avoid bounce, elastic overshoot, large flashes, parallax, and automatic carousel movement.

## Responsive Rules

- Preserve the 90:300 rail-to-detail relationship at the 390-pixel reference width.
- Scale proportionally on similar portrait aspect ratios.
- Keep the rail wide enough for an 18-pixel rune and readable class label; never shrink it until
  names collide with the clipped right edge.
- Keep the portrait arch at a stable visual height relative to the 220-pixel reference rather than
  stretching it to consume surplus height.
- Give surplus vertical space to the scrollable information panel.
- On shorter screens, retain the fixed HUD, plaque, portrait, divider, and navigation; reduce only
  nonessential vertical gaps before considering a smaller proportional portrait.
- Do not convert the class rail into a dropdown or horizontal carousel at the target mobile width.
- Respect localized text expansion in metadata, skills, and future paths. Preserve minimum touch
  targets even when visible ornament is smaller.

## Asset and Implementation Boundaries

- Build the class rail, class tab, portrait arch, information panel, metadata tag, abilities entry,
  skill cell, advancement cell, and primary action as reusable scene-local UI components.
- Use containers for the rail stack, metadata row, skill grid, and advancement row wherever
  practical.
- Keep class data outside authored textures.
- Keep every label, skill name, description, current marker, and action state dynamic and
  localizable.
- Construct simple frames and runes as vectors or Godot-drawn geometry when that preserves the
  exact reference.
- Store each large class emblem independently from the arch, tint, glow, watermark, and frame.
- Do not bake multiple class states into one texture.
- Do not bake text, selection glows, borders, or the current-state marker into class emblem art.
- If raster emblems are generated later, follow the relevant character/equipment art documents and
  asset import standards before generation or import.

## Prohibited Deviations

- No light surfaces, parchment, wood, realistic metal, or photorealism.
- No rounded cards, pill buttons, circular portrait frames, or circular tab buttons.
- No thick gold borders, excessive bloom, noisy textures, or large ornamental flourishes.
- No battle skill dock or chat strip while Heroes is active.
- No class-color takeover of the global HUD or bottom navigation.
- No emoji or third-party game icons in production.
- No truncation of English reference copy at 390 x 844.
- No equipping a class merely by browsing its tab.
- No scrolling of the class rail, portrait arch, shared shell, or bottom navigation with the info
  panel.

## Acceptance Checklist

The Heroes screen is acceptable only when all of the following are true:

- The composition matches the supplied screenshots at 390 x 844 logical pixels.
- The global HUD, plaque, divider, and navigation match `interface-design.md`.
- The screen uses a fixed 90-pixel rail and a 300-pixel detail column.
- All five class tabs fit simultaneously and show distinct inactive, browsed, and current states.
- Browsing and equipping are separate interactions.
- The portrait arch is fixed while only the information panel scrolls.
- The arch uses thin gold structure, faint class tint, class nodes, side ticks, and a bottom glow.
- Each class displays the correct accent, tint, weapon, role, description, skills, and future paths.
- Non-current classes use the cyan `SELECT CLASS` action.
- The current class uses a class-colored `CURRENT CLASS` action and gold rail marker.
- Heroes is cyan-active in navigation while the Battle pedestal remains structurally gold.
- Text remains readable without clipping at the reference viewport.
- All prototype emoji have been replaced with approved production emblems before release.
- Glow is restrained and the dark-violet hierarchy remains dominant.
