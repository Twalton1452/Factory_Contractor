extends Control

## Class to route to appropriate UI when player selects an ingame Building

@onready var selected_icon : TextureRect = $SelectedIcon
@onready var assembler_display : AssemblerDisplay = $AssemblerDisplay
@onready var storage_container_display : StorageContainerDisplay = $StorageContainerDisplay

var building_focus : Building = null

func _ready():
	MessageBus.player_selected_building.connect(_on_player_selected_building)
	hide_display()
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)

func _on_moved_to_coordinates(_coords: Vector2) -> void:
	hide_display()

func show_display() -> void:
	show()

func hide_display() -> void:
	hide()
	cleanup_displays()

func cleanup_displays() -> void:
	storage_container_display.hide_display()
	assembler_display.hide_display()
	if MessageBus.player_released_cancel.is_connected(_on_player_released_cancel):
		MessageBus.player_released_cancel.disconnect(_on_player_released_cancel)

func set_selected_icon_to(data: ComponentData) -> void:
	selected_icon.texture = data.icon
	selected_icon.self_modulate = data.color_adjustment

func _on_player_selected_building(building: Building) -> void:
	if building is StorageBuilding:
		select_building(building)
		assembler_display.hide_display()
		storage_container_display.show_display(building)
		await storage_container_display.visibility_changed
		if not storage_container_display.visible:
			hide_display()
		return
	
	var assembler : Assembler = building.get_node_or_null(Constants.ASSEMBLER)
	if assembler != null:
		select_building(building)
		storage_container_display.hide_display()
		assembler_display.show_display(assembler)
		await assembler_display.visibility_changed
		if not assembler_display.visible:
			hide_display()
		return

func select_building(building: Building) -> void:
	building_focus = building
	set_selected_icon_to(building_focus.data)
	cleanup_displays()
	show_display()
	if not MessageBus.player_released_cancel.is_connected(_on_player_released_cancel):
		MessageBus.player_released_cancel.connect(_on_player_released_cancel)

func _on_player_released_cancel() -> void:
	hide_display()
