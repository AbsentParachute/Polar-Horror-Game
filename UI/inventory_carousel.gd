class_name InventoryCarousel
extends Node3D

#TODO:
# 1. Figure out how to disable player movement when in a menu.

@export_group("Layout")
@export var x_offset: float = 1.25 # left/right spacing
@export var neighbor_z: float = 0.0 # z for side items
@export var selected_z: float = 0.35 # z for focused/selected item
@export var selected_scale: float = 1.1 # slight pop/inc in scale for selected item
@export var move_time: float = 0.18 # tween time per shift
@export var spin_speed_deg: float = 20.0 # spin only the focused item

@onready var items_root: Node3D = $ItemsRoot
@onready var inv_cam: Camera3D = $InventoryCam

var items : Array[ItemData]
var count : int #Index
var selected_index: int = 0
var _wrappers: Array[Node3D] = [] # one wrapper per item; each is a Node3D per item each containing a SpinPivot(N3D) and display_scene instance
var _spin_pivot: Node3D = null # child node we rotate on focus

func open_and_build() -> void: # when "I" is pressed run this func
	selected_index = 0 # Resets the selected item to 0
	self.visible = true
	inv_cam.current = true
	_build_from_inventory()
	_update_visible_set(false)
	set_process(true)

func close_inventory() -> void:
	self.visible = false
	set_process(false)

# Used by left-button
func next_item() -> void: 
	if count <= 0:
		return
	selected_index += 1
	if selected_index >= count:
		selected_index = 0
	_update_visible_set(true)

# Used by right-button
func prev_item() -> void:
	if count <= 0:
		return
	selected_index -= 1
	if selected_index < 0:
		selected_index = count - 1
	_update_visible_set(true)

# Used by labels
func get_selected_item_data() -> ItemData: 
	if count <= 0 or selected_index < 0 or selected_index >= count:
		return null
	return items[selected_index]

func rebuild_after_inventory_change() -> void: #Call this if items changed while open
	_build_from_inventory()
	_update_visible_set(false)

func _process(delta: float) -> void:
	if _spin_pivot != null:
		_spin_pivot.rotate_y(deg_to_rad(spin_speed_deg) * delta)


## --- Build Inventory --- ##
func _build_from_inventory() -> void:
	#Clear old content
	for c in items_root.get_children():
		c.queue_free()
	_wrappers.clear()
	_spin_pivot = null
	
	items = InventoryManager.get_all_items()
	count = items.size()
	if count == 0:
		selected_index = 0
		return
	
	# One wrapper per item, with a SpinPivot child that will hold the item scene
	for i in range(count):
		#Create a wrapper for each item in inventory (index)
		var data: ItemData = items[i]
		var wrapper := Node3D.new()
		wrapper.name = "Item_%d" % i # %d is format specifier for decimal int, % adds the "i' ass the int. so Item_1 if i=1
		items_root.add_child(wrapper)
		_wrappers.append(wrapper)
		
		# Add a pivot node3d as a child of wrapper
		if data != null and data.display_scene != null:
			var pivot := Node3D.new()
			pivot.name = "SpinPivot"
			wrapper.add_child(pivot)
			
			# Instantiate the item's scene as child of the pivot
			var inst := data.display_scene.instantiate()
			if inst is Node3D:
				pivot.add_child(inst)
				inst.position = Vector3.ZERO


## --- Layout for 3 visible slots --- ##
func _update_visible_set(animated: bool) -> void:
	# If no items
	if _wrappers.is_empty():
		_spin_pivot = null
		selected_index = 0
		return
	# Ensure 'count' matches what we build (wrappers)
	count = _wrappers.size()
	
	# --- 0 items --- #
	if count == 0:
		_spin_pivot = null
		return
	
	# Clamp selection into range before using it
	if selected_index < 0:
		selected_index = count - 1
	elif selected_index >= count:
		selected_index = 0
	
	# --- 1 item --- #
	if count == 1:
		var only := _wrappers[0]
		# Center and focus
		var target_pos := Vector3(0.0, 0.0, selected_z)
		var target_scale = Vector3(selected_scale, selected_scale, selected_scale)
		only.show()
		if animated:
			var tw0 := create_tween() # tw0 = "tween" the 0 is just to differentiate it
			tw0.tween_property(only, "position", target_pos, move_time)
			tw0.parallel().tween_property(only, "scale", target_scale, move_time) # Parallel is so it animates/tweens the scale at the same time as the position.
		else:
			only.position = target_pos
			only.scale = target_scale
		_spin_pivot = _find_spin_pivot(only)
		return
	
	# --- 2 items --- #
	if count == 2:
		var sel_node := _wrappers[selected_index]
		var other_index := 0
		if selected_index == 0:
			other_index = 1
		var other_node := _wrappers[other_index]
		
		# Selected centered and focused
		var sel_pos := Vector3(0.0, 0.0, selected_z)
		var sel_scale = Vector3(selected_scale, selected_scale, selected_scale)
		sel_node.show()
		if animated:
			var tw1 := create_tween() # tw1 = "tween" the 1 is just to differentiate it
			tw1.tween_property(sel_node, "position", sel_pos, move_time)
			tw1.parallel().tween_property(sel_node, "scale", sel_scale, move_time) # Parallel is so it animates/tweens the scale at the same time as the position.
		else:
			sel_node.position = sel_pos
			sel_node.scale = sel_scale
		_spin_pivot = _find_spin_pivot(sel_node)
	
		# the other on the RIGHT (change to LEFT by swapping +/- x_offset)
		var other_pos := Vector3(x_offset, 0.0, neighbor_z)
		other_node.show()
		if animated:
			create_tween().tween_property(other_node, "position", other_pos, move_time)
		else:
			other_node.position = other_pos
		return
	
	# --- 3+ items --- #
	# Determine which indices are visible left / selected/focused / right
	var left_idx : int = (selected_index - 1 + count) % count
	var right_idx : int = (selected_index + 1) % count
	
	for i in range(count):
		var w := _wrappers[i]
		
		#Decide target transform + visibility
		var target_pos := Vector3.ZERO
		var target_scale := Vector3.ONE
		var should_show : bool = false
		var is_selected : bool = false
		
		if i == selected_index:
			should_show = true
			is_selected = true
			target_pos = Vector3(0.0, 0.0, selected_z)
			target_scale = Vector3(selected_scale, selected_scale, selected_scale)
		elif i == left_idx:
			should_show = true
			target_pos = Vector3(-x_offset, 0.0, neighbor_z)
		elif i == right_idx:
			should_show = true
			target_pos = Vector3(x_offset, 0.0, neighbor_z)
		
		# Apply visibility + animation
		if should_show:
			w.show()
			if animated:
				var tw := create_tween() # tw = "tween"
				tw.tween_property(w, "position", target_pos, move_time)
				tw.parallel().tween_property(w, "scale", target_scale, move_time) # Parallel is so it animates/tweens the scale at the same time as the position.
			else:
				w.position = target_pos
				w.scale = target_scale
		else:
			# Hide non-neighbors off-screen; also reset scale so it looks correct when it becomes visible later
			w.hide()
			w.position = Vector3(0.0, 0.0, neighbor_z)
			w.scale = Vector3.ONE
			
		# Track which node spins
		if is_selected:
			_spin_pivot = _find_spin_pivot(w)
		else: 
			if _find_spin_pivot(w) == _spin_pivot:
				_spin_pivot = null

func _find_spin_pivot(wrapper: Node3D) -> Node3D:
	for child in wrapper.get_children():
		if child is Node3D and child.name == "SpinPivot":
			return child
	return null
