extends Interactable

signal fuse_interacted(fuse_id)

@export var fuse_id : FuseTypes.FuseID
@export_enum ("fuse_10", "fuse_20", "fuse_30", "fuse_50", "fuse_80", "fuse_100", "fuse_160", "fuse_250", "fuse_350", "fuse_600") var fuse_item_id : String = "fuse_10"

func _ready() -> void:
	# If we need, automatically set ray_pickable as well as delcare monitoruyabel etc.
	pass

func _input_event(camera, event, position, normal, shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# You can pass null or a reference depending on your design
			interact(null)

@warning_ignore("unused_parameter")
func interact(interactor) -> void:
	fuse_interacted.emit(fuse_id)
