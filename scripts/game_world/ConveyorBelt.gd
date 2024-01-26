extends Node
class_name ConveyorBelt

## Node to attach to a Building.
## Will move things ontop of the Building.
## Will grab things behind the Building. (Grabber from Plate Up! for simplicity)

var building : Building = null
var holding : Component = null

func _ready() -> void:
	add_to_group(Constants.CONVEYOR_GROUP)
	name = Constants.CONVEYOR_BELT
	
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	building.collision_mask |= Constants.COMPONENT_LAYER
	
	find_grab_target()

func find_grab_target() -> void:
	# Cast ray behind the building and pull from it if we can
	var result = Helpers.ray_cast(building, -building.transform.x, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	if result.size() == 0:
		return
	
	var found_building = result.collider
	var extractor : Extractor = found_building.get_node_or_null(Constants.EXTRACTOR)
	if extractor:
		extractor.register_requestor(self)

func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_LAYER == Constants.COMPONENT_LAYER:
		holding = area

func _on_building_exited(area: Area2D) -> void:
	if area == holding:
		holding = null

func tick() -> void:
	if holding:
		holding.position += building.transform.x.normalized() * Constants.TILE_SIZE

