extends Node

# Autoloaded

## Class to hold events that are used across different places with possibly hard to reach references

# UI
signal build_slot_pressed(component_data: ComponentData)
signal recipe_slot_pressed(component_data: ComponentData)

# Player
signal player_selecting
signal player_released_select
signal player_selected_assembler(assembler: Assembler)
signal player_selected_storage_container(storage_container: StorageBuilding)
signal player_canceling
signal player_released_cancel
signal player_rotated
signal player_picked
signal player_picking_up
signal player_released_picking_up

# Contracts
signal delivered_component(component_data: ComponentData)
