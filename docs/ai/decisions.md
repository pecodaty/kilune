# Decisions

## Heroes sub-tab architecture

HeroesTab is a vertical stack: HeroHeader (identity + Back), a clipped
ContentWrapper holding one page per destination (Class rail/arch/panel plus
one scrollable SubTabPage per Skills/Talents/Equipment/Cards/Pets), and the
SubTabBar. The ItemModal overlay covers only the ContentWrapper so the header
and sub-tab bar stay reachable. All reference-state hero data (cast order,
talents, inventory, gear slots) lives in `scripts/ui/heroes/hero_data.gd`
until hero/progression systems own it. Modal and section actions emit signals
for future systems instead of mutating game state.

## Safe-area coordinates

`DisplayServer.get_display_safe_area()` may return global desktop coordinates.
Convert its position to window-local coordinates by subtracting
`DisplayServer.window_get_position()` before calculating UI margins.

