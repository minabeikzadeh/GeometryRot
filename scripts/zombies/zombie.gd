class_name Zombie
extends Shape
## Infected shape. Follows a Path2D toward the Core.
## OWNER: Member 2.

var zombie_id: String = ""
var stats: Dictionary = {}
var path_follow: PathFollow2D = null   # set by WaveSpawner when spawned
var speed_multiplier: float = 1.0      # slowed by Oval, slime, etc.


func _ready() -> void:
	is_zombie = true
	add_to_group("zombies")


func setup(id: String) -> void:
	zombie_id = id
	stats = GameData.zombies[id]
	sides = stats["sides"]
	shape_color = Color(stats["color"])
	max_health = stats["health"]
	health = max_health
	queue_redraw()


func _process(delta: float) -> void:
	if path_follow == null:
		return
	path_follow.progress += float(stats["speed"]) * speed_multiplier * delta
	global_position = path_follow.global_position
	if path_follow.progress_ratio >= 1.0:
		GameEvents.zombie_reached_core.emit(self)
		_cleanup()


func _on_death() -> void:
	GameEvents.zombie_killed.emit(self, int(stats["reward"]))
	# TODO (Member 2): if stats["special"] == "split_on_death", spawn split_into x split_count.
	_cleanup()


func _cleanup() -> void:
	if path_follow:
		path_follow.queue_free()
	queue_free()
