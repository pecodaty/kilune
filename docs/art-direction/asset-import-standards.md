# Asset Import Standards

Version: 1.0

This document defines the canonical asset import pipeline for Shroomer.

Every asset generated through AutoSprite MCP or any future image generation tool MUST follow this process before being accepted into the repository.

This document exists to ensure:

- visual consistency
- deterministic imports
- clean repository structure
- reproducible assets
- minimal manual work

If an asset does not satisfy these requirements it MUST NOT be committed.

---

# Philosophy

Generated art is not production art.

Generated art becomes production art only after validation.

Every imported asset should be:

- reproducible
- replaceable
- documented
- deterministic

---

# Asset Categories

Assets belong to one of the following categories.

## Characters

Examples

- Hero
- Monster
- NPC

---

## Animations

Examples

- Idle
- Attack
- Cast
- Hit
- Death

---

## Visual Effects

Examples

- Slash
- Beam
- Explosion
- Aura
- Buff
- Particles

---

## User Interface

Examples

- HUD
- Buttons
- Skill Slots
- Dialogs
- Windows
- Icons

---

## Environments

Examples

- Forest
- Beach
- Cave
- Dungeon
- Sky

---

# Canonical Directory Structure

Every asset must be stored in a deterministic location.

Example

art/

heroes/

warrior/

reference.png

idle.png

attack.png

cast.png

death.png

spriteframes.tres

---

heroes/

mage/

...

---

monsters/

forest_mage/

idle.png

attack.png

death.png

---

effects/

slash/

slash_01.png

slash_02.png

beam/

particles/

---

ui/

hud/

top_bar.png

skill_bar.png

portrait_frame.png

buttons/

icons/

dialogs/

---

backgrounds/

forest/

beach/

cave/

---

Never mix categories.

---

# Naming Convention

Use lowercase.

Use snake_case.

Examples

good

forest_mage_idle.png

greatsword_attack.png

skill_slot_empty.png

top_hud.png

bad

Idle.png

AttackFinal2.png

NEWAttack.png

spriteFINAL.png

---

# Source Preservation

Never overwrite the original generation.

For every accepted asset preserve:

generated/

raw/

warrior_attack_autosprite.png

processed/

warrior_attack.png

Never lose the original source.

---

# Accepted Image Formats

Spritesheets

PNG

Transparent

UI

PNG

Transparent

Backgrounds

PNG

Portrait

VFX

PNG

Transparent

Do not import:

JPEG

WEBP

BMP

GIF

unless explicitly requested.

---

# Transparency

All gameplay assets must use true alpha transparency.

Never accept:

white background

checkerboard baked into image

black background

color spill

Background removal should always use:

Ultra

---

# Spritesheet Validation

Every imported spritesheet must verify:

16 frames

4x4 layout

512x512 canvas

transparent

equal cell sizes

no cropped frames

consistent pivot

consistent scale

No exceptions.

---

# Sprite Registration

Character registration is canonical.

Check:

feet baseline

body height

pelvis position

camera distance

Ignore:

weapon trails

spell effects

particles

Registration should match the accepted Idle animation.

---

# Frame Validation

Every frame should contain:

complete body

complete weapon

complete cape

complete hair

No clipping.

No accidental cropping.

---

# Visual Style Validation

Before accepting any asset confirm:

matches visual-language.md

matches color palette

matches rendering style

matches shading

matches crystal aesthetic

If uncertain:

Regenerate.

---

# Environment Validation

Backgrounds must preserve:

45% battle area

55% scenery

clean gameplay center

portrait orientation

No environment should interfere with gameplay readability.

---

# UI Validation

UI assets must:

match the canonical Figma HUD colors

match its thin gold, purple, and cyan borders

match its faceted octagonal and clipped-corner geometry

match glow intensity

match gradients

Never introduce a different visual language.

See `interface-design.md`; it overrides generic visual-language rules for UI assets.

---

# VFX Validation

Effects should:

share the game's cyan/purple palette

remain readable

avoid noisy particles

avoid realistic smoke

avoid photorealistic fire

---

# Godot Import Rules

After importing:

Verify texture imported correctly.

Disable filtering only if pixel art.

Shroomer uses high-resolution stylized assets.

Filtering should remain enabled.

Mipmaps according to intended usage.

Compression:

Use lossless whenever possible.

---

# SpriteFrames

Whenever a spritesheet is imported:

Update SpriteFrames.

Verify:

FPS

Loop

Frame order

Animation names

Transitions

Never leave unused frames.

---

# Scene Validation

After import:

Run the game.

Verify:

Idle

Attack

Cast

Hit

Death

No visual jumps.

No clipping.

No incorrect pivots.

---

# Version Control

Commit generated assets separately from gameplay code whenever possible.

Recommended commit structure

feat(hero):

Add Warrior attack animation

feat(ui):

Redesign skill slots

feat(background):

Add Crystal Beach

Avoid mixing:

art

gameplay

refactoring

in the same commit.

---

# MCP Metadata

Whenever AutoSprite MCP generates an accepted asset record:

Model

Generation Date

Credits Used

Prompt

Negative Prompt

Frame Count

Canvas Size

This information should be stored in:

docs/generated-prompts/

Example

warrior_attack.md

This allows deterministic regeneration later.

---

# Codex Responsibilities

Whenever Codex imports a generated asset:

1. Read visual-language.md

2. Read animation-standards.md

3. Validate generation settings

4. Validate registration

5. Validate transparency

6. Validate proportions

7. Place asset in canonical directory

8. Preserve raw source

9. Update SpriteFrames

10. Test inside Godot

11. Report any inconsistencies

Codex should never silently replace assets.

---

# Quality Checklist

Before accepting any imported asset:

✓ Correct folder

✓ Correct filename

✓ Raw source preserved

✓ PNG

✓ Transparent

✓ Correct resolution

✓ Correct registration

✓ Correct proportions

✓ Correct color palette

✓ Correct style

✓ No clipping

✓ No artifacts

✓ Matches visual-language.md

✓ Imported into Godot

✓ Scene tested

✓ SpriteFrames updated

✓ Repository remains organized

If any answer is NO:

DO NOT IMPORT.

Regenerate or fix the asset first.

---

# Golden Rule

Consistency is more valuable than novelty.

Every new asset should look as though it was created by the same artist, using the same tools, on the same day.

If a player can distinguish which assets were generated months apart, the asset should be regenerated until it matches the project's visual language.
