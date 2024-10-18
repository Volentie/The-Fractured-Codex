extends Node

func set_play(stream: AudioStreamPlayer3D, res: Resource, initial_position: float = 0) -> void:
	if stream.stream != res:
		stream.set_stream(res)
	if !stream.playing:
		stream.play(initial_position)
		print("Playing sound ", res, initial_position)

func reset_pitch(stream) -> void:
	if stream.pitch_scale != 1.0:
		stream.pitch_scale = 1.0

func set_volume(stream: AudioStreamPlayer3D, volume: float) -> void:
	if stream.volume_db != volume:
		stream.volume_db = volume

func stop(stream: AudioStreamPlayer3D) -> void:
	if stream.playing:
		stream.stop()
		reset_pitch(stream)