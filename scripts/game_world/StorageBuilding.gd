extends Building
class_name StorageBuilding

## Inherited from Building Class to store many things instead of one

class Slot:
	var component_data: ComponentData
	var amount = 0

var inventory_slots : Array[Slot] = []
const MAX_SLOTS = 16
const MAX_SLOT_SIZE = 99

# Optimizations
## Keeps track of the last slot that had something to make repeated attempts
## at taking from the Building quicker
var cached_slot_with_anything_i = -1
## Keeps track of the last slot that was available to make repeated attempts
## at inserting into the Building quicker
var cached_available_slot_i = -1

func _ready():
	super()
	inventory_slots.resize(MAX_SLOTS)
	for i in range(inventory_slots.size()):
		inventory_slots[i] = Slot.new()

func empty_slots() -> void:
	for slot in inventory_slots:
		slot.component_data = null
		slot.amount = 0

func get_next_available_slot_for(component: Component) -> int:
	if cached_available_slot_i != -1 and \
	inventory_slots[cached_available_slot_i].component_data == component.data and \
	inventory_slots[cached_available_slot_i].amount < MAX_SLOT_SIZE:
		return cached_available_slot_i
	
	# Look for existing slots with that component
	for i in range(inventory_slots.size()):
		if inventory_slots[i].component_data == component.data and inventory_slots[i].amount < MAX_SLOT_SIZE:
			cached_available_slot_i = i
			return i
	
	# Find the next available slot
	for i in range(inventory_slots.size()):
		if (inventory_slots[i].component_data == null or inventory_slots[i].component_data == component.data) and \
		inventory_slots[i].amount < MAX_SLOT_SIZE:
			cached_available_slot_i = i
			return i
	
	cached_available_slot_i = -1
	return -1

func get_first_slot_with_anything() -> int:
	if cached_slot_with_anything_i != -1 and \
	inventory_slots[cached_slot_with_anything_i].component_data != null and \
	inventory_slots[cached_slot_with_anything_i].amount > 0:
		return cached_slot_with_anything_i
	
	for i in range(inventory_slots.size()):
		if inventory_slots[i].component_data != null and inventory_slots[i].amount > 0:
			cached_slot_with_anything_i = i
			return i
	
	cached_slot_with_anything_i = -1
	return -1

func can_receive(component: Component) -> bool:
	return \
	not received_this_frame and \
	(holding_allow_dict.size() == 0 or holding_allow_dict.has(component.data) and holding_allow_dict[component.data] > 0) and \
	get_next_available_slot_for(component) != -1

func receive(component: Component) -> void:
	var slot_i : int = get_next_available_slot_for(component)
	
	if slot_i != -1:
		inventory_slots[slot_i].component_data = component.data
		inventory_slots[slot_i].amount += 1
	
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
	return get_first_slot_with_anything() != -1

## Subtract the amount from the Slot and spawn an ingame entity
func _take(slot: Slot) -> Component:
	var taking : Component = null
	
	if slot.component_data != null and slot.amount > 0:
		var taking_data : ComponentData = slot.component_data
		taking = spawn(taking_data)
		slot.amount -= 1
		if slot.amount <= 0:
			slot.component_data = null
			slot.amount = 0
		
		taken_from_this_frame = true
		component_taken.emit(taking)
		
	return taking

## Subtract the amount from the Slot, but don't spawn an ingame entity
func _take_no_component_spawn(slot: Slot) -> ComponentData:
	var taking : ComponentData = null
	
	if slot.component_data != null and slot.amount > 0:
		taking = slot.component_data
		slot.amount -= 1
		if slot.amount <= 0:
			slot.component_data = null
			slot.amount = 0
		
		taken_from_this_frame = true
		component_taken.emit(null)
		
	return taking

func take_from() -> Component:
	var slot_i = get_first_slot_with_anything()
	if slot_i == -1:
		return null
	return _take(inventory_slots[slot_i])

func take_from_slot(slot: Slot) -> Component:
	return _take(slot)

func take_from_slot_no_spawn(slot: Slot) -> ComponentData:
	return _take_no_component_spawn(slot)
