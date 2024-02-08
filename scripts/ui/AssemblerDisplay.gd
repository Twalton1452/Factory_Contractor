extends Control
class_name AssemblerDisplay

## Class to manage the UI elements related to adjusting Assemblers

# TODO:
# Instead of showing the Required Components for the Craft
# Show the contents of the Assembler and update in real time
# So the player can see the Assembler getting the Components

@onready var craftable_parent : GridContainer = $AvailableRecipesPanel/MarginContainer/Recipes
@onready var current_recipe_icon : TextureRect = $CurrentRecipeIcon
@onready var required_components_parent : Container = $RequiredComponentsPanel/MarginContainer/Components
@onready var required_components_panel : Container = $RequiredComponentsPanel


var assembler_focus : Assembler = null :
	set(value):
		assembler_focus = value
		if assembler_focus and assembler_focus.end_result != null:
			current_recipe_icon.texture = assembler_focus.end_result.icon
			current_recipe_icon.tooltip_text = ComponentDB.construct_tooltip(assembler_focus.end_result)
			required_components_panel.show()
		else:
			current_recipe_icon.tooltip_text = ""
			current_recipe_icon.texture = null
			required_components_panel.hide()


func _ready():
	hide_display()
	setup_recipe_buttons()
	setup_required_component_slots()

func show_display(assembler: Assembler) -> void:
	assembler_focus = assembler
	if assembler_focus.end_result != null:
		populate_required_component_slots(assembler_focus)
		assembler_focus.building.received_component.connect(_on_assembler_building_component_changed)
		assembler_focus.building.component_taken.connect(_on_assembler_building_component_changed)
	populate_recipe_slots()
	show()

func hide_display() -> void:
	if assembler_focus != null:
		if assembler_focus.building.received_component.is_connected(_on_assembler_building_component_changed):
			assembler_focus.building.received_component.disconnect(_on_assembler_building_component_changed)
		if assembler_focus.building.component_taken.is_connected(_on_assembler_building_component_changed):
			assembler_focus.building.component_taken.disconnect(_on_assembler_building_component_changed)
	assembler_focus = null
	hide()

func setup_recipe_buttons() -> void:
	var pressable_slot_scene : PackedScene = load("res://scenes/ui/pressable_component_amount_slot.tscn")
	for recipe_data in ComponentDB.available_recipes:
		var pressable_slot : PressableComponentAmountSlot = pressable_slot_scene.instantiate()
		pressable_slot.button.pressed.connect(_on_player_chose_recipe.bind(recipe_data))
		craftable_parent.add_child(pressable_slot)
	
	populate_recipe_slots()

func setup_required_component_slots() -> void:
	var required_component_slot_scene : PackedScene = load("res://scenes/ui/component_amount_slot.tscn")
	var max_num_components_required = 0
	
	for recipe_data in ComponentDB.available_recipes:
		max_num_components_required = max(max_num_components_required, recipe_data.required_components.size())
	
	for i in range(max_num_components_required):
		var required_component_slot : ComponentAmountSlot = required_component_slot_scene.instantiate()
		required_components_parent.add_child(required_component_slot)
		required_component_slot.hide()

func populate_recipe_slots() -> void:
	for i in range(ComponentDB.available_recipes.size()):
		(craftable_parent.get_child(i) as PressableComponentAmountSlot).set_to(ComponentDB.available_recipes[i])
		craftable_parent.get_child(i).show()

func populate_required_component_slots(assembler: Assembler) -> void:
	var i = 0
	for key in assembler.storage.keys(): # { key: ComponentData, val: int }
		var required_component_slot : ComponentAmountSlot = required_components_parent.get_child(i)
		required_component_slot.set_to(key, assembler.storage[key])
		required_component_slot.show()
		
		if assembler.storage[key] < assembler.end_result.required_components[key]:
			required_component_slot.background.self_modulate = Color.RED
		else:
			required_component_slot.background.self_modulate = Color.WHITE
		i += 1
	
	for j in range(i, required_components_parent.get_child_count()):
		required_components_parent.get_child(j).hide()

func _on_player_chose_recipe(recipe: ComponentData) -> void:
	assembler_focus.end_result = recipe
	hide_display()

func _on_assembler_building_component_changed(_component: Component) -> void:
	populate_required_component_slots(assembler_focus)
