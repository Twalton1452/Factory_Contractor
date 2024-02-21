extends Node

## Class to handle Player Input

signal exited_build_mode

## Distance in pixels from the avg Placer position
const DETECTED_AXIS_LOCK_AMOUNT = 12.0
const LAST_PLACER_POSITIONS_SIZE = 5

@onready var placer : Node2D = $Placer
@onready var sprite : Sprite2D = $Placer/Sprite2D
@onready var outline : Sprite2D = $Placer/Outline
@onready var shape_cast : ShapeCast2D = $Placer/PlaceShapeCast2D
@onready var required_shape_cast : ShapeCast2D = $Placer/RequiredShapeCast2D
@onready var camera : Camera2D = $"../Camera2D"

var placed_scene : PackedScene = preload("res://scenes/building.tscn")

var current_data : ComponentData = null

## When the player holds Right click and is building something at the same time-
## delete things, but keep what they're building.
## When the player didn't delete something then cancel their build
var deleted_something_during_cancel = false
var last_spawn_position = Vector2(0.1, 0.1)
#region Build Mode Axis Lock
## Sample the last few placement attempt positions to determine if the player
## is trying to build only on 1 axis
var last_placer_positions : Array[Vector2] = []
var last_placer_i = 0
var locked_to_x_axis = false
var locked_to_y_axis = false
var x_axis_lock_pos = 0.0
var y_axis_lock_pos = 0.0
#endregion Build Mode Axis Lock

func _ready():
	MessageBus.build_slot_pressed.connect(_on_build_slot_pressed)
	MessageBus.player_selecting.connect(_on_player_selected)
	MessageBus.player_released_select.connect(_on_player_released_selected)
	MessageBus.player_canceling.connect(_on_player_canceled)
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	MessageBus.player_rotated.connect(_on_player_rotated)
	MessageBus.player_picked.connect(_on_player_picked)
	MessageBus.player_picking_up.connect(_on_player_picking_up)
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	exit_build_mode()
	last_placer_positions.resize(LAST_PLACER_POSITIONS_SIZE)

func _on_moved_to_coordinates(_coords: Vector2) -> void:
	var plot = Plots.get_current_plot()
	if not in_build_mode() or plot.player_owned:
		return
	
	if plot == null or plot.contract == null:
		exit_build_mode()

func in_build_mode() -> bool:
	return current_data != null

func _on_build_slot_pressed(component_data: ComponentData) -> void:
	enter_build_mode_with(component_data)
	sprite.rotation = 0.0

func enter_build_mode_with(component_data: ComponentData) -> void:
	current_data = component_data
	if current_data == null:
		return
	
	sprite.show()
	sprite.texture = component_data.icon
	shape_cast.collision_mask = current_data.placed_layer
	required_shape_cast.collision_mask = current_data.required_layer
	if shape_cast.collision_mask & Constants.UNDERGROUND_LAYER == Constants.UNDERGROUND_LAYER:
		show_range_indicator(Constants.UNDERGROUND_CONVEYOR_MAX_RANGE)
	outline.scale = Vector2(current_data.size, current_data.size)
	match current_data.size:
		1:
			shape_cast.shape = load("res://resources/collision_rect_15.tres")
			required_shape_cast.shape = load("res://resources/collision_rect_15.tres")
		2:
			shape_cast.shape = load("res://resources/collision_rect_30.tres")
			required_shape_cast.shape = load("res://resources/collision_rect_30.tres")
		3:
			shape_cast.shape = load("res://resources/collision_rect_45.tres")
			required_shape_cast.shape = load("res://resources/collision_rect_45.tres")

func show_range_indicator(_max_range: int) -> void:
	# enable a ray cast in 4 directions
	# when the ray finds another of the same building
	# facing the same direction as the player is trying to build
	# highlight it green
	await exited_build_mode
	# hide

func exit_build_mode() -> void:
	sprite.hide()
	sprite.rotation = 0.0
	current_data = null
	shape_cast.collision_mask |= Constants.ASSEMBLER_LAYER
	exited_build_mode.emit()
	last_spawn_position = Vector2(0.1, 0.1)
	outline.scale = Vector2.ONE

