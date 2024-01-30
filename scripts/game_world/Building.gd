@icon("res://art/editor_icons/building.svg")
@tool
extends Area2D
class_name Building

## Class for ingame world placement of buildings.
## Buildings have child Nodes for their logic

signal received_component(component: Component)
signal rotated
signal new_neighbor(neighbor: Building)

@export var data : ComponentData : 
	set(value):
		data = value
		sprite.texture = data.icon
		sprite.modulate = data.color_adjustment
		collision_layer = data.placed_layer

@export var sprite : Sprite2D

var holding : Component = null
# TODO: Bit flags?
var received_this_frame = false
var taken_from_this_frame = false

## Helper class for easy access of Neighbors
## instead of needing to remember indicies on an Array or keys on a Dictionary
class Neighbors:
	var building: Building
	var forward: Building
	var behind: Building
	var left: Building
	var right: Building
	
	func _init(reference_building: Building):
		building = reference_building
		forward = Helpers.ray_forward(building)
		behind = Helpers.ray_behind(building)
		left = Helpers.ray_left(building)
		right = Helpers.ray_right(building)
	
	func as_array() -> Array[Building]:
		var buildings : Array[Building] = []
		if forward != null:
			buildings.push_back(forward)
		if behind != null:
			buildings.push_back(behind)
		if left != null:
			buildings.push_back(left)
		if right != null:
			buildings.push_back(right)
		return buildings

func _ready():
	if data.to_attach != null:
		add_child.call_deferred(data.to_attach.new())
	add_to_group(Constants.BUILDING_GROUP)
	
	#area_entered.connect(_on_building_entered)
	#area_exited.connect(_on_building_exited)
	
	# Let this Building move in and get setup
	# Then tell the neighbors about how you moved in
	greet_neighbors.call_deferred()

func _exit_tree() -> void:
	if holding != null:
		holding.queue_free()

func greet_neighbors() -> void:
	for neighbor in get_neighbors().as_array():
		neighbor.receive_neighbor_greeting(self)

func receive_neighbor_greeting(building: Building) -> void:
	new_neighbor.emit(building)

func rotate_to(new_rotation: float) -> void:
	rotation = new_rotation
	rotated.emit()

func get_neighbors() -> Neighbors:
	return Neighbors.new(self)

func can_receive() -> bool:
	return holding == null and not received_this_frame

func receive(component: Component) -> void:
	holding = component
	holding.position = position
	received_this_frame = true
	received_component.emit(holding)

func can_take() -> bool:
	return holding != null and not received_this_frame and not taken_from_this_frame

func take_from() -> Component:
	var taking = holding
	holding = null
	taken_from_this_frame = true
	return taking

func post_tick() -> void:
	taken_from_this_frame = false
	received_this_frame = false

#func _on_building_entered(area) -> void:
	#holding = area
#
#func _on_building_exited(area) -> void:
	#holding = null
