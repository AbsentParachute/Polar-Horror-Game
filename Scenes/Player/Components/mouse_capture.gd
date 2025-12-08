class_name MouseCaptureComponent
extends Node

#NOTE:
# This is the controller for ANY mouse capture activity and thus needs a signal to change the states of mouse_mode
# Otherwise you will have bad physics interpolation / jittering when moving and turning mouse

@export var debug : bool = false

@export_category("References")
@export var camera_controller : CameraController

@export_category("Mouse Capture Settings")
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity : float = 0.005

var _capture_mouse : bool
var _mouse_input : Vector2

func _unhandled_input(event: InputEvent) -> void:
	_capture_mouse = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _capture_mouse:
		_mouse_input.x += -event.screen_relative.x * mouse_sensitivity
		_mouse_input.y += -event.screen_relative.y * mouse_sensitivity
		
	if debug:
		print(_mouse_input)

func _ready() -> void:
	Input.mouse_mode = current_mouse_mode
	EventBus.mouse_mode_changed.connect(_mouse_mode_changed)

#func consume_mouse_delta() -> Vector2:
	#var delta := _mouse_input
	#_mouse_input = Vector2.ZERO
	#return delta

func _process(_delta: float) -> void:
	_mouse_input = Vector2.ZERO

func _mouse_mode_changed(mode: int) -> void:
	match mode: #Add others as needed
		EventBus.MouseMode.VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		EventBus.MouseMode.CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
