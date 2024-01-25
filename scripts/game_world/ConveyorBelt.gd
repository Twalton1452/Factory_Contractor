extends Node
class_name ConveyorBelt

## Node to attach to a Building.
## Will move things ontop of the Building.
## Will grab things behind the Building. (Grabber from Plate Up! for simplicity)

var building : Building = null
var holding: Component = null

func _ready() -> void:
	add_to_group(Constants.CONVEYOR_GROUP)
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	building.collision_mask |= Constants.COMPONENT_LAYER

func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_LAYER == Constants.COMPONENT_LAYER:
		holding = area

func _on_building_exited(area: Area2D) -> void:
	if area == holding:
		area = null

func tick() -> void:
	if holding:
		holding.position += building.transform.x.normalized()
