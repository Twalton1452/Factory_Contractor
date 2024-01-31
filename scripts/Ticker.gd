extends Node


func _physics_process(_delta):
	if Engine.get_physics_frames() % Constants.BUILDING_TICK_RATE == 0:
		tick_buildings()

func tick_buildings() -> void:
	for conveyor in get_tree().get_nodes_in_group(Constants.CONVEYOR_GROUP):
		(conveyor as ConveyorBelt).tick()
	
	for conveyor in get_tree().get_nodes_in_group(Constants.SPLITTER_GROUP):
		(conveyor as Splitter).tick()
	
	for extractor in get_tree().get_nodes_in_group(Constants.EXTRACTOR_GROUP):
		(extractor as Extractor).tick()
	
	for building in get_tree().get_nodes_in_group(Constants.BUILDING_GROUP):
		building.post_tick()
