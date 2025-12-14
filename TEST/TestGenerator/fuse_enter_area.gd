extends Interactable

signal fuse_enter_int() 

func interact(interactor) -> void:
	fuse_enter_int.emit()
