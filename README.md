# Geometry Rot

Shape-based tower defense for ECS 179. Place shapes, merge them into stronger forms, and stop the infected shapes ("the Rot") from reaching the Core.


## Controls (current skeleton)

- **Left click** an empty cell: place the selected shape (pick one from the bottom bar).
- **Left click** a tower, then an adjacent tower: request a merge.
- **Right click**: cancel selection.
- **Start Wave** button: begins wave 1; later waves start automatically.

## Folder layout

| Folder | What lives there |
|---|---|
| `scripts/core` | Autoloads (`GameEvents`, `GameData`), `Shape` base class, `GameManager` |
| `scripts/towers` | `Tower` |
| `scripts/zombies` | `Zombie` |
| `scripts/grid` | `GridManager` |
| `scripts/systems` | `MergeManager`, `WaveSpawner`, `InfectionSystem`, `EconomyManager` |
| `scripts/ui` | HUD, main menu, win/lose |
| `scenes` | `.tscn` files |
| `data` | JSON balance data: shapes, merge recipes, zombies, waves |
| `assets` | Sprites, audio, shaders, effects (empty for now; shapes are drawn in code) |
| `docs` | Task list and architecture notes |

## Ground rules

- **Balance lives in `data/*.json`.** Do not hardcode stats in scripts.
- **Systems talk through `GameEvents` signals**, not direct references, so we can work in parallel without conflicts.
- **One owner per script** (see `docs/TASKS.md`). If you need a change in someone else's file, message them or make a small PR.
- **Git:** one branch per feature, small PRs, merge to `main` only if the project still opens and runs. Do not commit `.godot/`.
- **Scenes cause merge conflicts.** Avoid two people editing the same `.tscn` at once; tell the group before you touch `level.tscn`.
