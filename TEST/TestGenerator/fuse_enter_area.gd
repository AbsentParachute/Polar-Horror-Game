extends Interactable

signal fuse_enter_int() 

@warning_ignore("unused_parameter")
func interactable(interactor) -> void:
	fuse_enter_int.emit()
