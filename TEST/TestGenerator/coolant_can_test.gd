extends Interactable

func interact(interactor) -> void:
	InventoryManager.add_item_by_id("Cool_Jerry_Can")
	queue_free()
