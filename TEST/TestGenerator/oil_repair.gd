extends RepairTaskComponent

#TODO
# 1. Connect UI
# 2. Connect Sounds

## NOTE
## If task selected, randomly set the oil level clamped to a low value.
## Additionally, if Oil needs to be purged, we will have to connect a signal from a button pressed which sets current_oil_level to 0.
## Remove Oil Cap - Interaction w/ Area sends signal
## Grab Oil Can - Interaction, adds Oil can to inventory
## Fill Oil Tank - Interaction, Check if Oil is in Inventory,hold "E" to Fill, in process while all conditions are met, increase oil level until max
## once full no longer fill oil.
## Close Oil Cap - Interaction, check if oil is full, close cap.
## Send signal indicating that the task has been completed.

@export var oil_tank_cap: MeshInstance3D
@export var oil_tank: Area3D
@export var oil_fill: Area3D 
@export var fill_rate : float = 10.0 # Fill rate = 100/time to full 10 = 10 seconds from 0
@export var jerry_can_id : String = "Oil_Jerry_Can"

const OIL_MAX : float = 100.0

var current_oil_level : float = 100 # 100 = full
var cap_removed : bool = false
var filling : bool = false

func _ready() -> void:
	oil_fill.set_collision_layer_value(6, false)
	oil_tank.set_collision_layer_value(6, false)
	#super._ready()
	
	#TEST REMOVE
	repair_selected = true 
	
	prepare_repair()


func prepare_repair() -> void:
	repair_completed = false
	set_process(true)
	oil_tank.set_collision_layer_value(6, true)
	oil_fill.set_collision_layer_value(6, false)
	
	# Set random oil level
	var new_oil_level : float = randf_range(0.0, 20.0) # randf is identical to randi; f=float i=int
	current_oil_level = new_oil_level
	
	# Connect signals
	oil_tank.oil_tank_int.connect(_on_oil_tank_interact)
	oil_fill.oil_fill_start_int.connect(_on_oil_fill_interact_start)
	oil_fill.oil_fill_stop_int.connect(_on_oil_fill_interact_stop)
	print("repair prepared successfully")

func _on_oil_tank_interact() -> void:
	if not cap_removed and not repair_completed: # if we don't have the 'and repair_completed" we can't disable the collision
		oil_tank_cap.visible = false
		cap_removed = true
		oil_fill.set_collision_layer_value(6, true)
		
		print("oil cap removed")
	else:
		if current_oil_level >= OIL_MAX:
			oil_tank_cap.visible = true
			cap_removed = false
			
			oil_tank.set_collision_layer_value(6, false)
			repair_completed = true
			print("oil cap replaced. Task Completed")
			repair_task_completed.emit()

func _on_oil_fill_interact_start() -> void:
	# Check for oil jerrycan in inventory
	if not InventoryManager.has_item_id(jerry_can_id):
		print("Not jerry can in inventory")
		return
	
	#focus player camera
	
	if filling == true:
		return
	filling = true
	print("filling")

func _on_oil_fill_interact_stop() -> void:
	filling = false
	print("current oil level ", current_oil_level)

func _process(delta: float) -> void:
	if filling:
		current_oil_level += delta * fill_rate
		if current_oil_level >= OIL_MAX:
			current_oil_level = OIL_MAX
			filling = false
			oil_fill.set_collision_layer_value(6, false)
			
			# Remove item from inventory
			if InventoryManager.has_item_id(jerry_can_id):
				InventoryManager.remove_item_id(jerry_can_id)
