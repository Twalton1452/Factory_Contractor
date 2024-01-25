extends Node

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
	set_physics_process(true)
	sprite.show()

func disable() -> void:
	set_physics_process(false)
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
	
	await get_tree().physics_frame
	if shape_cast.get_collision_count() > 0:
		return
	
	var component : Component = component_scene.instantiate()
	component.data = current_data
	component.position = placing_position(get_viewport().get_mouse_position())
	component.rotation = sprite.rotation
	objects_parent.add_child(component)

func _on_player_canceled() -> void:
	disable()

func _on_player_rotated() -> void:
	sprite.rotation += PI/2

func placing_position(pos: Vector2) -> Vector2:
	return Vector2(snapped(floor(pos.x), 16.0), snapped(floor(pos.y), 16.0))

func _physics_process(_delta):
	if shape_cast.get_collision_count() > 0:
		sprite.modulate = Color.RED
		sprite.modulate.a = 0.5
	else:
		sprite.modulate = Color.WHITE
		sprite.modulate.a = 0.5

func _process(_delta):
	placer.global_position = placing_position(get_viewport().get_mouse_position())
