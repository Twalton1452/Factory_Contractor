extends Node

var selecting = false
var canceling = false
var picking_up = false

func _unhandled_input(event):
	if event.is_action_pressed("navigate_left"):
		navigate_left()
	if event.is_action_pressed("navigate_right"):
		navigate_right()
	if event.is_action_pressed("navigate_up"):
		navigate_up()
	if event.is_action_pressed("navigate_down"):
		navigate_down()
	
	if event.is_action_released("select"):
		stop_select()
	elif event.is_action_pressed("select"):
		select()
	
	if event.is_action_released("cancel"):
		stop_cancel()
	elif event.is_action_pressed("cancel"):
		cancel()
	
	if event.is_action_pressed("options"):
		get_tree().quit()
	
	if event.is_action_pressed("rotate"):
		rotate()
	
	if event.is_action_pressed("picker"):
		picker()
	
	if event.is_action_released("pickup"):
		stop_pickup()
	elif event.is_action_pressed("pickup"):
		pickup()
	
	if event.is_action_pressed("contracts"):
		contracts()
	
	if event.is_action_pressed("menu"):
		pass # Open inventory/crafting

func select() -> void:
	if selecting:
		return
	
	selecting = true
	while selecting:
		MessageBus.player_selecting.emit()
		await get_tree().physics_frame

func stop_select() -> void:
	selecting = false
	MessageBus.player_released_select.emit()

func cancel() -> void:
	if canceling:
		return
	
	canceling = true
	while canceling:
		MessageBus.player_canceling.emit()
		await get_tree().physics_frame

func stop_cancel() -> void:
	canceling = false
	MessageBus.player_released_cancel.emit()

func rotate() -> void:
	MessageBus.player_rotated.emit()

func picker() -> void:
	MessageBus.player_picked.emit()

func pickup() -> void:
	if picking_up:
		return
	
	picking_up = true
	while picking_up:
		MessageBus.player_picking_up.emit()
		await get_tree().physics_frame

func stop_pickup() -> void:
	picking_up = false
	MessageBus.player_released_picking_up.emit()

func contracts() -> void:
	MessageBus.player_contract_toggle.emit()

func navigate_left() -> void:
	MessageBus.player_navigated_left.emit()

func navigate_right() -> void:
	MessageBus.player_navigated_right.emit()

func navigate_up() -> void:
	MessageBus.player_navigated_up.emit()

func navigate_down() -> void:
	MessageBus.player_navigated_down.emit()
