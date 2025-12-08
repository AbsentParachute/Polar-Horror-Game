extends RepairTaskComponent

#TODO
# 1. Change prelod to be a preload UID
# 2. Connect UI
# 3. Connect Sounds

@export var filter_a : MeshInstance3D
@export var filter_b : MeshInstance3D
@export var lid_a : MeshInstance3D
@export var lid_b : MeshInstance3D

@export var lid_a_int : Area3D
@export var lid_b_int : Area3D
@export var filter_a_int : Area3D
@export var filter_b_int : Area3D

@export var clean_filter_id : String = "Air_Filter"

const CLEAN_FILTER : StandardMaterial3D = preload("res://TEST/TestGenerator/Clean_Filter_Test.tres")

# Change when filter has been replaced and lid placed back on.
var filter_a_repaired : bool = false
var filter_b_repaired : bool = false

# Change when filter replaced
var filter_a_replaced : bool = false
var filter_b_replaced : bool = false

func _ready() -> void:
	lid_a_int.set_collision_layer_value(6, false)
	lid_b_int.set_collision_layer_value(6, false)
	filter_a_int.set_collision_layer_value(6, false)
	filter_b_int.set_collision_layer_value(6, false)
	
	#super._ready()
	
	#TEST REMOVE
	repair_selected = true 
	prepare_repair()

func prepare_repair() -> void:
	# Reset
	repair_completed = false
	filter_a_repaired = false
	filter_b_repaired = false
	filter_a_replaced = false
	filter_b_replaced = false
	set_process(true)
	
	# Set Materials to be dirty (default)
	filter_a.material_override = null # We remove material as we will set the clean as the override. Alternatively in the future we could just change the texture
	filter_b.material_override = null

	# Add collision
	lid_a_int.set_collision_layer_value(6, true)
	lid_b_int.set_collision_layer_value(6, true)
	
	# Signal connection
	lid_a_int.lid_a_int.connect(_on_lid_a_interact)
	lid_b_int.lid_b_int.connect(_on_lid_b_interact)
	filter_a_int.filter_a_int.connect(_on_filter_a_interact)
	filter_b_int.filter_b_int.connect(_on_filter_b_interact)

func _check_repair_completeion() -> void:
	if filter_a_repaired and filter_b_repaired:
		repair_completed = true
		repair_task_completed.emit()
		print("air filter repair completed")
	print("An air filter still needs replaced")
	return

func _on_lid_a_interact() -> void:
	if lid_a.visible: 
		lid_a.visible = false
		lid_a_int.set_collision_layer_value(6, false)
		filter_a_int.set_collision_layer_value(6, true)
	else:
		if not lid_a.visible and filter_a_replaced:
			lid_a.visible = true
			filter_a_repaired = true
			lid_a_int.set_collision_layer_value(6, false)
			_check_repair_completeion()

func _on_lid_b_interact() -> void:
	if lid_b.visible: 
		lid_b.visible = false
		lid_b_int.set_collision_layer_value(6, false)
		filter_b_int.set_collision_layer_value(6, true)
	else:
		if not lid_b.visible and filter_b_replaced:
			lid_b.visible = true
			filter_b_repaired = true
			lid_b_int.set_collision_layer_value(6, false)
			_check_repair_completeion()

func _on_filter_a_interact() -> void:
	# Remove Filter
	if filter_a.visible: #Check if visible.
		if filter_a.get_surface_override_material(0) == null: # Check for override material
			filter_a.visible = false # If no override then 'remove' filter
	
	else: # If filter_a is not visibile
		# Check player inventory for new filter
		if not InventoryManager.has_item_id(clean_filter_id):
			print("No air filter in inventory")
			return
		else:
			filter_a.material_override = CLEAN_FILTER # Set material override to be clean
			filter_a.visible = true
			filter_a_replaced = true
			filter_a_int.set_collision_layer_value(6, false)
			lid_a_int.set_collision_layer_value(6, true)
			InventoryManager.remove_item_id(clean_filter_id)

func _on_filter_b_interact() -> void:
	# Remove Filter
	if filter_b.visible: #Check if visible.
		if filter_b.get_surface_override_material(0) == null: # Check for override material
			filter_b.visible = false # If no override then 'remove' filter
	
	else: # If filter_b is not visibile
		# Check player inventory for new filter
		if not InventoryManager.has_item_id(clean_filter_id):
			print("No air filter in inventory")
			return
		else:
			filter_b.material_override = CLEAN_FILTER # Set material override to be clean
			filter_b.visible = true
			filter_b_replaced = true
			filter_b_int.set_collision_layer_value(6, false)
			lid_b_int.set_collision_layer_value(6, true)
			InventoryManager.remove_item_id(clean_filter_id)
