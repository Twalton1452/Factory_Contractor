@icon("res://art/editor_icons/data.svg")
extends Resource
class_name ComponentData

@export var display_name : StringName
@export var icon : Texture
@export var color_adjustment = Color.WHITE
@export var required_components : Array[ComponentData]
