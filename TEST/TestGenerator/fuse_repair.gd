extends RepairTaskComponent

# TODO:
# DONE - Figure out how to allow mouse to "interact" with fuses. Mouse needs to be a ray and function like the current interaction. 
# DONE - Connected Fuse_repair with ControlStackManager to allow enter and exiting.
# Fine tune collision shapes for the weird camera angle

# NOTE: For dictionaries, the "key" is unique identifier to search to find a "value"
# Below the "Key" is fuse_id and the "Value" is the node.
@export_group("References")
@export var fuse_enter : Interactable
@export var fuse_camera_marker : Marker3D

var fuse_areas : Dictionary = {}
var fuse_meshes : Dictionary = {}
var fuse_lights : Dictionary = {}

var all_fuses : Array[FuseTypes.FuseID] = []
var selected_fuses : Array[FuseTypes.FuseID] = [] # Fuses that are active and need repaired - Consider checking for empty to confirm complete

var _flash_tweens : Dictionary = {} # Stores fuse_id to refer back to specific tween to kill it

const FUSE_GOOD : StandardMaterial3D = preload("uid://cpyf4f3su2101")
const _desired_state : EventBus.ControlState = EventBus.ControlState.FUSE_REPAIR

func _ready() -> void:
	# Remove collisions
	for child in get_children():
		if child is Interactable:
			child.set_collision_layer_value(6, false) 
	
	#super._ready()
	
	prepare_repair()

func prepare_repair() -> void:
	repair_completed = false
	set_process(true)
	
	EventBus.control_state_changed.connect(_on_control_state_changed)
	
	fuse_enter.fuse_enter_int.connect(_on_fuse_entered)
	fuse_enter.set_collision_layer_value(6, true)
	
	# Connect all child interact signals, and fill all dictionaries 
	for child in get_children():
		if child is Interactable and "fuse_id" in child:
			fuse_areas[child.fuse_id] = child # Add child to dict
			_collect_parts(child) # Run func to add mesh and lights to dicts
			child.fuse_interacted.connect(_on_fuse_interacted)
	
	# Give green light by default
	for light : MeshInstance3D in fuse_lights.values():
		light.set_surface_override_material(1, FUSE_GOOD)
	
	# Build all fuses
	all_fuses.clear()
	for value in FuseTypes.FuseID.values():
		var id : FuseTypes.FuseID = value
		
		all_fuses.append(id)
	
	# Build selected_fuses
	selected_fuses.clear()
	selected_fuses = all_fuses.duplicate()
	selected_fuses.shuffle()
	selected_fuses = selected_fuses.slice(0, randi_range(3, 14))
	
	# Sift through selected fuses and enable collision
	for value in selected_fuses:
		var area : Area3D = fuse_areas[value]
		area.set_collision_layer_value(6, true)

		var light : MeshInstance3D = fuse_lights[value]
		light.set_surface_override_material(1, null) # Remove the override material
		start_flash(value)

func _check_repair_completeion() -> void:
	if selected_fuses.is_empty(): # Since we remove the fuse_id once selected_fuses is empty then we know we are done
		fuse_enter.set_collision_layer_value(6, false)
		# _on_fuse_exited() # We could run this once task is complete to force player out of view
		repair_task_completed.emit()
		print("Fuse repair completed")
	else:
		return

func _collect_parts(node: Node3D) -> void:
	for child in node.get_children():
		if "part_type" in child:
			if child.part_type == "Fuse":
				fuse_meshes[child.fuse_id] = child
			if child.part_type == "Light":
				fuse_lights[child.fuse_id] = child

func _on_fuse_entered() -> void:
	# Append state to array
	EventBus.request_append_control_state.emit(_desired_state)
	# Set Unique State for Inventory
	InventoryManager.inventory_state = InventoryManager.Inventory_State.FUSE
	fuse_enter.set_collision_layer_value(6, false)

func _on_control_state_changed(old_state : EventBus.ControlState, new_state : EventBus.ControlState) -> void:
	if old_state == EventBus.ControlState.FUSE_REPAIR and new_state == EventBus.ControlState.GAMEPLAY:
		_on_fuse_exited()
	
	if old_state == EventBus.ControlState.GAMEPLAY and new_state == EventBus.ControlState.FUSE_REPAIR: # Only run this when entering fuse_repair from gameplay
		# Inform camera controller to accept target_transform and tween camera
		EventBus.target_camera_transform.emit(fuse_camera_marker.global_transform)

func _on_fuse_exited() -> void:
	# Emit signal to transition camera back to origin
	EventBus.camera_to_origin.emit()
	# Unfreeze request handled by Camera_Controller
	
	# Return State to Normal for Inventory
	InventoryManager.inventory_state = InventoryManager.Inventory_State.NORMAL
	if repair_completed != true:
		fuse_enter.set_collision_layer_value(6, true)

func _on_fuse_interacted(fuse_id) -> void:
	var area : Area3D = fuse_areas[fuse_id]
	var light : MeshInstance3D = fuse_lights[fuse_id]
	var mesh : MeshInstance3D = fuse_meshes[fuse_id]
	var fuse_item_id : String = area.fuse_item_id
		
	if mesh.visible == true:
		mesh.visible = false
	
	if mesh.visible == false:
		if not InventoryManager.has_item_id(fuse_item_id):
			print("Missing correct fuse in inventory, need", fuse_item_id)
			return
		else:
			stop_flash(fuse_id)
			light.set_surface_override_material(1, FUSE_GOOD)# Set material override to be clean
			mesh.visible = true
			area.set_collision_layer_value(6, false) 
			selected_fuses.erase(fuse_id) # Remove fuse_id from selected fuses array
			_check_repair_completeion() # Check to see if task is complete
			InventoryManager.remove_item_id(fuse_item_id)

func start_flash(fuse_id) -> void:
	var light : MeshInstance3D = fuse_lights[fuse_id]
	var mat : StandardMaterial3D = light.get_active_material(1)
	
	mat = mat.duplicate() # Make this material unique so we don't afect all of the same mats
	light.set_surface_override_material(1, mat)
	
	mat.emission_enabled = true
	mat.emission_energy_multiplier = 0.0 # Start off
	
	# Kill old tween if it exists
	if _flash_tweens.has(fuse_id):
		var old : Tween = _flash_tweens[fuse_id]
		if old.is_valid():
			old.kill()
	
	var tween : Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()  # no args = loop forever
	
	tween.tween_property(mat, 
		"emission_energy_multiplier", 
		2.0, # Emission strength - Fully On
		0.12 # time to reach this strength
	).from(0.0)
	
	tween.tween_interval(1.0)
	
	tween.tween_property(mat, 
		"emission_energy_multiplier", 
		0.0, # Emission strength - Fully off
		0.12 # time to reach this strength
	).from(2.0)
	
	tween.tween_interval(1.0)
	
	_flash_tweens[fuse_id] = tween # Add to the tween dict to be killed later

func stop_flash(fuse_id) -> void:
	if not _flash_tweens.has(fuse_id):
		return
	
	var tween : Tween = _flash_tweens[fuse_id]
	if tween.is_valid():
		tween.kill()
	_flash_tweens.erase(fuse_id)
