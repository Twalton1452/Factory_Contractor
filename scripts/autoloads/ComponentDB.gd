extends Node

## Autoloaded

## Class for holding references to Components and containers of Components.
## This should help reduce points of failure when refactoring/moving files

const COMPONENT_SCENE = preload("res://scenes/component.tscn")

# Raw Components - No Required Components (Harvested)
const COPPER = preload("res://resources/components/copper.tres")
const IRON = preload("res://resources/components/iron.tres")

# Tier 1 Components - Takes Refined/Unrefined Components
const BASIC_EXTRACTOR = preload("res://resources/components/basic_extractor.tres")
const BASIC_ASSEMBLER = preload("res://resources/components/basic_assembler.tres")
const CONVEYOR_BELT = preload("res://resources/components/conveyor_belt.tres")
const STORAGE_BUILDING = preload("res://resources/components/storage_building.tres")
const SPLITTER = preload("res://resources/components/splitter.tres")

# Tier 2 Components - Takes a Tier 1 Component
const UNDERGROUND_CONVEYOR = preload("res://resources/components/underground_conveyor.tres")

# This might need its own Resource
var available_recipes : Array[ComponentData] = [
	BASIC_EXTRACTOR,
	BASIC_ASSEMBLER,
	CONVEYOR_BELT,
	SPLITTER,
	STORAGE_BUILDING,
	UNDERGROUND_CONVEYOR,
]

func construct_tooltip(data: ComponentData) -> String:
	if data == null:
		return ""
	
	var tooltip = data.display_name + "\n"
	for component_data in data.required_components.keys():
		tooltip += Constants.TOOLTIP_LINE.format({"amount": data.required_components[component_data], "display_name": component_data.display_name }) + "\n"
	return tooltip
