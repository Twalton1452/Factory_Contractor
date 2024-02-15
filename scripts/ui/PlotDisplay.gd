extends Control
class_name PlotDisplay

## Class for displaying information related to the Plot

@onready var title_label : Label = $TopPanel/MarginContainer/Title
@onready var coordinates_label : Label = $TopPanel/MarginContainer/Coordinates
@onready var progress_bar : ProgressBar = $TopPanel/MarginContainer/ProgressBar
@onready var unowned_display : UnownedPlotDisplay = $UnownedDisplay

var contract : Contract = null

func _ready() -> void:
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	unowned_display.hide_display()

func _on_moved_to_coordinates(location: Vector2) -> void:
	coordinates_label.text = str(location.x) + "," + str(location.y)
	
	var plot = Plots.get_plot(location)
	if plot == null:
		unowned_display.show_display(plot)
		title_label.text = "Hidden"
		return
	
	title_label.text = plot.display_name
	if not plot.player_owned:
		unowned_display.show_display(plot)
	else:
		unowned_display.hide_display()
