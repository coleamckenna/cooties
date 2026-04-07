extends AudioStreamPlayer
class_name RecordAudioManager

var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@onready var output : AudioStreamPlayer2D
@export var auth: int

func _enter_tree() -> void:
	set_multiplayer_authority(auth) # make sure this is set or stuff will absolutely go wrong
	
func _ready() -> void:
	# we only want to initalize the mic for the peer using it
	#if (is_multiplayer_authority()):
		print("somethng")
		idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_mute(idx,true)
		var bus_name: String = str("Record",auth)
		AudioServer.set_bus_name(idx,bus_name)
		bus = bus_name
		var capture: = AudioEffectCapture.new()
		AudioServer.add_bus_effect(idx,capture,0)
		effect = AudioServer.get_bus_effect(idx, 0)
		stream = AudioStreamMicrophone.new()
		print(AudioServer.bus_count)
		ResourceSaver.save(AudioServer.generate_bus_layout(),"res://audio_stuff/bus.tres")
		play()
		
			
	# playback variable will be needed for playback on other peers	
	#playback = output.get_stream_playback()

func _process(_delta: float) -> void:
	if (not is_multiplayer_authority()): return
	if (effect.can_get_buffer(512) && playback.can_push_buffer(512)):
		send_data.rpc(effect.get_buffer(512))
	effect.clear_buffer()

# if not "call_remote," then the player will hear their own voice
# also don't try and do "unreliable_ordered." didn't work from my experience
@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array) -> void:
	for i in range(0,512):
		playback.push_frame(data[i])
