@icon("res://art/editor_icons/building.svg")
@tool
extends Area2D
class_name Building

## Class for ingame world placement of buildings.
## Buildings have child Nodes for their logic

@export var data : ComponentData : 
	set(value):
		data = value
		sprite.texture = data.icon
		sprite.modulate = data.color_adjustment
		collision_layer = data.placed_layer

@export var sprite : Sprite2D

func _ready():
	if data.to_attach != null:
		add_child.call_deferred(data.to_attach.new())
