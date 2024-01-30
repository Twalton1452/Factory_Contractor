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
			check_building()

func _ready() -> void:
	add_to_group(Constants.ASSEMBLER_GROUP)
	name = Constants.ASSEMBLER
	
	building = get_parent()
	building.received_component.connect(_on_component_received)
	
	building.collision_layer |= Constants.ASSEMBLER_LAYER

func check_building() -> void:
	if building.holding:
		_on_component_received(building.holding)

func _on_component_received(component: Component) -> void:
	# Don't store things if the Assembler doesn't have a recipe yet
	if end_result == null:
		return
	
	if storage.has(component.data):
		storage[component.data] += 1
	else:
		storage[component.data] = 1
	
	# Wait some frames so the Player can see it go into the Building
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	building.take_from()
	# Delete it because now it will just be kept track in the UI
	component.queue_free()

func _on_building_entered(_area) -> void:
	pass

func _on_building_exited(_area) -> void:
	pass
