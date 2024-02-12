extends Control
class_name ContractBrowser

@onready var contract_button : Button = $"../ContractButton"
@onready var available_contracts_parent : Control = $ContractsPanel
@onready var contracts_parent : Control = $ContractsPanel/Contracts
@onready var contract_detail_display : ContractDetailDisplay = $ContractDetails

var contract_slot_scene : PackedScene = load("res://scenes/ui/contract_slot.tscn")

func _ready():
	Contracts.accepted_contract.connect(_on_accepted_contract)
	contract_button.toggled.connect(_on_contract_button_toggled)
	_on_contract_button_toggled(false) # Hide the display

func _on_contract_button_toggled(toggled_on: bool) -> void:
	cleanup_available_contracts()
	if toggled_on:
		show()
		display_available_contracts()
		select_first_contract()
	else:
		hide()

func display_available_contracts() -> void:
	for available_contract in Contracts.available_contracts:
		var contract_slot = contract_slot_scene.instantiate()
		var contract_slot_button : Button = contract_slot.get_node("MarginContainer/Button")
		contract_slot_button.pressed.connect(_on_contract_slot_pressed.bind(available_contract))
		contract_slot_button.text = available_contract.display_name
		contracts_parent.add_child(contract_slot)

func select_first_contract() -> void:
	if contracts_parent.get_child_count() == 0:
		return
	
	var first_contract_slot : Control = contracts_parent.get_child(0)
	first_contract_slot.get_node("MarginContainer/Button").pressed.emit()

func cleanup_available_contracts() -> void:
	for child in contracts_parent.get_children():
		child.queue_free()

func _on_contract_slot_pressed(contract: Contract) -> void:
	contract_detail_display.contract = contract

func _on_accepted_contract(contract: Contract) -> void:
	if not visible:
		return
	
	cleanup_available_contracts()
	#display_available_contracts()
	contract_button.button_pressed = false
	contract_detail_display.contract = null
