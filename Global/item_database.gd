extends Node

## Add Preload of itemdata path here
## NOTE any changes mad to the filepath including name must also be changed here.

const ITEMS: Array[ItemData] = [
	preload("res://TEST/TestGenerator/oil_jerry_can.tres"),
	preload("res://TEST/TestGenerator/coolant_jerry_can.tres"),
	preload("res://TEST/TestGenerator/air_filter.tres")
	
]

var _items_by_id : Dictionary = {} # String -> ItemData

func _ready() -> void:
	for item in ITEMS:
		register_item(item)

func register_item(data: ItemData) -> void:
	if data ==  null:
		push_error("Tried to register null ItemData")
		return
	if data.id == "":
		push_error("ItemData w/o id: %s" % [data.resource_path])
		return
	if _items_by_id.has(data.id):
		push_error("Duplicate item id: %s" % data.id)
		return
	
	_items_by_id[data.id] = data

func get_item(id: String) -> ItemData:
	return _items_by_id.get(id) # null if not found
