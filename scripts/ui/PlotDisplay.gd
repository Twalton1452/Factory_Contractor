extends Control
class_name PlotDisplay

## Class for displaying information related to the Plot

@onready var title_label : Label = $MarginContainer/Title
@onready var coordinates_label : Label = $MarginContainer/Coordinates
@onready var progress_bar : ProgressBar = $MarginContainer/ProgressBar

var contract : Contract = null

func _ready() -> void:
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)

func _on_moved_to_coordinates(location: Vector2) -> void:
	var plot = Plots.get_plot(location)
	coordinates_label.text = str(location.x) + "," + str(location.y)
	if plot != null:
		title_label.text = plot.display_name
	else:
		title_label.text = ""
