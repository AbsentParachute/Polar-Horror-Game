extends Interactable

signal oil_tank_int()

func interact(interactor) -> void:
	oil_tank_int.emit()
