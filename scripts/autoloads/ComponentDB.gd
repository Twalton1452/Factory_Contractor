extends Node

## Autoloaded

## Class for holding references to Components and containers of Components.
## This should help reduce points of failure when refactoring/moving files

const COMPONENT_SCENE = preload("res://scenes/component.tscn")

# Raw Components - No Required Components (Harvested)
const COPPER = preload("res://resources/components/copper.tres")
const IRON = preload("res://resources/components/iron.tres")

const RAW_COMPONENTS : Array[ComponentData] = [
	COPPER,
	IRON,
]

# Tier 1.5 Components - Refined Raw Components
const SMELTED_COPPER = preload("res://resources/components/smelted_copper.tres")
const SMELTED_IRON = preload("res://resources/components/smelted_iron.tres")

const TIER_HALF : Array[ComponentData] = [
	SMELTED_COPPER,
	SMELTED_IRON,
]

# Tier 1 Components - Takes Refined/Unrefined Components
const BASIC_EXTRACTOR = preload("res://resources/components/basic_extractor.tres")
const BASIC_ASSEMBLER = preload("res://resources/components/basic_assembler.tres")
const CONVEYOR_BELT = preload("res://resources/components/conveyor_belt.tres")
const DELIVERY_ZONE = preload("res://resources/components/delivery_zone.tres")
const STORAGE_BUILDING = preload("res://resources/components/storage_building.tres")
const SPLITTER = preload("res://resources/components/splitter.tres")

const TIER_ONE_COMPONENTS : Array[ComponentData] = [
	BASIC_EXTRACTOR,
	BASIC_ASSEMBLER,
	CONVEYOR_BELT,
	DELIVERY_ZONE,
	STORAGE_BUILDING,
	SPLITTER,
]

# Tier 2 Components - Takes a Tier 1 Component
const UNDERGROUND_CONVEYOR = preload("res://resources/components/underground_conveyor.tres")

const TIER_TWO_COMPONENTS : Array[ComponentData] = [
	UNDERGROUND_CONVEYOR,
]

# This might need its own Resource
var available_recipes : Array[ComponentData] = [
	BASIC_EXTRACTOR,
	BASIC_ASSEMBLER,
	CONVEYOR_BELT,
	DELIVERY_ZONE,
	SPLITTER,
	STORAGE_BUILDING,
	UNDERGROUND_CONVEYOR,
	# TODO: Remove later
	SMELTED_COPPER,
	SMELTED_IRON
]

var smeltable_recipes : Array[ComponentData] = [
	SMELTED_COPPER,
	SMELTED_IRON,
]

## Used for indicies in TIERS array
enum Tier {
	RAW = 0,
	TIER_HALF = 1,
	TIER_ONE = 2,
	TIER_TWO = 3,
}

## lower tier components appear first
var TIERS : Array[Array] = []

func _ready():
	TIERS.push_back(RAW_COMPONENTS)
	TIERS.push_back(TIER_HALF)
	TIERS.push_back(TIER_ONE_COMPONENTS)
	TIERS.push_back(TIER_TWO_COMPONENTS)

func construct_tooltip(data: ComponentData) -> String:
	if data == null:
		return ""
	
	var tooltip = data.display_name + "\n"
	for component_data in data.required_components.keys():
		tooltip += Constants.TOOLTIP_LINE.format({"amount": data.required_components[component_data], "display_name": component_data.display_name }) + "\n"
	return tooltip
