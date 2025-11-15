extends Area3D

@export var knob_name : String = "Blue"
@export var pivot : Node3D
@export var puzzle : Node3D
@export var steps: int = 8                   # 8 detents => 45° each / Change _detent_deg to match
@export var pivot_axis: int = 1              # 0=X, 1=Y, 2=Z (rotation axis)

var _detent_deg : float = 45.0 
var _current_angle : float = 0.0             # current visual angle

@warning_ignore("unused_parameter")
func _input_event(camera: Node, event: InputEvent, pos: Vector3, normal: Vector3, shape_idx: int) -> void:
	var mbe := event as InputEventMouseButton
	if mbe == null or not mbe.pressed:
		return
	
	if mbe.button_index == MOUSE_BUTTON_LEFT:
		_step(-1)
	elif mbe.button_index == MOUSE_BUTTON_RIGHT:
		_step(+1)
	elif mbe.button_index == MOUSE_BUTTON_WHEEL_UP: 
		_step(-1)
	elif mbe.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_step(+1)
	
func _step(delta: int) -> void:
	var delta_steps: int = delta * -1 # We multiply by -1 to flip the sign so it matches with turning right = +1 left = -1
	
	#Visual: rotate pivot by 1 detent deg
	_current_angle += float(delta) * _detent_deg
	_set_pivot_angle(_current_angle)

	# Emit signal from puzzle to puzzle to say which knob and what direction it was turned
	puzzle.knob_turned.emit(knob_name, delta_steps)
	print(knob_name, delta_steps)

func _set_pivot_angle(deg: float) -> void:
	var r: Vector3 = pivot.rotation_degrees
	if pivot_axis == 0: #This is required but never used
		r.x = deg
	elif pivot_axis == 1:
		r.y = deg
	else: #This is required but never used
		r.z = deg
	pivot.rotation_degrees = r
