extends Control
class_name ContractSlot

## Class to display a Contract at a high level

@export var button : Button
@export var progress_bar : ProgressBar

var hovering = false

var contract : Contract = null :
	set(value):
		contract = value
		if contract and button:
			button.text = contract.display_name
			contract.progressed.connect(_on_contract_progressed)

func _ready():
	mouse_entered.connect(_on_mouse_hover_enter)
	mouse_exited.connect(_on_mouse_hover_exit)

func _exit_tree():
	if contract != null and contract.progressed.is_connected(_on_contract_progressed):
		contract.progressed.disconnect(_on_contract_progressed)

func _on_contract_progressed() -> void:
	var sum_goal_percent = 0.0
	for goal in contract.goals:
		sum_goal_percent += float(goal.current_amount) / float(goal.required_amount)
	progress_bar.value = sum_goal_percent / contract.goals.size()

#region Tooltip
func _on_mouse_hover_enter() -> void:
	hovering = true
	update_tooltip()
	while hovering and contract.active:
		var prev_progress = progress_bar.value
		# Update the tooltip at the same tickrate as Buildings
		if Engine.get_physics_frames() % Constants.BUILDING_TICK_RATE != 0:
			await get_tree().physics_frame
			continue
		
		# Only update tooltip if progress changed
		if prev_progress != progress_bar.value:
			update_tooltip()

func update_tooltip() -> void:
	var tooltip = ""
	for goal in contract.goals:
		tooltip += Constants.CONTRACT_GOAL_TOOLTIP_LINE.format({ \
			"display_name": goal.component_data.display_name, \
			"current_amount": goal.current_amount, \
			"required_amount": goal.required_amount \
			}) + "\n"
	button.tooltip_text = tooltip

func _on_mouse_hover_exit() -> void:
	hovering = false
#endregion Tooltip
