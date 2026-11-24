# Issues to create on GitHub

Create each one under **Issues, New issue**, then assign it to the teammate who takes it. Copy the title and body as written.

---

## 1. Infection system
**Body:** Towers touched by zombies should turn into zombies. See the TODO steps in `scripts/systems/infection_system.gd`. Use `infect_time` from `data/zombies.json`. Emit `GameEvents.tower_infected`. Pentagon-buffed neighbors infect more slowly.
**Done when:** a tower left next to a zombie flips to a zombie that walks the path, and killing it works like any other zombie.
**Files:** `scripts/systems/infection_system.gd`, `scripts/zombies/zombie.gd`

## 2. Zombie specials: slime trail and splitting
**Body:** Melting Circle leaves a slime trail that slows nearby towers' fire rate. Hexagon Host splits into `split_count` of `split_into` when killed (see `data/zombies.json` and the TODO in `zombie.gd`).
**Done when:** both behaviors are visible in a playthrough and use the JSON values.
**Files:** `scripts/zombies/zombie.gd`, `data/zombies.json`

## 3. Tower specials: splash, pierce, buffs
**Body:** Implement `splash`, `splash_slow`, `pierce`, `buff_adjacent`, and `buff_and_repair` in `scripts/towers/tower.gd` using `stats["special"]`. Buffs set `buff_multiplier` on neighbors; recalc after a merge or sale.
**Done when:** Circle hits several zombies, Diamond pierces a line, Pentagon visibly raises neighbors' fire rate.
**Files:** `scripts/towers/tower.gd`, `data/shapes.json`

## 4. Spike Ball (Triangle + Circle hybrid)
**Body:** The Spike Ball does not shoot. It rolls along the path damaging everything it touches. Needs a path-following tower variant.
**Done when:** merging Triangle + Circle produces a Spike Ball that rolls and damages zombies.
**Files:** `scripts/towers/`, `scripts/systems/merge_manager.gd`

## 5. Sound effects
**Body:** Add sounds for place, shoot, kill, merge, Core hit, and win/lose. Put files in `assets/audio/`. Keep sounds short and quiet by default.
**Done when:** each event above plays a sound, hooked through `GameEvents` signals.

## 6. Music and menu polish
**Body:** Looping synthwave track, volume setting in a simple settings menu, and a pause menu (Esc).
**Done when:** music plays in the level, Esc pauses, and the volume slider works.

## 7. Neon look and kill effects
**Body:** Add glow (WorldEnvironment glow or a shader) and shatter particles when a zombie dies. Hook into `GameEvents.zombie_killed`.
**Done when:** zombies burst into shards when killed and the screen has a soft glow.

## 8. Levels 2 and 3 plus tutorial
**Body:** Two new layouts (new `Path2D` curve and `path_cells`) with their own wave data, and a short tutorial level teaching place, merge, and infection. Coordinate with the team before editing `scenes/level.tscn`.
**Done when:** the menu lets you pick a level, and each is winnable.
