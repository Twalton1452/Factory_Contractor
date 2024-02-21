extends Control
class_name BuilderPanel

@onready var slots_parent : Container = $MarginContainer/Slots

func _ready():
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	Contracts.accepted_contract.connect(_on_accepted_contract)
	Inventory.changed.connect(_on_inventory_changed)
	update_slots()

func _on_inventory_changed() -> void:
	update_slots()

func _on_accepted_contract(contract: Contract) -> void:
	var plot = Plots.get_current_plot()
	assert(plot != null, "Accepted Contract on an empty space")
	if plot.contract == contract:
		show()

func _on_moved_to_coordinates(_coords: Vector2) -> void:
	var plot = Plots.get_current_plot()
	if plot == null or (plot.contract == null and not plot.player_owned):
		hide()
	else:
		show()

func update_slots() -> void:
	for slot in slots_parent.get_children():
		if slot.data:
			(slot as BuildSlot).update_amount(Inventory.how_many(slot.data))
