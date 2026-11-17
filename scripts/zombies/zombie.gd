class_name Zombie
extends Shape
## Infected shape. Follows a Path2D toward the Core.
## Looks like a decayed version of its shape: dented edges, spikes or drips, cracks, wobble, glitch flicker.
## OWNER: Member 2.

const CRACK_GLOW := Color("#a6ff3a")
const GLITCH_COLOR := Color("#ff3bd4")

var zombie_id: String = ""
var stats: Dictionary = {}
var path_follow: PathFollow2D = null   # set by WaveSpawner when spawned
var speed_multiplier: float = 1.0      # slowed by Oval, slime, etc.

# Visual deformation (random per zombie, so no two look the same)
var _vert_scale := PackedFloat32Array()
var _vert_angle := PackedFloat32Array()
var _crack_idx: Array[int] = []
var _time: float = 0.0
var _glitch: float = 0.0


func _ready() -> void:
	is_zombie = true
	add_to_group("zombies")
	_time = randf() * 10.0


func setup(id: String) -> void:
	zombie_id = id
	stats = GameData.zombies[id]
	sides = stats["sides"]
	shape_color = Color(stats["color"])
	max_health = stats["health"]
	health = max_health
	_build_deformation()
	queue_redraw()


## Builds a damaged outline: twice as many points as sides, so edges can dent inward.
func _build_deformation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_vert_scale.clear()
	_vert_angle.clear()
	_crack_idx.clear()
	var round_shape: bool = sides > 8
	var n: int = 16 if round_shape else sides * 2
	for i in n:
		var corner: bool = round_shape or i % 2 == 0
		var s: float
		match zombie_id:
			"jagged_triangle":
				# long spikes at the corners, deep notches between them
				s = rng.randf_range(1.15, 1.45) if corner else rng.randf_range(0.35, 0.6)
			"melting_circle":
				s = rng.randf_range(0.8, 1.05)
				var a := TAU * float(i) / float(n) - PI / 2.0
				if sin(a) > 0.3:
					s *= rng.randf_range(1.15, 1.55)   # drips hang off the bottom
			_:
				# cracked square, hexagon host: lumpy and dented
				s = rng.randf_range(0.85, 1.15) if corner else rng.randf_range(0.55, 0.95)
		_vert_scale.append(s)
		_vert_angle.append(rng.randf_range(-0.1, 0.1))
	for i in 3:
		_crack_idx.append(rng.randi_range(0, n - 1))


func _process(delta: float) -> void:
	_time += delta
	_glitch = maxf(0.0, _glitch - delta)
	if randf() < delta * 0.4:
		_glitch = 0.12
	queue_redraw()

	if path_follow == null:
		return
	path_follow.progress += float(stats["speed"]) * speed_multiplier * delta
	global_position = path_follow.global_position
	if path_follow.progress_ratio >= 1.0:
		GameEvents.zombie_reached_core.emit(self)
		_cleanup()


func _draw() -> void:
	var n := _vert_scale.size()
	if n == 0:
		return
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n) - PI / 2.0 + _vert_angle[i]
		var wobble := 1.0 + 0.04 * sin(_time * 6.0 + float(i) * 1.7)
		pts.append(Vector2(cos(a), sin(a)) * radius * _vert_scale[i] * wobble)

	var frac: float = clampf(health / max_health, 0.0, 1.0)
	var fill := shape_color.darkened(0.6)
	fill.a = lerpf(0.3, 0.85, frac)
	draw_colored_polygon(pts, fill)

	var outline := pts.duplicate()
	outline.append(pts[0])
	draw_polyline(outline, shape_color.lightened(0.25), 2.5, true)

	# Cracks: dark line with a thin toxic-green glow beside it
	for idx in _crack_idx:
		var tip: Vector2 = pts[idx]
		draw_line(tip * 0.15, tip * 0.85, Color(0, 0, 0, 0.8), 2.0)
		draw_line(tip * 0.15 + Vector2(1, 1), tip * 0.85 + Vector2(1, 1), Color(CRACK_GLOW, 0.6), 1.0)

	# Occasional glitch flicker: offset magenta copy of the outline
	if _glitch > 0.0:
		var off := Vector2(randf_range(-3.0, 3.0), randf_range(-2.0, 2.0))
		var ghost := PackedVector2Array()
		for p in outline:
			ghost.append(p + off)
		draw_polyline(ghost, Color(GLITCH_COLOR, 0.6), 1.5, true)


func _on_death() -> void:
	GameEvents.zombie_killed.emit(self, int(stats["reward"]))
	# TODO (Member 2): if stats["special"] == "split_on_death", spawn split_into x split_count.
	_cleanup()


func _cleanup() -> void:
	if path_follow:
		path_follow.queue_free()
	queue_free()
