@tool
extends Control

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon

@export var button : Button

func _on_button_pressed():
	MessageBus.build_slot_pressed.emit(data)
