@tool
extends Area2D
class_name Component

@export var data : ComponentData : 
	set(value):
		data = value
		sprite.texture = data.icon
		sprite.modulate = data.color_adjustment

@export var sprite : Sprite2D
