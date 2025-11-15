extends Interactable

func interact(interactor) -> void:
	InventoryManager.add_item_by_id("Air_Filter")
	queue_free()
