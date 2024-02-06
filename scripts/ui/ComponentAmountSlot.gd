extends Control
class_name ComponentAmountSlot

@export var background : ColorRect
@export var texture_rect : TextureRect
@export var amount_label : Label

var original_bg_color : Color


func _ready():
	original_bg_color = background.color

func set_to(data: ComponentData, amount: int) -> void:
	texture_rect.texture = data.icon
	texture_rect.modulate = data.color_adjustment
	texture_rect.tooltip_text = Constants.TOOLTIP_LINE.format({"amount": amount, "display_name": data.display_name })
	amount_label.text = str(amount)
