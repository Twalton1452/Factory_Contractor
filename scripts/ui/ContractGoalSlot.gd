extends Control
class_name ContractGoalSlot

@export var texture_rect : TextureRect
@export var amount_label : Label

var goal : Contract.Goal :
	set(value):
		goal = value
		if goal:
			texture_rect.texture = goal.component_data.icon
			texture_rect.self_modulate = goal.component_data.color_adjustment
			amount_label.text = str(goal.required_amount)
			texture_rect.tooltip_text = goal.component_data.display_name
