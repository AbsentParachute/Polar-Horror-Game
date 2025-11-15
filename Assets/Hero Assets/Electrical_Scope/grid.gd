extends Node2D

@export var background_color: Color = Color (0.863, 0.863, 0.863, 1.0)
@export var grid_minor: Color = Color (0.08, 0.09, 0.11, 1.0)
@export var grid_major: Color = Color (0.12, 0.14, 0.18, 1.0)
@export var spacing_px: int = 64        # square grid cells
@export var major_every: int = 4         # every 4th line is "major"


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var sz : Vector2 = get_viewport_rect().size #sz = size 

	#Background
	draw_rect(Rect2(Vector2.ZERO, sz), background_color, true)

	var step: float = float(max(8, spacing_px))
	var cols: int = int(ceil(sz.x / step))
	var rows: int = int(ceil(sz.y / step))

	#Draw Columns
	for c in cols + 1:
		var x: float = float(c) * step
		var col: Color = grid_minor
		if major_every > 0 and c % major_every == 0:
			col = grid_major
		draw_line(Vector2(x, 0.0), Vector2(x, sz.y), col, 1.0)

	#Draw Rows
	for r in rows + 1:
		var y: float = float(r) * step
		var col: Color = grid_minor
		if major_every > 0 and r % major_every == 0:
			col =  grid_major
		draw_line(Vector2(0.0, y), Vector2(sz.x, y), col, 1.0)
	
