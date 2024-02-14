extends Node2D
class_name Plot

var display_name = "Home"
var contract : Contract = null

func _ready():
	add_to_group(Constants.PLOT_GROUP)
