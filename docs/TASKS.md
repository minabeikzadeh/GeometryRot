# Task list by member

Matches the plan in the Initial Plan doc (10-week quarter). Weeks are suggestions; adjust at your first team meeting.

## First 30 minutes (everyone)

1. Clone the repo, open in Godot 4.3+, press F5, and fix any parse errors in the Output panel. Tell the group what you fixed.
2. Check that the menu opens, Play loads the level, the grid shows, and you can place a Triangle.
3. Read `docs/ARCHITECTURE.md`.

## Member 1: Gameplay Programmer (Merge System), subrole systems/data

Owns: `scripts/systems/merge_manager.gd`, `scripts/towers/tower.gd`, `data/shapes.json`, `data/merges.json`

- [ ] Week 1-2: Confirm tower stats load and each base shape fires correctly (Triangle, Square, Circle).
- [ ] Week 3-4: Implement tower specials in `tower.gd`: `splash`, `pierce`, `buff_adjacent`.
- [ ] Week 5-6: **Merge system.** Highlight valid merges, add a merge preview, handle all 5 recipes, support buff recalculation after merges.
- [ ] Week 6: Hybrid recipe `spike_ball` (rolls along the path).
- [ ] Week 7-8: Balance pass on tower stats and costs with Member 2.

## Member 2: Gameplay Programmer (Enemies), subrole AI/pathing

Owns: `scripts/zombies/zombie.gd`, `scripts/systems/wave_spawner.gd`, `scripts/systems/infection_system.gd`, `data/zombies.json`, `data/waves.json`

- [ ] Week 1-3: Verify path following and spawning; add a health bar or damage flash.
- [ ] Week 3-4: Wave flow: delay between waves, wave clear detection, edge cases (zombie killed by splash while spawning).
- [ ] Week 4-5: Zombie specials: `slime_trail`, `ignore_slow`, `split_on_death`, speed multiplier hook for slow effects.
- [ ] Week 7: **Infection system** (steps are in the TODO inside `infection_system.gd`). Cut first if the schedule slips.
- [ ] Week 7-8: Write 3 levels' worth of waves in `waves.json`.

## Member 3: Gameplay Programmer (Core Systems), subrole UI/UX

Owns: `scripts/core/game_manager.gd`, `scripts/grid/grid_manager.gd`, `scripts/systems/economy_manager.gd`, `scripts/ui/*`, `scenes/level.tscn`, `scenes/hud.tscn`, menu scenes

- [ ] Week 1-2: Grid placement polish: hover highlight, invalid cell feedback, sell/remove tower, show Core at the end of the path.
- [ ] Week 3-4: Economy: Core damage scaling by zombie size, edge reward popups, not enough Edges feedback.
- [ ] Week 4: Win/lose screen shows the correct result; retry works.
- [ ] Week 8-9: HUD polish, merge recipe tooltips, pause menu, settings, level select, save progress.
- [ ] Week 8: Second and third level layouts (new `path_cells` and curve).

## Member 4: Producer, subrole game feel / art / audio

Owns: `assets/*`, `README.md`, `docs/*`, build and repo management, playtests

- [ ] Week 1: Set up the Git repo, branch rules, and a shared task board. Run the first team meeting.
- [ ] Week 2-3: Neon glow (WorldEnvironment glow or shader), screen shake, first sound effects (place, hit, kill).
- [ ] Week 5-6: Merge VFX and sound (coordinate with Member 1).
- [ ] Week 7-9: Shatter particles for zombies, music tracks, UI sounds.
- [ ] Week 8: Run an internal playtest; collect notes in `docs/PLAYTEST.md`.
- [ ] Week 9-10: Run outside playtests, track bugs, produce the final build and submission.
