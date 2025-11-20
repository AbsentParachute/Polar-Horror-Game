extends Interactable

signal lid_a_int()

func interact(interactor) -> void:
	lid_a_int.emit()
