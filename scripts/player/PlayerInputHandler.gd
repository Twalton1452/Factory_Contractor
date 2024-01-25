extends Node

## Class to handle Player Input

@export var objects_parent : Node2D

@onready var placer : Node2D = $Placer
@onready var sprite : Sprite2D = $Placer/Sprite2D
@onready var shape_cast : ShapeCast2D = $Placer/ShapeCast2D

var component_scene : PackedScene = preload("res://scenes/component.tscn")

var current_data : ComponentData = null

func _ready():
	MessageBus.build_slot_pressed.connect(_on_build_slot_pressed)
	MessageBus.player_selected.connect(_on_player_selected)
	MessageBus.player_canceled.connect(_on_player_canceled)
	MessageBus.player_rotated.connect(_on_player_rotated)
	disable()

func enable() -> void:
	sprite.show()

func disable() -> void:
	sprite.hide()
	sprite.rotation = 0.0
	current_data = null

func _on_build_slot_pressed(component_data: ComponentData) -> void:
	current_data = component_data
	enable()
	if current_data:
		sprite.texture = component_data.icon

func _on_player_selected() -> void:
	if current_data == null:
		return
	
	var player_selected_position = placing_position(get_viewport().get_mouse_position())
	await get_tree().physics_frame # Let previous spawns set themselves up
	if shape_cast.is_colliding():
		return
	
	var component : Component = component_scene.instantiate()
	component.data = current_data
	component.position = player_selected_position
	component.rotation = sprite.rotation
	objects_parent.add_child(component)

func _on_player_canceled() -> void:
	if current_data != null:
		sprite.hide()
		current_data = null
	
	if shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Component and not node.is_queued_for_deletion():
			node.queue_free()

func _on_player_rotated() -> void:
	if current_data != null:
		sprite.rotation += PI/2
	elif shape_cast.is_colliding():
		var node = shape_cast.get_collider(0)
		if node is Component:
			node.rotation += PI/2

func placing_position(pos: Vector2) -> Vector2:
	return Vector2(snapped(floor(pos.x), 16.0), snapped(floor(pos.y), 16.0))

func _physics_process(_delta):
	if shape_cast.is_colliding():
		sprite.modulate = Color.RED
		sprite.modulate.a = 0.5
	elif current_data:
		sprite.modulate = current_data.color_adjustment
		sprite.modulate.a = 0.5
	
	placer.global_position = placing_position(get_viewport().get_mouse_position())
