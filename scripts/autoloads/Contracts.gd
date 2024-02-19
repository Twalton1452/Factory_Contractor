extends Node

## Autoloaded

signal accepted_contract(contract: Contract)

var available_contracts : Array[Contract] = []
var active_contracts : Array[Contract] = []
var completed_contracts : Array[Contract] = []

const MAX_DIFFICULTY = 4

func accept_contract(contract: Contract) -> void:
	available_contracts.erase(contract)
	active_contracts.push_back(contract)
	contract.start()
	contract.fulfilled.connect(_on_contract_fulfilled, CONNECT_ONE_SHOT)
	accepted_contract.emit(contract)
	print_debug("Player Accepted Contract: ", contract.display_name)

func _on_contract_fulfilled(contract: Contract) -> void:
	active_contracts.erase(contract)
	completed_contracts.push_back(contract)
	print("Player fulfilled Contract: ", contract.display_name)

func generate_contract_for_coordinates(coords: Vector2) -> Contract:
	var new_contract = Contract.new()
	if coords == Plots.HOME_COORDINATES:
		new_contract.contract_type = Contract.Type.REMOTE
		# TODO: allow player to fulfill contracts at their already owned spaces for bonuses
	else:
		new_contract.contract_type = Contract.Type.ON_SITE
	
	# Difficulty increases as the player goes further from their home base
	var difficulty_level : int = clamp(ceili(coords.distance_to(Plots.HOME_COORDINATES)), 0, MAX_DIFFICULTY) # Distance difficulty
	var required_component_pool = pow(difficulty_level, 2.0) * 100 # Total number of components needed
	var tier_distribution = get_component_distribution_from_difficulty(difficulty_level) # Component Tier information
	
	for tier_key in tier_distribution.keys():
		var taken_from_pool = tier_distribution[tier_key]["pool_percent"] * required_component_pool
		required_component_pool -= taken_from_pool
		for goal in get_unique_goals(tier_key, tier_distribution[tier_key]["num_goals"], taken_from_pool):
			new_contract.goals.push_back(goal)
	
	new_contract.display_name = "Contract: " + str(coords) + " Difficulty: " + str(difficulty_level)
	new_contract.requested_by = "Auto-Generated"
	print("Spawned New Contract for {coords} {display_name}".format({ "coords": coords, "display_name": new_contract.display_name }))
	for goal in new_contract.goals:
		print("Goal: {component} {amount}".format({ "component": goal.component_data.display_name, "amount": goal.required_amount }))
	print("--------------------------------------------------------")
	return new_contract

## Hard coded difficulty settings until I can figure out a formula for how I want it
func get_component_distribution_from_difficulty(difficulty: int) -> Dictionary:
	match difficulty:
		0:
			return {
				ComponentDB.Tier.RAW: {
					"num_goals": 1,
					"pool_percent": 1.0
				}
			}
		1:
			return {
				ComponentDB.Tier.TIER_HALF: {
					"num_goals": 2,
					"pool_percent": 1.0
				}
			}
		2:
			return {
				ComponentDB.Tier.TIER_HALF: {
					"num_goals": 2,
					"pool_percent": 0.8
				},
				ComponentDB.Tier.TIER_ONE: {
					"num_goals": 1,
					"pool_percent": 0.2
				},
			}
		3:
			return {
				ComponentDB.Tier.TIER_HALF: {
					"num_goals": 1,
					"pool_percent": 0.3
				},
				ComponentDB.Tier.TIER_ONE: {
					"num_goals": 2,
					"pool_percent": 0.6
				},
				ComponentDB.Tier.TIER_TWO: {
					"num_goals": 1,
					"pool_percent": 0.1
				},
			}
		4:
			return {
				ComponentDB.Tier.TIER_HALF: {
					"num_goals": 1,
					"pool_percent": 0.2
				},
				ComponentDB.Tier.TIER_ONE: {
					"num_goals": 3,
					"pool_percent": 0.5
				},
				ComponentDB.Tier.TIER_TWO: {
					"num_goals": 2,
					"pool_percent": 0.3
				},
				#ComponentDB.Tier.TIER_THREE: {
					#"num_goals": 1,
					#"pool_percent": 0.1
				#},
			}
	
	return {}

func get_unique_goals(tier: ComponentDB.Tier, num_goals: int, total_amount: int) -> Array[Contract.Goal]:
	var goals : Array[Contract.Goal] = []
	var tier_copy = ComponentDB.TIERS[tier].duplicate()
	var amount_per_goal : int = floori(float(total_amount) / float(num_goals)) # Even distribution
	
	while goals.size() < num_goals and tier_copy.size() > 0:
		var random_i = randi_range(0, tier_copy.size() - 1)
		var component_data : ComponentData = tier_copy[random_i]
		goals.push_back(Contract.Goal.new(component_data, amount_per_goal))
		tier_copy.remove_at(random_i)
	
	return goals
