class_name InfectionSystem
extends Node
## Zombies touching towers fill an infection timer. When full, the tower becomes a zombie. OWNER: Member 2.
## SKELETON ONLY: build this in weeks 7 (see docs/TASKS.md). Cut first if schedule slips.

@export var grid: GridManager
@export var touch_distance: float = 36.0


func _process(delta: float) -> void:
	# TODO (Member 2):
	# 1. For each zombie, find towers within touch_distance.
	# 2. Add delta / zombie.stats["infect_time"] to tower.infect_progress (slower if buffed by Pentagon).
	# 3. If progress >= 1.0: remove the tower from the grid, spawn a zombie of the same shape
	#    on the path at the nearest point, emit GameEvents.tower_infected.
	# 4. Decay infect_progress when no zombie is touching.
	pass
