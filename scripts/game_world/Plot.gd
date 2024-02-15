extends Node2D
class_name Plot

var display_name = "Home"
var player_owned = false
var contract : Contract = null
var available_contract : Contract = null

func _init(waiting_to_be_accepted: Contract = null):
	available_contract = waiting_to_be_accepted

func _ready():
	add_to_group(Constants.PLOT_GROUP)
