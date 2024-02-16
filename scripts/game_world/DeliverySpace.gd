extends Node
class_name DeliverySpace

## Class designated to deliver components out of a StorageBuilding to the Clients

# TODO:
#	- Players can flood the Space with a resource and choke out the others
#		- Ex: Contract calls for 100 iron and 5 copper, player could fill every slot with iron and never deliver copper
#		- Solution: Limit each resource to one slot when a DeliverySpace is attached
#	- UI to display progress
#	- Animation when in progress (Also applies to Assemblers)

var building : StorageBuilding = null

var contract_to_deliver_to : Contract = null
var packaging_delivery = false
var progress = 0.0
var time_to_package_seconds = 1.0
var payload_capacity = 5

func _ready():
	name = Constants.DELIVERY_SPACE
	add_to_group(Constants.DELIVERY_SPACE_GROUP)
	
	building = get_parent()
	var plot : Plot = Plots.get_current_plot()
	assert(plot != null, "Placed DeliverySpace on a null Plot")
	
	if plot.contract == null:
		plot.accepted_contract.connect(_on_accepted_plot_contract.bind(plot), CONNECT_ONE_SHOT)
	else:
		contract_to_deliver_to = plot.contract

func _on_accepted_plot_contract(plot: Plot) -> void:
	contract_to_deliver_to = plot.contract

func check_to_see_if_packaging_should_occur() -> void:
	if packaging_delivery or \
	contract_to_deliver_to == null or \
	contract_to_deliver_to.goals_fulfilled:
		return
	
	begin_packaging()

func begin_packaging() -> void:
	if packaging_delivery or contract_to_deliver_to == null:
		return
	
	var payload : Array[ComponentData] = []
	for slot in building.inventory_slots:
		for goal in contract_to_deliver_to.goals:
			if not goal.met and slot.component_data == goal.component_data:
				# Throughput restriction
				# Only taking 1 from each potential slot at the moment
				# Encourage putting multiple Delivery Zones / Upgrading?
				payload.push_back(building.take_from_slot_no_spawn(slot))
			
			if payload.size() >= payload_capacity:
				break
	
	if payload.size() == 0:
		return
	
	await package_contents()
	send_package(payload)

## Just a progress percentage to wait on for completion
func package_contents() -> void:
	var tick_progress = 1.0 / (Engine.physics_ticks_per_second * time_to_package_seconds)
	packaging_delivery = true
	
	while packaging_delivery and progress < 1.0:
		progress += tick_progress
		await get_tree().physics_frame
	
	progress = 0.0
	packaging_delivery = false

func send_package(package: Array[ComponentData]) -> void:
	for component_data in package:
		contract_to_deliver_to.deliver(component_data)

func tick() -> void:
	check_to_see_if_packaging_should_occur()
