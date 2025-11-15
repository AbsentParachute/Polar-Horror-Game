extends Area3D

@export_enum ("WARM", "SHELTERED") var exposure_type: String = "WARM"

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		EventBus.exposure_area_entered.emit(exposure_type)
	else:
		pass

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("PLAYER"):
		EventBus.exposure_area_exited.emit(exposure_type)
	else:
		pass
