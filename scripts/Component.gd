@tool
extends Node2D
class_name Component

@export var data : ComponentData : 
	set(value):
		data = value
		sprite.texture = data.icon

@export var sprite : Sprite2D
