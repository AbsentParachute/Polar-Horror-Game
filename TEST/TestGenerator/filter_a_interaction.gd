extends Interactable

signal filter_a_int()

func interact(interactor) -> void:
	filter_a_int.emit()
