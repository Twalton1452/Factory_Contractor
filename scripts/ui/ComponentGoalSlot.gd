extends Control
class_name ComponentGoalSlot

## Class to show the goals in a contract so the player can see progress at a glance

@onready var texture_rect : TextureRect = $TextureRect
@onready var current_amount_label : Label = $CurrentAmountLabel
@onready var max_amount_label : Label = $MaxAmountLabel

var data : ComponentData = null

#func _ready():
	#MessageBus.delivered_component.connect(_on_delivered_component)

func _on_delivered_component(_delivered: ComponentData) -> void:
	#if delivered == data:
		#current_amount_label
	pass

func update_amount(new_amount: int) -> void:
	current_amount_label.text = str(new_amount)
