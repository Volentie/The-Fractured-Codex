class_name StateMachine

var name: String
var states: Dictionary
var current_state: State

func _init(_name: String, _states: Dictionary) -> void:
	name = _name
	states = _states

func switch(state_name: String)-> void:
	assert(states.has(state_name), "Invalid state ("+state_name+")")
	var _state = states[state_name]
	if current_state != _state:
		current_state = _state
		current_state.enter()
