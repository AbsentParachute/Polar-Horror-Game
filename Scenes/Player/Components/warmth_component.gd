extends Node

enum Exposure {WARM, SHELTERED, EXPOSED} #Warm = Heating player up; Shelter = Decreased warmth loss and does not account for Weather only Temperature; Exposed = Normal Warmth loss, accounts for weather and temperature.

const EXPOSURE_DATA = {
	Exposure.WARM: {
		"name": "Warm",
		"exposure_mult": -1 #DEBUG - Safety Check
	},
	Exposure.SHELTERED: {
		"name": "Sheltered",
		"exposure_mult": .5 
	},
	Exposure.EXPOSED: {
		"name": "Exposed",
		"exposure_mult": 1
	}
}

const EXPOSURE_TO_ENUM = {
	"WARM": Exposure.WARM,
	"SHELTERED": Exposure.SHELTERED,
}

const WARMTH_MAX: int = 100 #Max warm you can be and baseline
const WARMTH_MIN: int = 0 #Min Warmth upon reach you die

@onready var coat_component: Node = $"../CoatComponent"

var warmth: float = 100
var actual_rate: float = 0.0
var cooling_rate: float = 0.222 #Calculate by taking WARMTH_MAX / (Base Rate (How long it should take to die mins)*60)
var warming_rate: float = 1.0
var warm_count: int = 0
var shelter_count: int = 0 
var current_exposure: int = Exposure.EXPOSED #They are int because an enum is held as int
var last_exposure: int = Exposure.EXPOSED
var temp_mult: float = 1.0
var weather_mult: float = 1.0

func _ready() -> void:
	EventBus.weather_changed.connect(_weather_changed)
	EventBus.exposure_area_entered.connect(_area_entered)
	EventBus.exposure_area_exited.connect(_area_exited)
	EventBus.coat_changed.connect(_update_actual_rate)
	_update_actual_rate() #Initialize an actual rate so it isn't stuck at 0 until a signal is emitted
	
	print("Warmth Component Ready") #DEBUG

func _process(delta) -> void:
	warmth += actual_rate * delta
	warmth = clamp(warmth, WARMTH_MIN, WARMTH_MAX)
	
	print("Warmth is currently", warmth) #DEBUG

func _area_entered(exposure_type: String) -> void:
	current_exposure = EXPOSURE_TO_ENUM[exposure_type]
	if current_exposure == Exposure.WARM:
		warm_count += 1
	elif current_exposure == Exposure.SHELTERED:
		shelter_count += 1
	
	_update_exposure()

func _area_exited(exposure_type: String) -> void:
	last_exposure = EXPOSURE_TO_ENUM[exposure_type]
	if last_exposure == Exposure.WARM:
		warm_count = max(0, warm_count - 1)
	elif last_exposure == Exposure.SHELTERED:
		shelter_count = max(0, shelter_count - 1)
	
	_update_exposure()

func _update_exposure() -> void:
	if warm_count > 0:
		current_exposure = Exposure.WARM
	elif shelter_count > 0:
		current_exposure = Exposure.SHELTERED
	else:
		current_exposure = Exposure.EXPOSED
	_update_actual_rate()

func _weather_changed(t_mult: float, w_mult: float) -> void:
	temp_mult = t_mult
	weather_mult = w_mult
	_update_actual_rate()

func _update_actual_rate() -> void:
	var coat_mult: int = 1
	if coat_component.coat_on == true:
		coat_mult = .5
	else:
		coat_mult = 1

	if current_exposure == Exposure.WARM:
		actual_rate = warming_rate
	elif current_exposure == Exposure.SHELTERED:
		actual_rate = -cooling_rate * coat_mult * EXPOSURE_DATA[current_exposure]["exposure_mult"] * temp_mult
	else:
		actual_rate = -cooling_rate * coat_mult * EXPOSURE_DATA[current_exposure]["exposure_mult"] * temp_mult * weather_mult
