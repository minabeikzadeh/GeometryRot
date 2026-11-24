extends Control
## OWNER: Member 3. Shows the result and lets the player retry or go back to the menu.


func _ready() -> void:
	var won: bool = GameData.last_result == "won"
	var title: Label = $VBox/Title
	title.text = "CORE SAVED" if won else "THE ROT WON"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#7df9ff") if won else Color("#ff3b4f"))
	$VBox/RetryButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://scenes/level.tscn")
	)
	$VBox/MenuButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)
