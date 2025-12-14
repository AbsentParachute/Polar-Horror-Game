extends Node

# TODO:
# DONE - Change all current camera_states to reference this and connect to the control_state_changed
# DONE - Change camera_state to make new bool

# NOTE:
# Rule of thumb regarding the control_state_changed signal:
# if expected state is recieved as old_state then they will exit
# if expected state is recieved as new state then they will enter

var control_stack : Array[EventBus.ControlState] = []

var _exit_still_processing : bool = false # If true, handle_esc wont function. We reset in update_player_freeze

func _ready() -> void:
	EventBus.request_append_control_state.connect(_on_request_append_control_state) # Source control state entered, add to end of array as current
	EventBus.request_update_player_freeze.connect(_update_player_freeze) # Source finished exit now requesting to see if we can unfreeze player

func _on_request_append_control_state(state : EventBus.ControlState) -> void:
	if _exit_still_processing == true: 
		return
	
	var current : EventBus.ControlState = _get_effective_state()
	print(current)
	
	# Toggle behavior: requesting the current state means "close it"
	if current == state: # If we are
		_handle_esc()
		return
	
	# Enter new state
	control_stack.append(state)
	EventBus.control_state_changed.emit(current, state) # Anyone who recieves new state as them will enter
	
	_apply_global_player_input_for_state(state) # Set new mouse input for this newly added state.
	_update_player_freeze()

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("ui_cancel"):
		_handle_esc()

# Handle all "esc" input events
func _handle_esc() -> void:
	if _exit_still_processing == true: # If we are still handling an esc/exit request, return and don't process any other state. 
		return
	
	# We pressed esc/exit while processing was false so this is an active state closure
	_exit_still_processing = true 
	var current : EventBus.ControlState = _get_effective_state()
	
	if current == EventBus.ControlState.GAMEPLAY:
		# Allow pausing the game
		EventBus.pause_unpause.emit()
		_exit_still_processing = false
		return
	
	# Don't exit for dialogue
	if current == EventBus.ControlState.DIALOGUE:
		_exit_still_processing = false
		return
	
	_pop_state()

func _pop_state() -> void:
	if control_stack.is_empty():
		return
	
	var old_state: EventBus.ControlState = _get_effective_state() # Capture old/current
	control_stack.pop_back() # Remove old/current
	var new_state : EventBus.ControlState = _get_effective_state() # Capture new
	
	EventBus.control_state_changed.emit(old_state, new_state)
	_apply_global_player_input_for_state(new_state)
	#_update_player_freeze() This will be handled by having the old_state emit a request_update_player_freeze signal instead when it has finished closing. 

func _get_effective_state() -> EventBus.ControlState:
	if control_stack.is_empty():
		return EventBus.ControlState.GAMEPLAY
	return control_stack.back()

func _apply_global_player_input_for_state(state : EventBus.ControlState) -> void:
	if state == EventBus.ControlState.GAMEPLAY:
		EventBus.mouse_mode_changed.emit(EventBus.MouseMode.CAPTURED)
	else:
		EventBus.mouse_mode_changed.emit(EventBus.MouseMode.VISIBLE)

func _update_player_freeze() -> void:
	var current: EventBus.ControlState = _get_effective_state()
	EventBus.request_player_freeze.emit(current != EventBus.ControlState.GAMEPLAY) # If current != GAMEPLAY then TRUE otherwise FALSE
	_exit_still_processing = false # We reset here
