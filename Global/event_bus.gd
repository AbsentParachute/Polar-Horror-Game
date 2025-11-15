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
