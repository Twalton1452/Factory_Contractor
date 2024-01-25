extends Node

var selecting = false
var canceling = false

func _unhandled_input(event):
	if event.is_action_released("select"):
		stop_select()
	if event.is_action_pressed("select"):
		select()
	
	if event.is_action_released("cancel"):
		stop_cancel()
	if event.is_action_pressed("cancel"):
		cancel()
	
	if event.is_action_pressed("options"):
		get_tree().quit()
	if event.is_action_pressed("rotate"):
		rotate()
	
	if event.is_action_pressed("menu"):
		pass # Open inventory/crafting

func select() -> void:
	if selecting:
		return
	
	selecting = true
	while selecting:
		MessageBus.player_selected.emit()
		await get_tree().physics_frame

func stop_select() -> void:
	selecting = false

func cancel() -> void:
	if canceling:
		return
	
	canceling = true
	while canceling:
		MessageBus.player_canceled.emit()
		await get_tree().physics_frame

func stop_cancel() -> void:
	canceling = false

func rotate() -> void:
	MessageBus.player_rotated.emit()
