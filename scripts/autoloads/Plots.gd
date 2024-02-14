extends Node

## Autoloaded

## Class to handle moving and managing different Plots the player will use

signal moved_to_plot(plot: Plot)

## increments of 1, to get real position, multiply by plot_size or get camera position
var current_location : Vector2 = Vector2.ZERO
var plot_size : Vector2
var camera : Camera2D
var plots : Dictionary = {} # { key: Vector2, val: Plot }

func _ready() -> void:
	Contracts.accepted_contract.connect(_on_accepted_contract)
	plot_size = get_viewport().get_visible_rect().size
	camera = get_viewport().get_camera_2d()
	
	MessageBus.player_navigated_left.connect(go_left)
	MessageBus.player_navigated_right.connect(go_right)
	MessageBus.player_navigated_up.connect(go_up)
	MessageBus.player_navigated_down.connect(go_down)
	var home = get_node("/root/Main/Home")
	plots[Vector2.ZERO] = home
	go_to(Vector2.ZERO)

func _on_accepted_contract(contract: Contract) -> void:
	if contract.contract_type == Contract.Type.ON_SITE:
		spawn(contract)
	else:
		pass # Get current location and assign contract to it

func spawn(contract: Contract) -> Plot:
	var plot = plots.get(current_location)
	if plot == null:
		var new_plot = Plot.new()
		new_plot.position = current_location * plot_size
		new_plot.display_name = contract.display_name
		plot = new_plot
	
	return plot

func get_plot(location: Vector2) -> Plot:
	return plots.get(location)

func go_to(destination: Vector2) -> void:
	current_location = destination
	moved_to_plot.emit(current_location)
	center_camera_on_current_location()

func center_camera_on_current_location() -> void:
	camera.position = current_location * plot_size

func go_left() -> void:
	go_to(Vector2(current_location.x - 1, current_location.y))

func go_right() -> void:
	go_to(Vector2(current_location.x + 1, current_location.y))

func go_up() -> void:
	go_to(Vector2(current_location.x, current_location.y - 1))

func go_down() -> void:
	go_to(Vector2(current_location.x, current_location.y + 1))
