extends Control

## Class to manage the UI elements related to adjusting Assemblers

@onready var craftable_parent : GridContainer = $PanelContainer/MarginContainer/GridContainer
@onready var current_recipe_icon : TextureRect = $TextureRect/CurrentRecipeIcon

var available_recipes : Array[ComponentData] = [
	load("res://resources/components/basic_extractor.tres"),
	load("res://resources/components/basic_machine.tres"),
	load("res://resources/components/conveyor_belt.tres"),
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

func setup_recipe_buttons() -> void:
	var recipe_slot_scene : PackedScene = load("res://scenes/ui/recipe_slot.tscn")
	for recipe_data in available_recipes:
		var recipe_slot : RecipeSlot = recipe_slot_scene.instantiate()
		recipe_slot.data = recipe_data
		craftable_parent.add_child(recipe_slot)

func _on_player_chose_recipe(recipe: ComponentData) -> void:
	currently_selected_assembler.end_result = recipe
	_on_player_released_cancel()

func _on_player_selected_assembler(assembler: Assembler) -> void:
	MessageBus.recipe_slot_pressed.connect(_on_player_chose_recipe)
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	currently_selected_assembler = assembler
	show()

func _on_player_released_cancel() -> void:
	MessageBus.recipe_slot_pressed.disconnect(_on_player_chose_recipe)
	MessageBus.player_released_cancel.disconnect(_on_player_released_cancel)
	currently_selected_assembler = null
	hide()
