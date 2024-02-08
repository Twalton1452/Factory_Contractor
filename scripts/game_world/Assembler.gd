extends Node
class_name Assembler

## Node to attach to a Building.
## Listens for Components intersecting with the Building.
## Puts them together to form a new Component

var building : Building = null
var storage : Dictionary = {} # { key: ComponentData, val: int }
var end_result : ComponentData = null :
	set(value):
		end_result = value
		if end_result:
			storage.clear()
			update_building_allow_dict()
			check_building()

func _ready() -> void:
	add_to_group(Constants.ASSEMBLER_GROUP)
	name = Constants.ASSEMBLER
	
	building = get_parent()
	building.received_component.connect(_on_component_received)
	
	building.collision_layer |= Constants.ASSEMBLER_LAYER

func update_building_allow_dict() -> void:
	building.holding_allow_dict = end_result.required_components.duplicate()
	storage = end_result.required_components.duplicate()
	for key in storage.keys():
		storage[key] = 0

func block_component(component_data: ComponentData) -> void:
	building.holding_allow_dict.erase(component_data)

func check_building() -> void:
	if building.holding:
		if end_result.required_components.has(building.holding.data):
			_on_component_received(building.holding)
		else:
			building.holding.queue_free()

func _on_component_received(component: Component) -> void:
	# Don't store things if the Assembler doesn't have a recipe yet
	if end_result == null:
		return
	
	if storage.has(component.data):
		if storage[component.data] < end_result.required_components[component.data]:
			storage[component.data] += 1
	else:
		storage[component.data] = 1
	building.holding_allow_dict[component.data] -= 1
	
	
	# Wait some frames so the Player can see it go into the Building
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var taking = building.take_from()
	check_storage_for_all_components_met()
	
	# Delete it because now it will just be kept track in the UI
	if taking:
		taking.queue_free()

func check_storage_for_all_components_met() -> void:
	for key in storage.keys():
		if storage[key] < end_result.required_components[key]:
			return
	
	storage.clear()
	var crafted_component : Component = craft()
	crafted_component.position = building.position
	building.holding = crafted_component
	update_building_allow_dict()

func craft() -> Component:
	var component : Component = ComponentDB.COMPONENT_SCENE.instantiate()
	component.data = end_result
	building.get_parent().add_child(component)
	return component

func _on_building_entered(_area) -> void:
	pass

func _on_building_exited(_area) -> void:
	pass
