extends Node
class_name UndergroundConveyor

var building : Building = null
var next_in_line : Building = null
var ticks_to_next_in_line = 0
var ticks = 0

func _ready() -> void:
	add_to_group(Constants.UNDERGROUND_CONVEYOR_GROUP)
	name = Constants.UNDERGROUND_CONVEYOR
	
	building = get_parent()
	building.rotated.connect(_on_rotated)
	building.new_neighbor.connect(_on_new_neighbor)
	building.collision_layer |= Constants.UNDERGROUND_LAYER
	
	update_neighbors()
	find_next_underground_conveyor()

func update_neighbors() -> void:
	for underground_neighbor in [
		Helpers.ray_behind(building, Constants.UNDERGROUND_CONVEYOR_MAX_RANGE, Constants.UNDERGROUND_LAYER),
		Helpers.ray_left(building, Constants.UNDERGROUND_CONVEYOR_MAX_RANGE, Constants.UNDERGROUND_LAYER),
		Helpers.ray_right(building, Constants.UNDERGROUND_CONVEYOR_MAX_RANGE, Constants.UNDERGROUND_LAYER)
	]:
		if underground_neighbor != null:
			(underground_neighbor.get_node(Constants.UNDERGROUND_CONVEYOR) as UndergroundConveyor).find_next_underground_conveyor()

## Tries to find another UndergroundConveyor first.
## When it cannot be found, it looks for a Building infront
func find_next_underground_conveyor() -> void:
	next_in_line = Helpers.ray_forward(building, Constants.UNDERGROUND_CONVEYOR_MAX_RANGE, Constants.UNDERGROUND_LAYER)
	if next_in_line != null:
		ticks_to_next_in_line = snapped(building.position.distance_to(next_in_line.position), 1.0) / Constants.TILE_SIZE
	else:
		next_in_line = Helpers.ray_forward(building)
	
	if next_in_line != null:
		building.sprite.modulate = building.data.color_adjustment
		if not next_in_line.tree_exited.is_connected(_on_next_in_line_gone):
			next_in_line.tree_exited.connect(_on_next_in_line_gone)
	else:
		building.sprite.modulate = building.data.color_adjustment.darkened(0.5)
	ticks = 0

func _on_next_in_line_gone() -> void:
	building.sprite.modulate = building.data.color_adjustment.darkened(0.5)
	next_in_line.tree_exited.disconnect(_on_next_in_line_gone)
	find_next_underground_conveyor.call_deferred()

func _on_new_neighbor(_new_neighbor: Building) -> void:
	find_next_underground_conveyor()

func _on_rotated() -> void:
	update_neighbors()
	find_next_underground_conveyor()

func tick() -> void:
	if not building.holding or next_in_line == null:
		return
	
	# TODO: Only moves one item at a time after X ticks which is bad
	ticks += 1
	if ticks >= ticks_to_next_in_line and next_in_line.can_receive(building.holding):
		next_in_line.receive(building.take_from())
		ticks = 0
