extends Node

## Autoloaded

signal accepted_contract(contract: Contract)

var available_contracts : Array[Contract] = []
var active_contracts : Array[Contract] = []
var completed_contracts : Array[Contract] = []

func _ready():
	var contract = Contract.new()
	contract.goals.push_back(Contract.Goal.new(ComponentDB.IRON, 100))
	contract.goals.push_back(Contract.Goal.new(ComponentDB.COPPER, 30))
	contract.display_name = "Backyard Rollercoaster"
	contract.requested_by = "Sally Briggendale"
	
	var contract_two = Contract.new()
	contract_two.goals.push_back(Contract.Goal.new(ComponentDB.IRON, 100))
	contract_two.goals.push_back(Contract.Goal.new(ComponentDB.COPPER, 100))
	contract_two.goals.push_back(Contract.Goal.new(ComponentDB.CONVEYOR_BELT, 50))
	contract_two.goals.push_back(Contract.Goal.new(ComponentDB.UNDERGROUND_CONVEYOR, 6))
	contract_two.display_name = "Mansion Hedge Maze"
	contract_two.requested_by = "Jon River"
	
	available_contracts = [
		contract,
		contract_two
	]

func accept_contract(contract: Contract) -> void:
	available_contracts.erase(contract)
	active_contracts.push_back(contract)
	contract.start()
	contract.fulfilled.connect(_on_contract_fulfilled, CONNECT_ONE_SHOT)
	accepted_contract.emit(contract)
	print_debug("Player Accepted Contract: ", contract.display_name)

func _on_contract_fulfilled(contract: Contract) -> void:
	active_contracts.erase(contract)
	completed_contracts.push_back(contract)
