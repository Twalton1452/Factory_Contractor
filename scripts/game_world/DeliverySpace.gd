extends Node
class_name DeliverySpace

## Class designated to listen for Components being received
## and delivering them to the Client

var building : Building = null

func _ready():
	name = Constants.DELIVERY_SPACE
	
	building = get_parent()
	building.received_component.connect(_on_received_component)

func _on_received_component(component: Component) -> void:
	MessageBus.delivered_component.emit(component.data)
