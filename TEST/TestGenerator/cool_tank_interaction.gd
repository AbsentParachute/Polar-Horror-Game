extends Interactable

signal cool_tank_int()

func interact(interactor) -> void:
	cool_tank_int.emit()
