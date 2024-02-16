extends Control
class_name ComponentGoalSlot

## Class to show the goals in a contract so the player can see progress at a glance

@onready var texture_rect : TextureRect = $TextureRect
@onready var current_amount_label : Label = $CurrentAmountLabel
@onready var max_amount_label : Label = $MaxAmountLabel

var data : ComponentData = null
var goal : Contract.Goal = null : set = _set_goal

func _set_goal(new_goal: Contract.Goal) -> void:
	if goal != null:
		if goal.progressed.is_connected(_on_goal_progressed):
			goal.progressed.disconnect(_on_goal_progressed)
	
	goal = new_goal
	
	if goal != null:
		goal.progressed.connect(_on_goal_progressed)
		texture_rect.texture = goal.component_data.icon
		texture_rect.self_modulate = goal.component_data.color_adjustment
		current_amount_label.text = str(goal.current_amount)
		max_amount_label.text = "/" + str(goal.required_amount)
		show()
	else:
		hide()
	

func _on_goal_progressed() -> void:
	update_amount(goal.current_amount)

func update_amount(new_amount: int) -> void:
	current_amount_label.text = str(new_amount)
