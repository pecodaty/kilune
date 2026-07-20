# Shroomer Heroes Screen Interface Directive

Version: 2.0  
Canonical revision date: 2026-07-19

## Purpose

The Heroes destination is Fern's live progression workspace. Traditional classes, class browsing,
and class switching are not part of the trait system. Fern is a level-32 `ADVENTURER` whose
selected build is `Harmony → Oracle`.

Use this directive with `interface-design.md`, which remains authoritative for the shared HUD,
stage plaque, ornamental divider, bottom navigation, palette, typography, and clipped geometry.

## Shared Shell

- Reference viewport: 390 × 844 logical pixels, with responsive support at 432 × 768.
- The stage plaque reads `Heroes · Character Stats`.
- Keep the Heroes header, fixed six-item subtab bar, ornamental divider, and bottom navigation.
- Remove the battle scene, skill dock, and chat strip while Heroes is active.
- Only the selected content page scrolls; the Heroes header, subtab bar, and bottom navigation stay fixed.
- Subtabs are `STATS`, `SKILLS`, `TALENTS`, `EQUIPMENT`, `CARDS`, and `PETS`. `STATS` is the default.

## Identity Language

- Use `FERN`, `Level 32`, and `ADVENTURER` consistently.
- Show `Harmony → Oracle` using living-growth and foresight glyphs; do not use class runes.
- The next milestone is `Level 50 · Choose a Second Path or deepen Harmony`.
- Path II and Specialization II remain unchosen, locked placeholders at levels 50 and 70.
- Do not name or preview an unselected future trait branch.

## Stats Tab

The Stats page is a vertically scrollable live character sheet. Its identity card shows Fern's
identity, current Path/Specialization, Skill and Talent point use, and next milestone.

Present these groups and values in order:

| Group | Values |
| --- | --- |
| Core | Power, Max HP, Max MP |
| Offense | Attack, Skill Power, Critical Chance, Critical Damage, Attack Speed |
| Defense | Defense, Block Chance, Evasion |
| Utility | Cooldown Reduction, Move Speed, Healing Power |

Each row is a touch target. Tapping opens its inline Base, Equipment, and Talent breakdown; only
one breakdown may be open. A second tap closes it. Equipment is added before talent percentage
modifiers. Whole resources/ratings use integer display and percentages use one decimal place.

Stats react immediately to shared progression changes. Skills have no passive stat contribution
unless a future mastery explicitly declares one. Cards and Pets do not contribute in v1.

## Skills and Talents

- Current skills: Harmony — Thorn Orb, Vine Web, Canopy Wave, Send Companion; Oracle — Dew
  Restore, Spirit Link, Sanctuary Bloom, Guiding Light.
- Preserve six loadout slots and show `8 Available · 16 eventual maximum`.
- Harmony's 12 nodes cover life, protection, summons, and adaptation. Its keystone is
  `Verdant Covenant`.
- Oracle's eight nodes cover healing, foresight, barriers, and resource flow. Its keystone is
  `Cycle of Renewal`.
- Preserve level gates, prerequisites, point limits, and dependency-safe refunds.

## Equipment

Equipment slots and collection items share the same live progression state as Stats. Item details
offer exactly the applicable `EQUIP`, `REPLACE`, or `UNEQUIP` action. Replacement is atomic within
the item's slot and must never double-count either item's modifiers.

## Visual and Interaction Rules

- Use the canonical near-black violet surfaces, thin gold structure, cyan active state, restrained
  violet/green trait accents, Cinzel titles, and Rajdhani compact data.
- Use clipped corners and thin borders; do not introduce parchment, rounded dashboard cards,
  photorealism, emoji, or another game's visual language.
- Maintain readable touch targets and vertical touch dragging at both reference sizes.
- Keep dynamic identity, ranks, equipment, totals, and expanded state in Godot rather than assets.

## Acceptance Checklist

- No Druid, traditional class, class-selection, or class-switching copy remains in Heroes.
- Stats, Header, Skills, Talents, and Equipment read from one Heroes-owned state.
- Skill/talent mutations and equipment equip/replace/unequip refresh all affected views immediately.
- Locked future milestones expose no invented branch content.
- The fixed shell and both target portrait viewports remain usable and unclipped.
