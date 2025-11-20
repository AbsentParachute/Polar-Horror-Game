extends Interactable

signal lid_b_int()

func interact(interactor) -> void:
	lid_b_int.emit()
