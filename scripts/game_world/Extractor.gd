extends Node
class_name Extractor

## Node to attach to a Building.
## Will extract Components ontop of the Building

var building : Building = null
var extracting_from : ComponentPatch = null

var component_scene : PackedScene = preload("res://scenes/component.tscn")

func _ready() -> void:
	add_to_group(Constants.EXTRACTOR_GROUP)
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	building.collision_mask |= Constants.COMPONENT_PATCH_LAYER

func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_PATCH_LAYER == Constants.COMPONENT_PATCH_LAYER:
		extracting_from = area

func _on_building_exited(area: Area2D) -> void:
	if area == extracting_from:
		extracting_from = null

func tick() -> void:
	if extracting_from and extracting_from.can_extract():
		var extracted = extracting_from.extract()
		if extracted == null:
			return
		
		var extracted_component : Component = component_scene.instantiate()
		extracted_component.data = extracted
		extracted_component.position = building.position
		# Temporary, maybe add Spawner autoload?
		building.get_parent().add_child(extracted_component)
