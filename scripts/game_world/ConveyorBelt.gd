extends Node
class_name ConveyorBelt

## Node to attach to a Building.
## Will move things ontop of the Building.
## Will grab things behind the Building.

var building : Building = null
var holding : Component = null
var next_in_line : ConveyorBelt = null
var grabbing_from : Extractor = null
var received_this_tick = false
var moved_this_tick = false

func _ready() -> void:
	add_to_group(Constants.CONVEYOR_GROUP)
	name = Constants.CONVEYOR_BELT
	
	building = get_parent()
	building.area_entered.connect(_on_building_entered)
	building.area_exited.connect(_on_building_exited)
	building.rotated.connect(_on_rotated)
	
	# Detecting Components to move them
	building.collision_mask |= Constants.COMPONENT_LAYER
	
	update_neighbors()

func _exit_tree():
	if grabbing_from != null:
		grabbing_from.unregister_requestor(self)

func update_neighbors() -> void:
	find_next_in_line()
	
	var neighbors = building.get_neighbors()
	for neighbor in neighbors.as_array():
		var conveyor : ConveyorBelt = neighbor.get_node_or_null(Constants.CONVEYOR_BELT)
		if conveyor:
			conveyor.find_next_in_line()
	
	# "Grabber" behavior (Think Plate Up!)
	if neighbors.behind != null:
		var extractor : Extractor = neighbors.behind.get_node_or_null(Constants.EXTRACTOR)
		if extractor:
			extractor.register_requestor(self)
			grabbing_from = extractor

func _on_rotated() -> void:
	if grabbing_from:
		grabbing_from.unregister_requestor(self)
	update_neighbors()

func find_next_in_line() -> void:
	var forward_building = Helpers.ray_forward(building)
	if forward_building == null:
		next_in_line = null
		return
	
	var conveyor : ConveyorBelt = forward_building.get_node_or_null(Constants.CONVEYOR_BELT)
	if conveyor:
		next_in_line = conveyor
		
		# Facing each other
		# if this conveyor appeared infront of a conveyor that previously didn't have a next_in_line
		#if (-next_in_line.building.transform.x.normalized()).is_equal_approx(building.transform.x.normalized()):
			#next_in_line.next_in_line = self

## Primarily for when a conveyor is placed ontop of a free Component
func _on_building_entered(area: Area2D) -> void:
	if area.collision_layer & Constants.COMPONENT_LAYER == Constants.COMPONENT_LAYER:
		receive(area)

func _on_building_exited(area: Area2D) -> void:
	if area == holding:
		holding = null

func can_receive() -> bool:
	return holding == null and not received_this_tick

func receive(something: Component) -> void:
	holding = something
	received_this_tick = true

# TODO: Revisit
# Unused, I kind of like the instant popping for the 1-bit artstyle atm.
# I think Lerping will be better for perf than tweening, but the smoothness and ease
# of the tween looks nice from an aesthetic perspective just watching things work
func animate_move() -> void:
	var t = holding.create_tween()
	var time_to_move = float(Constants.CONVEYOR_TICK_RATE) / float(Engine.physics_ticks_per_second) - 0.05
	var target_position = holding.position + building.transform.x.normalized() * Constants.TILE_SIZE
	t.tween_property(holding, "position", target_position, time_to_move)

func tick() -> void:
	if holding and (not received_this_tick or moved_this_tick):
		if next_in_line != null:
			if next_in_line.can_receive():
				next_in_line.receive(holding)
				holding.position += (building.transform.x.normalized().snapped(Vector2.ONE) * Constants.TILE_SIZE)
				moved_this_tick = true
				holding = null
		# Throw it off the Belt
		#else:
			#holding.position += building.transform.x.normalized() * Constants.TILE_SIZE
			#holding = null
			#print("end of the line for ", name)

func post_tick() -> void:
	received_this_tick = false
	moved_this_tick = false
