extends RepairTaskComponent

#TODO
# 1. Connect UI
# 2. Connect Sounds

@export var cool_tank_cap: MeshInstance3D
@export var cool_tank: Area3D
@export var cool_fill: Area3D 
@export var fill_rate : float = 10.0 # Fill rate = 100/time to full 10 = 10 seconds from 0
@export var jerry_can_id : String = "Cool_Jerry_Can"

const COOL_MAX : float = 100.0

var current_cool_level : float = 100 # 100 = full
var cap_removed : bool = false
var filling : bool = false

func _ready() -> void:
	cool_fill.set_collision_layer_value(6, false)
	cool_tank.set_collision_layer_value(6, false)
	#super._ready()
	
	#TEST REMOVE
	repair_selected = true 
	
	prepare_repair()


func prepare_repair() -> void:
	repair_completed = false
	set_process(true)
	cool_tank.set_collision_layer_value(6, true)
	cool_fill.set_collision_layer_value(6, false)
	
	# Set random cool level
	var new_cool_level : float = randf_range(0.0, 20.0) # randf is identical to randi; f=float i=int
	current_cool_level = new_cool_level
	
	# Connect signals
	cool_tank.cool_tank_int.connect(_on_cool_tank_interact)
	cool_fill.cool_fill_start_int.connect(_on_cool_fill_interact_start)
	cool_fill.cool_fill_stop_int.connect(_on_cool_fill_interact_stop)
	print("repair prepared successfully")

func _on_cool_tank_interact() -> void:
	if not cap_removed and not repair_completed: # if we don't have the 'and repair_completed" we can't disable the collision
		cool_tank_cap.visible = false
		cap_removed = true
		cool_fill.set_collision_layer_value(6, true)
		
		print("cool cap removed")
	else:
		if current_cool_level >= COOL_MAX:
			cool_tank_cap.visible = true
			cap_removed = false
			
			cool_tank.set_collision_layer_value(6, false)
			repair_completed = true
			print("cool cap replaced. Task Completed")
			repair_task_completed.emit()

func _on_cool_fill_interact_start() -> void:
	# Check for cool jerrycan in inventory
	if not InventoryManager.has_item_id(jerry_can_id):
		print("Not jerry can in inventory")
		return
	
	#focus player camera
	
	if filling == true:
		return
	filling = true
	print("filling")

func _on_cool_fill_interact_stop() -> void:
	filling = false
	print("current cool level ", current_cool_level)

func _process(delta: float) -> void:
	if filling:
		current_cool_level += delta * fill_rate
		if current_cool_level >= COOL_MAX:
			current_cool_level = COOL_MAX
			filling = false
			cool_fill.set_collision_layer_value(6, false)
			
			# Remove item from inventory
			if InventoryManager.has_item_id(jerry_can_id):
				InventoryManager.remove_item_id(jerry_can_id)
