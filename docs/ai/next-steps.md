# Next Steps — Playable Loop Implementation Plan

Status: In progress — Phase 1 complete
Scope: First playable loop, excluding Stages and main progression

## Objective

Turn the existing UI and progression baseline into one repeatable, persistent gameplay loop:

```text
Configure Fern → Enter Encounter → Fight → Win/Lose → Receive Rewards
      ↑                                                   ↓
      └──────────── Equip or Enhance → Save ──────────────┘
```

## Importance Scale

| Priority | Meaning |
| ---: | --- |
| 1 | Critical blocker for playability |
| 2 | Required to complete the core loop |
| 3 | Required for a reliable external test build |
| 4 | Valuable content, balance, or polish |
| 5 | Safe to defer until after the vertical slice |

## Phase 1 — Runtime Foundation

Goal: establish one authoritative source of gameplay data.

Status: **Complete (2026-07-19).** The shared-shell scene owns `GameSession`, which owns a
versioned `PlayerProfile`. Heroes, Backpack, Equipment, HUD, Shop currency displays, Dungeon
attempts, and the combat skill dock are bound to the composed profile states. Typed catalogs and
validated mutation results are in place; disk persistence remains Phase 4 work.

| Work | Priority |
| --- | ---: |
| Add a scene-owned `GameSession` / `PlayerProfile` | 1 |
| Move currencies, inventory, equipment, progression, and activity attempts into it | 1 |
| Compose the existing `HeroProgressionState` into the profile | 1 |
| Replace Backpack's separate static inventory with profile snapshots | 1 |
| Define typed skill, item, enemy, and reward catalogs | 1 |
| Define a versioned save-data schema | 1 |
| Standardize validated mutations, results, and change signals | 2 |

Target ownership:

```text
GameSession
├── PlayerProfile
│   ├── HeroProgressionState
│   ├── InventoryState
│   ├── WalletState
│   └── ActivityState
├── CombatController
└── SaveService
```

Exit criteria:

- [x] Heroes, Backpack, Equipment, HUD, and currency displays read the same data.
- [x] Equipping an item updates Backpack, Equipment, Stats, and combat snapshots.
- [x] No UI screen owns authoritative Phase 1 gameplay values.
- [x] A profile round-trips through a versioned dictionary before disk persistence is enabled.

## Phase 2 — Functional Combat

Goal: make one encounter genuinely interactive.

### Combat engine

| Work | Priority |
| --- | ---: |
| Combatant HP, MP, stats, and alive/dead state | 1 |
| Basic attacks and attack timing | 1 |
| Damage and healing calculation | 1 |
| Defense, critical hits, block, and evasion | 1 |
| Skill resource costs and cooldowns | 1 |
| Target selection | 1 |
| Manual skill activation | 1 |
| Victory and defeat conditions | 1 |
| Auto-combat decision logic | 2 |
| Buffs, debuffs, barriers, and periodic effects | 2 |
| Summoned companion support | 2 |

Combat logic must remain independent from presentation. `CombatView` should consume events such as
`action_started`, `damage_dealt`, `healing_applied`, `status_added`, `combatant_defeated`, and
`combat_finished`.

### Skill implementation order

1. Thorn Orb — direct damage.
2. Dew Restore — direct healing.
3. Vine Web — control or debuff.
4. Sanctuary Bloom — area healing or barrier.
5. Canopy Wave — area effect.
6. Guiding Light — buff.
7. Spirit Link — linked target or resource interaction.
8. Send Companion — summon.

| Skill scope | Priority |
| --- | ---: |
| Current five equipped skills work | 1 |
| All eight available skills work | 2 |
| Skill ranks affect magnitude, cost, or cooldown | 2 |
| Mastery behavior | 3 |
| Advanced animation and VFX | 4 |

Exit criteria:

- Fern can fight one enemy manually.
- HP, MP, cooldowns, equipment, and calculated Stats affect the result.
- Auto mode can finish the same battle without bypassing combat rules.
- Victory and defeat are caused by combat state rather than timers.
- Combat calculations have deterministic automated tests.

## Phase 3 — Repeatable Reward Loop

Goal: make combat produce meaningful character improvement.

### Encounter integration

| Work | Priority |
| --- | ---: |
| Convert one existing Dungeon into a real encounter | 1 |
| Add an enemy definition and simple AI | 1 |
| Support enter, leave, retry, victory, and defeat | 1 |
| Add difficulty and power validation | 2 |
| Consume and restore activity attempts correctly | 3 |
| Add additional enemy behaviors | 4 |

