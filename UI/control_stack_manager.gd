extends Node

# TODO:
# Change all current camera_states to reference this and connect to the control_state_changed
# Change camera_state to make new bool

var control_stack : Array[EventBus.ControlState] = []

func _ready() -> void:
	EventBus.request_push_control_state.connect(_on_request_push_control_state)

func _on_request_push_control_state(state : EventBus.ControlState) -> void:
	_push_state(state)

# Handle all "esc" input events
func _handle_esc() -> void:
	var current : EventBus.ControlState = _get_effective_state()
	
	if current == EventBus.ControlState.GAMEPLAY:
		# Allow pausing the game
		_push_state(EventBus.ControlState.PAUSE)
		return
	
	# Don't exit for dialogue
	if current == EventBus.ControlState.DIALOGUE:
		return
	
	_pop_state()

func _pop_state() -> void:
	if control_stack.is_empty():
		return
	
	var old_state: EventBus.ControlState = _get_effective_state() # Capture old/current
	control_stack.pop_back() # Remove old/current
	var new_state : EventBus.ControlState = _get_effective_state() # Capture new
	
	EventBus.control_state_changed.emit(old_state, new_state)
	_update_player_freeze()

func _get_effective_state() -> EventBus.ControlState:
	if control_stack.is_empty():
		return EventBus.ControlState.GAMEPLAY
	return control_stack.back()

# Only used for pausing
func _push_state(state : EventBus.ControlState) -> void:
	var old_state : EventBus.ControlState = _get_effective_state()
	control_stack.push_back(state)
	var new_state : EventBus.ControlState = _get_effective_state()
	
	EventBus.control_state_changed.emit(old_state, new_state)
	_update_player_freeze()

func _update_player_freeze() -> void:
	var current: EventBus.ControlState = _get_effective_state()
	EventBus.request_player_freeze.emit(current != EventBus.ControlState.GAMEPLAY) # If current != GAMEPLAY then TRUE otherwise FALSE
