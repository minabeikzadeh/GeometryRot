class_name Shape
extends Node2D
## Base class for everything that is a shape (towers and zombies).
## Draws itself as a regular polygon with a neon outline, so no sprite art is needed.

signal died(shape: Shape)

var max_health: float = 1.0
var health: float = 1.0
var sides: int = 3
var shape_color: Color = Color.WHITE
var radius: float = 20.0
var is_zombie: bool = false


func take_damage(amount: float) -> void:
	health -= amount
	queue_redraw()
	if health <= 0.0:
		died.emit(self)
		_on_death()


func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	queue_redraw()


func _on_death() -> void:
	queue_free()


func _draw() -> void:
	var pts := PackedVector2Array()
	for i in sides:
		var a := TAU * float(i) / float(sides) - PI / 2.0
		pts.append(Vector2(cos(a), sin(a)) * radius)
	# Fill gets darker as health drops.
	var health_frac: float = clampf(health / max_health, 0.0, 1.0)
	var fill := shape_color.darkened(0.7)
	fill.a = lerpf(0.25, 0.8, health_frac)
	draw_colored_polygon(pts, fill)
	var closed := pts.duplicate()
	closed.append(pts[0])
	draw_polyline(closed, shape_color, 2.5, true)
