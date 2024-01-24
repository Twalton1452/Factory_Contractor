extends Node

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		pass # Open inventory/crafting
	if event.is_action_pressed("select"):
		pass # Cast ray at mouse pos
	if event.is_action_pressed("rotate"):
		pass # Rotate target
	if event.is_action_pressed("options"):
		get_tree().quit()

func select() -> void:
	pass
