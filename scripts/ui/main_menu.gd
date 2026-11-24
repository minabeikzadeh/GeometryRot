extends Control
## OWNER: Member 3.


func _ready() -> void:
	$VBox/PlayButton.pressed.connect(
		func(): get_tree().change_scene_to_file("res://scenes/level.tscn")
	)
	$VBox/QuitButton.pressed.connect(func(): get_tree().quit())
