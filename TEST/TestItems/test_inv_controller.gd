# res://test/InventoryTestController.gd
extends Node

@onready var overlay: Control = $InventoryOverlay/InventoryRoot
@onready var carousel: InventoryCarousel = $InventoryOverlay/InventoryRoot/SubViewportContainer/SubViewport/InventoryCarousel


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		if overlay.visible:
			overlay.close_inventory()
			EventBus.mouse_mode_changed.emit(EventBus.MouseMode.CAPTURED)
		else:
			overlay.open_inventory()
			EventBus.mouse_mode_changed.emit(EventBus.MouseMode.VISIBLE)
		get_viewport().set_input_as_handled()

	# Drive carousel with keyboard too (in addition to your buttons)
	if overlay.visible:
		if event.is_action_pressed("ui_left"):
			carousel.prev_item()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right"):
			carousel.next_item()
			get_viewport().set_input_as_handled()

	# Add test items live
	if event.is_action_pressed("test_add_item_r"):
		var it: ItemData = load("res://TEST/TestItems/redbox.tres")
		InventoryManager._add_item(it)    # use your autoload name
		if overlay.visible:
			carousel.rebuild_after_inventory_change()

	if event.is_action_pressed("test_add_item_b"):
		var it2: ItemData = load("res://TEST/TestItems/bluebox.tres")
		InventoryManager._add_item(it2)
		if overlay.visible:
			carousel.rebuild_after_inventory_change()

	if event.is_action_pressed("test_add_item_g"):
		var it3: ItemData = load("res://TEST/TestItems/greenbox.tres")
		InventoryManager._add_item(it3)
		if overlay.visible:
			carousel.rebuild_after_inventory_change()
