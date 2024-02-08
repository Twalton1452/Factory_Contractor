extends Building
class_name StorageBuilding

## Inherited from Building Class to store many things instead of one

# TODO: Refactor into Slot approach so there can be multiple Stacks of a thing
var inventory : Dictionary = {} # { key: ComponentData, val: int }
const MAX_SLOTS = 16
const MAX_SLOT_SIZE = 99

func can_receive(component: Component) -> bool:
	return \
	(inventory.get(component.data, 0) < MAX_SLOT_SIZE or inventory.size() < MAX_SLOTS) and \
	not received_this_frame and \
	(holding_allow_dict.size() == 0 or holding_allow_dict.has(component.data) and holding_allow_dict[component.data] > 0)

func receive(component: Component) -> void:
	if inventory.has(component.data):
		if inventory[component.data] < MAX_SLOT_SIZE:
			inventory[component.data] += 1
	else:
		inventory[component.data] = 1
	
	# Wait some frames so the Player can see it go into the Building
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	component.queue_free()
	received_component.emit(component)

func spawn(to_spawn_data: ComponentData) -> Component:
	var component : Component = ComponentDB.COMPONENT_SCENE.instantiate()
	component.data = to_spawn_data
	get_parent().add_child(component)
	return component

func can_take() -> bool:
	return inventory.size() > 0

func take_from() -> Component:
	var taking : Component = null
	
	if can_take():
		var taking_data : ComponentData = inventory.keys().front()
		taking = spawn(taking_data)
		inventory[taking_data] -= 1
		if inventory[taking_data] <= 0:
			inventory.erase(taking_data)
		
		taken_from_this_frame = true
		component_taken.emit(taking)
		return taking
	
	return taking
