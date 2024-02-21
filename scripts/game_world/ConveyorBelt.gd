extends Node
class_name ConveyorBelt

## Node to attach to a Building.
## Will move things ontop of the Building.
## Will grab things behind the Building.

var building : Building = null
var next_in_line : Building = null
var grabbing_from : Building = null

func _ready() -> void:
	add_to_group(Constants.CONVEYOR_GROUP)
	name = Constants.CONVEYOR_BELT
	
	building = get_parent()
	building.rotated.connect(_on_rotated)
	building.new_neighbor.connect(_on_new_neighbor)
	
	update_neighbors()

func update_neighbors() -> void:
	# This is dependent on physics updating, but signal frames can occur faster than physics updates
	# So make sure we're on the latest physics update before attempting anything
	# If we don't, its possible it doesn't detect neighbors correctly.
	# Again another problem for Physics based detection instead of using a Grid
	await get_tree().physics_frame
	
	next_in_line = Helpers.ray_forward(building)
	grabbing_from = Helpers.ray_behind(building)

func _on_new_neighbor(_new_neighbor: Building) -> void:
	update_neighbors()

func _on_rotated() -> void:
	update_neighbors()

# TODO: Revisit
# Unused, I kind of like the instant popping for the 1-bit artstyle atm.
# I think Lerping will be better for perf than tweening, but the smoothness and ease
# of the tween looks nice from an aesthetic perspective just watching things work
func animate_move() -> void:
	var t = building.holding.create_tween()
	var time_to_move = float(Constants.BUILDING_TICK_RATE) / float(Engine.physics_ticks_per_second) - 0.05
	var target_position = building.holding.position + building.transform.x.normalized() * Constants.TILE_SIZE
	t.tween_property(building.holding, "position", target_position, time_to_move)

func push() -> void:
	if not building.holding or next_in_line == null:
		return
	
	if next_in_line.can_receive(building.holding) and building.can_take():
		var moving = building.take_from()
		next_in_line.receive(moving)

func pull() -> void:
	if building.holding or grabbing_from == null:
		return
	
	if grabbing_from.can_take():
		var taking = grabbing_from.take_from()
		building.receive(taking)

func tick() -> void:
	pass
