extends Node

# Day related events
@warning_ignore("unused_signal")
signal day_started(day: int, temperature: String, weather: String)
@warning_ignore("unused_signal")
signal day_ended #Probably used for auto saves

# Weather related events
@warning_ignore("unused_signal")
signal weather_changed(temp_mult: float, weather_mult: float)

# Warmth related events
@warning_ignore("unused_signal")
signal coat_changed()
@warning_ignore("unused_signal")
signal exposure_area_exited(exposure_type: String)
@warning_ignore("unused_signal")
signal exposure_area_entered(exposure_type: String)

# Task related events
@warning_ignore("unused_signal")
signal task_completed(task_id: String)

# Mouse capture related events
enum MouseMode {VISIBLE, CAPTURED} # Add others as needed
@warning_ignore("unused_signal")
signal mouse_mode_changed(mode: int) # Emit like EventBus.mouse_mode_changed.emit(EventBus.MouseMode.VISIBILE)

# TEST WIP 12/10/25
# Control Stack Related related events
enum ControlState { GAMEPLAY = -1, PAUSE, INVENTORY, FUSE_REPAIR, DIALOGUE}
@warning_ignore("unused_signal")
signal control_state_changed(old_state : ControlState, new_state : ControlState) # Emit when chaning control state
@warning_ignore("unused_signal")
signal request_append_control_state(state : ControlState) # Adds the newly opened state to array
@warning_ignore("unused_signal")
signal request_player_freeze(bool) # False =  Player can move / Normal gameplay; True = disable player movement and camera control
@warning_ignore("unused_signal")
signal request_update_player_freeze(bool) # Requests ControlStackManager to run the _update_player_freeze() func which will then emit request_player_freeze() to actually freeze or unfreeze
@warning_ignore("unused_signal")
signal target_camera_transform(target_global_transforms : Transform3D) # Sends the Transform3D to Player/Camera to tween the camera
@warning_ignore("unused_signal")
signal camera_to_origin()
@warning_ignore("unused_signal")
signal pause_unpause()
