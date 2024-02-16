extends Control
class_name UnownedPlotDisplay

@onready var icon : TextureRect = $TextureRect
@onready var contract_panel : Control = $PanelContainer
@onready var contract_slot : ContractSlot = $PanelContainer/MarginContainer/ContractSlot
@onready var hidden_display : Control = $HiddenPlot

func _ready():
	contract_slot.button.pressed.connect(_on_contract_slot_pressed)

func show_display(plot: Plot) -> void:
	if plot == null:
		show_unowned_and_hidden_plot()
	else:
		show_unowned_but_contract_available_plot(plot)
	
	show()

func hide_display() -> void:
	hide()

func show_unowned_but_contract_available_plot(plot: Plot) -> void:
	hidden_display.hide()
	
	icon.show()
	contract_panel.show()
	contract_slot.contract = plot.available_contract

func show_unowned_and_hidden_plot() -> void:
	icon.hide()
	contract_panel.hide()
	hidden_display.show()

func _on_contract_slot_pressed() -> void:
	icon.hide()
	contract_panel.hide()
