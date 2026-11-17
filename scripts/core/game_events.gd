extends Node
## Global signal bus (autoload: GameEvents).
## Systems talk through these signals instead of holding references to each other.
## If you add a signal, add one line to docs/ARCHITECTURE.md so teammates know about it.

# --- Economy / core (Member 3) ---
signal edges_changed(new_amount: int)
signal core_health_changed(new_health: int)
signal level_won
signal level_lost

# --- Placement (Member 3) ---
signal tower_placed(tower: Node2D, cell: Vector2i)
signal tower_removed(tower: Node2D, cell: Vector2i)
signal tower_selected(tower: Node2D)

# --- Merge (Member 1) ---
signal merge_requested(tower_a: Node2D, tower_b: Node2D)
signal merge_completed(result_tower: Node2D)
signal merge_failed(reason: String)

# --- Zombies / waves / infection (Member 2) ---
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal zombie_spawned(zombie: Node2D)
signal zombie_killed(zombie: Node2D, edge_reward: int)
signal zombie_reached_core(zombie: Node2D)
signal tower_infected(tower: Node2D)
