extends MeshInstance3D

@export var fuse_id : FuseTypes.FuseID
@export_enum ("Fuse", "Light") var part_type : String = "Fuse"

func _ready() -> void:
	fuse_id = get_parent().fuse_id #Consider changing since apparently get_parent() is bad
