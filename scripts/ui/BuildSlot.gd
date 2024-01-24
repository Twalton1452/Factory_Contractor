@tool
extends Control

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon

@export var button : Button

func _on_texture_button_pressed():
	pass # Emit an event signaling we pressed this Slot
