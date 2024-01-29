extends Node
class_name Extractor

## Node to attach to a Building.
## Will extract Components ontop of the Building

signal extracted(output: Component)

var building : Building = null
var extracting_from : ComponentPatch = null
var holding : Component = null

var component_scene : PackedScene = preload("res://scenes/component.tscn")

func _ready() -> void:
	add_to_group(Constants.EXTRACTOR_GROUP)
	name = Constants.EXTRACTOR
	
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	
	# Detecting Patch's to Extract from them
	building.collision_mask |= Constants.COMPONENT_PATCH_LAYER

func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_PATCH_LAYER == Constants.COMPONENT_PATCH_LAYER:
		extracting_from = area
		extracting_from.empty.connect(_on_patch_empty)

func _on_building_exited(area: Area2D) -> void:
	if area == extracting_from:
		if extracting_from.empty.is_connected(_on_patch_empty):
			extracting_from.empty.disconnect(_on_patch_empty)
		extracting_from = null
	elif area == holding:
		holding = null

func _on_patch_empty() -> void:
	extracting_from = null
	building.modulate = building.modulate.darkened(0.6)

func take_from() -> Component:
	var taking = holding
	holding = null
	return taking

func tick() -> void:
	if extracting_from != null and holding == null:
		var extracted_data = extracting_from.extract()
		if extracted_data == null:
			return
		
		var extracted_component : Component = component_scene.instantiate()
		extracted_component.data = extracted_data
		extracted_component.position = building.position
		holding = extracted_component
		building.get_parent().add_child(extracted_component)
		extracted.emit(extracted_component)
