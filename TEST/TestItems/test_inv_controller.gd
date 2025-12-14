# res://test/InventoryTestController.gd
extends Node
@onready var inventory_root: Control = $".."
@onready var carousel: InventoryCarousel = $SubViewport/InventoryCarousel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("test_add_item_b"):
		var it2: ItemData = load("res://TEST/TestItems/bluebox.tres")
		InventoryManager._add_item(it2)
		if inventory_root.visible:
			carousel.rebuild_after_inventory_change()
