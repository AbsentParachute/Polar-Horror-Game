extends Node

const DAY_DATA = {
	1: { "temp": "DANGEROUSLY_COLD", "weather": "WHITEOUT" },
}

var _current_day: int = 0 #Default start on day 0 so the _ready can set to day 1

func _ready() -> void:
	if _current_day == 0:
		start_next_day()

func get_current_day() -> int: #Should be called by any script that needs to get access to the current day
	return _current_day

func get_day_state(day: int) -> Dictionary:
	var dict = DAY_DATA.get(day)
	##Need safety net since dict can = null
	return dict

func start_next_day() -> void:
	_current_day += 1
	var state := get_day_state(_current_day)
	EventBus.day_started.emit(_current_day, state["temp"], state["weather"])

func start_day_end() -> void: 
	EventBus.day_ended.emit() #Tell everything that cares about the day ending, IE saving data
	start_next_day()
