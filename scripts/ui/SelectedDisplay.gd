extends Control

## Class to manage the UI elements related to adjusting Assemblers

@onready var craftable_parent : GridContainer = $AvailableRecipesPanel/MarginContainer/GridContainer
@onready var selected_icon : TextureRect = $SelectedIcon
@onready var current_recipe_icon : TextureRect = $SelectedIcon/CurrentRecipeIcon
@onready var required_components_parent : Container = $RequiredComponentsPanel/MarginContainer/GridContainer
@onready var required_components_panel : Container = $RequiredComponentsPanel

var available_recipes : Array[ComponentData] = [
	load("res://resources/components/basic_extractor.tres"),
	load("res://resources/components/basic_assembler.tres"),
	load("res://resources/components/conveyor_belt.tres"),
	load("res://resources/components/underground_conveyor.tres"),
	load("res://resources/components/storage_building.tres"),
]

# TODO: Refactor into a single "SelectedBuilding" or multiple single responsibility scripts
var currently_selected_assembler : Assembler = null :
	set(value):
		currently_selected_assembler = value
		if currently_selected_assembler and currently_selected_assembler.end_result != null:
			current_recipe_icon.texture = currently_selected_assembler.end_result.icon
		else:
			current_recipe_icon.texture = null

var currently_selected_storage : StorageBuilding = null

func _ready():
	MessageBus.player_selected_assembler.connect(_on_player_selected_assembler)
	MessageBus.player_selected_storage_container.connect(_on_player_selected_storage_container)
	hide()
	setup_recipe_buttons()
	setup_required_component_slots()

func set_selected_icon_to(data: ComponentData) -> void:
	selected_icon.texture = data.icon
	selected_icon.self_modulate = data.color_adjustment

func setup_recipe_buttons() -> void:
	var recipe_slot_scene : PackedScene = load("res://scenes/ui/recipe_slot.tscn")
	for recipe_data in available_recipes:
		var recipe_slot : RecipeSlot = recipe_slot_scene.instantiate()
		craftable_parent.add_child(recipe_slot)
	
	populate_recipe_slots()

func setup_required_component_slots() -> void:
	var required_component_slot_scene : PackedScene = load("res://scenes/ui/component_amount_slot.tscn")
	var max_num_components_required = 0
	
	for recipe_data in available_recipes:
		max_num_components_required = max(max_num_components_required, recipe_data.required_components.size())
	
	for i in range(max_num_components_required):
		var required_component_slot : ComponentAmountSlot = required_component_slot_scene.instantiate()
		required_components_parent.add_child(required_component_slot)
		required_component_slot.hide()
	required_components_panel.hide()

func populate_recipe_slots() -> void:
	for i in range(available_recipes.size()):
		(craftable_parent.get_child(i) as RecipeSlot).set_to(available_recipes[i])
		craftable_parent.get_child(i).show()

func populate_required_component_slots(crafting_intent: ComponentData) -> void:
	var i = 0
	for key in crafting_intent.required_components.keys(): # { key: ComponentData, val: int }
		var required_component_slot : ComponentAmountSlot = required_components_parent.get_child(i)
		required_component_slot.set_to(key, crafting_intent.required_components[key])
		required_component_slot.show()
		i += 1
	
	for j in range(i, required_components_parent.get_child_count()):
		required_components_parent.get_child(j).hide()

func populate_storage_container_inventory_slots(storage_container: StorageBuilding) -> void:
	var i = 0
	for key in storage_container.inventory.keys(): # { key: ComponentData, val: int }
		var component_slot : ComponentAmountSlot = required_components_parent.get_child(i)
		component_slot.set_to(key, storage_container.inventory[key])
		component_slot.show()
		i += 1
	
	for j in range(i, required_components_parent.get_child_count()):
		required_components_parent.get_child(j).hide()

func _on_player_chose_recipe(recipe: ComponentData) -> void:
	currently_selected_assembler.end_result = recipe
	hide_display()

func _on_player_selected_assembler(assembler: Assembler) -> void:
	MessageBus.recipe_slot_pressed.connect(_on_player_chose_recipe)
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	set_selected_icon_to(assembler.building.data)
	currently_selected_assembler = assembler
	if currently_selected_assembler.end_result != null:
		populate_required_component_slots(currently_selected_assembler.end_result)
	populate_recipe_slots()
	show()
	required_components_panel.show()

func _on_player_selected_storage_container(storage_container: StorageBuilding) -> void:
	MessageBus.player_released_cancel.connect(_on_player_released_cancel)
	storage_container.received_component.connect(_update_storage_container_display.bind(storage_container))
	set_selected_icon_to(storage_container.data)
	currently_selected_storage = storage_container
	_update_storage_container_display(null, storage_container)
	show()
	required_components_panel.hide()

# TODO: Can be done better, currently updating every slot upon receiving anything
func _update_storage_container_display(_received_component: Component, storage_container: StorageBuilding) -> void:
	var i = 0
	for data_key in storage_container.inventory.keys():
		(craftable_parent.get_child(i) as RecipeSlot).set_to(data_key, storage_container.inventory[data_key])
		craftable_parent.get_child(i).show()
		i += 1
	
	for j in range(i, craftable_parent.get_child_count()):
		craftable_parent.get_child(j).hide()

func _on_player_released_cancel() -> void:
	hide_display()

func hide_display() -> void:
	if MessageBus.recipe_slot_pressed.is_connected(_on_player_chose_recipe):
		MessageBus.recipe_slot_pressed.disconnect(_on_player_chose_recipe)
	if MessageBus.player_released_cancel.is_connected(_on_player_released_cancel):
		MessageBus.player_released_cancel.disconnect(_on_player_released_cancel)
	
	if currently_selected_storage != null and \
	currently_selected_storage.received_component.is_connected(_update_storage_container_display):
		currently_selected_storage.received_component.disconnect(_update_storage_container_display)
	
	currently_selected_assembler = null
	currently_selected_storage = null
	hide()
