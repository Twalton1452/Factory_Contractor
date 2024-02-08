extends Node
class_name Extractor

## Node to attach to a Building.
## Will extract Components ontop of the Building

var building : Building = null
var extracting_from : ComponentPatch = null

func _ready() -> void:
	add_to_group(Constants.EXTRACTOR_GROUP)
	name = Constants.EXTRACTOR
	
	building = get_parent()
	find_component_patch_to_extract_from()

func find_component_patch_to_extract_from() -> void:
	extracting_from = Helpers.ray_self(building, Constants.COMPONENT_PATCH_LAYER)
	
	if extracting_from != null:
		extracting_from.empty.connect(_on_patch_empty)

func _exit_tree() -> void:
	if extracting_from and extracting_from.empty.is_connected(_on_patch_empty):
		extracting_from.empty.disconnect(_on_patch_empty)

func _on_patch_empty() -> void:
	extracting_from = null
	building.modulate = building.modulate.darkened(0.6)

func tick() -> void:
	if extracting_from != null and building.holding == null:
		var extracted_data = extracting_from.extract()
		if extracted_data == null:
			return
		
		var extracted_component : Component = ComponentDB.COMPONENT_SCENE.instantiate()
		extracted_component.data = extracted_data
		extracted_component.position = building.position
		building.receive(extracted_component)
		building.get_parent().add_child(extracted_component)
