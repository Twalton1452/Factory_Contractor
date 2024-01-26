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
	building.collision_mask |= Constants.COMPONENT_PATCH_LAYER
	
	find_requestors()

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

## When the Extract is placed, it needs to fight where to Extract to
## If it was already placed and there is nothing nearby then whenever a neighboring
## requestor is placed, it will register itself to this Extractor
func find_requestors() -> void:
	# TODO: Check to make sure the Building is facing the opposite direction of this Extractor
	# Problem (E is Extractor, > is Conveyor facing Right):
	# 		E
	#		>
	# The conveyor is receiving Extracted Components, but I want it to Pull when it visually makes sense
	var left = Helpers.ray_cast(building, Vector2.LEFT, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	var down = Helpers.ray_cast(building, Vector2.DOWN, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	var right = Helpers.ray_cast(building, Vector2.RIGHT, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	var up = Helpers.ray_cast(building, Vector2.UP, Constants.TILE_SIZE, Constants.FACTORY_LAYER)
	
	if left.size() > 0:
		check_for_valid_requestor(left.collider)
	if down.size() > 0:
		check_for_valid_requestor(down.collider)
	if right.size() > 0:
		check_for_valid_requestor(right.collider)
	if up.size() > 0:
		check_for_valid_requestor(up.collider)

func check_for_valid_requestor(area: Area2D) -> void:
	var conveyor : ConveyorBelt = area.get_node_or_null(Constants.CONVEYOR_BELT)
	if conveyor != null:
		register_requestor(conveyor)

func register_requestor(requestor: ConveyorBelt) -> void:
	requestors.push_back(requestor)
	requestor.tree_exited.connect(_unregister_requestor)

func _unregister_requestor() -> void:
	var to_erase : ConveyorBelt = null
	for requestor in requestors:
		if not requestor.is_inside_tree():
			to_erase = requestor
			break
	requestors.erase(to_erase)

func tick() -> void:
	if extracting_from and requestors.size() > 0:
		var extracted = extracting_from.extract()
		if extracted == null:
			return
		
		var extracted_component : Component = component_scene.instantiate()
		extracted_component.data = extracted
		extracted_component.position = requestors[current_requestor].building.position
		current_requestor = (current_requestor + 1) % requestors.size()
		# Temporary, maybe add Spawner autoload?
		building.get_parent().add_child(extracted_component)
