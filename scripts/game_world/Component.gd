@icon("res://art/editor_icons/cog.svg")
@tool
extends Area2D
class_name Component

## Physical representation of the Component in the Game World
## Ex: Unrefined Ore, Assembled Extractor

@export var data : ComponentData : 
	set(value):
		data = value
		sprite.texture = data.icon
		sprite.modulate = data.color_adjustment
		collision_layer = data.placed_layer

@export var sprite : Sprite2D

# TODO: When not placed as a Building and is movable, show as smaller
