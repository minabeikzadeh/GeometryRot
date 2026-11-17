class_name GameManager
extends Node2D
## Level root script: owns the level state and ties systems together. OWNER: Member 3.
## Also owns tower placement and selection for now (PlacementController can be split out later).

enum State { PLAYING, WON, LOST }

@export var grid: GridManager
@export var economy: EconomyManager
@export var spawner: WaveSpawner
@export var tower_scene: PackedScene

var state: State = State.PLAYING
var selected_shape_id: String = "triangle"   # set by the HUD shape buttons
var selected_tower: Tower = null             # first tower clicked for a merge


func _ready() -> void:
	GameEvents.level_lost.connect(func(): _end(State.LOST))
	GameEvents.wave_cleared.connect(_on_wave_cleared)


func _unhandled_input(event: InputEvent) -> void:
	if state != State.PLAYING:
		return
	if event.is_action_pressed("place_tower"):
		_handle_click(get_global_mouse_position())
	elif event.is_action_pressed("cancel"):
		selected_tower = null


func _handle_click(world_pos: Vector2) -> void:
	var cell := grid.world_to_cell(world_pos)
	if grid.occupied.has(cell):
		_handle_tower_click(grid.occupied[cell])
	elif grid.can_place(cell):
		place_tower(selected_shape_id, cell)


func place_tower(shape_id: String, cell: Vector2i) -> Tower:
	var cost: int = int(GameData.shapes[shape_id]["cost"])
	if not economy.spend(cost):
		return null
	var t: Tower = tower_scene.instantiate()
	t.setup(shape_id)
	t.cell = cell
	grid.add_child(t)
	t.global_position = grid.cell_to_world(cell)
	grid.occupy(cell, t)
	GameEvents.tower_placed.emit(t, cell)
	return t


## Click one tower, then click an adjacent one to request a merge.
func _handle_tower_click(t: Tower) -> void:
	if selected_tower == null:
		selected_tower = t
		GameEvents.tower_selected.emit(t)
	else:
		GameEvents.merge_requested.emit(selected_tower, t)
		selected_tower = null


func start_first_wave() -> void:
	spawner.start_next_wave()


func _on_wave_cleared(wave_index: int) -> void:
	if wave_index >= GameData.waves.size() - 1:
		_end(State.WON)
	else:
		await get_tree().create_timer(spawner.time_between_waves).timeout
		if state == State.PLAYING:
			spawner.start_next_wave()


func _end(new_state: State) -> void:
	if state != State.PLAYING:
		return
	state = new_state
	if new_state == State.WON:
		GameEvents.level_won.emit()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/win_lose.tscn")
	# TODO (Member 3): pass WON/LOST to the win_lose scene (e.g. through a static var or autoload).
