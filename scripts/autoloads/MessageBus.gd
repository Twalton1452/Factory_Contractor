extends Node

# Autoloaded

## Class to hold events that are used across different places with possibly hard to reach references

# UI
signal build_slot_pressed(component_data: ComponentData)

# Player
signal player_selected
signal player_canceled
signal player_rotated
