extends CanvasLayer
## Edges, Core health, wave counter, and shape picker. OWNER: Member 3.

@export var game_manager: GameManager

@onready var edges_label: Label = $Root/TopBar/EdgesLabel
@onready var core_label: Label = $Root/TopBar/CoreLabel
@onready var wave_label: Label = $Root/TopBar/WaveLabel
@onready var shape_buttons: HBoxContainer = $Root/ShapeBar


func _ready() -> void:
	GameEvents.edges_changed.connect(func(v): edges_label.text = "Edges: %d" % v)
	GameEvents.core_health_changed.connect(func(v): core_label.text = "Core: %d" % v)
	GameEvents.wave_started.connect(func(i): wave_label.text = "Wave %d / %d" % [i + 1, GameData.waves.size()])
	for id in ["triangle", "square", "circle", "pentagon"]:
		var b := Button.new()
		b.text = "%s (%d)" % [GameData.shapes[id]["name"], GameData.shapes[id]["cost"]]
		b.pressed.connect(func(): game_manager.selected_shape_id = id)
		shape_buttons.add_child(b)
	$Root/StartWaveButton.pressed.connect(func():
		game_manager.start_first_wave()
		$Root/StartWaveButton.hide())
