# Animation Standards

Version: 1.0

This document defines the canonical animation standards for Shroomer.

Every character animation generated through AutoSprite MCP MUST follow these rules.

If an animation violates any requirement in this document, it MUST be regenerated.

---

# Animation Philosophy

Animations should feel:

- Smooth
- Responsive
- Readable
- Premium
- Elegant

Shroomer is an idle RPG.

Players constantly watch the battle.

Animations should therefore prioritize:

- readability
- anticipation
- impact
- smooth transitions

over realism.

The player should instantly understand what is happening.

---

# General Rules

Every animation MUST preserve:

- character identity
- character proportions
- camera angle
- sprite scale
- pivot point
- weapon proportions
- lighting
- rendering style

The animation should never redesign the character.

Only motion changes.

---

# AutoSprite Configuration

Unless explicitly requested otherwise, ALWAYS generate animations using:

Model:
Pro

Frame Count:
16

Grid:
4 x 4

Canvas:
512 x 512

Background Removal:
Ultra

Output:
Transparent PNG

Never use Lite model unless explicitly requested.

---

# AutoSprite Cost Confirmation

Before calling the AutoSprite MCP, Codex MUST calculate the total generation cost.

Cost Formula

Pro Model:

10 Credits per generated image.

Example

Character:

Warrior

Animations:

Idle

Attack

Cast

Hit

Death

Total Images:

5

Total Cost:

50 Credits

Before generation display:

-------------------------------------

AutoSprite Generation Summary

Model:
Pro

Images:
5

Credits:
50

Configuration:

16 Frames

4x4 Grid

512x512

Background Removal:
Ultra

Proceed?

-------------------------------------

Wait for user confirmation before invoking the MCP.

Never automatically spend credits.

---

# Canonical Sprite Registration

This is one of the most important rules.

Every animation belonging to the same character MUST share:

- identical body scale
- identical foot position
- identical root position
- identical camera distance
- identical character proportions

Ignore:

- slash trails
- magic effects
- floating particles
- weapons extending outside the body

These should never influence character scale.

---

# Character Position

The character remains centered.

Do not move the character around the canvas.

The root position should remain fixed.

Feet should always share the same baseline.

Do not crop:

- cape
- hair
- weapon
- spell effects

---

# Camera

Camera is fixed.

Never generate:

- zoom
- pan
- shake
- rotation
- perspective change

Every frame uses the same camera.

---

# Idle Animation

Purpose

The character is alive while waiting.

Idle is NOT walking.

Allowed motion

✔ breathing

✔ slight torso movement

✔ tiny shoulder movement

✔ cloth sway

✔ hair sway

✔ cape sway

✔ magical glow

✔ floating particles

✔ weapon glow

Forbidden

✖ walking

✖ marching

✖ stepping

✖ bouncing

✖ changing stance

✖ weapon swings

✖ body translation

The first frame and last frame should match perfectly.

The loop should be seamless.

Recommended duration

~2 seconds

16 frames

---

# Attack Animation

Structure

Idle

↓

Anticipation

↓

Attack

↓

Impact

↓

Follow Through

↓

Recovery

↓

Idle

The first frame MUST match the accepted idle pose.

The last frame MUST smoothly return to the exact idle pose.

Never snap directly from attack to idle.

Recovery is mandatory.

---

# Heavy Melee Attacks

Examples

Warrior

Greatsword

Axe

Requirements

Weapon remains in the correct hand.

Feet stay planted.

The body rotates naturally.

The attack conveys weight.

No stepping.

No jumping.

No sliding.

The attack arc should be smooth.

Oversized weapons should feel heavy.

---

# Magical Cast Animation

Structure

Idle

↓

Gather Energy

↓

Magic Charge

↓

Release

↓

Magic Dissipates

↓

Recovery

↓

Idle

Magic should originate from:

- staff
- hands
- crystal

Cloth reacts to magical energy.

Hair reacts subtly.

No exaggerated body movement.

---

# Projectile Release

Projectile animations should clearly communicate:

Charge

↓

Release

↓

Return

The projectile itself should be generated separately.

Character animations should not include long-lived projectile graphics.

Only the release moment.

---

# Hit Animation

Purpose

Show impact without breaking flow.

Recommended

Small recoil.

Tiny body compression.

Weapon reacts.

Cape reacts.

Forbidden

Large knockback.

Walking backwards.

Changing camera.

Recommended duration

6–8 frames.

---

# Death Animation

Purpose

Communicate defeat clearly.

Readable.

Not overly dramatic.

Sequence

Idle

↓

Stagger

↓

Collapse

↓

Rest

No looping.

---

# Monster Animation

Small monsters should exaggerate:

Squash

Stretch

Floating

Head tilt

Body compression

Cute creatures should remain expressive.

Large monsters should move slower.

---

# Secondary Motion

Every animation should include subtle secondary motion.

Examples

Hair

Cape

Scarf

Cloth

Weapon ribbons

Floating crystals

Magic wisps

Never animate every body part equally.

Primary action leads.

Secondary motion follows.

---

# Magical Effects

Effects should be generated separately whenever possible.

Character animations should not permanently embed:

Large slash effects.

Long beams.

Large explosions.

Only:

small glow

tiny particles

brief magical flashes

---

# Animation Timing

Preferred pacing

Frames 1–3

Anticipation

Frames 4–8

Primary Action

Frames 9–12

Follow Through

Frames 13–16

Recovery

Not every animation needs equal timing.

Impact frames may be held slightly longer.

---

# Transition Quality

The player should never notice transitions.

Required transitions

Idle → Attack

Attack → Idle

Idle → Cast

Cast → Idle

Idle → Hit

Hit → Idle

All transitions should appear continuous.

---

# Readability

Animation readability is more important than realism.

At mobile scale:

The player should instantly recognize:

Idle

Attack

Cast

Hit

Death

Silhouette should remain readable.

---

# Validation Checklist

Before accepting an animation verify:

✓ 16 frames

✓ 4x4 grid

✓ 512x512

✓ Transparent PNG

✓ Pro model used

✓ Ultra background removal

✓ Character scale matches idle

✓ Feet share identical baseline

✓ Root position unchanged

✓ Camera unchanged

✓ First frame matches idle

✓ Last frame returns to idle

✓ No walking during idle

✓ No stepping during attack

✓ No cropped weapon

✓ No cropped hair

✓ No cropped cape

✓ No unwanted background

✓ Smooth loop where appropriate

✓ Readable at mobile scale

If any item fails:

REGENERATE.

---

# Codex Responsibilities

When generating animations through AutoSprite MCP:

1. Read this document.
2. Inspect existing accepted animation for the character.
3. Preserve canonical proportions.
4. Estimate credit cost.
5. Ask user for approval.
6. Generate using AutoSprite Pro.
7. Validate registration.
8. Import into Godot.
9. Update SpriteFrames if necessary.
10. Verify transitions in-game.

Animation quality is more important than generation speed.

Never accept inconsistent sprite sheets simply because generation succeeded.
