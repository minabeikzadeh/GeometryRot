class_name GridManager
extends Node2D
## Tracks which cells are open, occupied, or path. OWNER: Member 3.
## Cells are Vector2i; cell_size is in pixels. The grid is drawn so the layout is visible without art.

@export var cell_size: int = 64
@export var columns: int = 16
@export var rows: int = 9
@export var path_cells: Array[Vector2i] = []   # filled by the level; towers cannot be placed here
@export var core_cells: Array[Vector2i] = []   # cells under the Core; also blocked

var occupied: Dictionary = {}   # Vector2i -> Tower


func world_to_cell(pos: Vector2) -> Vector2i:
	var local := to_local(pos)
	return Vector2i(floori(local.x / cell_size), floori(local.y / cell_size))


func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(Vector2(cell) * cell_size + Vector2(cell_size, cell_size) / 2.0)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < columns and cell.y < rows


func can_place(cell: Vector2i) -> bool:
	return in_bounds(cell) and not occupied.has(cell) and not path_cells.has(cell) and not core_cells.has(cell)


func occupy(cell: Vector2i, tower: Node2D) -> void:
	occupied[cell] = tower


func free_cell(cell: Vector2i) -> void:
	occupied.erase(cell)


## Used by MergeManager: returns the towers in the 4 neighboring cells.
func get_adjacent_towers(cell: Vector2i) -> Array:
	var result: Array = []
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var n: Vector2i = cell + offset
		if occupied.has(n):
			result.append(occupied[n])
	return result


func _draw() -> void:
	var line_color := Color(1, 1, 1, 0.07)
	for x in columns + 1:
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, rows * cell_size), line_color)
	for y in rows + 1:
		draw_line(Vector2(0, y * cell_size), Vector2(columns * cell_size, y * cell_size), line_color)
	for c in path_cells:
		draw_rect(Rect2(Vector2(c) * cell_size, Vector2(cell_size, cell_size)), Color(0.4, 0.1, 0.15, 0.35))
