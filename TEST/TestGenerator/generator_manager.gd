class_name GeneratorManager
extends Node3D

signal setup_complete()

var selected_repairs : Array[GeneratorTypes.RepairType] = []
var all_repairs : Array[GeneratorTypes.RepairType] = [
	GeneratorTypes.RepairType.AIR_FILTER,
	GeneratorTypes.RepairType.FUSE,
	GeneratorTypes.RepairType.OIL,
	GeneratorTypes.RepairType.FUEL,
	GeneratorTypes.RepairType.BATTERY,
	GeneratorTypes.RepairType.COOLANT,
	GeneratorTypes.RepairType.VOLTAGE,
	GeneratorTypes.RepairType.SENSOR
]

func _ready() -> void:
	_select_random_repairs()
	_connect_repair_signals()

func _select_random_repairs() -> void:
	selected_repairs.clear()
	selected_repairs = all_repairs.duplicate()
	selected_repairs.shuffle()
	selected_repairs = selected_repairs.slice(0, randi_range(2, 5))
	setup_complete.emit() # This is so the _ready() for the RepairTaskComponent will run only when the selected_repairs have been filled.

func _connect_repair_signals() -> void:
	for child in get_children():
		if child is RepairTaskComponent:
			var repair_comp : RepairTaskComponent = child
			repair_comp.repair_task_completed.connect(_check_all_selected_repairs_completed)

func _check_all_selected_repairs_completed() -> void:
	# Loop through all children
	for child in get_children():
		if child is RepairTaskComponent and child.repair_selected:
			# If any selected repair is NOT completed, we exit early
			if not child.repair_completed:
				return # Stop here, not all completed
	
	# If we reached this point, all selected repairs ARE completed
	EventBus.task_completed.emit("Generator")
