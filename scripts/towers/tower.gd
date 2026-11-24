class_name Tower
extends Shape
## OWNER: Member 1 and Member 3.

const SHOT_DURATION := 0.12

var shape_id: String = ""
var stats: Dictionary = {}
var cell: Vector2i = Vector2i.ZERO
var fire_cooldown: float = 0.0
var buff_multiplier: float = 1.0  # set by Pentagon/Hexagon support (TODO Member 1)
var infect_progress: float = 0.0  # filled by InfectionSystem (Member 2)
var selected: bool = false

var _shot_pos: Vector2 = Vector2.ZERO
var _shot_time: float = 0.0


func setup(id: String) -> void:
	shape_id = id
	stats = GameData.shapes[id]
	radius = 13.0
	sides = stats["sides"]
	shape_color = Color(stats["color"])
	max_health = stats["health"]
	health = max_health
	queue_redraw()


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


## Quick scale bounce, used when a tower is placed or created by a merge.
func pop() -> void:
	scale = Vector2(1.6, 1.6)
	(
		create_tween()
		. tween_property(self, "scale", Vector2.ONE, 0.25)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)


func _process(delta: float) -> void:
	if _shot_time > 0.0:
		_shot_time -= delta
		queue_redraw()
	if stats.get("fire_rate", 0.0) <= 0.0:
		return
	fire_cooldown -= delta
	if fire_cooldown > 0.0:
		return
	var target := _find_target()
	if target:
		_attack(target)
		fire_cooldown = 1.0 / (float(stats["fire_rate"]) * buff_multiplier)


func _find_target() -> Shape:
	var best: Shape = null
	var best_dist: float = float(stats["range"])
	for z in get_tree().get_nodes_in_group("zombies"):
		var d := global_position.distance_to(z.global_position)
		if d <= best_dist:
			best_dist = d
			best = z
	return best


## TODO (Member 1): handle special behaviors from stats["special"]:
## pierce, splash, splash_slow, buff_adjacent, buff_and_repair, rolls_path.
func _attack(target: Shape) -> void:
	_shot_pos = target.global_position
	_shot_time = SHOT_DURATION
	queue_redraw()
	target.take_damage(float(stats["damage"]) * buff_multiplier)


func _draw() -> void:
	super._draw()
	if selected:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 40, Color.WHITE, 2.0, true)
	if _shot_time > 0.0:
		var a: float = _shot_time / SHOT_DURATION
		var end: Vector2 = to_local(_shot_pos)
		draw_line(Vector2.ZERO, end, Color(shape_color, a), 3.0, true)
		draw_circle(end, 2.0 + 5.0 * a, Color(1, 1, 1, a))
