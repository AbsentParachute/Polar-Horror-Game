extends Node2D

@export_group("References")
@export var ch1r : Line2D
@export var ch2b : Line2D
@export var ch3g : Line2D
@export var ch4y : Line2D
@export var puzzle : Node3D

@export_group("Offset")
@export var samples: int = 512  # number of plotted points per wave
@export var red_offset_px: float = -80.0
@export var blue_offset_px: float = -26.0
@export var green_offset_px: float = -26.0
@export var yellow_offset_px: float = -80.0

@export_group("Jitter")
@export var jitter_px: float = 1.5          # max ±px per point (1.0–2.0 = subtle)
@export var jitter_updates_hz: float = 24.0 # how often we refresh the flicker
@export var jitter_fraction: float = 0.06   # fraction of points that get new targets each tick
@export var jitter_smooth: float = 0.30     # 0..1, how fast offsets ease toward targets

# --- amplitude (px) and frequency (cycles across width) lookup tables per knob value 0..7 ---
##NOTE Need to make everything distinct enough, like 5 high vs 5 low or 3 freq and 4 freq so they look different
const RED_AMP  := [20.0, 25.0, 30.0, 36.0, 42.0, 48.0, 56.0, 64.0]
const RED_FREQ := [1.0,  2.0,  2.2,  2.5,  3.0,  3.5,  4.0,  5.0]

const BLUE_AMP  := [18.0, 22.0, 26.0, 30.0, 34.0, 38.0, 42.0, 46.0]
const BLUE_FREQ := [1.0,  2.5,  2.0,  3.5,  3.0,  4.5,  4.0,  5.0]

# “Complex” = fundamental + 3rd harmonic (nice ‘rich’ shape)
const GREEN_AMP  := [26.0, 50.0, 24.0, 48.0, 42.0, 26.0, 40.0, 14.0]
const GREEN_FREQ := [1.8,  2.0,  3.2,  3.0,  4.6,  4.8,  5.0,  5.4]

const YELLOW_AMP  := [14.0, 38.0, 22.0, 46.0, 30.0, 40.0, 18.0, 42.0]
const YELLOW_FREQ := [3.0,  3.0,  5.0,  5.0,  7.0,  8.0,  6.0,  2.8]

# Calculation vectors
var sz: Vector2
var w: float
var h: float
var mid_y: float

# Jitter and RNG
var _rng: RandomNumberGenerator
var _jitter_timer: float = 0.0
var _jitter_dt: float = 0.0

# base curves (clean) per channel
var _base_r: PackedVector2Array
var _base_b: PackedVector2Array
var _base_g: PackedVector2Array
var _base_y: PackedVector2Array

# per-point current offsets 
var _off_r: PackedFloat32Array
var _off_b: PackedFloat32Array
var _off_g: PackedFloat32Array
var _off_y: PackedFloat32Array

# target offsets per channel
var _tgt_r: PackedFloat32Array
var _tgt_b: PackedFloat32Array
var _tgt_g: PackedFloat32Array
var _tgt_y: PackedFloat32Array

func _ready() -> void:
	await get_tree().process_frame
	_refresh_dims()
	
	var vp := get_viewport()
	var svp := vp as SubViewport
	if svp != null:
		svp.size_changed.connect(_on_vp_size_changed)
	
	puzzle.knob_value_changed.connect(_on_knob_value_changed)
	
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

	set_red_from_knob(_rng.randi_range(0,7))
	set_blue_from_knob(_rng.randi_range(0,7))
	set_green_from_knob(_rng.randi_range(0,7))
	set_yellow_from_knob(_rng.randi_range(0,7))

	_jitter_dt = 1.0 / jitter_updates_hz

func _process(delta: float) -> void:
	_jitter_timer += delta
	if _jitter_timer < _jitter_dt:
		return
	_jitter_timer -= _jitter_dt

	# Jitter each channel a tiny bit
	_jitter_channel(ch1r, _base_r, _off_r, _tgt_r)
	_jitter_channel(ch2b, _base_b, _off_b, _tgt_b)
	_jitter_channel(ch3g, _base_g, _off_g, _tgt_g)
	_jitter_channel(ch4y, _base_y, _off_y, _tgt_y)

func _on_vp_size_changed() -> void:
	_refresh_dims()
	
	# Replot all channels with current knob values (so bases get rebuilt)
	set_red_from_knob(0)
	set_blue_from_knob(0)
	set_green_from_knob(0)
	set_yellow_from_knob(0)

func _refresh_dims() -> void:
	var rect := get_viewport_rect()
	sz = rect.size
	w = sz.x
	h = sz.y
	mid_y = h * 0.5

func set_red_from_knob(knob_value: int) -> void:
	var idx: int = clampi(knob_value, 0, 7)
	_plot_sine(ch1r, RED_AMP[idx], RED_FREQ[idx], mid_y + red_offset_px)

func set_blue_from_knob(knob_value: int) -> void:
	var idx: int = clampi(knob_value, 0, 7)
	_plot_square(ch2b, BLUE_AMP[idx], BLUE_FREQ[idx], mid_y + blue_offset_px)

func set_green_from_knob(knob_value: int) -> void:
	var idx: int = clampi(knob_value, 0, 7)
	_plot_complex(ch3g, GREEN_AMP[idx], GREEN_FREQ[idx], mid_y - green_offset_px)

func set_yellow_from_knob(knob_value: int) -> void:
	var idx: int = clampi(knob_value, 0, 7)
	_plot_sawtooth(ch4y, YELLOW_AMP[idx], YELLOW_FREQ[idx], mid_y - yellow_offset_px)

