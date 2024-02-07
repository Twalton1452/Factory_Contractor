extends Node

## Class to handle Player Input

signal exited_build_mode

@export var objects_parent : Node2D

@onready var placer : Node2D = $Placer
@onready var sprite : Sprite2D = $Placer/Sprite2D
@onready var shape_cast : ShapeCast2D = $Placer/PlaceShapeCast2D
@onready var required_shape_cast : ShapeCast2D = $Placer/RequiredShapeCast2D

var placed_scene : PackedScene = preload("res://scenes/building.tscn")

var current_data : ComponentData = null

## When the player holds Right click and is building something at the same time-
## delete things, but keep what they're building.
## When the player didn't delete something then cancel their build
var deleted_something_during_cancel = false

func _ready():
	MessageBus.build_slot_pressed.connect(_on_build_slot_pressed)
	MessageBus.player_selecting.connect(_on_player_selected)
	MessageBus.player_released_select.connect(_on_player_released_selected)
	MessageBus.player_canceling.connect(_on_player_canceled)
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	MessageBus.player_rotated.connect(_on_player_rotated)
	MessageBus.player_picked.connect(_on_player_picked)
	MessageBus.player_picking_up.connect(_on_player_picking_up)
	exit_build_mode()

func in_build_mode() -> bool:
	return current_data != null

func _on_build_slot_pressed(component_data: ComponentData) -> void:
	enter_build_mode_with(component_data)
	sprite.rotation = 0.0

func enter_build_mode_with(component_data: ComponentData) -> void:
	current_data = component_data
	if current_data:
		sprite.show()
		sprite.texture = component_data.icon
		shape_cast.collision_mask = current_data.placed_layer
		required_shape_cast.collision_mask = current_data.required_layer
		if shape_cast.collision_mask & Constants.UNDERGROUND_LAYER == Constants.UNDERGROUND_LAYER:
			show_range_indicator(Constants.UNDERGROUND_CONVEYOR_MAX_RANGE)

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

func _on_player_selected() -> void:
	if not in_build_mode():
		return
	
	var player_selected_position = placing_position(get_viewport().get_mouse_position())
	await get_tree().physics_frame # Let previous spawns set themselves up
	if shape_cast.is_colliding() or (required_shape_cast.collision_mask > 0 and not required_shape_cast.is_colliding()):
		return
	
	var placed_node : Node2D = placed_scene.instantiate() if current_data.scene_override == null else current_data.scene_override.instantiate()
	if placed_node is Building or placed_node is Component:
		placed_node.data = current_data
	
	placed_node.position = player_selected_position
	placed_node.rotation = sprite.rotation
	placed_node.collision_layer = current_data.placed_layer
	objects_parent.add_child(placed_node)

func _on_player_released_selected() -> void:
	if in_build_mode():
		return
	
	if shape_cast.is_colliding():
		var colliding = shape_cast.get_collider(0)
		if colliding is Building:
			var assembler = colliding.get_node_or_null(Constants.ASSEMBLER)
			if assembler:
				MessageBus.player_selected_assembler.emit(assembler)
			elif colliding is StorageBuilding:
				MessageBus.player_selected_storage_container.emit(colliding)

func _on_player_canceled() -> void:
	# Remove things underneath what we're hovering
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Building and not node.is_queued_for_deletion():
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
	if required_shape_cast.is_colliding() and not shape_cast.is_colliding():
		sprite.modulate = Color.GREEN
		sprite.modulate.a = 0.5
	elif shape_cast.is_colliding():
		sprite.modulate = Color.RED
		sprite.modulate.a = 0.5
	elif in_build_mode():
		sprite.modulate = current_data.color_adjustment
		sprite.modulate.a = 0.5
	
	placer.global_position = placing_position(get_viewport().get_mouse_position())
