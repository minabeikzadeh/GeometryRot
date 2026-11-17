class_name EconomyManager
extends Node
## Edges (currency) and Core health. OWNER: Member 3.

@export var starting_edges: int = 150
@export var core_max_health: int = 20

var edges: int = 0
var core_health: int = 0


func _ready() -> void:
	edges = starting_edges
	core_health = core_max_health
	GameEvents.zombie_killed.connect(_on_zombie_killed)
	GameEvents.zombie_reached_core.connect(_on_zombie_reached_core)
	_emit_initial_values.call_deferred()


func _emit_initial_values() -> void:
	GameEvents.edges_changed.emit(edges)
	GameEvents.core_health_changed.emit(core_health)


func can_afford(cost: int) -> bool:
	return edges >= cost


func spend(cost: int) -> bool:
	if not can_afford(cost):
		return false
	edges -= cost
	GameEvents.edges_changed.emit(edges)
	return true


func add_edges(amount: int) -> void:
	edges += amount
	GameEvents.edges_changed.emit(edges)


func _on_zombie_killed(_zombie: Node2D, reward: int) -> void:
	add_edges(reward)


func _on_zombie_reached_core(_zombie: Node2D) -> void:
	core_health -= 1   # TODO: scale by zombie size
	GameEvents.core_health_changed.emit(core_health)
	if core_health <= 0:
		GameEvents.level_lost.emit()
