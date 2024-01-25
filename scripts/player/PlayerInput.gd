extends Node

func _unhandled_input(event):
	if event.is_action_pressed("menu"):
		pass # Open inventory/crafting
	if event.is_action_pressed("select"):
		select()
	if event.is_action_pressed("cancel"):
		cancel()
	if event.is_action_pressed("rotate"):
		pass # Rotate target
	if event.is_action_pressed("options"):
		get_tree().quit()

func select() -> void:
	MessageBus.player_selected.emit()

func cancel() -> void:
	MessageBus.player_canceled.emit()
