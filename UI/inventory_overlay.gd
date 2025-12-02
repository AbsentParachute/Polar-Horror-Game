extends Control

@export var debug : bool = false

@onready var container: SubViewportContainer = $SubViewportContainer
@onready var subvp: SubViewport = $SubViewportContainer/SubViewport
@onready var carousel: InventoryCarousel = $SubViewportContainer/SubViewport/InventoryCarousel
@onready var left_btn: Button = $LeftButton
@onready var right_btn: Button = $RightButton
@onready var name_label: Label = $ItemNameLabel
@onready var desc_label: Label = $ItemDescriptionLabel

func _ready() -> void:
	_resize_subviewport()
	resized.connect(_resize_subviewport)
	
	##NOTE not hooked up to refresh when using arrow keys
	left_btn.pressed.connect(func(): 
		carousel.prev_item()
		_refresh_labels()
	)
	right_btn.pressed.connect(func():
		carousel.next_item()
		_refresh_labels()
	)
	
	visible = false # starts hidden

func open_inventory() -> void:
	visible = true
	_resize_subviewport()
	
	carousel.open_and_build()
	_refresh_labels()

func close_inventory() -> void:
	carousel.close_inventory()
	subvp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	visible = false

func _resize_subviewport() -> void:
	var s := container.size
	var w := int(round(s.x))
	var h := int(round(s.y))
	if w < 1:
		w = 1
	if h < 1:
		h = 1
	subvp.size = Vector2i(w, h)
	subvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _refresh_labels() -> void:
	var data : ItemData = carousel.get_selected_item_data()
	
	if debug:
		print("refresh_labels -> selected_index:", carousel.selected_index, " data:", data)
	
	if data == null:
		name_label.text = ""
		desc_label.text = ""
		return
	name_label.text = data.display_name
	desc_label.text = data.description
