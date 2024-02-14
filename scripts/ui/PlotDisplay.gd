extends Control
class_name PlotDisplay

## Class for displaying information related to the Plot

@onready var title_label : Label = $MarginContainer/Label
@onready var progress_bar : ProgressBar = $MarginContainer/ProgressBar

var contract : Contract = null

func _ready() -> void:
	Plots.moved_to_plot.connect(_on_moved_to_plot)

func _on_moved_to_plot(location: Vector2) -> void:
	var plot = Plots.get_plot(location)
	if plot == null:
		title_label.text = str(location.x) + "," + str(location.y)
	else:
		title_label.text = plot.display_name
