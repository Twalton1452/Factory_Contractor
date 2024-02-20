extends Node2D
class_name Plot

signal accepted_contract(accepted_contract: Contract)

var display_name = "Home"
var player_owned = false
var coordinates : Vector2

var contract : Contract = null

var available_contract : Contract = null : 
	set(value):
		available_contract = value
		if available_contract != null:
			available_contract.started.connect(_on_contract_started, CONNECT_ONE_SHOT)

func _init(waiting_to_be_accepted: Contract = null):
	available_contract = waiting_to_be_accepted
	if available_contract:
		display_name = waiting_to_be_accepted.display_name

func _ready():
	add_to_group(Constants.PLOT_GROUP)

func _on_contract_started() -> void:
	contract = available_contract
	available_contract = null
	accepted_contract.emit(contract)
