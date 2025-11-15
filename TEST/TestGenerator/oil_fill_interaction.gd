extends Interactable

signal oil_fill_start_int()
signal oil_fill_stop_int()

func interact_hold(delta, interactor) -> void:
	oil_fill_start_int.emit()

func interact_release(interactor) -> void:
	oil_fill_stop_int.emit()
