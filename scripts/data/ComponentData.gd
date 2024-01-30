@icon("res://art/editor_icons/data.svg")
extends Resource
class_name ComponentData

@export var display_name : StringName
@export var icon : Texture
@export var color_adjustment = Color.WHITE
@export var required_components : Dictionary # { key: ComponentData, val: int }

@export_category("Placement")
## Nodes to attach to this Component when placed. Signifies it is a Building whe not null |
## TODO: BuildingData instead?
@export var to_attach : Script

## When the Component is placed into the game world it will exist on this collision layer
@export_flags_2d_physics var placed_layer : int
## When the Player is attempting to place this Component into the game world it require being placed on this layer
## Ex: Extractor Machines need Patches
@export_flags_2d_physics var required_layer : int
