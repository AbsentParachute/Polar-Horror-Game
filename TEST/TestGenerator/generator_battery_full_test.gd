extends Interactable

func interact(interactor) -> void:
	InventoryManager.add_item_by_id("Battery_Gen_Full")
	queue_free()
