extends Interactable

signal cool_fill_start_int()
signal cool_fill_stop_int()

func interact_hold(delta, interactor) -> void:
	cool_fill_start_int.emit()

func interact_release(interactor) -> void:
	cool_fill_stop_int.emit()
