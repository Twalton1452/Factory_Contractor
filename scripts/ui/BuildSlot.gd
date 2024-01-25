@tool
extends Control

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon
			button.add_theme_color_override("icon_normal_color", data.color_adjustment)

@export var button : Button

func _on_button_pressed():
	MessageBus.build_slot_pressed.emit(data)
