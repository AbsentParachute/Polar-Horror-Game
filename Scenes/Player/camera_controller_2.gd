class_name CameraController2
extends Node3D

const DEFAULT_HEIGHT: float = 0.5

@onready var camera_3d: Camera3D = $Camera3D

@export var debug: bool = false

@export_category("References")
@export var player_controller: PlayerController
@export var component_mouse_capture: MouseCaptureComponent

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90, -60) var tilt_lower_limit: int = -80
@export_range(60, 90) var tilt_upper_limit: int = 80

@export_group("Crouch Vertical Movement")
@export var crouch_offset: float = 0.0
@export var crouch_speed: float = 3.0

@export_group("Follow")
@export var follow_speed: float = 15.0

var processes_enabled : bool = true

# _rotation.x = pitch, _rotation.y = yaw
var _rotation: Vector2 = Vector2.ZERO
var _height: float = DEFAULT_HEIGHT


func _ready() -> void:
	_height = DEFAULT_HEIGHT


func _process(delta: float) -> void:
	if player_controller == null:
		return
	if component_mouse_capture == null:
		return

	# 1) Handle mouse look in _process() (not in _physics_process())
	var look: Vector2 = component_mouse_capture._mouse_input
	_update_camera_rotation(look)

	# 2) Follow the PLAYER'S interpolated transform (not our own)
	var player_tr: Transform3D = player_controller.get_smooth_transform()
	var target_pos: Vector3 = player_tr.origin + Vector3(0.0, _height, 0.0)

	global_position = global_position.lerp(
		target_pos,
		min(follow_speed * delta, 1.0)
	)

	# 3) Apply pitch to the camera; yaw lives on the player
	rotation.x = _rotation.x
	rotation.y = _rotation.y
	rotation.z = 0.0   # keep camera upright

func _update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x

	_rotation.x = clamp(
		_rotation.x,
		deg_to_rad(tilt_lower_limit),
		deg_to_rad(tilt_upper_limit)
	)

	player_controller.update_rotation(_rotation.y)

	# (or Option B if you prefer)
	# player_controller.update_rotation(_rotation.y)


func update_camera_height(delta: float, direction: int) -> void:
	# direction: 1 = move toward DEFAULT_HEIGHT, -1 = move toward crouch_offset
	_height = clampf(
		_height + crouch_speed * float(direction) * delta,
		crouch_offset,
		DEFAULT_HEIGHT
	)
