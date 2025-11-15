extends PlayerState


func _on_grounded_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("move_jump") and player_controller.is_on_floor() and not Input.is_action_pressed("move_crouch"):
		player_controller.jump()
		player_controller.state_chart.send_event("onAirborne")
	
	if not player_controller.is_on_floor():
		player_controller.state_chart.send_event("onAirborne")