### Rewards and economy

| Work | Priority |
| --- | ---: |
| Apply rewards atomically through a `RewardService` | 1 |
| Add one soft currency | 2 |
| Add stackable materials | 2 |
| Add equipment drops | 2 |
| Support inventory capacity and duplicate handling | 2 |
| Make the victory screen reflect actual awarded values | 2 |
| Add one equipment-enhancement action and material sink | 2 |
| Externalize reward tables from UI code | 2 |
| Add item comparison before equipping | 3 |
| Add randomized affixes or rarity rolls | 4 |

Exit criteria:

- Winning grants real currency, materials, or equipment.
- Rewards appear in the unified Backpack.
- Equipping or enhancing an item changes Stats and later combat.
- Replacement never double-counts equipment modifiers.
- Defeat grants no unintended rewards.
- The loop can be repeated without restarting the game.

Completion of Phase 3 is the first internally playable milestone.

## Phase 4 — Persistence and Test-Build Reliability

Goal: make the playable loop safe enough for external testing.

### Persistence

| Work | Priority |
| --- | ---: |
| Implement local save and load | 1 |
| Autosave after meaningful mutations | 1 |
| Use atomic or recoverable file writing | 1 |
| Add save versions and migrations | 2 |
| Add corrupted-save fallback | 2 |
| Add new-game initialization | 2 |
| Add a development-only profile reset | 3 |
| Add cloud saving | 5 |

Autosave after skill, talent, loadout, equipment, reward, enhancement, currency, and activity-attempt
mutations.

### Player experience and reliability

| Work | Priority |
| --- | ---: |
| Handle mobile pause, background, and resume safely | 2 |
| Add a first-session loadout/combat/reward tutorial | 3 |
| Explain unavailable and disabled actions | 3 |
| Protect loading and screen transitions | 3 |
| Confirm expensive or destructive actions | 3 |
| Add audio, vibration, and accessibility settings | 3–4 |

### Required validation

| Test area | Priority |
| --- | ---: |
| Combat calculations | 1 |
| Reward duplication and loss | 1 |
| Save round-trip | 1 |
| Save migration | 2 |
| Inventory and equipment integration | 2 |
| Long Auto-combat simulations | 2 |
| Mobile navigation and touch | 2 |
| Target-device performance | 3 |

Exit criteria:

- Closing and reopening restores the exact profile.
- Interrupted saving does not erase the profile.
- Backgrounding does not corrupt combat or rewards.
- No reward can be claimed twice.
- The complete loop survives repeated automated simulations.

Completion of Phase 4 is the first external test-build milestone.

## Phase 5 — Content and Presentation

Goal: make the vertical slice feel like Kilune rather than a technical prototype.

### Presentation and variety

| Work | Priority |
| --- | ---: |
| Replace Warrior combat assets with Fern | 3 |
| Add Fern idle, attack, cast, hit, and defeat animations | 3 |
| Add enemy sprites and animations | 3 |
| Add skill-specific VFX and combat feedback | 3 |
| Add combat sound effects | 3 |
| Add three distinct enemy behaviors | 3 |
| Balance all eight current skills | 3 |
| Create meaningful equipment choices | 3 |
| Add music and ambience | 4 |
| Add dungeon difficulty variants and more rewards | 4 |

### Deferred until after the vertical slice

| System | Priority |
| --- | ---: |
| Cards affecting combat Stats | 5 |
| Pets as a complete progression system | 5 |
| Second Path or Specialization selection | 5 |
| Multiple heroes | 5 |
| Guild backend and multiplayer | 5 |
| Real-money shop and receipt validation | 5 |
| Gacha economy | 5 |
| Live mailbox and backend events | 5 |
| Leaderboards and social systems | 5 |
| Stages and main progression | Excluded |

## Delivery Checkpoints

1. **Foundation complete:** every gameplay screen shares one authoritative profile.
2. **Combat sandbox:** Fern can defeat or lose to one real enemy.
3. **Internally playable:** combat rewards improve subsequent combat.
4. **External test build:** the complete loop persists safely across sessions.
5. **Vertical-slice quality:** Fern art, effects, sound, enemy variety, and balance are present.

Do not expand Guild, Shop, Cards, Pets, or content quantity before Phase 3 works. One connected
encounter and reward loop is the priority over additional presentation-only systems.
