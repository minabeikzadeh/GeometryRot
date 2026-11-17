class_name MergeManager
extends Node
## Finds valid merges and replaces two towers with the result. OWNER: Member 1.
## Recipes live in data/merges.json (looked up through GameData.find_merge_result).

@export var grid: GridManager
@export var tower_scene: PackedScene


func _ready() -> void:
	GameEvents.merge_requested.connect(_on_merge_requested)


func can_merge(a: Tower, b: Tower) -> bool:
	if a == b:
		return false
	if not _are_adjacent(a, b):
		return false
	return GameData.find_merge_result(a.shape_id, b.shape_id) != ""


func _are_adjacent(a: Tower, b: Tower) -> bool:
	var d := (a.cell - b.cell).abs()
	return d.x + d.y == 1


func _on_merge_requested(a: Node2D, b: Node2D) -> void:
	var ta := a as Tower
	var tb := b as Tower
	if not can_merge(ta, tb):
		GameEvents.merge_failed.emit("These shapes cannot merge.")
		return
	var result_id := GameData.find_merge_result(ta.shape_id, tb.shape_id)
	var target_cell := tb.cell                      # result takes the cell of the second tower
	var combined_health_frac := (ta.health / ta.max_health + tb.health / tb.max_health) / 2.0

	grid.free_cell(ta.cell)
	grid.free_cell(tb.cell)
	ta.queue_free()
	tb.queue_free()

	var merged: Tower = tower_scene.instantiate()
	merged.setup(result_id)
	merged.cell = target_cell
	merged.health = merged.max_health * combined_health_frac
	grid.add_child(merged)
	merged.global_position = grid.cell_to_world(target_cell)
	grid.occupy(target_cell, merged)
	GameEvents.merge_completed.emit(merged)
	# TODO (Member 1): merge VFX hook, support-buff recalculation for neighbors.
