extends Control
class_name ContractSlot

## Class to display a Contract at a high level

@export var button : Button
@export var progress_bar : ProgressBar

var contract : Contract = null :
	set(value):
		if contract:
			if contract.progressed.is_connected(_on_contract_progressed):
				contract.progressed.disconnect(_on_contract_progressed)
		
		contract = value
		if contract and button:
			button.text = contract.display_name
			contract.progressed.connect(_on_contract_progressed)
			update_progress_bar()
			# TODO: clear tooltip if hovering
			# setting tooltip_text = "" | doesn't update existing tooltip

var hovering = false

func _ready():
	mouse_entered.connect(_on_mouse_hover_enter)
	mouse_exited.connect(_on_mouse_hover_exit)
	button.pressed.connect(_on_button_pressed)

func _exit_tree():
	if contract != null and contract.progressed.is_connected(_on_contract_progressed):
		contract.progressed.disconnect(_on_contract_progressed)

func _on_button_pressed() -> void:
	MessageBus.contract_slot_pressed.emit(self)

func _on_contract_progressed() -> void:
	update_progress_bar()

func update_progress_bar() -> void:
	var sum_goal_percent = 0.0
	for goal in contract.goals:
		sum_goal_percent += float(goal.current_amount) / float(goal.required_amount)
	progress_bar.value = sum_goal_percent / contract.goals.size()

#region Tooltip
func _on_mouse_hover_enter() -> void:
	hovering = true
	if contract == null:
		return
	
	update_tooltip()
	while hovering and contract.active:
		var prev_progress = progress_bar.value
		# Update the tooltip at the same tickrate as Buildings
		await get_tree().physics_frame
		if Engine.get_physics_frames() % Constants.BUILDING_TICK_RATE != 0:
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
