@icon("res://art/editor_icons/data.svg")
extends Resource
class_name ComponentData

@export var display_name : StringName
@export var icon : Texture
@export var color_adjustment = Color.WHITE
@export var required_components : Dictionary # { key: ComponentData, val: int }
@export var crafting_time_seconds : float = 1.0

@export_category("Placement")
## Nodes to attach to this Component when placed. Signifies it is a Building whe not null |
## TODO: BuildingData instead?
@export var to_attach : Script
## Override the default Building Scene. Useful when you need a more customized Building.
@export var scene_override : PackedScene
## 1 == 1x1 | 2 == 2x2 | 3 == 3x3
@export_range(1, 3) var size : int = 1

## When the Component is placed into the game world it will exist on this collision layer
@export_flags_2d_physics var placed_layer : int
## When the Player is attempting to place this Component into the game world it require being placed on this layer
## Ex: Extractor Machines need Patches
@export_flags_2d_physics var required_layer : int
