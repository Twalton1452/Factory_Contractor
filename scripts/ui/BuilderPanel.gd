extends Control
class_name BuilderPanel

func _ready():
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	Contracts.accepted_contract.connect(_on_accepted_contract)

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