## Sample previous mouse positions to determine if the player wants to build only on 1 axis
func detect_axis_lock(attempted_placement_pos: Vector2) -> void:
	if locked_to_x_axis or locked_to_y_axis:
		return
	
	# Hold previous placer positions for axis lock
	last_placer_positions[last_placer_i] = placer.global_position
	last_placer_i = (last_placer_i + 1) % LAST_PLACER_POSITIONS_SIZE
	
	# last position will be null when player stops building
	# this is to make sure we have enough data points to accurately determine the axis-lock
	if last_placer_positions[-1] == null:
		return
	
	var avg_x = 0
	var avg_y = 0
	
	for last_pos in last_placer_positions:
		avg_x += last_pos.x
		avg_y += last_pos.y
	avg_x /= LAST_PLACER_POSITIONS_SIZE
	avg_y /= LAST_PLACER_POSITIONS_SIZE
	
	var x_dist = abs(attempted_placement_pos.x - avg_x)
	var y_dist = abs(attempted_placement_pos.y - avg_y)
	
	if x_dist > DETECTED_AXIS_LOCK_AMOUNT and y_dist > DETECTED_AXIS_LOCK_AMOUNT:
		pass
	elif x_dist > DETECTED_AXIS_LOCK_AMOUNT:
		locked_to_x_axis = true
		y_axis_lock_pos = attempted_placement_pos.y
	elif y_dist > DETECTED_AXIS_LOCK_AMOUNT:
		locked_to_y_axis = true
		x_axis_lock_pos = attempted_placement_pos.x

func _on_player_selected() -> void:
	if not in_build_mode():
		return
	if not Inventory.has(current_data) or not Inventory.how_many(current_data) > 0:
		return
	
	var placer_position = placing_position(placer.position)
	detect_axis_lock(placer_position)
	
	# This wouldn't be an issue if converted to a Grid approach instead of Physics
	# Had overlapping buildings despite the collision checks
	# This checks the last building placed's position, accounting for multiple sizes
	if snapped(placer_position.distance_to(last_spawn_position), 1.0) < (Constants.TILE_SIZE * current_data.size - 1):
		shape_cast.force_shapecast_update()
	
	if shape_cast.is_colliding() or (required_shape_cast.collision_mask > 0 and not required_shape_cast.is_colliding()):
		return
	
	var placed_node : Node2D = placed_scene.instantiate() if current_data.scene_override == null else current_data.scene_override.instantiate()
	if placed_node is Building or placed_node is Component:
		placed_node.data = current_data
	
	var plot : Plot = Plots.get_current_plot()
	plot.add_child(placed_node)
	placed_node.position = placer_position - camera.position
	placed_node.rotation = sprite.rotation
	placed_node.collision_layer = current_data.placed_layer
	last_spawn_position = placed_node.position
	Inventory.subtract(current_data, 1)

func _on_player_released_selected() -> void:
	locked_to_x_axis = false
	locked_to_y_axis = false
	last_placer_i = 0
	last_placer_positions.clear()
	last_placer_positions.resize(LAST_PLACER_POSITIONS_SIZE)
	if in_build_mode():
		return
	
	if shape_cast.is_colliding():
		var colliding = shape_cast.get_collider(0)
		if colliding is Building:
			MessageBus.player_selected_building.emit(colliding)

func _on_player_canceled() -> void:
	# Remove things underneath what we're hovering
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Building and not node.is_queued_for_deletion():
			Inventory.add(node.data)
			node.queue_free()
			deleted_something_during_cancel = true

func _on_player_released_cancel() -> void:
	# Cancel the Build if we aren't hovering anything
	if in_build_mode() and not shape_cast.is_colliding() and not deleted_something_during_cancel:
		exit_build_mode()
	deleted_something_during_cancel = false

func _on_player_rotated() -> void:
	if in_build_mode():
		sprite.rotation += PI/2
	
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Building:
			node.rotate_to(node.rotation + PI/2)
			sprite.rotation = node.rotation

func _on_player_picked() -> void:
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Building:
			# TODO: When picking Buildings with Assemblers attached
			# Copy the Assembler recipe and overwrite existing Buildings with this recipe
			enter_build_mode_with(node.data)
			sprite.rotation = node.rotation
	else:
		exit_build_mode()

func _on_player_picking_up() -> void:
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Building and node.holding:
			node.take_from().queue_free()

func placing_position(pos: Vector2) -> Vector2:
	return Vector2(snapped(floor(pos.x), Constants.TILE_SIZE), snapped(floor(pos.y), Constants.TILE_SIZE))

func _physics_process(_delta):
	var next_placer_pos = placing_position(get_viewport().get_mouse_position() + camera.position)
	
	if required_shape_cast.is_colliding() and not shape_cast.is_colliding():
		sprite.modulate = Color.GREEN
		sprite.modulate.a = 0.5
	elif shape_cast.is_colliding():
		sprite.modulate = Color.RED
		sprite.modulate.a = 0.5
	elif in_build_mode():
		sprite.modulate = current_data.color_adjustment
		sprite.modulate.a = 0.5
	
	if locked_to_x_axis:
		next_placer_pos.y = y_axis_lock_pos
	elif locked_to_y_axis:
		next_placer_pos.x = x_axis_lock_pos
	
	placer.global_position = next_placer_pos
