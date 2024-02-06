extends Node
class_name ComponentGoal

var components_dict : Dictionary = {} # { key: ComponentData, val: int }
var reward = 0

var building : Building = null

func _ready():
	building = get_parent()
	building.received_component.connect(_on_received_component)

func _on_received_component(component: Component) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	component.queue_free()

func deposit(data: ComponentData) -> void:
	pass
