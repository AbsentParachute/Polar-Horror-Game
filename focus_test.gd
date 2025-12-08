extends Node

# NOTE:
# This should fix any jitters when the game loses focus. Consider creating this as an autoload singleton.
# If keeping, place in Global and rename everything.

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Engine.max_fps = 0 # Zero means uncapped
		OS.low_processor_usage_mode = false
		get_tree().paused = false
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Engine.max_fps = 1
		OS.low_processor_usage_mode = true
		get_tree().paused = true
