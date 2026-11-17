extends Control
## OWNER: Member 3. Shows the result and lets the player retry or go back to the menu.


func _ready() -> void:
	# TODO: show "Core saved!" or "The Rot won" depending on the result.
	$VBox/RetryButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/level.tscn"))
	$VBox/MenuButton.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))
