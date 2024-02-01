extends Control

## Class to manage the UI elements related to adjusting Assemblers

@onready var craftable_parent : GridContainer = $AvailableRecipesPanel/MarginContainer/GridContainer
@onready var current_recipe_icon : TextureRect = $TextureRect/CurrentRecipeIcon
@onready var required_components_parent : Container = $RequiredComponentsPanel/MarginContainer/GridContainer

var available_recipes : Array[ComponentData] = [
	load("res://resources/components/basic_extractor.tres"),
	load("res://resources/components/basic_assembler.tres"),
	load("res://resources/components/conveyor_belt.tres"),
	load("res://resources/components/underground_conveyor.tres"),
]

var currently_selected_assembler : Assembler = null :
	set(value):
		currently_selected_assembler = value
		if currently_selected_assembler and currently_selected_assembler.end_result != null:
			current_recipe_icon.texture = currently_selected_assembler.end_result.icon
		else:
			current_recipe_icon.texture = null

func _ready():
	MessageBus.player_selected_assembler.connect(_on_player_selected_assembler)
	hide()
	setup_recipe_buttons()
	setup_required_component_slots()

func setup_recipe_buttons() -> void:
	var recipe_slot_scene : PackedScene = load("res://scenes/ui/recipe_slot.tscn")
	for recipe_data in available_recipes:
		var recipe_slot : RecipeSlot = recipe_slot_scene.instantiate()
		recipe_slot.data = recipe_data
		craftable_parent.add_child(recipe_slot)

func setup_required_component_slots() -> void:
	var required_component_slot_scene : PackedScene = load("res://scenes/ui/required_component_slot.tscn")
	var max_num_components_required = 0
	
	for recipe_data in available_recipes:
		max_num_components_required = max(max_num_components_required, recipe_data.required_components.size())
	
	for i in range(max_num_components_required):
		var required_component_slot : RequiredComponentSlot = required_component_slot_scene.instantiate()
		required_components_parent.add_child(required_component_slot)
		required_component_slot.hide()

func _on_player_chose_recipe(recipe: ComponentData) -> void:
	currently_selected_assembler.end_result = recipe
	_on_player_released_cancel()

func populate_required_component_slots(crafting_intent: ComponentData) -> void:
	var i = 0
	for key in crafting_intent.required_components.keys(): # { key: ComponentData, val: int }
		var required_component_slot : RequiredComponentSlot = required_components_parent.get_child(i)
		required_component_slot.set_to(key, crafting_intent.required_components[key])
		required_component_slot.show()
		i += 1
	
	for j in range(i, required_components_parent.get_child_count()):
		required_components_parent.get_child(j).hide()

func _on_player_selected_assembler(assembler: Assembler) -> void:
	MessageBus.recipe_slot_pressed.connect(_on_player_chose_recipe)
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	currently_selected_assembler = assembler
	if currently_selected_assembler.end_result != null:
		populate_required_component_slots(currently_selected_assembler.end_result)
	show()

func _on_player_released_cancel() -> void:
	MessageBus.recipe_slot_pressed.disconnect(_on_player_chose_recipe)
	MessageBus.player_released_cancel.disconnect(_on_player_released_cancel)
	currently_selected_assembler = null
	hide()
