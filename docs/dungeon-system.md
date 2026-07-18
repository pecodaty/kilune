# Dungeon System

The dungeon feature uses four boundaries:

- `DungeonDefinition` and `DungeonLevelDefinition` are immutable catalog data.
- `DungeonProgressState` is persistable player state: independent attempts, unlocks, completion, and reset metadata.
- `DungeonRunState` is one transient five-phase run. Closing during a run is treated as abandonment; active runs are not saved.
- `DungeonBattleController` coordinates phases and delegates attacks, damage, targeting, health, enemies, and projectiles to the shared combat components.

Attempts are consumed only after validation and successful run creation, immediately before combat. Defeat, retry, and abandonment consume that attempt; retry creates a new run and consumes another. Failed initialization is refunded. The policy is centralized in `DungeonService` and `DungeonProgressState`.

Daily reset uses a deterministic UTC day boundary and is idempotent. The first version uses device time; production should replace the time input with server-authoritative time.

Rewards are immutable entries, level-scaled, and granted by `DungeonRewardService.grant_once`. The run's `reward_granted` flag makes duplicate victory callbacks harmless. Material rewards use `ForgeInventoryState`; gold uses the hero currency dictionary.

Future extensions belong in definitions/services: keys and availability rules, sweep/auto-clear, first-clear rewards, rankings, difficulty modifiers, boss behavior, server reset time, and persisted active-run recovery.
