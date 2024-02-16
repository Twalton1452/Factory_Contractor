extends Node
class_name Contract

signal started
signal progressed
signal fulfilled(contract: Contract)

enum Type {
	ON_SITE, ## Unlocks the space for the Player to build on upon completion
	REMOTE, ## Unlocks bonuses for the Player upon completion
}

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
var active = false
var display_name = ""
var requested_by = ""
var contract_type : Type = Type.ON_SITE
var coordinates : Vector2 # Where it needs to be fulfilled when ON_SITE

func start() -> void:
	assert(!active, "Tried to start " + display_name + " while already started")
	for goal in goals:
		goal.fulfilled.connect(_on_goal_fulfilled, CONNECT_ONE_SHOT)
	active = true
	started.emit()

func complete() -> void:
	goals_fulfilled = true
	active = false
	fulfilled.emit(self)

func _on_goal_fulfilled() -> void:
	for goal in goals:
		if not goal.met:
			return
	
	complete()

func deliver(component_data: ComponentData) -> void:
	for goal in goals:
		if goal.component_data == component_data:
			goal.progress()
			progressed.emit()
			break
