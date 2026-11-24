class_name CoreTarget
extends Node2D
## The thing the player is defending. Drawn in code: a spinning octagon with a health ring.
## Flashes when a zombie reaches it and shifts from cyan to red as health drops.
## OWNER: Member 3 (art polish: Member 4).

const BASE_COLOR := Color("#7df9ff")
const DANGER_COLOR := Color("#ff3b4f")

@export var radius: float = 30.0

var max_health: int = 1
var health: int = 1
var _time: float = 0.0
var _flash: float = 0.0


func _ready() -> void:
	add_to_group("core")
	GameEvents.core_health_changed.connect(_on_health_changed)
	GameEvents.zombie_reached_core.connect(func(_z): _flash = 1.0)


func _on_health_changed(value: int) -> void:
	max_health = maxi(max_health, value)  # first value we hear is the full health
	health = value


func _process(delta: float) -> void:
	_time += delta
	_flash = maxf(0.0, _flash - delta * 3.0)
	queue_redraw()


func _draw() -> void:
	var frac := clampf(float(health) / float(max_health), 0.0, 1.0)
	var col := DANGER_COLOR.lerp(BASE_COLOR, frac).lerp(Color.WHITE, _flash)
	var pulse := 1.0 + 0.05 * sin(_time * 3.0)

	# Soft glow rings
	for i in 3:
		var a := 0.14 - 0.04 * float(i)
		draw_arc(
			Vector2.ZERO,
			radius * pulse + 8.0 + 6.0 * float(i),
			0.0,
			TAU,
			48,
			Color(col.r, col.g, col.b, a),
			4.0
		)

	# Health ring: full circle = full health
	var ring_r := radius + 14.0
	draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 64, Color(1, 1, 1, 0.12), 4.0)
	if frac > 0.0:
		draw_arc(Vector2.ZERO, ring_r, -PI / 2.0, -PI / 2.0 + TAU * frac, 64, col, 4.0, true)

	# Outer octagon (spins slowly)
	var outer := _polygon(8, radius * pulse, _time * 0.4)
	draw_colored_polygon(outer, Color(col.r, col.g, col.b, 0.22))
	outer.append(outer[0])
	draw_polyline(outer, col, 3.0, true)

	# Inner square (spins the other way)
	var inner := _polygon(4, radius * 0.5, -_time * 0.8)
	draw_colored_polygon(inner, Color(col.r, col.g, col.b, 0.6))


func _polygon(sides: int, r: float, rot: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in sides:
		var a := TAU * float(i) / float(sides) + rot
		pts.append(Vector2(cos(a), sin(a)) * r)
	return pts
