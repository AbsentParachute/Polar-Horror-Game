extends Interactable

signal batt_b_int()

func interact(interactor) -> void:
	batt_b_int.emit()
