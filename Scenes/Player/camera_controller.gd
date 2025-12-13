class_name CameraController
extends Node3D

# NOTE
# No more jitter - Jitter caused by CSG meshes as objects and the Alt+Esc can be fixed by pausing the game and resuming. Need full time solution.
# Sill required to have everything as physics_process. Choppy camera when in process. 
# Might be able to fix by transforming the cameracontroller via the advanced interpolation and keeping it top level.

const DEFAULT_HEIGHT : float = 0.5

@export var debug : bool = false

@export_category("References")
@export var player_controller : PlayerController
@export var component_mouse_capture : MouseCaptureComponent
@export var camera : Camera3D

@export_category("Camera Settings")
@export_group("Camera Tilt")
@export_range(-90,-60) var tilt_lower_limit : int = -90
@export_range(60, 90) var tilt_upper_limit : int = 90
@export_group("Crouch Vertical Movement")
@export var crouch_offset : float = 0.0
@export var crouch_speed : float = 3.0

var _rotation : Vector3

func _ready() -> void:
	EventBus.target_camera_transform.connect(_move_camera_to_target)
	EventBus.camera_to_origin.connect(_move_camera_to_origin)

func _move_camera_to_target(t: Transform3D) -> void:
	var target_transform = t
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(camera, "global_transform", target_transform, 1.0)
	
func _move_camera_to_origin() -> void:
	var origin_transform : Transform3D = self.global_transform
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(camera, "global_transform", origin_transform, 1.0)
	
	await tween.finished # We await the tween finish because then the camera is back where it should be
	EventBus.camera_state_changed.emit(EventBus.Camera_State.PLAYER)

func _physics_process(_delta: float) -> void:
	if player_controller.camera_state != EventBus.Camera_State.PLAYER: # Player Controller holds the one truth of state which is why I am referecning here.
		return
	
	update_camera_rotation(component_mouse_capture._mouse_input)

func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y
	_rotation.y += input.x
	_rotation.x = clamp(_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))

	var _player_rotation = Vector3(0.0,_rotation.y,0.0)
	var _camera_rotation = Vector3(_rotation.x, 0.0, 0.0)
	
	transform.basis = Basis.from_euler(_camera_rotation)
	player_controller.update_rotation(_player_rotation)
	rotation.z = 0.0

func update_camera_height(delta: float, direction: int) -> void:
	if position.y >= crouch_offset and position.y <= DEFAULT_HEIGHT:
		position.y = clampf(position.y + (crouch_speed * direction) * delta, crouch_offset, DEFAULT_HEIGHT)
