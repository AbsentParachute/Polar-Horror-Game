extends RepairTaskComponent

#TODO
# 1. Connect UI
# 2. Connect Sounds

# NOTE
# We need to make it so we add the battery to inventory no matter what, we won't know if its actually dead and unable to be charged.
# So when we take the battery to the recharge station if it doesn't work, when we interact with it it will "discard" it.
# Otherwise when we interact with it, it will charge fully then we can add it to our inventory. 

@export var battery_a: MeshInstance3D
@export var battery_b: MeshInstance3D
@export var batt_a_int: Area3D
@export var batt_b_int: Area3D

var battery_id : String = "Battery_Gen" # REPLACE WITH NON TEST ID
var battery_full_id : String = "Battery_Gen_Full" # REPLACE WITH NON TEST ID

var batt_a_recharge : bool = false
var batt_b_recharge : bool = false
var batt_a_dead : bool = false
var batt_b_dead : bool = false

var battery_a_complete : bool = false
var battery_b_complete : bool = false

func _ready() -> void:
	batt_a_int.set_collision_layer_value(6, false)
	batt_b_int.set_collision_layer_value(6, false)
	#super._ready()
	
	#TEST REMOVE
	repair_selected = true 
	
	prepare_repair()

func prepare_repair() -> void:
	# Reset
	repair_completed = false
	set_process(true)
	
	if not batt_a_dead:
		var a_dead : int = randi_range(0, 9)
		if a_dead >= 7:
			batt_a_dead = true
		else:
			batt_a_recharge = true

	if batt_a_dead or batt_a_recharge:
		batt_a_int.set_collision_layer_value(6, true)
		batt_a_int.batt_a_int.connect(_on_battery_a_int)

	if not batt_b_dead:
		var b_dead : int = randi_range(0, 9)
		if b_dead >= 7:
			batt_b_dead = true
		else:
			batt_b_recharge = true

	if batt_b_dead or batt_b_recharge:
		batt_b_int.set_collision_layer_value(6, true)
		batt_b_int.batt_b_int.connect(_on_battery_b_int)

func _check_repair_completeion() -> void:
	if battery_a_complete and battery_b_complete:
		repair_completed = true
		repair_task_completed.emit()
		print("Repair Complete")

func _on_battery_a_int() -> void:
	if battery_a.visible:
		if batt_a_dead:
			battery_a.visible = false
		else:
			battery_a.visible = false
			InventoryManager.add_item_by_id(battery_id)
		
	else:
		if InventoryManager.has_item_id(battery_full_id):
			battery_a.visible = true
			battery_a_complete = true
			InventoryManager.remove_item_id(battery_full_id)
			batt_a_int.set_collision_layer_value(6, false)
			_check_repair_completeion()
		else:
			print("Missing Battery")

func _on_battery_b_int() -> void:
	if battery_b.visible:
		if batt_b_dead:
			battery_b.visible = false
		else:
			battery_b.visible = false
			InventoryManager.add_item_by_id(battery_id)
		
	else:
		if InventoryManager.has_item_id(battery_full_id):
			battery_b.visible = true
			battery_b_complete = true
			InventoryManager.remove_item_id(battery_full_id)
			batt_b_int.set_collision_layer_value(6, false)
			_check_repair_completeion()
		else:
			print("Missing Battery")
