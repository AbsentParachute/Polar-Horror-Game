class_name Interactable
extends CollisionObject3D

@export var interact_text_hover: String = ""
@export var interact_enabled : bool = false
#@export var can_hold: bool = false # Defeauot false, if true then can interact_hold

# One-Time press
@warning_ignore("unused_parameter")
func interact(interactor: Node) -> void:
	pass

# Press and Hold - Called each frame while holding (after threshold)
@warning_ignore("unused_parameter")
func interact_hold(delta: float, interactor: Node) -> void:
	pass

# On Release
@warning_ignore("unused_parameter")
func interact_release(interactor: Node) -> void:
	pass
