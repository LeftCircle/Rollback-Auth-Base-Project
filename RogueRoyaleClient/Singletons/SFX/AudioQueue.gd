extends Node

@onready var audio_stream_queue = $AudioStreamLoopingArray
#var audio_stream_2d_queue = AudioStreamLoopingArray.new()

var to_play_sounds = false

func _init():
	#audio_stream_2d_queue.init_audio_streams(true)
	process_priority = ProjectSettings.get_setting("global/PROCESS_LAST")

func queue_audio(sound) -> void:
	print("Audio queued on frame " + str(CommandFrame.frame))
	if not ProjectSettings.get_setting("global/spawn_test_characters"):
		audio_stream_queue.add_data(sound)

func queue_audio_2d(sound) -> void:
	pass

func execute():
	# We should test if it is better to push this to the render thread for
	# whatever reason
	#to_play_sounds = true
	_play_queued_audio()

#func _process(delta):
#	if to_play_sounds:
#		_play_queued_audio()
#		to_play_sounds = false

func _play_queued_audio():
	audio_stream_queue.play_audio()
	#audio_stream_2d_queue.play_audio()


