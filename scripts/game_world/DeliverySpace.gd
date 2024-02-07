extends Node
class_name DeliverySpace

## Class designated to listen for Components being received
## and delivering them to the Client

var building : Building = null

var to_deliver : Array[ComponentData] = []

func _ready():
	name = Constants.DELIVERY_SPACE
	
	building = get_parent()
	building.received_component.connect(_on_received_component)

func _on_received_component(component: Component) -> void:
	if not component.data in to_deliver:
		return
	
	MessageBus.delivered_component.emit(component.data)

func flag_component_for_delivery(component_data: ComponentData) -> void:
	if not component_data in to_deliver:
		to_deliver.push_back(component_data)
