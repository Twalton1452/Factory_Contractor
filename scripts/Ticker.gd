extends Node

const CONVEYOR_TICK_RATE = 60
const EXTRACTOR_TICK_RATE = 60

func _physics_process(_delta):
	if Engine.get_physics_frames() % CONVEYOR_TICK_RATE == 0:
		tick_conveyors()
	if Engine.get_physics_frames() % EXTRACTOR_TICK_RATE == 0:
		tick_extractors()

func tick_conveyors() -> void:
	for conveyor in get_tree().get_nodes_in_group(Constants.CONVEYOR_GROUP):
		(conveyor as ConveyorBelt).tick()

func tick_extractors() -> void:
	for conveyor in get_tree().get_nodes_in_group(Constants.EXTRACTOR_GROUP):
		(conveyor as Extractor).tick()
