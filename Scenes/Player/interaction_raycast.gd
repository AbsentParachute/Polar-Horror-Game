extends RayCast3D

##TODO
## Build in UI connectivity

@export var interactor : Node3D
@export var default_hold_threshold: float = 0.35

var current_object
var current_interactable

var is_holding : bool = false
var hold_time : float = 0.0
var hold_active : bool = false

func _ready() -> void:
	if interactor == null: # Safety Check
		interactor = get_tree().get_first_node_in_group("PLAYER")

func _process(delta: float) -> void:
	_update_target()
	_update_hold(delta)

func _update_target() -> void:
	if is_colliding():
		var object = get_collider()
		
		# If object hasn't changed return early
		if object == current_object:
			return
		
		# If object we are looking at changed
		elif object != current_object:
			# Release the old object if we were holding it
			if current_object != null and current_interactable != null and is_holding:
				# Run interact_release func if available
				current_interactable.interact_release(interactor)
				# Reset hold vars
				is_holding = false
				hold_active = false
				hold_time = 0.0
			
			# Set object and interactable
			current_object = object
			current_interactable = _find_interactable(object)
		
	# If we stopped colliding with anything
	else:
		if current_object != null:
			if current_interactable != null and is_holding:
				# Run interact_release func if available
				current_interactable.interact_release(interactor)
		
		# Reset all vars
		current_object = null
		current_interactable = null
		is_holding = false
		hold_active = false
		hold_time = 0.0

func _find_interactable(object: Object) -> Interactable:
	if object is Interactable:
		
		return object as Interactable
	else:
		return null
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_start_interact()
	elif event.is_action_released("interact"):
		_stop_interact()


func _start_interact() -> void:
	if current_interactable == null:
		return
	
	is_holding = true
	hold_active = false
	hold_time = 0.0
	
	current_interactable.interact(interactor) ## CALL INTERACT()

func _stop_interact() -> void:
	if not is_holding: # If true then button was pressed
		return
	
	if current_interactable != null:
		current_interactable.interact_release(interactor) ## CALL INTERACT_RELEASE()
	
	is_holding = false
	hold_active = false
	hold_time = 0.0

func _update_hold(delta: float) -> void:
	if not is_holding or current_interactable == null:
		return
	
	hold_time += delta
	
	if not hold_active and hold_time >= default_hold_threshold:
		hold_active = true
	
	if hold_active:
		current_interactable.interact_hold(delta, interactor)
	
