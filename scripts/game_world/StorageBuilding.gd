extends Building
class_name StorageBuilding

## Inherited from Building Class to store many things instead of one

class Slot:
	var component_data: ComponentData
	var amount = 0

# TODO: Refactor into Slot approach so there can be multiple Stacks of a thing
#var inventory : Dictionary = {} # { key: ComponentData, val: int }
var inventory_slots : Array[Slot] = [] # { key: ComponentData, val: int }
const MAX_SLOTS = 16
const MAX_SLOT_SIZE = 99

func _ready():
	super()
	inventory_slots.resize(MAX_SLOTS)
	for i in range(inventory_slots.size()):
		inventory_slots[i] = Slot.new()

func get_next_available_slot_for(component: Component) -> Slot:
	# Theres a better way to do this for sure
	
	# Look for existing slots with that component
	for slot in inventory_slots:
		if slot.component_data == component.data and slot.amount < MAX_SLOT_SIZE:
			return slot
	
	# Find the next available slot
	for slot in inventory_slots:
		if slot.component_data == null or slot.component_data == component.data and slot.amount < MAX_SLOT_SIZE:
			return slot
	
	return null

func get_first_slot_with_anything() -> Slot:
	for slot in inventory_slots:
		if slot.component_data != null and slot.amount > 0:
			return slot
	return null

func can_receive(component: Component) -> bool:
	return \
	not received_this_frame and \
	(holding_allow_dict.size() == 0 or holding_allow_dict.has(component.data) and holding_allow_dict[component.data] > 0) and \
	get_next_available_slot_for(component) != null

func receive(component: Component) -> void:
	var slot = get_next_available_slot_for(component)
	if slot != null:
		slot.component_data = component.data
		slot.amount += 1
	
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
	return get_first_slot_with_anything() != null

func take_from() -> Component:
	var taking : Component = null
	
	if can_take():
		var slot : Slot = get_first_slot_with_anything()
		var taking_data : ComponentData = slot.component_data
		taking = spawn(taking_data)
		slot.amount -= 1
		if slot.amount <= 0:
			slot.component_data = null
			slot.amount = 0
		
		taken_from_this_frame = true
		component_taken.emit(taking)
		return taking
	
	return taking
