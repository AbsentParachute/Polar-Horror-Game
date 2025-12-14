extends Control

var pause_toggle : bool = false

func _ready() -> void:
	pause_toggle = false
	self.visible = false
	#EventBus.control_state_changed.connect(_on_control_state_changed)
	EventBus.pause_unpause.connect(_on_pause_unpause)

func _on_pause_unpause() -> void:
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle
	
	if pause_toggle == true:
		EventBus.mouse_mode_changed.emit(EventBus.MouseMode.VISIBLE)
	else:
		EventBus.mouse_mode_changed.emit(EventBus.MouseMode.CAPTURED)

#func _on_control_state_changed(old_state : EventBus.ControlState, new_state : EventBus.ControlState) -> void:
	#if new_state == EventBus.ControlState.PAUSE:
		#_pause_game()
	#
	#if old_state == EventBus.ControlState.PAUSE:
		#_unpause_game()
#
#func _pause_game() -> void:
	#get_tree().paused = true
