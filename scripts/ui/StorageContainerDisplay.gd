extends Control
class_name StorageContainerDisplay

## Class to manage the UI elements related to inspecting Storage Containers

@onready var storage_slots_parent : Container = $PanelContainer/MarginContainer/Inventory

var storage_focus : StorageBuilding = null

func _ready():
	hide_display()
	setup_storage_slots()

func show_display(storage_container: StorageBuilding) -> void:
	storage_focus = storage_container
	populate_storage_slots_for(storage_container)
	listen_for_changes_in(storage_container)
	show()

func hide_display() -> void:
	stop_listening_for_changes()
	storage_focus = null
	hide()

func setup_storage_slots() -> void:
	var pressable_slot_scene : PackedScene = load("res://scenes/ui/pressable_component_amount_slot.tscn")
	for i in range(StorageBuilding.MAX_SLOTS):
		var pressable_slot : PressableComponentAmountSlot = pressable_slot_scene.instantiate()
		storage_slots_parent.add_child(pressable_slot)

func populate_storage_slots_for(storage_container: StorageBuilding) -> void:
	var i = 0
	for inventory_slot in storage_container.inventory_slots:
		var pressable_slot : PressableComponentAmountSlot = storage_slots_parent.get_child(i)
		pressable_slot.set_to(inventory_slot.component_data, inventory_slot.amount)
		pressable_slot.show()
		i += 1
	
	for j in range(i, storage_slots_parent.get_child_count()):
		(storage_slots_parent.get_child(j) as PressableComponentAmountSlot).set_to(null)

func listen_for_changes_in(storage_container: StorageBuilding) -> void:
	if not storage_container.received_component.is_connected(_update_storage_container_display):
		storage_container.received_component.connect(_update_storage_container_display.bind(storage_container))
	if not storage_container.component_taken.is_connected(_update_storage_container_display):
		storage_container.component_taken.connect(_update_storage_container_display.bind(storage_container))
	
	_update_storage_container_display(null, storage_container)

func stop_listening_for_changes() -> void:
	if storage_focus == null:
		return
	
	if storage_focus.received_component.is_connected(_update_storage_container_display):
		storage_focus.received_component.disconnect(_update_storage_container_display)
	if storage_focus.component_taken.is_connected(_update_storage_container_display):
		storage_focus.component_taken.disconnect(_update_storage_container_display)

# TODO: Can be done better, currently updating every slot upon receiving anything
func _update_storage_container_display(_received_component: Component, storage_container: StorageBuilding) -> void:
	var i = 0
	for inventory_slot in storage_container.inventory_slots:
		(storage_slots_parent.get_child(i) as PressableComponentAmountSlot).set_to(inventory_slot.component_data, inventory_slot.amount)
		storage_slots_parent.get_child(i).show()
		
		i += 1
	
	for j in range(i, storage_slots_parent.get_child_count()):
		(storage_slots_parent.get_child(j) as PressableComponentAmountSlot).set_to(null)
