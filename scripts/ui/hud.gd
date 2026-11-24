extends CanvasLayer
## Edges, Core health, wave counter, shape picker, and short messages. OWNER: Member 3.

@export var game_manager: GameManager

var _toast_tween: Tween

@onready var edges_label: Label = $Root/TopBar/EdgesLabel
@onready var core_label: Label = $Root/TopBar/CoreLabel
@onready var wave_label: Label = $Root/TopBar/WaveLabel
@onready var shape_buttons: HBoxContainer = $Root/ShapeBar
@onready var toast: Label = $Root/Toast


func _ready() -> void:
	GameEvents.edges_changed.connect(func(v): edges_label.text = "Edges: %d" % v)
	GameEvents.core_health_changed.connect(func(v): core_label.text = "Core: %d" % v)
	GameEvents.wave_started.connect(
		func(i): wave_label.text = "Wave %d / %d" % [i + 1, GameData.waves.size()]
	)
	GameEvents.placement_failed.connect(func(msg): show_toast(msg, Color("#ff6b6b")))
	GameEvents.merge_failed.connect(func(msg): show_toast(msg, Color("#ff6b6b")))
	GameEvents.merge_completed.connect(
		func(t): show_toast("Merged into %s!" % t.stats["name"], Color("#7dff9a"))
	)
	GameEvents.tower_selected.connect(
		func(_t): show_toast("Now click an adjacent shape to merge", Color("#cfd8ff"))
	)

	var group := ButtonGroup.new()
	for id in ["triangle", "square", "circle", "pentagon"]:
		var b := Button.new()
		b.text = "%s (%d)" % [GameData.shapes[id]["name"], GameData.shapes[id]["cost"]]
		b.toggle_mode = true
		b.button_group = group
		b.button_pressed = (id == game_manager.selected_shape_id)
		b.pressed.connect(func(): game_manager.selected_shape_id = id)
		shape_buttons.add_child(b)
	$Root/StartWaveButton.pressed.connect(
		func():
			game_manager.start_first_wave()
			$Root/StartWaveButton.hide()
	)


func show_toast(text: String, color: Color = Color.WHITE) -> void:
	toast.text = text
	toast.add_theme_color_override("font_color", color)
	if _toast_tween:
		_toast_tween.kill()
	toast.modulate.a = 1.0
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.4)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.5)
