extends Control
class_name PlotDisplay

## Class for displaying information related to the Plot

@onready var title_label : Label = $TopPanel/MarginContainer/Title
@onready var coordinates_label : Label = $TopPanel/MarginContainer/Coordinates
@onready var progress_bar : ProgressBar = $TopPanel/MarginContainer/ProgressBar
@onready var unowned_display : UnownedPlotDisplay = $UnownedDisplay
@onready var goals_panel : Container = $GoalPanel
@onready var goals_parent : Container = $GoalPanel/MarginContainer/Goals

var plot : Plot = null

func _ready() -> void:
	Plots.moved_to_coordinates.connect(_on_moved_to_coordinates)
	unowned_display.hide_display()
	hide_goals()
	update_progress_bar(null)

func _on_moved_to_coordinates(location: Vector2) -> void:
	coordinates_label.text = str(location.x) + "," + str(location.y)
	
	var moved_to_plot = Plots.get_plot(location)
	if plot != moved_to_plot:
		if plot != null:
			if plot.contract != null and plot.contract.progressed.is_connected(_on_contract_progressed):
				plot.contract.progressed.disconnect(_on_contract_progressed)
			if plot.accepted_contract.is_connected(_on_accepted_plot_contract):
				plot.accepted_contract.disconnect(_on_accepted_plot_contract)
		plot = moved_to_plot
	
	if plot == null:
		unowned_display.show_display(plot)
		goals_parent.hide()
		title_label.text = "Hidden"
		update_progress_bar(null)
		hide_goals()
		return
	
	title_label.text = plot.display_name
	update_progress_bar(plot.contract)
	
	# Active contract in Plot
	if plot.contract != null:
		plot.contract.progressed.connect(_on_contract_progressed)
		unowned_display.hide_display()
		show_goals()
	# Available contract in Plot
	elif not plot.player_owned and plot.available_contract != null and plot.contract == null:
		plot.accepted_contract.connect(_on_accepted_plot_contract)
		unowned_display.show_display(plot)
		hide_goals()
	# Out of range Plot
	else:
		unowned_display.hide_display()
		hide_goals()

func _on_contract_progressed() -> void:
	update_progress_bar(plot.contract)

func update_progress_bar(contract: Contract) -> void:
	if contract == null:
		progress_bar.hide()
		return
	
	progress_bar.show()
	var sum_goal_percent = 0.0
	for goal in contract.goals:
		sum_goal_percent += float(goal.current_amount) / float(goal.required_amount)
	progress_bar.value = sum_goal_percent / contract.goals.size()

func _on_accepted_plot_contract(contract: Contract) -> void:
	update_progress_bar(contract)
	show_goals()
	if not plot.contract.progressed.is_connected(_on_contract_progressed):
		plot.contract.progressed.connect(_on_contract_progressed)

func hide_goals() -> void:
	goals_panel.hide()
	for child in goals_parent.get_children():
		(child as ComponentGoalSlot).goal = null

func show_goals() -> void:
	var i = 0
	for goal in plot.contract.goals:
		(goals_parent.get_child(i) as ComponentGoalSlot).goal = goal
		i += 1
	
	for child_i in range(i, goals_parent.get_child_count()):
		(goals_parent.get_child(child_i) as ComponentGoalSlot).goal = null
	goals_panel.show()
