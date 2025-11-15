extends Node

enum Temperature {SAFE, COLD, VERY_COLD, EXTREMELY_COLD, DANGEROUSLY_COLD}
enum Weather {CLEAR, SNOW, WHITEOUT}

##NOTE "name" will be used for Debug purposes

const TEMP_DATA = {
	Temperature.SAFE: {
		"name": "Safe", #To access the "name" or "temp_min" you need brackets [] for example: if we have current_temp_state = Temperature.SAFE then var min_temp = TEMP_DATA[current_temp_state]["temp_min] this would make the min_temp be -50
		"temp_min": -50,
		"temp_max": -40,
		"temp_mult": 1.0 #No warmth loss unless no coat?
	},
 	Temperature.COLD: {
 		"name": "Cold",
 		"temp_min": -70,
 		"temp_max": -61,
 		"temp_mult": 1.5
 	},
 	Temperature.VERY_COLD: {
 		"name": "Very Cold",
 		"temp_min": -80,
 		"temp_max": -71,
 		"temp_mult": 2.0 
 	},
 	Temperature.EXTREMELY_COLD: {
 		"name": "Extremely Cold",
 		"temp_min": -90,
 		"temp_max": -81,
 		"temp_mult": 2.5 
 	},
 	Temperature.DANGEROUSLY_COLD: {
 		"name": "Dangerously Cold",
 		"temp_min": -100,
 		"temp_max": -91,
 		"temp_mult": 3.0  	
	}
}

const WEATHER_DATA = {
	Weather.CLEAR:{
		"name": "Clear",
		## Will implement solution for snowfall, and visibility at a later date when applicable
		## Focusing now on just the warmth system. 
		"weather_mult": 1.0
	},
 	Weather.SNOW:{
 		"name": "Snow",
 		"weather_mult": 1.5
	},
 	Weather.WHITEOUT:{
 		"name": "Whiteout",
 		"weather_mult": 2.0
	},
}

const TEMP_TO_ENUM = {
	"SAFE": Temperature.SAFE,
	"COLD": Temperature.COLD,
	"VERY_COLD": Temperature.VERY_COLD,
	"EXTTREMELY_COLD": Temperature.EXTREMELY_COLD,
	"DANGEROUSLY_COLD": Temperature.DANGEROUSLY_COLD
}

const WEATHER_TO_ENUM = {
	"CLEAR": Weather.CLEAR,
	"SNOW": Weather.SNOW,
	"WHITEOUT": Weather.WHITEOUT
}

var _weather_state = null
var _temperature_state = null

var weather_mult: float = 0
var temp_mult: float = 0
var temp_min: float = 0
var temp_max: float = 0

func _ready() -> void:
	EventBus.day_started.connect(_on_day_started)
	#_on_day_started(DayService.get_current_day()) #Initial sync for current day REDUNDANT ALREADY SENT VIA DAY SERVICE. Could do this as part of inital setup as var state := #DayService.get_day_state(DayService.get_current_day())
	#_on_day_started(DayService.get_current_day(), state["temp"], state["weather"])

func _on_day_started(_day: int, temp: String, weather: String) -> void: 
	_temperature_state = TEMP_TO_ENUM[temp]
	_weather_state = WEATHER_TO_ENUM[weather]

	var temp_data = TEMP_DATA[_temperature_state]
	var weather_data = WEATHER_DATA[_weather_state]

	temp_mult = temp_data["temp_mult"]
	temp_min = temp_data["temp_min"]
	temp_max = temp_data["temp_max"]
	weather_mult = weather_data["weather_mult"]
	
	EventBus.weather_changed.emit(temp_mult, weather_mult) #eventually add the temp min and max for display purposes. This is to notify WarmthComponent of a change in the weather/temp.
