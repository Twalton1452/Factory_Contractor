extends Node
class_name Smelter

var building : Building = null
var storage : Dictionary = {} # { key: ComponentData, val: int }
var end_result : ComponentData = null
var crafting = false
var craft_progress = 0.0

func _ready() -> void:
	building = get_parent()
	building.received_component.connect(_on_component_received)
	
	for smeltable in ComponentDB.smeltables:
		building.holding_allow_dict[smeltable] = smeltable.required_components.values().front()

func _on_component_received(component: Component) -> void:
	if not component.data in ComponentDB.smeltables:
		return
	else:
		end_result
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
	
	# Delete it because now it will just be kept track in the UI
	if taking:
		taking.queue_free()
