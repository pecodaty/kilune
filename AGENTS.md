# AGENTS.md

# Project

## Overview

Mobile game built with Godot.

Primary goals:

- Small, readable code
- Low-token AI-assisted development
- High maintainability

---

## Godot Conventions

- Godot version is 4.7.1
- Use GDScript unless there is a strong reason not to.
- Keep scripts small and scene-local whenever possible.
- Prefer composition over inheritance.
- Use typed GDScript.
- Avoid global singletons unless they represent true game-wide state.

### Project Structure

- `scenes/` for `.tscn`
- `scripts/` for reusable scripts
- `assets/` for art/audio
- `docs/` for design notes
- `tests/` for GUT or other test frameworks

---

# Development Workflow

## Before Searching the Repository

1. Search MemPalace for relevant architectural decisions when appropriate.
2. If memory is insufficient, inspect only the relevant repository files using RTK.
3. Explain the intended approach before editing.

Do **not** search MemPalace for:

- formatting
- typo fixes
- isolated one-file changes
- trivial refactors

Search MemPalace when:

- continuing previous work
- implementing previously discussed features
- investigating recurring bugs
- architectural decisions may already exist

---

## Repository Inspection

Prefer RTK wrappers whenever inspecting the repository or running development tools.

Examples include:

- `rtk read`
- `rtk grep`
- `rtk find`
- `rtk git diff`
- `rtk git status`

General rules:

- Inspect the fewest files necessary.
- Avoid rereading the same file.
- Prefer summaries over raw output.
- Never dump large files, logs or diffs unless explicitly requested.

---

## Editing

Before editing:

1. Identify the minimum required files.
2. Explain the intended changes.
3. Edit the fewest files necessary.
4. Prefer targeted edits over broad rewrites.

---

# Memory Protocol

## Reading Memory

Before answering questions about previous work or architectural decisions:

- Search MemPalace first.
- Never guess if project memory may exist.
- Prefer retrieved summaries over rereading unrelated repository files.

---

## Writing Memory

Persist only long-lived knowledge such as:

- architectural decisions
- gameplay design decisions
- project conventions
- public APIs
- performance discoveries
- rejected alternatives

When making an architectural decision:

- Ask whether it should be remembered.

Never store:

- logs
- test output
- generated code
- temporary debugging
- large diffs
- credentials, secrets or private keys

After meaningful work:

- Update `docs/ai/decisions.md` when appropriate.
- Add a short entry to `docs/ai/session-log.md`.

---

# Validation

- Run the smallest relevant validation first.
- Use Godot CLI validation when available.
- For script-only changes, validate syntax and dependencies.

---

# Context Budget

Treat context as a limited resource.

Prefer:

- fewer inspected files
- concise summaries
- targeted repository searches
- RTK output instead of raw tool output

Avoid:

- repeated explanations
- rereading files
- unrelated repository exploration
- long command output

---

# Success Criteria

Prefer solutions that:

- inspect fewer files
- produce less tool output
- require fewer iterations
- preserve readability
- preserve correctness

Token efficiency must never come at the expense of correctness, maintainability or code quality.

## Art Direction (Canonical Source)

Everything related to visual assets MUST follow the documentation under:

docs/art-direction/

These documents are the canonical source of truth for the game's visual identity.

Codex must never invent a new visual style or color palette if the answer already exists in the art-direction documentation.

Always read the relevant documentation before generating prompts or invoking the AutoSprite MCP.

---

## Character Art

When creating or modifying:

- Heroes
- Monsters
- NPCs
- Bosses
- Pets
- Weapons
- Equipment

Read in this order:

1. docs/art-direction/visual-language.md
2. docs/art-direction/character-style.md
3. docs/art-direction/animation-standards.md (if animated)
4. docs/art-direction/sprite-registration.md
5. docs/art-direction/asset-import-standards.md

If generating sprites, follow docs/art-direction/autosprite-mcp.md before invoking the MCP.

---

## Environment Art

When creating:

- Backgrounds
- Forests
- Beaches
- Caves
- Dungeons
- Towns
- Battle arenas

Read:

1. docs/art-direction/visual-language.md
2. docs/art-direction/environment-style.md

If generated through AutoSprite, also read:

3. docs/art-direction/autosprite-mcp.md

---

## UI Art

When creating or modifying:

- HUD
- Buttons
- Skill bars
- Windows
- Panels
- Icons
- Dialogs
- Menus

Read:

1. docs/art-direction/visual-language.md
2. docs/art-direction/interface-design.md

If generating assets through AutoSprite:

3. docs/art-direction/autosprite-mcp.md

---

## Visual Effects

When creating:

- Slashes
- Explosions
- Magic
- Projectiles
- Buffs
- Particles

Read:

1. docs/art-direction/visual-language.md
2. docs/art-direction/effects-style.md

If animated:

3. docs/art-direction/animation-standards.md

---

## Sprite Generation Workflow

Whenever generating sprite sheets:

1. Read the appropriate art-direction documents.
2. Read docs/art-direction/autosprite-mcp.md.
3. Calculate the total credit cost.
4. Present the total cost to the user.
5. Wait for confirmation.
6. Invoke the AutoSprite MCP.
7. Validate the output against the style guide.
8. Reject assets that don't match the canonical style.

---

## Art Consistency Rules

All generated assets must:

- Match the canonical color palette.
- Match the rendering style.
- Match the material language.
- Match the lighting.
- Match the silhouette philosophy.
- Match the Kilune universe.

Never mix styles.

Never generate photorealistic assets.

Never use another game's visual language as the final result.

References from other games may inspire composition or posing, but every generated asset must be transformed to match the Shroomer art direction.

When in doubt, the documentation under docs/art-direction/ always takes precedence over example images.

---

## UI Implementation Guidelines

- Favor deeply nested reusable Control scenes over one large scene.
- Every reusable panel should be its own .tscn.
- Layout containers are preferred over absolute positioning whenever practical.
- Separate visual representation from gameplay logic.

IMPORTANT

Whenever a task involves creating, modifying or regenerating any visual asset, Codex MUST consult the relevant documentation in docs/art-direction/ before writing prompts or calling the AutoSprite MCP.

The art-direction documents are considered the canonical specification and always override previous conversation context unless explicitly updated.
