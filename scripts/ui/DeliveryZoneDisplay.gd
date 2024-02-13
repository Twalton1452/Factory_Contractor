extends Control
class_name DeliveryZoneDisplay

@onready var contracts_parent : Container = $PanelContainer/MarginContainer/Contracts

var delivery_space_focus : DeliverySpace = null
var active_contract_slot : ContractSlot = null
var contract_slot_scene : PackedScene = load("res://scenes/ui/contract_slot.tscn")

func show_display(delivery_space: DeliverySpace) -> void:
	delivery_space_focus = delivery_space
	
	for active_contract in Contracts.active_contracts:
		var contract_slot : ContractSlot = contract_slot_scene.instantiate()
		contract_slot.contract = active_contract
		contract_slot.button.pressed.connect(_on_contract_slot_pressed.bind(contract_slot, active_contract))
		contracts_parent.add_child(contract_slot)
		
		# Assigned contract displays first
		if delivery_space.contract_to_deliver_to != null and delivery_space.contract_to_deliver_to == active_contract:
			contracts_parent.move_child(contract_slot, 0)
			active_contract_slot = contract_slot
	
	show()

func hide_display() -> void:
	hide()
	delivery_space_focus = null
	active_contract_slot = null
	for child in contracts_parent.get_children():
		if child is HSeparator:
			continue
		child.queue_free()

func _on_contract_slot_pressed(contract_slot: ContractSlot, contract: Contract) -> void:
	delivery_space_focus.contract_to_deliver_to = contract
	if active_contract_slot != null:
		contracts_parent.move_child(active_contract_slot, -1)
	active_contract_slot = contract_slot
	contracts_parent.move_child(active_contract_slot, 0)
