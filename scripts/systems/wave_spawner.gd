class_name WaveSpawner
extends Node
## Reads data/waves.json and spawns zombies along a Path2D. OWNER: Member 2.

@export var path: Path2D
@export var zombie_scene: PackedScene
@export var time_between_waves: float = 6.0

var current_wave: int = -1
var alive_in_wave: int = 0
var _spawning: bool = false


func _ready() -> void:
	GameEvents.zombie_killed.connect(func(_z, _r): _on_zombie_gone())
	GameEvents.zombie_reached_core.connect(func(_z): _on_zombie_gone())


func start_next_wave() -> void:
	current_wave += 1
	if current_wave >= GameData.waves.size():
		return  # GameManager decides when the level is won
	GameEvents.wave_started.emit(current_wave)
	_run_wave(GameData.waves[current_wave])


func _run_wave(wave: Dictionary) -> void:
	_spawning = true
	for group in wave["groups"]:
		for i in int(group["count"]):
			spawn_zombie(group["zombie"])
			await get_tree().create_timer(float(group["interval"])).timeout
	_spawning = false
	# Every zombie may already be dead by the time spawning ends; the kill handler
	# ignored it while _spawning was true, so check once here.
	if alive_in_wave <= 0:
		GameEvents.wave_cleared.emit(current_wave)


func spawn_zombie(zombie_id: String) -> Zombie:
	var follow := PathFollow2D.new()
	follow.loop = false
	follow.rotates = false
	path.add_child(follow)
	var z: Zombie = zombie_scene.instantiate()
	z.setup(zombie_id)
	z.path_follow = follow
	get_parent().add_child(z)
	z.global_position = follow.global_position
	alive_in_wave += 1
	GameEvents.zombie_spawned.emit(z)
	return z


func _on_zombie_gone() -> void:
	alive_in_wave -= 1
	if alive_in_wave <= 0 and not _spawning:
		GameEvents.wave_cleared.emit(current_wave)
