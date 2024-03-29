class_name Constants

# World
const TILE_SIZE = 16
const UNDERGROUND_CONVEYOR_MAX_RANGE = 5 * Constants.TILE_SIZE

# Groups
const ASSEMBLER_GROUP = "Assemblers"
const BUILDING_GROUP = "Buildings"
const CONVEYOR_GROUP = "ConveyorBelts"
const DELIVERY_SPACE_GROUP = "DeliverySpaces"
const EXTRACTOR_GROUP = "Extractors"
const PLOT_GROUP = "Plots"
const SPLITTER_GROUP = "Splitters"
const UNDERGROUND_CONVEYOR_GROUP = "UndergroundConveyors"

# Layers
const FACTORY_LAYER = 1 << 0
const COMPONENT_PATCH_LAYER = 1 << 1
const COMPONENT_LAYER = 1 << 2
const ASSEMBLER_LAYER = 1 << 3
const UNDERGROUND_LAYER = 1 << 4

# Building Component Names
const ASSEMBLER = "Assembler"
const EXTRACTOR = "Extractor"
const CONVEYOR_BELT = "ConveyorBelt"
const DELIVERY_SPACE = "DeliverySpace"
const SPLITTER = "Splitter"
const UNDERGROUND_CONVEYOR = "UndergroundConveyor"

# Tick Rates
const BUILDING_TICK_RATE = 20

# UI
const TOOLTIP_LINE = "{amount}x {display_name}"
const CONTRACT_GOAL_TOOLTIP_LINE = "{display_name}: {current_amount}/{required_amount}"
