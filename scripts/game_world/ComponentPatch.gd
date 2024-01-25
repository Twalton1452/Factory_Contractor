@icon("res://art/editor_icons/patch.svg")
@tool
extends Area2D
class_name ComponentPatch

## Script that is instantiated in the game world to extract a specific component out of
## Ex: Extracting Copper

signal empty

@export var component_to_extract : ComponentData :
	set(value):
		component_to_extract = value
		sprite.texture = component_to_extract.icon
		sprite.modulate = component_to_extract.color_adjustment.darkened(0.2)

@export var sprite : Sprite2D
@export var amount : int = 100


func can_extract() -> bool:
	return amount > 0

func extract() -> ComponentData:
	if can_extract():
		amount -= 1
		return component_to_extract
	
	empty.emit()
	return null
