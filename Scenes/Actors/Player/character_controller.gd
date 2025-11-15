extends CharacterBody3D

#########################
## REWORK ENTIRE SCRIPT##
#########################

# ────────────────────── Movement & Physics ──────────────────────
@export var walk_speed      : float = 5.0
@export var sprint_speed    : float = 10.0
@export var crouch_speed    : float = 2.5
@export var accel_ground    : float = 20.0
@export var accel_air       : float = 6.0
@export var decel_stop_ground : float = 40.0
@export var jump_velocity   : float = 4.5
@export var gravity         : float = ProjectSettings.get_setting("physics/3d/default_gravity")

# ────────────────────── Camera / View ───────────────────────────
@export var mouse_sens      : Vector2 = Vector2(0.002, 0.002)
@export_range(-89.0, 89.0) var pitch_limit : float = 89.0
@onready var head           : Node3D      = $Head
@onready var camera         : Camera3D    = $Head/Camera

# ────────────────────── Head-bob & Crouch ───────────────────────
@export var crouch_cam_off  : float = -1.0
@export var crouch_height_scale : float = 0.55
@onready var collider       : CollisionShape3D = $CollisionShape3D

# ────────────────────── Internal State ──────────────────────────
var _yaw          : float = 0.0
var _pitch        : float = 0.0
var _move_dir     : Vector3 = Vector3.ZERO
var _target_speed : float = 0.0
var _cam_origin   : Vector3

var _stand_height : float
var _stand_center : Vector3

# ────────────────────── Ready ───────────────────────────────────
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_cam_origin   = camera.transform.origin
	_stand_height = (collider.shape as CapsuleShape3D).height
	_stand_center = collider.position

# ────────────────────── Raw Mouse Input ─────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw   -= event.relative.x * mouse_sens.x
		_pitch = clamp(_pitch - event.relative.y * mouse_sens.y,
					   deg_to_rad(-pitch_limit), deg_to_rad(pitch_limit))
		rotation.y      = _yaw
		head.rotation.x = _pitch

# ────────────────────── Physics Step ────────────────────────────
func _process(delta: float) -> void:
	_gather_movement_input()
	_apply_gravity(delta)
	_apply_horizontal_move(delta)

	move_and_slide()   # ← basic Godot 4 movement
	_update_crouch(delta)

# ────────────────────── Movement Helpers ────────────────────────
func _gather_movement_input() -> void:
	var in_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	_move_dir = (global_transform.basis * Vector3(in_vec.x, 0, in_vec.y)).normalized()

	var crouched  := Input.is_action_pressed("move_crouch")
	var sprinting := Input.is_action_pressed("move_sprint") and not crouched

	if is_on_floor():
		_target_speed = (
			crouch_speed if crouched else
			sprint_speed if sprinting else
			walk_speed
		)
		if Input.is_action_just_pressed("move_jump"):
			velocity.y = jump_velocity
	else:
		_target_speed = walk_speed

func _apply_gravity(delta: float) -> void:
	velocity.y -= gravity * delta
	if is_on_floor() and velocity.y < 0.0:
		velocity.y = -0.1

func _apply_horizontal_move(delta: float) -> void:
	var horiz := velocity
	horiz.y = 0.0

	var desired   := _move_dir * _target_speed
	var accel     := accel_ground if is_on_floor() else accel_air
	var braking   := decel_stop_ground

	if _move_dir.length() > 0.01:
		horiz = horiz.move_toward(desired, accel * delta)
	else:
		horiz = horiz.move_toward(Vector3.ZERO, braking * delta)

	velocity.x = horiz.x
	velocity.z = horiz.z

# ────────────────────── Crouch ─────────────────────
func _update_crouch(delta: float) -> void:
	var crouched := Input.is_action_pressed("move_crouch")

	var cam_target := _cam_origin.y + (crouch_cam_off if crouched else 0.0)
	camera.transform.origin.y = lerp(camera.transform.origin.y, cam_target, 12.0 * delta)

	var cap := collider.shape as CapsuleShape3D
	var target_h := _stand_height * (crouch_height_scale if crouched else 1.0)
	cap.height = lerp(cap.height, target_h, 12.0 * delta)

	var offset := (_stand_height - cap.height) * 0.5
	collider.position.y = lerp(collider.position.y, _stand_center.y - offset, 12.0 * delta)
