extends Node

func _unhandled_input(event):
	if event.is_action_pressed("select"):
		select()
	if event.is_action_pressed("cancel"):
		cancel()
	if event.is_action_pressed("options"):
		get_tree().quit()
	if event.is_action_pressed("rotate"):
		rotate()
	
	if event.is_action_pressed("menu"):
		pass # Open inventory/crafting

func select() -> void:
	MessageBus.player_selected.emit()

func cancel() -> void:
	MessageBus.player_canceled.emit()

func rotate() -> void:
	MessageBus.player_rotated.emit()
