# Shroomer Interface Art Direction

Version: 2.0  
Canonical redesign date: 2026-07-17

## Source of Truth

The Figma interface redesign is the canonical source of truth for all Shroomer interface art.
It replaces every earlier light, rounded, circular-skill-slot, cyan-dominant, or
"gold only for rewards" interface direction.

Canonical references, in precedence order:

1. The rendered Figma composition represented by
   `references/InterfaceRedesign/src/imports/image_2026-07-17_205025786.png`.
2. The responsive layout, component states, animation intent, colors, dimensions, and SVG
   construction in `references/InterfaceRedesign/src/app/App.tsx`.
3. The decomposed visual specifications in:
   - `references/InterfaceRedesign/src/assets/hud-panel.svg`
   - `references/InterfaceRedesign/src/assets/skill-bar.svg`
   - `references/InterfaceRedesign/src/assets/chat-bar.svg`
   - `references/InterfaceRedesign/src/assets/nav-bar.svg`

When these references differ, match the rendered composition first and use the TypeScript to
resolve behavior and states. Do not reinterpret the interface through older art-direction rules.

This document governs UI only. Character, environment, animation, registration, and import
standards remain authoritative within their own scopes.

## Target Composition

- Reference viewport: 390 x 844 logical pixels.
- Orientation: portrait mobile.
- Scale the composition proportionally and respect device safe areas.
- Preserve the vertical hierarchy: top HUD, stage plaque, combat view, skill dock, chat strip,
  ornamental divider, and bottom navigation.
- Keep the combat view dominant. Interface bands frame the action without obscuring it.

Reference logical dimensions:

| Component | Size |
| --- | ---: |
| Top HUD | 390 x 74 |
| Portrait frame | 52 x 52 |
| Map control | 48 x 22 |
| Reward control | 48 x 30 |
| Stage plaque | approximately 120 x 16 |
| Stat bar | approximately 162 x 7 |
| Skill slot | 50 x 50 |
| Auto control | 44 x 50 |
| Skill dock body | 390 x approximately 64 |
| Chat strip | 390 x 26 |
| Bottom navigation | 390 x 72 |
| Standard navigation frame | 30 x 30 |
| Battle navigation frame | 36 x 36 |

## Visual Identity

The interface is a dark arcane-fantasy control frame with restrained neon energy. It combines:

- near-black violet surfaces;
- faceted octagonal and clipped-corner construction;
- fine gold structural borders;
- cyan active-state energy;
- violet inactive and magical accents;
- sparse geometric ornament;
- compact, high-contrast information;
- subtle glows against large dark fields.

The finish is precise and graphic. Do not replace it with parchment, light storybook surfaces,
rounded glass cards, circular crystal rings, thick painterly frames, or ornamental medieval metal.

## Canonical Palette

Use the values in the exported code directly. Small derived variations are permitted for
legibility, interpolation, or state modulation, but must remain visually subordinate.

### Foundations

| Role | Color |
| --- | --- |
| Outer background | `#020108` |
| Interface canvas | `#06040F` |
| HUD upper surface | `#0D0825` |
| HUD lower surface | `#08041A` |
| Deep panel | `#0D0520` |
| Skill/nav lower surface | `#060210` / `#07040F` |
| Dark border | `#2A1845` |
| Purple structure | `#3D2060` |

### Structural and Active Accents

| Role | Color |
| --- | --- |
| Primary gold | `#FFD700` |
| Bright gold highlight | `#FFE066` |
| Muted gold | `#D4A017` |
| Deep gold | `#8B6200` / `#9A6400` |
| Active cyan | `#00E5C8` |
| Auto active green | `#00E580` |
| Purple ornament | `#7B2FF7` |
| Class glow | `#8844FF` |

### Information and Skill Accents

| Role | Color |
| --- | --- |
| HP | `#22DD6E` |
| MP | `#448AFF` |
| Fire rune | `#FF7733` with warm highlights |
| Ice rune | `#66DDFF` / `#AAEEFF` |
| Wind rune | `#88CCBB` / `#AADDCC` |
| Shadow rune | `#6633AA` / `#AA77EE` |
| Primary pale cyan text | `#A0F8E8` |
| Lavender text | `#C8A0E0` / `#A090C0` |
| Inactive icon/text | `#4A3068` / `#3A2858` |

Gold is a defining structural color in this interface. It is not restricted to currencies or
rewards. Use it for faceted frames, selected emphasis, divider centers, the Battle pedestal,
stage stars, and premium reward cues as shown in the canonical render.

