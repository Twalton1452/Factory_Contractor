extends Control
class_name ContractDetailDisplay

@onready var title_label : Label = $MarginContainer/Content/TitleLabel
@onready var requestor_name_label : Label = $MarginContainer/Content/TitleLabel/RequestorNameLabel
@onready var goals_parent : Container = $MarginContainer/Content/RequirementsLabel/Goals
@onready var accept_button : Button = $MarginContainer/Content/AcceptButton
@onready var content : Control = $MarginContainer/Content

var contract : Contract = null : set = _set_contract

var contract_goal_slot_scene : PackedScene = load("res://scenes/ui/contract_goal_slot.tscn")

func _set_contract(to_display: Contract) -> void:
	contract = to_display
	if contract == null:
		for child in goals_parent.get_children():
			child.queue_free()
		content.hide()
		return
	
	content.show()
	title_label.text = contract.display_name
	requestor_name_label.text = contract.requested_by
	# TODO: more efficient setting of the requirements
	# Just delete and remake for now
	for child in goals_parent.get_children():
		child.queue_free()
	
	await get_tree().physics_frame
	for goal in contract.goals:
		var goal_slot : ContractGoalSlot = contract_goal_slot_scene.instantiate()
		goal_slot.goal = goal
		goals_parent.add_child(goal_slot)

func _ready():
	accept_button.pressed.connect(_on_accept_button_pressed)
	contract = null

func _on_accept_button_pressed() -> void:
	Contracts.accept_contract(contract)
	# Update tracker display
