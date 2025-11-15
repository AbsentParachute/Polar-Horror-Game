extends Node

@export var coat_on_sfx: AudioStream
@export var coat_off_sfx: AudioStream

@onready var sfx_pool: Node = $"../../SFXPool"
@onready var coat_mesh: MeshInstance3D = $"../../Head/Camera/CoatMesh" #Need new place for hoodmesh so it works with NPC (NPC wont have camera)

var coat_on: bool = false

func toggle_coat() -> void:
	coat_on = not coat_on
	
	EventBus.coat_changed.emit() # Potential BUG - Will need to consider a solution for when this is on an NPC
	
	coat_mesh.visible = coat_on

	var coat_sfx = AudioStream
	if coat_on == true:
		coat_sfx = coat_on_sfx
	else: 
		coat_sfx = coat_off_sfx
	
	var audio_player = get_free_audio()
	if audio_player:
		audio_player.stream = coat_sfx
		audio_player.volume_db = 0
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		audio_player.play()

func get_free_audio() -> AudioStreamPlayer3D:
	for a in sfx_pool: #a = AudioStreamPlayer3D
		if not a.playing():
			return a
	return null
