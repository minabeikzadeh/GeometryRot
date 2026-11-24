class_name GameManager
extends Node2D
## owns the level state and ties systems together. OWNER: Member 3.

enum State { PLAYING, WON, LOST }

@export var grid: GridManager
@export var economy: EconomyManager
@export var spawner: WaveSpawner
@export var tower_scene: PackedScene
@export var end_screen_delay: float = 1.2

var state: State = State.PLAYING
var selected_shape_id: String = "triangle" 
var selected_tower: Tower = null  # first tower clicked for a merge


func _ready() -> void:
	GameEvents.level_lost.connect(func(): _end(State.LOST))
	GameEvents.wave_cleared.connect(_on_wave_cleared)


func _process(_delta: float) -> void:
	grid.preview_range = float(GameData.shapes[selected_shape_id]["range"])


func _unhandled_input(event: InputEvent) -> void:
	if state != State.PLAYING:
		return
	if event.is_action_pressed("place_tower"):
		_handle_click(get_global_mouse_position())
	elif event.is_action_pressed("cancel"):
		_clear_selection()


func _handle_click(world_pos: Vector2) -> void:
	var cell := grid.world_to_cell(world_pos)
	if not grid.in_bounds(cell):
		return
	if grid.occupied.has(cell):
		_handle_tower_click(grid.occupied[cell])
	elif grid.can_place(cell):
		_clear_selection()
		place_tower(selected_shape_id, cell)
	else:
		GameEvents.placement_failed.emit("Can't build on the path")


func place_tower(shape_id: String, cell: Vector2i) -> Tower:
	var cost: int = int(GameData.shapes[shape_id]["cost"])
	if not economy.spend(cost):
		GameEvents.placement_failed.emit("Not enough Edges (need %d)" % cost)
		return null
	var t: Tower = tower_scene.instantiate()
	t.setup(shape_id)
	t.cell = cell
	grid.add_child(t)
	t.global_position = grid.cell_to_world(cell)
	t.pop()
	grid.occupy(cell, t)
	GameEvents.tower_placed.emit(t, cell)
	return t


## Click one tower, then click an adjacent one to request a merge.
## Click the same tower again to cancel.
func _handle_tower_click(t: Tower) -> void:
	if not is_instance_valid(selected_tower):
		selected_tower = t
		t.set_selected(true)
		GameEvents.tower_selected.emit(t)
	elif selected_tower == t:
		_clear_selection()
	else:
		var first := selected_tower
		_clear_selection()
		GameEvents.merge_requested.emit(first, t)


func _clear_selection() -> void:
	if is_instance_valid(selected_tower):
		selected_tower.set_selected(false)
	selected_tower = null


func start_first_wave() -> void:
	spawner.start_next_wave()


func _on_wave_cleared(wave_index: int) -> void:
	if state != State.PLAYING:
		return
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
	_clear_selection()
	if new_state == State.WON:
		GameData.last_result = "won"
		GameEvents.level_won.emit()
	else:
		GameData.last_result = "lost"
	await get_tree().create_timer(end_screen_delay).timeout
	get_tree().change_scene_to_file("res://scenes/win_lose.tscn")
