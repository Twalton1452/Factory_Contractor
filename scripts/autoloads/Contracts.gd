extends Node

## Autoloaded

signal accepted_contract(contract: Contract)

var available_contracts : Array[Contract] = []
var active_contracts : Array[Contract] = []
var completed_contracts : Array[Contract] = []

func _ready():
	var contract = Contract.new()
	contract.goals.push_back(Contract.Goal.new(load("res://resources/components/iron.tres"), 100))
	contract.goals.push_back(Contract.Goal.new(load("res://resources/components/copper.tres"), 30))
	contract.display_name = "Backyard Rollercoaster"
	contract.requested_by = "Sally Briggendale"
	
	var contract_two = Contract.new()
	contract_two.goals.push_back(Contract.Goal.new(load("res://resources/components/iron.tres"), 100))
	contract_two.goals.push_back(Contract.Goal.new(load("res://resources/components/copper.tres"), 100))
	contract_two.goals.push_back(Contract.Goal.new(load("res://resources/components/conveyor_belt.tres"), 50))
	contract_two.goals.push_back(Contract.Goal.new(load("res://resources/components/underground_conveyor.tres"), 6))
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
