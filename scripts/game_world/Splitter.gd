extends Node
class_name Splitter

var building : Building = null
var neighbors : Array[Building] = []
var next_in_line_index = 0

func _ready() -> void:
	add_to_group(Constants.SPLITTER_GROUP)
	name = Constants.SPLITTER
	
	building = get_parent()
	building.rotated.connect(_on_rotated)
	building.new_neighbor.connect(_on_new_neighbor)
	building.neighbor_left.connect(_on_neighbor_left)
	
	update_neighbors()

func _exit_tree() -> void:
	for neighbor in neighbors:
		if neighbor.rotated.is_connected(_on_neighbor_rotated):
			neighbor.rotated.disconnect(_on_neighbor_rotated)

func update_neighbors() -> void:
	var building_neighbors := building.get_neighbors()
	neighbors.clear()
	
	# Don't push to Buildings facing us
	for neighbor in building_neighbors.as_array():
		if not neighbor.rotated.is_connected(_on_neighbor_rotated):
			neighbor.rotated.connect(_on_neighbor_rotated)
		
		# Don't output to things that Move Components that are also facing the Splitter
		# Otherwise directionality doesn't matter
		if neighbor.get_node_or_null(Constants.CONVEYOR_BELT) or neighbor.get_node_or_null(Constants.UNDERGROUND_CONVEYOR):
			if Helpers.is_node_facing_away_from_other_node(neighbor, building):
				neighbors.push_back(neighbor)
		else:
			neighbors.push_back(neighbor)

func _on_new_neighbor(_new_neighbor: Building) -> void:
	update_neighbors()

func _on_neighbor_left(leaving_neighbor: Building) -> void:
	neighbors.erase(leaving_neighbor)

func _on_rotated() -> void:
	update_neighbors()

func _on_neighbor_rotated() -> void:
	update_neighbors()

func get_next_neighbor() -> Building:
	var i = 0
	next_in_line_index = (next_in_line_index + 1) % neighbors.size()
	while !neighbors[next_in_line_index].can_receive(building.holding):
		next_in_line_index = (next_in_line_index + 1) % neighbors.size()
		i += 1
		if i >= neighbors.size():
			return null
	return neighbors[next_in_line_index]

func tick() -> void:
	if neighbors.size() == 0 or building.holding == null:
		return
	
	var next_neighbor = get_next_neighbor()
	if next_neighbor == null:
		return
	
	next_neighbor.receive(building.take_from())
