class_name Tower
extends Shape
## Player-owned shape. Stats come from data/shapes.json via setup(shape_id).
## OWNER: Member 1 (stats/merge behavior) and Member 3 (placement integration).

var shape_id: String = ""
var stats: Dictionary = {}
var cell: Vector2i = Vector2i.ZERO
var fire_cooldown: float = 0.0
var buff_multiplier: float = 1.0   # set by Pentagon/Hexagon support (TODO Member 1)
var infect_progress: float = 0.0   # filled by InfectionSystem (Member 2)


func setup(id: String) -> void:
	shape_id = id
	stats = GameData.shapes[id]
	sides = stats["sides"]
	shape_color = Color(stats["color"])
	max_health = stats["health"]
	health = max_health
	queue_redraw()


func _process(delta: float) -> void:
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
	target.take_damage(float(stats["damage"]) * buff_multiplier)
