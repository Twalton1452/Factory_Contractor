extends Node

# Autoloaded

## Class to hold events that are used across different places with possibly hard to reach references

# UI
signal build_slot_pressed(component_data: ComponentData)
signal contract_slot_pressed(contract_slot: ContractSlot)

# Player
signal player_selecting
signal player_released_select
signal player_selected_building(building: Building)
signal player_canceling
signal player_released_cancel
signal player_rotated
signal player_picked
signal player_picking_up
signal player_released_picking_up
signal player_contract_toggle

signal player_navigated_left
signal player_navigated_right
signal player_navigated_up
signal player_navigated_down

# Contracts
#signal delivery_ready(delivery_space: DeliverySpace)
#signal delivered_component(component_data: ComponentData)
