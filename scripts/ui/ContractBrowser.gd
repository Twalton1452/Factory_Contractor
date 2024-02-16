extends Control
class_name ContractBrowser

@onready var contract_button : Button = $"../ContractButton"
@onready var available_contracts_parent : Control = $ContractsPanel
@onready var contracts_parent : Control = $ContractsPanel/Contracts
@onready var contract_detail_display : ContractDetailDisplay = $ContractDetails

var contract_slot_scene : PackedScene = load("res://scenes/ui/contract_slot.tscn")

func _ready():
	Contracts.accepted_contract.connect(_on_accepted_contract)
	#MessageBus.player_contract_toggle.connect(_on_player_contract_toggle)
	MessageBus.contract_slot_pressed.connect(_on_contract_slot_pressed)
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	contract_button.toggled.connect(_on_contract_button_toggled)
	_on_contract_button_toggled(false) # Hide the display
	available_contracts_parent.hide()

func _on_player_contract_toggle() -> void:
	contract_button.button_pressed = !contract_button.button_pressed

func _on_contract_button_toggled(toggled_on: bool) -> void:
	cleanup_available_contracts()
	if toggled_on:
		show()
		display_available_contracts()
		select_first_contract()
	else:
		hide()

func _on_moved_to_coordinates(_coords: Vector2) -> void:
	contract_button.button_pressed = false
	#hide()

func display_available_contracts() -> void:
	for available_contract in Contracts.available_contracts:
		var contract_slot : ContractSlot = contract_slot_scene.instantiate()
		contract_slot.contract = available_contract
		contracts_parent.add_child(contract_slot)

func select_first_contract() -> void:
	if contracts_parent.get_child_count() == 0:
		return
	
	var first_contract_slot : Control = contracts_parent.get_child(0)
	if first_contract_slot is ContractSlot:
		first_contract_slot.button.pressed.emit()

func cleanup_available_contracts() -> void:
	for child in contracts_parent.get_children():
		child.queue_free()

func _on_contract_slot_pressed(contract_slot: ContractSlot) -> void:
	contract_detail_display.contract = contract_slot.contract
	contract_button.button_pressed = true
	#show()

func _on_accepted_contract(contract: Contract) -> void:
	if not visible:
		return
	
	cleanup_available_contracts()
	#display_available_contracts()
	contract_button.button_pressed = false
	contract_detail_display.contract = null
