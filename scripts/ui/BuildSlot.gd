@tool
extends Control
class_name BuildSlot

@export var data : ComponentData : 
	set(value):
		data = value
		if data and button:
			button.icon = data.icon
			button.add_theme_color_override("icon_normal_color", data.color_adjustment)
			amount_label.show()
		else:
			amount_label.hide()

@export var button : Button
@export var amount_label : Label

func _ready():
	if data == null:
		amount_label.hide()

func _on_button_pressed():
	MessageBus.build_slot_pressed.emit(data)

func update_amount(amount: int) -> void:
	button.disabled = amount <= 0
	amount_label.text = str(amount)
	update_tooltip(amount)

func update_tooltip(amount: int) -> void:
	button.tooltip_text = data.display_name + " (" + str(amount) + ")"
	
