extends Node3D

signal knob_turned(knob_name: String, delta: int)
signal knob_value_changed(knob_name: String, value: int)

@export var task_id: String = "Electrical"

#var knobs = {
	#"Red": {"value":0, "max":7, "carry":0, "secondary_target":"Yellow", "denominator":2},
	#"Yellow": {"value":0, "max":7, "carry":0, "secondary_target":"Blue", "denominator":2},
	#"Blue": {"value":0, "max":7, "carry":0, "secondary_target":"Green", "denominator":3},
	#"Green": {"value":0, "max":7, "carry":0, "secondary_target":"Red", "denominator":4}
#}

var knobs = {
	"Red":    {"value":0, "max":7, "turns":0, "last_q":0, "denominator":2, "next":"Yellow"},
	"Yellow": {"value":0, "max":7, "turns":0, "last_q":0, "denominator":2, "next":"Blue"},
	"Blue":   {"value":0, "max":7, "turns":0, "last_q":0, "denominator":3, "next":"Green"},
	"Green":  {"value":0, "max":7, "turns":0, "last_q":0, "denominator":4, "next":"Red"},
}

var red_target: int = 0
var yellow_target: int = 0
var blue_target: int = 0
var green_target: int = 0

var _turn_depth: int = 0

func _ready() -> void:
	knob_turned.connect(_turn_knob)
	EventBus.day_started.connect(_new_random_solution) #Determine if this signal will be send by the day or an RNG manager
	_new_random_solution()

# Keep your public entry:
func _turn_knob(knob_name: String, delta: int) -> void:
	_turn_depth += 1 #Increase depth by 1 so when we subtract after the internal func it becomes 0 for the if statement
	_turn_knob_internal(knob_name, delta, true, "")  # source, allow_propagation, origin
	_turn_depth -= 1
	if _turn_depth == 0:
		_check_solution()


func _turn_knob_internal(knob_name: String, delta: int, allow_propagation: bool = true, origin: String = "") -> void:
	if not knobs.has(knob_name):
		push_error("ElectricalPuzzle: unknown knob '%s'" % knob_name)
		return

	var k: Dictionary = knobs[knob_name]

	# 1) Apply this knob’s own detent move (visual/logic value)
	k["value"] = (k["value"] + delta + k["max"] + 1) % (k["max"] + 1)

	# 2) Update the signed turn accumulator
	k["turns"] = k["turns"] + delta

	# 3) Compute how many whole groups of q we’re at now (truncate toward zero!)
	var q = k["denominator"]
	var new_q: int = int(float(int(k["turns"])) / float(q))   # truncates toward zero

	# 4) Any change in quotient becomes downstream steps on 'next'
	var dq = new_q - k["last_q"]
	if allow_propagation:
		if dq != 0:
			var next_name = k["next"]
			var start = origin
			if start == "":
				start = knob_name  # first hop sets the origin

			if next_name != start:
				_turn_knob_internal(next_name, dq, true, start)

	# 5) Store the quotient we’ve already applied
	k["last_q"] = new_q

	# 6) Notify and check (unchanged)
	knob_value_changed.emit(knob_name, int(k["value"]))

func _new_random_solution() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	red_target = rng.randi_range(0, knobs["Red"]["max"])
	yellow_target = rng.randi_range(0, knobs["Yellow"]["max"])
	blue_target = rng.randi_range(0, knobs["Blue"]["max"])
	green_target = rng.randi_range(0, knobs["Green"]["max"])
	#print(red_target, yellow_target, blue_target, green_target)


func _check_solution() -> void:
	var r = knobs["Red"]["value"]
	var y = knobs["Yellow"]["value"]
	var b = knobs["Blue"]["value"]
	var g = knobs["Green"]["value"]

	var r_ok: bool = (r == red_target)
	var y_ok: bool = (y == yellow_target)
	var b_ok: bool = (b == blue_target)
	var g_ok: bool = (g == green_target)

	var r_status: String = "BAD"
	if r_ok:
		r_status = "OK"
	var y_status: String = "BAD"
	if y_ok:
		y_status = "OK"
	var b_status: String = "BAD"
	if b_ok:
		b_status = "OK"
	var g_status: String = "BAD"
	if g_ok:
		g_status = "OK"

	#print("Knob status ->  Red: %d / %d [%s] | Yellow: %d / %d [%s] | Blue: %d / %d [%s] | Green: %d / %d [%s]" %
		#[r, red_target, r_status, y, yellow_target, y_status, b, blue_target, b_status, g, green_target, g_status])
	if r_ok and y_ok and b_ok and g_ok:
		#print("Puzzle SOLVED ✅")
		EventBus.task_completed.emit(task_id)
	#else:
		#print("Solved: false")
