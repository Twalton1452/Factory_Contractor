extends Node


func _physics_process(_delta):
	if Engine.get_physics_frames() % Constants.CONVEYOR_TICK_RATE == 0:
		tick_conveyors()
	if Engine.get_physics_frames() % Constants.EXTRACTOR_TICK_RATE == 0:
		tick_extractors()

func tick_conveyors() -> void:
	for conveyor in get_tree().get_nodes_in_group(Constants.CONVEYOR_GROUP):
		(conveyor as ConveyorBelt).tick()
	
	for conveyor in get_tree().get_nodes_in_group(Constants.CONVEYOR_GROUP):
		(conveyor as ConveyorBelt).post_tick()

func tick_extractors() -> void:
	for conveyor in get_tree().get_nodes_in_group(Constants.EXTRACTOR_GROUP):
		(conveyor as Extractor).tick()
