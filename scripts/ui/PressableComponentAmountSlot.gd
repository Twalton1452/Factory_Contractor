@tool
extends Control
class_name PressableComponentAmountSlot

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon
			button.add_theme_color_override("icon_normal_color", data.color_adjustment)
			button.tooltip_text = ComponentDB.construct_tooltip(data)
		elif data == null and button:
			button.icon = null
			button.remove_theme_color_override("icon_normal_color")
			button.tooltip_text = ""
			amount_label.hide()

@export var button : Button
@export var amount_label : Label


func set_to(component_data: ComponentData, amount: int = -1) -> void:
	data = component_data
	if data == null:
		amount_label.hide()
	elif amount >= 0:
		amount_label.text = str(amount)
		amount_label.show()
	else:
		amount_label.hide()
