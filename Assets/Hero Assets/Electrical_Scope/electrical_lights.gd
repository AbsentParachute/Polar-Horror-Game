extends Node3D

@export var red_light : MeshInstance3D
@export var blue_light : MeshInstance3D
@export var green_light : MeshInstance3D
@export var yellow_light : MeshInstance3D
@export var puzzle: Node3D

var _red_mat: StandardMaterial3D
var _blue_mat: StandardMaterial3D
var _green_mat: StandardMaterial3D
var _yellow_mat: StandardMaterial3D

func _ready() -> void:
	_red_mat    = _get_or_make_led_mat(red_light)
	_blue_mat   = _get_or_make_led_mat(blue_light)
	_green_mat  = _get_or_make_led_mat(green_light)
	_yellow_mat = _get_or_make_led_mat(yellow_light)
	
	_force_all_off()
	
	puzzle.knob_value_changed.connect(_on_any_knob_changed)
	
	await get_tree().process_frame
	_update_all()

func _on_any_knob_changed(_name: String, _value: int) -> void:
	_update_all()

func _force_all_off() -> void:
	_set_emission_enabled(_red_mat, false)
	_set_emission_enabled(_blue_mat, false)
	_set_emission_enabled(_green_mat, false)
	_set_emission_enabled(_yellow_mat, false)

func _update_all() -> void:
	if puzzle == null:
		return

	var knobs: Dictionary = puzzle.knobs
	var r_val: int = int(knobs["Red"]["value"])
	var y_val: int = int(knobs["Yellow"]["value"])
	var b_val: int = int(knobs["Blue"]["value"])
	var g_val: int = int(knobs["Green"]["value"])

	var r_t: int = int(puzzle.red_target)
	var y_t: int = int(puzzle.yellow_target)
	var b_t: int = int(puzzle.blue_target)
	var g_t: int = int(puzzle.green_target)

	_set_emission_enabled(_red_mat,    r_val == r_t)
	_set_emission_enabled(_yellow_mat, y_val == y_t)
	_set_emission_enabled(_blue_mat,   b_val == b_t)
	_set_emission_enabled(_green_mat,  g_val == g_t)

func _set_emission_enabled(mat: StandardMaterial3D, enabled: bool) -> void:
	if mat == null:
		print("Mat null")
		return
	mat.emission_enabled = enabled  # flips emissive ON/OFF, keeps your color/energy/texture

func _get_or_make_led_mat(mi: MeshInstance3D) -> StandardMaterial3D:
	if mi == null:
		return null

	# 1) Prefer an existing StandardMaterial3D override
	var mo := mi.material_override
	var std := mo as StandardMaterial3D
	if std != null:
		std.resource_local_to_scene = true
		return std

	# 2) Try a surface override on this instance and duplicate it
	var surf := mi.get_surface_override_material(0)
	std = surf as StandardMaterial3D
	if std != null:
		var dup := std.duplicate() as StandardMaterial3D
		dup.resource_local_to_scene = true
		mi.material_override = dup
		return dup

	# 3) Try the mesh's original surface material and duplicate it
	if mi.mesh != null:
		var base_mat := mi.mesh.surface_get_material(0)
		std = base_mat as StandardMaterial3D
		if std != null:
			var dup2 := std.duplicate() as StandardMaterial3D
			dup2.resource_local_to_scene = true
			mi.material_override = dup2
			return dup2

	# 4) Fallback: create a new StandardMaterial3D override (no presets to copy)
	var fresh := StandardMaterial3D.new()
	fresh.resource_local_to_scene = true
	mi.material_override = fresh
	push_warning("%s had no StandardMaterial3D to duplicate; created a fresh override. If you want presets, assign a StandardMaterial3D on the mesh first." % mi.name)
	return fresh
