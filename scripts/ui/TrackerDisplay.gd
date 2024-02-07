extends Control
class_name TrackerDisplay

## Class for the Player to track specific Components flowing in an out

var component_goal_slot_scene : PackedScene = load("res://scenes/ui/component_goal_slot.tscn")

func _ready():
	Contracts.accepted_contract.connect(_on_contract_accepted)

func _on_contract_accepted(contract: Contract) -> void:
	add_new_contract_view(contract)

func add_new_contract_view(_contract: Contract) -> void:
	pass
	# Add Goal Slots that increment when the associated component is delivered
