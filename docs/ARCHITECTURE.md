# Architecture

## Class hierarchy

```
Node2D
 └─ Shape (scripts/core/shape.gd)         health, sides, color, draws itself as a polygon
	 ├─ Tower  (scripts/towers/tower.gd)   player-owned, stats from shapes.json
	 └─ Zombie (scripts/zombies/zombie.gd) enemy, follows a Path2D, stats from zombies.json
```

## Scene tree (level.tscn)

```
Level            game_manager.gd  (state, placement, merge click flow)
├─ Grid          grid_manager.gd  (cells, occupied, path cells)
├─ Path2D        zombie route (cell centers; keep in sync with Grid.path_cells)
├─ Core          core.gd (drawn at screen center; path ends here; Grid.core_cells blocks its 2 cells)
├─ Economy       economy_manager.gd (Edges, Core health)
├─ Spawner       wave_spawner.gd
├─ MergeManager  merge_manager.gd
├─ InfectionSystem infection_system.gd (skeleton)
└─ HUD           hud.tscn
```

## Autoloads

- `GameEvents`: signal bus. Add new signals in `scripts/core/game_events.gd`.
- `GameData`: loads `data/*.json` into dictionaries. `GameData.find_merge_result(a, b)` looks up a recipe.

## Main flows

**Place tower:** click → `GameManager._handle_click` → `Economy.spend` → instantiate `Tower` → `Grid.occupy` → `tower_placed`.

**Merge:** click tower A, click adjacent tower B → `merge_requested(A, B)` → `MergeManager` checks adjacency and recipe → frees both, spawns result → `merge_completed`.

**Wave:** `Spawner.start_next_wave` → spawns zombies on a timer → zombies killed (`zombie_killed` → Edges) or reach the Core (`zombie_reached_core` → Core health) → `wave_cleared` → next wave, or `level_won` after the last.

## Data files

| File | Keyed by | Used by |
|---|---|---|
| `shapes.json` | shape id (towers, base and merged) | `Tower.setup`, HUD |
| `merges.json` | list of `{inputs, result}` | `GameData.find_merge_result` |
| `zombies.json` | zombie id | `Zombie.setup` |
| `waves.json` | list of waves, each with groups `{zombie, count, interval}` | `WaveSpawner` |

## Known gaps in the skeleton

- Tower specials (splash, pierce, buffs, rolling) and zombie specials (slime, split) are TODOs.
- Infection system is an empty skeleton.
- Win/lose scene does not yet know which result happened.
- The Path2D curve and `Grid.path_cells` are separate; if you edit one, edit the other.
