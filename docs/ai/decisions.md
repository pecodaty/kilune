# Decisions

## Runtime profile and Heroes progression ownership

The shared-shell `MainGameplayInterface` owns a scene-local `GameSession`; it is not an autoload.
`GameSession` owns one versioned `PlayerProfile`, which composes `HeroProgressionState`,
`InventoryState`, `WalletState`, and `ActivityState`. Screens receive the profile or the narrow
state they need through `bind_profile` / `bind_state`, consume defensive snapshots, and request
validated mutations returning `StateMutationResult`. One aggregate change signal identifies the
changed domain and kind. Replacing a profile causes all bound screens to rebind, which keeps the
same API ready for a future save service.

HeroesTab remains a vertical stack of HeroHeader, a clipped content wrapper, and a fixed six-item
SubTabBar. Its default Stats page replaces the removed class browser. Stats, Skills, Talents,
Equipment, Cards, and HeroHeader all consume state from the profile. `InventoryState` is the sole
owner of item quantities and equipped slots; `HeroProgressionState` delegates equipment mutations
to it and recalculates Stats from its changes. ItemModal actions carry the item ID back to
Equipment for safe equip, replacement, and unequip mutations.

## Safe-area coordinates

`DisplayServer.get_display_safe_area()` may return global desktop coordinates.
Convert its position to window-local coordinates by subtracting
`DisplayServer.window_get_position()` before calculating UI margins.

## Battle and Dungeon navigation architecture

`MainGameplayInterface` owns the shared-shell destinations: farming combat,
Battle Modes lobby, and Heroes. The lobby keeps the top HUD, stage plaque, and
bottom navigation while replacing the farming combat/dock bands. Entering a
dungeon hides the shared shell and shows one persistent full-screen
`DungeonFlow`, which owns the list, level-pick, combat, victory, and leave-modal
states. Typed enemy and reward definitions come from `GameCatalog`, while daily attempts come
from the profile's `ActivityState`. Combat behavior and reward application remain future phases;
outward navigation is signal-based.

## Guild navigation architecture

Guild is a shared-shell destination: its custom header and content replace the
gameplay HUD while the persistent bottom navigation remains visible. A
`GuildScreen` inside the shell's main content column owns the hall hub and opens
scene-local pages for Hall, Boss, Shop, Schedule, and Academy above that
navigation. The Hall page
owns its Family Hall, Members, and Donation tabs. Reference-state guild data is
kept beside the page that presents it until Guild, Economy, Event, and Research
systems take ownership. Mutating actions emit signals instead of changing the
reference data directly.

## Hero switching access

Heroes screens present the currently active hero but do not expose a quick hero
selector in their shared header. Hero switching, when supported, must use a
dedicated progression or party-management flow rather than an inline dropdown
available from every Heroes sub-tab.

## Shop navigation and ownership

Shop is a shared-shell destination like Guild: its storefront occupies the main
content column while the persistent bottom navigation remains visible and
selected on Shop. `ShopScreen` owns the Supply, Limited, Outfit, Bundle, and
Gacha presentation states and reads currencies from the profile's `WalletState`. Purchase,
outfit-equip, and summon actions still emit signals; application of purchases remains future
Economy and Collection work.

## Floating quick menu and Backpack ownership

The floating right menu is a reusable root overlay shown over the regular main
game/Battle content and hidden for dedicated Heroes, Dungeon, Guild, and Shop
destinations. It owns only collapsed/expanded presentation and emits Bag, Mail,
Map, and Config actions. Bag opens `BackpackScreen` inside the shared content
column, with the persistent bottom navigation as its only outward navigation;
Backpack has no local Close action. Backpack owns only filtering and display sorting; item
quantities, equipment assignments, capacity validation, and mutations belong to the profile's
`InventoryState`.

## Global versus nested navigation controls

Top-level destinations do not expose local Back buttons; users move between
Home, Heroes, Battle, Guild, Shop, and Backpack through the persistent bottom
navigation. Back/close controls are reserved for nested pages that must return
to a parent inside the same destination, such as Guild Boss returning to the
Guild hub or Dungeon level selection returning to the Dungeon list. The former
CAP Reward HUD shortcut is not part of the global HUD.
