class_name RepairTaskComponent
extends Node3D

##NOTE If using this as a class template, make sure to call super._ready()
## in the new ready for the inherited script otherwise you will overwrite this.
## If we want to connect signals only if repair_selected = true then
## put the signal.connect in the prepare_task func since that only runs when 
## repair_selected == true

signal repair_task_completed() # Emit when repair is completed

@export var repair_name : GeneratorTypes.RepairType
@export var generator_manager : Node3D

var repair_selected : bool = false
var repair_completed : bool = false

func _ready() -> void:
	# We await the ready func until after the generator_manager's "ready/setup complete" is complete
	await generator_manager.setup_complete 
	
	var active_gen_repairs : Array = generator_manager.selected_repairs
	
	# Check to see if this repair is an active repair.
	repair_selected = repair_name in active_gen_repairs
	if repair_selected == true:
		prepare_repair()

func prepare_repair() -> void:
	pass # Fill with repair specific setup script.