## Shape Language

- Use clipped corners, diamonds, narrow trapezoids, and regular octagonal frames.
- Skill slots and the Auto control are faceted octagons, not circles.
- The portrait is a large clipped-corner medallion, not a circular portrait.
- Navigation uses a shallow gold arch with a raised center Battle pedestal.
- Stat bars use slim slanted ends and diamond terminal markers.
- Lines are thin and deliberate. Avoid thick borders and oversized bevels.
- Keep the composition symmetrical and grid-aligned.
- Rounded geometry may be used only where it appears in the Figma reference or improves an
  invisible touch target; it is not the default visible language.

## Component Rules

### Top HUD

- Use a full-width dark-violet band with fine gold corner brackets and a gold lower edge.
- Order content as portrait; name/activity/timer; HP and MP; Map and Reward actions.
- Keep the player portrait, frame, level badge, text, stat fills, and buttons as separate nodes.
- Name and timer use gold emphasis. Secondary activity text remains muted violet.
- The stage plaque hangs centrally below the HUD and must not be baked into the HUD texture.

### Skill Dock

- Use one Auto control followed by six 50 x 50 skill slots.
- Active slots use gold outer facets, a cyan inner line, dark-blue interiors, four small gold
  nodes, and restrained cyan glow.
- Locked slots use desaturated purple structure, a lock symbol, and a small level requirement.
- Skill art remains independent from frames and cooldown overlays.
- Cooldowns are Godot-driven radial masks over the icon and must not be baked into slot art.

### Chat Strip

- Use a 26-pixel dark translucent band between the skill dock and navigation.
- Keep the chat icon, channel prefix, message, and action text dynamic.
- Gold marks the channel and action; message text uses muted violet.

### Bottom Navigation

- Use five equal destinations: Home, Heroes, Battle, Guild, and Shop.
- Preserve the raised center arch and permanent Battle pedestal.
- The selected destination uses cyan icon/text emission and a thin cyan top shimmer.
- Battle retains its special gold structure even when another destination is selected.
- Inactive destinations remain low-contrast violet.

### Icons

- Use simple outlined rune-like symbols with consistent line weight.
- Prefer strong silhouettes and very low internal detail at mobile size.
- General navigation icons follow the Figma set: house, heroes, crossed weapons, shield, bag.
- Do not substitute emoji in production. Emoji in the prototype are placeholders for registered
  character and portrait art.

## Typography

- Titles, player name, premium labels, and the Auto label: Cinzel, generally bold.
- Stats, timers, navigation, chat, and compact labels: Rajdhani, medium to bold.
- Bundle licensed font files locally; do not depend on Google Fonts at runtime.
- Preserve uppercase navigation labels and compact tracking.
- Never bake dynamic copy, values, timers, level requirements, or localized labels into art.

## Motion and State Language

Preferred motion:

- short press compression around 0.1 seconds;
- soft cyan or class-color glow pulses;
- restrained active-state shimmer;
- reward-icon pulse;
- radial cooldown progression;
- floating damage/healing text;
- slow ambient particles and energy rays.

Avoid bounce, elastic overshoot, large flashes, or effects that cover combat. Every interactive
component must support idle, pressed, disabled, and selected/active states where applicable.
Derive states through Godot modulation and shaders when that faithfully matches the reference.

## Asset Construction

- Build frames, icons, portraits, environment art, masks, and content as independent assets.
- Composite SVGs in the Figma export are specifications, not production-ready monoliths.
- Keep text, numeric values, progress fills, cooldowns, selection state, and layout in Godot.
- Use nine-patch construction only where it preserves the reference geometry.
- Keep borders inside image bounds and leave 4-8 pixels of transparent padding around glows.
- Do not bake neighboring controls, shadows, or unrelated UI systems into one bitmap.
- Preserve exact logical proportions at the 390 x 844 reference size before responsive scaling.

## Validation Checklist

An interface implementation is acceptable only when it:

- matches the rendered Figma hierarchy and proportions;
- uses the canonical dark-violet, gold, cyan, and purple palette;
- preserves faceted octagonal slots and clipped-corner frames;
- preserves the raised Battle navigation arch;
- keeps dynamic information out of authored textures;
- remains readable at 390 x 844 logical pixels;
- retains combat as the dominant visual area;
- uses subtle, not overpowering, glow;
- replaces prototype emoji and generic icons with production assets without changing their
  established visual roles.

If another document conflicts with this guide on interface art, this guide and the Figma
references take precedence.
