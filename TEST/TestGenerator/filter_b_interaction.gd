extends Interactable

signal filter_b_int()

func interact(interactor) -> void:
	filter_b_int.emit()