func _on_knob_value_changed(knob_name: String, value: int) -> void:
	var name_key: String = String(knob_name)
	if name_key == "Red":
		set_red_from_knob(value)
	elif name_key == "Blue":
		set_blue_from_knob(value)
	elif name_key == "Green":
		set_green_from_knob(value)
	elif name_key == "Yellow":
		set_yellow_from_knob(value)

## Plotting Helpers
func _plot_sine(line: Line2D, amplitude: float, frequency: float, base_y: float) -> void:
	var pts := PackedVector2Array()
	pts.resize(samples)

	var i: int = 0
	while i < samples:
		var t: float = float(i) / float(samples - 1) # 0..1 across width
		var x: float = t * w #x spans full width
		var theta: float = TAU * frequency * t # 2π * freq * t
		var y: float = base_y - amplitude * sin(theta) # minus so positive is “up”
		pts[i] = Vector2(x, y)
		i += 1
		
	line.points = pts
	_cache_base_for_line(line, pts) 

func _plot_square(line: Line2D, amplitude: float, frequency: float, base_y: float) -> void:
	var pts := PackedVector2Array()
	pts.resize(samples)
	
	var i: int = 0
	while i < samples:
		var t: float = float(i) / float(samples - 1) # 0..1 across width
		var x: float = t * w #x spans full width
		var s: float = sin(TAU * frequency * t)
		var sgn: float = 1.0
		if s < 0.0:
			sgn = -1.0
		var y: float = base_y - amplitude * sgn
		pts[i] = Vector2(x, y)
		i += 1
		
	line.points = pts
	_cache_base_for_line(line, pts) 

func _plot_complex(line: Line2D, amplitude: float, frequency: float, base_y: float) -> void:
	var pts := PackedVector2Array()
	pts.resize(samples)
	var a1: float = 0.75
	var a3: float = 0.25

	var i: int = 0
	while i < samples:
		var t: float = float(i) / float(samples - 1)
		var x: float = t * w
		var s: float = a1 * sin(TAU * (frequency * t)) \
					+ a3 * sin(TAU * (3.0 * frequency * t))
		var y: float = base_y - amplitude * s
		pts[i] = Vector2(x, y)
		i += 1
	line.points = pts
	_cache_base_for_line(line, pts) 

func _plot_sawtooth(line: Line2D, amplitude: float, frequency: float, base_y: float) -> void:
	var pts := PackedVector2Array()
	pts.resize(samples)

	var i: int = 0
	while i < samples:
		var t: float = float(i) / float(samples - 1) # 0..1 across width
		var x: float = t * w #x spans full width
		var cyc: float = frequency * t
		var frac: float = cyc - floor(cyc) # 0..1 within each cycle
		var s: float = 2.0 * frac - 1.0
		var y: float = base_y - amplitude * s
		pts[i] = Vector2(x,y)
		i += 1
		
	line.points = pts
	_cache_base_for_line(line, pts) 

# Store the clean points for that line and zero the jitter buffers to same length
func _cache_base_for_line(line: Line2D, pts: PackedVector2Array) -> void:
	if line == ch1r:
		_base_r = pts
		_off_r = PackedFloat32Array()
		_tgt_r = PackedFloat32Array()
		_off_r.resize(pts.size())
		_tgt_r.resize(pts.size())
		var i: int = 0
		while i < pts.size():
			_off_r[i] = 0.0
			_tgt_r[i] = 0.0
			i += 1
	elif line == ch2b:
		_base_b = pts
		_off_b = PackedFloat32Array()
		_tgt_b = PackedFloat32Array()
		_off_b.resize(pts.size())
		_tgt_b.resize(pts.size())
		var j: int = 0
		while j < pts.size():
			_off_b[j] = 0.0
			_tgt_b[j] = 0.0
			j += 1
	elif line == ch3g:
		_base_g = pts
		_off_g = PackedFloat32Array()
		_tgt_g = PackedFloat32Array()
		_off_g.resize(pts.size())
		_tgt_g.resize(pts.size())
		var k: int = 0
		while k < pts.size():
			_off_g[k] = 0.0
			_tgt_g[k] = 0.0
			k += 1
	elif line == ch4y:
		_base_y = pts
		_off_y = PackedFloat32Array()
		_tgt_y = PackedFloat32Array()
		_off_y.resize(pts.size())
		_tgt_y.resize(pts.size())
		var m: int = 0
		while m < pts.size():
			_off_y[m] = 0.0
			_tgt_y[m] = 0.0
			m += 1

# Tiny per-point flicker around the base curve (no horizontal motion)
func _jitter_channel(line: Line2D,
		base: PackedVector2Array,
		off: PackedFloat32Array,
		tgt: PackedFloat32Array) -> void:

	if base.size() == 0:
		return

	var n_pts: int = base.size()

	# how many points get retargeted this tick
	var n_change: int = int(float(n_pts) * jitter_fraction)
	if n_change < 1:
		n_change = 1

	# choose a handful of indices and assign new target offsets within ±jitter_px
	var c: int = 0
	while c < n_change:
		var idx: int = _rng.randi_range(0, n_pts - 1)
		tgt[idx] = _rng.randf_range(-jitter_px, jitter_px)
		c += 1

	# ease offsets toward targets
	var i: int = 0
	while i < n_pts:
		off[i] = off[i] + (tgt[i] - off[i]) * jitter_smooth
		# deadzone small values so they don't drift forever
		if off[i] < 0.05 and off[i] > -0.05:
			off[i] = 0.0
		i += 1

	# apply offsets (y only) to a copy of the base, then swap onto the line
	var pts := PackedVector2Array()
	pts.resize(n_pts)
	var j: int = 0
	while j < n_pts:
		var p: Vector2 = base[j]
		p.y = p.y + off[j]
		pts[j] = p
		j += 1

	line.points = pts
