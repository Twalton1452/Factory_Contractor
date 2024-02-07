extends Node
class_name Contract

signal fulfilled(contract: Contract)

class Goal:
	signal progressed
	signal fulfilled
	
	var component_data : ComponentData
	var current_amount = 0
	var required_amount = 1
	var met = false
	
	func _init(data: ComponentData, req_amt: int) -> void:
		component_data = data
		required_amount = req_amt
	
	func progress() -> void:
		current_amount += 1
		if current_amount >= required_amount:
			if not met:
				met = true
				fulfilled.emit()
		else:
			progressed.emit()

var goals : Array[Goal] = []
var goals_fulfilled = false
var display_name = "Backyard Rollercoaster"
var requested_by = "Sally Longbottom"

func start() -> void:
	MessageBus.delivered_component.connect(_on_component_delivered)
	for goal in goals:
		goal.fulfilled.connect(_on_goal_fulfilled, CONNECT_ONE_SHOT)

func complete() -> void:
	MessageBus.delivered_component.disconnect(_on_component_delivered)
	
	goals_fulfilled = true
	fulfilled.emit(self)

func _on_goal_fulfilled() -> void:
	for goal in goals:
		if not goal.met:
			return
	
	complete()

func _on_component_delivered(component_data: ComponentData) -> void:
	for goal in goals:
		if goal.component_data == component_data:
			goal.progress()
			break
