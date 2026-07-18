# AutoSprite Production Directive

## Purpose

Use AutoSprite through MCP to create production-ready character animations for the Shroomer Godot project.

AutoSprite is the preferred source for:

- idle animations
- attack animations
- casting animations
- hit reactions
- death animations
- custom poses
- character sprite sheets

Do not use it for general interface assets unless an available MCP operation explicitly supports that asset type.

## Source of truth

Before generating an animation, inspect:

1. The existing character reference.
2. Existing accepted sprite sheets for that character.
3. The Godot scene consuming the animation.
4. The required facing direction.
5. The expected cell dimensions and frame count.

Never redesign the character when the task only asks for a new animation.

## Character preservation

Preserve exactly:

- character identity
- armor and clothing
- hairstyle
- face and eye design
- weapon design
- hand holding the weapon
- body proportions
- color palette
- viewing angle
- rendering style

The animation prompt should mostly describe motion and registration, not redescribe the character.

## Standard animation contract

Unless a task specifies otherwise:

- Direction: explicitly defined as LEFT or RIGHT.
- Frame count: 16 frames.
- Canvas dimensions: match the project’s canonical animation size.
- Every cell must have identical dimensions.
- Character root must remain fixed.
- Feet must share a consistent ground baseline.
- Character body scale must match the accepted idle animation.
- Ignore weapons, trails, particles and spell effects when determining body scale.
- Preserve transparent background.
- Do not independently fit each frame to its visible content.

## Idle animation

A true idle animation is not walking in place.

Allowed motion:

- extremely subtle breathing
- tiny shoulder and torso rise/fall
- slight hair, scarf or cape secondary motion
- subtle weapon glow
- minimal magical particle movement

Forbidden motion:

- walking
- stepping
- bouncing
- marching
- horizontal weight shifting
- large weapon movement
- changing stance

The first and last frames must match exactly for a seamless loop.

## Attack animation

Attack sequences should follow:

idle → anticipation → attack → impact/follow-through → recovery → idle

The first frame must match the accepted idle pose.

The final frame must return smoothly to the same idle pose.

Do not snap directly from impact to idle.

Keep the root and foot baseline stable unless the design explicitly requires movement.

## Registration validation

For every generated sprite sheet:

1. Split the sheet into cells.
2. Detect or estimate the character body bounds.
3. Ignore weapon trails and detached VFX.
4. Compare body height against the canonical idle sheet.
5. Compare foot baseline across frames.
6. Compare pelvis/root position across frames.
7. Reject the sheet if visible scale changes between animations.
8. Reject the sheet if the character drifts within the cells.
9. Reject cropped weapons, hair, capes or VFX.

## Godot integration

After downloading the approved output:

1. Save the source sheet under the correct character directory.
2. Preserve the raw output separately.
3. Create or update the matching `SpriteFrames` resource.
4. Set the correct grid columns and rows.
5. Configure FPS based on target duration.
6. Enable looping only for animations intended to loop.
7. Test the transition from idle to attack and back to idle.
8. Verify no scale jump, position jump or baseline jitter occurs.
9. Capture a test screenshot or short preview for validation.

Never compensate for incorrect source registration by adding arbitrary per-animation node scaling unless explicitly approved.

# AutoSprite Generation Rules
## Default Model

Always use:

Model:
Pro

Never use Turbo unless explicitly requested.

Reason:
Highest quality.
Most consistent anatomy.
Best animation quality.

Cost:
10 credits per generation.

## Default Spritesheet Configuration

Frames: 16

Grid:
4 x 4

Resolution:
512x512

Background Removal:
Ultra

Output:
Transparent PNG

Unless explicitly requested otherwise, every sprite animation must use this configuration.

## Before Every Generation

Before calling AutoSprite MCP:

1. Count how many images will be generated.

2. Multiply by 10 credits.

3. Show the user:

-----------------------------------

AutoSprite Generation Summary

Model:
Pro

Images:
4

Credits:
40

Configuration:

16 Frames

4x4 Grid

512x512

Ultra Background Removal

Proceed?

-----------------------------------

Only continue after user confirmation.

Every AutoSprite generation follows:

Inspect existing assets

↓

Read style guide

↓

Generate prompt

↓

Show credit estimate

↓

Wait for approval

↓

Generate

↓

Validate

↓

Import

↓

Update SpriteFrames

# Automatic Registration Validation

Before accepting any character spritesheet:

Codex MUST compare the new spritesheet against the accepted Idle spritesheet.

Validation includes:

- body height (±2%)
- head size (±2%)
- root position
- feet baseline
- pelvis position
- camera distance

Ignore:

- weapons
- spell effects
- slash trails
- floating particles

If body scale differs by more than 2%:

REJECT THE ASSET.

Generate a new version.

Never compensate using Godot node scaling.

The source spritesheet must be corrected instead.
