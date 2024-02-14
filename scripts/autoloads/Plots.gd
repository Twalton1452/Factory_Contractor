extends Node

## Autoloaded

## Class to handle moving and managing different Plots the player will use

signal moved_to_plot(plot: Plot)

var current_location : Vector2 = Vector2.ZERO
var locations : Array[Array] = [[]]
var plot_size : Vector2
var camera : Camera2D

var num_plots_x = 16
var num_plots_y = 16

func _ready() -> void:
	Contracts.accepted_contract.connect(_on_accepted_contract)
	plot_size = get_viewport().get_visible_rect().size
	camera = get_viewport().get_camera_2d()
	setup_plots()
	
	MessageBus.player_navigated_left.connect(go_left)
	MessageBus.player_navigated_right.connect(go_right)
	MessageBus.player_navigated_up.connect(go_up)
	MessageBus.player_navigated_down.connect(go_down)
	go_to(Vector2.ZERO)

func setup_plots() -> void:
	var main_node = get_node("/root/Main")
	
	locations.resize(num_plots_y)
	for y in range(num_plots_y):
		locations[y].resize(num_plots_x)
		
		for x in range(num_plots_x):
			var new_plot = Plot.new()
			new_plot.display_name = str(x) + "," + str(y)
			main_node.add_child(new_plot)
			locations[y][x] = new_plot

func _on_accepted_contract(contract: Contract) -> void:
	if contract.contract_type == Contract.Type.ON_SITE:
		var new_plot = spawn(contract)
		locations.push_back(new_plot)
	else:
		pass # Get current location and assign contract to it

func spawn(contract: Contract) -> Plot:
	var new_plot = Plot.new()
	new_plot.display_name = contract.display_name
	return new_plot

func go_to(destination: Vector2) -> void:
	locations[current_location.y][current_location.x].hide()
	
	current_location = destination
	locations[current_location.y][current_location.x].show()
	moved_to_plot.emit(locations[current_location.y][current_location.x])
	center_camera_on_current_location()

func center_camera_on_current_location() -> void:
	camera.position = current_location * plot_size

func go_left() -> void:
	if current_location.x - 1 >= 0:
		go_to(Vector2(current_location.x - 1, current_location.y))

func go_right() -> void:
	if current_location.x + 1 < num_plots_x:
		go_to(Vector2(current_location.x + 1, current_location.y))

func go_up() -> void:
	if current_location.y - 1 >= 0:
		go_to(Vector2(current_location.x, current_location.y - 1))

func go_down() -> void:
	if current_location.y + 1 < num_plots_y:
		go_to(Vector2(current_location.x, current_location.y + 1))
