extends Node

# References
@onready var wood_footsteps = load("res://Resources/sounds/234263__fewes__footsteps-wood.ogg")
@onready var wood_jump = load("res://Resources/sounds/446789__ianlyanx__salto-madera.wav")
@onready var wood_land = load("res://Resources/sounds/422857__ipaddeh__jump_landing_wood_01.wav")

func handle_sounds(player: Node3D, streams: Dictionary) -> void:
	var walk_stream = streams["walk_stream"]
	#var jump_stream = streams["jump_stream"]
	
	# TODO: Handle jumping and landing sounds, make the volume lower

	if player.mode.get_cur_state_name() == "Walking":
		SoundHandler.set_play(walk_stream, wood_footsteps, randf() * 0.3)
		if walk_stream.playing and player.mode.get_last_state_name() == "Running":
			walk_stream.pitch_scale = lerp(walk_stream.pitch_scale, 1.0, 0.1)
	elif player.mode.get_cur_state_name() == "Running":
		walk_stream.pitch_scale = lerp(walk_stream.pitch_scale, 1.5, 0.1)
		if !walk_stream.playing:
			SoundHandler.set_play(walk_stream, wood_footsteps, randf() * 0.3)
	else:
		SoundHandler.stop(walk_stream)
	# elif player.mode.get_cur_state_name() == "Idle":
	# 	if stream.playing:
	# 		stream.stop()
	# 		SoundHandler.reset_pitch(stream)
	# elif player.mode.get_cur_state_name() == "Air":
	# 	if stream.playing:
	# 		stream.stop()
	# 		SoundHandler.reset_pitch(stream)
			
			
