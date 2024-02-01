@tool
extends Control
class_name RecipeSlot

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon
			button.add_theme_color_override("icon_normal_color", data.color_adjustment)
			button.tooltip_text = construct_tooltip()

@export var button : Button


func construct_tooltip() -> String:
	if data == null:
		return ""
	
	var tooltip = data.display_name + "\n"
	for component_data in data.required_components.keys():
		tooltip += Constants.TOOLTIP_LINE.format({"amount": data.required_components[component_data], "display_name": component_data.display_name }) + "\n"
	return tooltip

func _on_button_pressed():
	MessageBus.recipe_slot_pressed.emit(data)
