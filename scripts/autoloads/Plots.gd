extends Node

## Autoloaded

## Class to handle moving and managing different Plots the player will use

signal moved_to_coordinates(coords: Vector2)

const HOME_COORDINATES = Vector2(0, 0)

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
	var home : Plot = get_node("/root/Main/Home")
	home.player_owned = true
	plots[HOME_COORDINATES] = home
	go_to(HOME_COORDINATES)
	#spawn_neighboring_plots_for(HOME_COORDINATES)

func _on_accepted_contract(contract: Contract) -> void:
	if contract.contract_type == Contract.Type.ON_SITE:
		spawn(contract)
	else:
		pass # Get current location and assign contract to it

## Spawns Plots around a point in 4 directions: left, right, up, down
func spawn_neighboring_plots_for(center: Vector2) -> void:
	var new_neighbor_coords : Array[Vector2] = [
		Vector2(center.x - 1, center.y), # left
		Vector2(center.x + 1, center.y), # right
		Vector2(center.x, center.y - 1), # up
		Vector2(center.x, center.y + 1), # down
	]
	
	for neighbor_coords in new_neighbor_coords:
		if get_plot(neighbor_coords) == null:
			var suitable_contract = Contracts.generate_contract_for_coordinates(neighbor_coords)
			plots[neighbor_coords] = Plot.new(suitable_contract)

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
	spawn_neighboring_plots_for(current_location)
	moved_to_coordinates.emit(current_location)
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
