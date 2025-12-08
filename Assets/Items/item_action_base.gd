class_name ItemActionBase
extends Resource

enum ActionSlot {
	PRIMARY,   # e.g. main, 
	SECONDARY, # e.g. under primary
	TERTIARY,  # e.g. under secondary
}

@export var slot: ActionSlot = ActionSlot.PRIMARY
@export var label: String = ""        # what the UI shows
@export var action_type: String = ""  # internal identifier for logic

func execute() -> void:
	pass
