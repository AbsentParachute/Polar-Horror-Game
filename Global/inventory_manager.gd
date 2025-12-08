extends Node

## TEST Working on item usage
#signal item_used(item_id : String) # emitted by the carousel or soemthing.
## TEST

var _items: Array[ItemData] = []

func _add_item(item: ItemData) -> void:
	if item == null: 
		push_error("_add_item: item is null")
		return
	_items.append(item) #Add the item to the Items array (Inventory)
	_sort_by_name()
	
func add_item_by_id(id: String) -> void:
	var data: ItemData = ItemDatabase.get_item(id) #Search ItemDatabase for ID and then return the ItemData for that ID
	if data == null:
		push_error("add_item_by_id: unknown id '%s'" % id)
		return
	_add_item(data) # Use the ItemData retrieved via ID as the input for _add_item()

func _remove_item_at(index: int) -> ItemData:
	if index < 0 or index >= _items.size():
		push_error("_remove_item_at: index out of range")
		return null
	return _items.pop_at(index) #Pop_at will remove the index# and then move all items in the array back by 1 so no index# is skipped.

func _get_item_at(index) -> ItemData: #Use Case: when the mouse hovers or the ui presents the item at this index. 
	if index < 0 or index >= _items.size():
		return null
	return _items[index]

func get_all_items() -> Array[ItemData]: #Use Case: This essentially gives something the whole index
	return _items

func has_item_id(id: String) -> bool: # Use Case: This is used when we need to check the inventory for a specific ID.
	for item: ItemData in _items:
		if item.id == id:
			return true
	return false

func remove_item_id(id: String) -> void: # We return a ture false incase we need it otherwise we don't really care bout the return value
	for i in range(_items.size()):
		var item: ItemData = _items[i]
		if item.id == id:
			_remove_item_at(i)
			return # Stop after first match

#___ Helpers ___

func _sort_by_name() -> void:
	_items.sort_custom(Callable(self, "_compare_by_name"))

func _compare_by_name(left_item: ItemData, right_item: ItemData) -> bool:
	# Case-insensitive alphabetical by display name, with id as tiebreaker
	var left_name: String = left_item.display_name.to_lower()
	var right_name: String = right_item.display_name.to_lower()
	
	if left_name == right_name:
		var left_id: String = String(left_item.id)
		var right_id: String = String(right_item.id)
		return left_id < right_id #Tie breaker
	
	return left_name < right_name
	
