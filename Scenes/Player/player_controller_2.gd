class_name PlayerController2
extends CharacterBody3D

#TODO: Need to lower airborne speed or add deceleration

@export_category("References")
@export var camera : CameraController
@export var state_chart : StateChart
@export var standing_collision : CollisionShape3D
@export var crouching_collision: CollisionShape3D
@export var crouch_check : ShapeCast3D
@export var interaction_raycast: RayCast3D

@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration : float = 0.2
@export var deceleration : float = 0.5
@export_group("Speed")
@export var default_speed : float = 7.0
@export var sprint_speed : float = 3.0
@export var crouch_speed : float = -5.0
@export_group("Jump Settings")
@export var jump_velocity : float = 5.

var _input_dir : Vector2 = Vector2.ZERO
var _movement_velocity : Vector3 = Vector3.ZERO
var sprint_modifier : float = 0.0
var crouch_modifier : float = 0.0
var speed : float = 3.0

var _prev_global_transform: Transform3D
var _curr_global_transform: Transform3D

var processes_enabled : bool = true

func _ready() -> void:
	_prev_global_transform = global_transform
	_curr_global_transform = global_transform

func _physics_process(delta: float) -> void:
	# --- manual interpolation bookkeeping ---
	_prev_global_transform = _curr_global_transform
	# ---------------------------------------

	var grounded = is_on_floor()
	
	if not grounded:
		velocity += get_gravity() * delta
		
	var speed_modifier = crouch_modifier
	if grounded:
		speed_modifier += sprint_modifier
	
	speed = default_speed + speed_modifier
	
	_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	var direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()
	
	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)
	
	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	velocity = _movement_velocity

	move_and_slide()

	# --- after movement, record new transform ---
	_curr_global_transform = global_transform
	# -------------------------------------------

func get_smooth_transform() -> Transform3D:
	var alpha: float = Engine.get_physics_interpolation_fraction()
	return _prev_global_transform.interpolate_with(_curr_global_transform, alpha)


func update_rotation(yaw: float) -> void:
	var current_rot: Vector3 = rotation
	current_rot.y = yaw
	rotation = current_rot


func sprint() -> void:
	sprint_modifier = sprint_speed

func walk() -> void:
	sprint_modifier = 0.0

func stand() -> void:
	crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true

func crouch() -> void:
	crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false

func jump() -> void:
	velocity.y += jump_velocity
