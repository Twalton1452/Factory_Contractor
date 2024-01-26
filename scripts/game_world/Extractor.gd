extends Node
class_name Extractor

## Node to attach to a Building.
## Will extract Components ontop of the Building

var building : Building = null
var extracting_from : ComponentPatch = null

var component_scene : PackedScene = preload("res://scenes/component.tscn")
## Multiple Conveyors trying to pull the Extracted material, do it in an orderly fashion
var requestors : Array[ConveyorBelt] = []
var current_requestor = 0

func _ready() -> void:
	add_to_group(Constants.EXTRACTOR_GROUP)
	name = Constants.EXTRACTOR
	
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	
	# Detecting Patch's to Extract from them
	building.collision_mask |= Constants.COMPONENT_PATCH_LAYER
	
	find_requestors()

func find_requestors() -> void:
	for neighbor in building.get_neighbors().as_array():
		var conveyor : ConveyorBelt = neighbor.get_node_or_null(Constants.CONVEYOR_BELT)
		if conveyor != null:
			conveyor.update_neighbors()

func register_requestor(requestor: ConveyorBelt) -> void:
	requestors.push_back(requestor)

func unregister_requestor(requestor: ConveyorBelt) -> void:
	requestors.erase(requestor)

func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_PATCH_LAYER == Constants.COMPONENT_PATCH_LAYER:
		extracting_from = area
		extracting_from.empty.connect(_on_patch_empty)

func _on_building_exited(area: Area2D) -> void:
	if area == extracting_from:
		if extracting_from.empty.is_connected(_on_patch_empty):
			extracting_from.empty.disconnect(_on_patch_empty)
		extracting_from = null

func _on_patch_empty() -> void:
	extracting_from = null
	building.modulate = building.modulate.darkened(0.6)

func get_next_requestor() -> ConveyorBelt:
	var iterations = 0
	while !requestors[current_requestor].can_receive() or requestors[current_requestor].is_queued_for_deletion():
		current_requestor = (current_requestor + 1) % requestors.size()
		
		iterations += 1
		if iterations > requestors.size() - 1:
			return null
	return requestors[current_requestor]

func tick() -> void:
	if extracting_from and requestors.size() > 0:
		var next_requestor = get_next_requestor()
		# All requestors are full!
		if next_requestor == null:
			return
		current_requestor = (current_requestor + 1) % requestors.size()
		
		var extracted = extracting_from.extract()
		if extracted == null:
			return
		
		var extracted_component : Component = component_scene.instantiate()
		extracted_component.data = extracted
		next_requestor.receive(extracted_component)
		extracted_component.position = next_requestor.building.position
		# Temporary, maybe add Spawner autoload? This is just relying on the Patch to be a child of "Objects"
		building.get_parent().add_child(extracted_component)
