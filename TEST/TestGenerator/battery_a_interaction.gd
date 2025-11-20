extends Interactable

signal batt_a_int()

func interact(interactor) -> void:
	batt_a_int.emit()
