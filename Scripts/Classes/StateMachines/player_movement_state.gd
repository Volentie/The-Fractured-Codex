class_name player_movement_state

# Available states
enum State {
    IDLE,
    WALKING,
    RUNNING,
    JUMPING,
    FALLING,
    MOVING,
    NULL
}

var state: State = State.IDLE

func set_state(_state: String) -> void:
    if _state in State:
        state = State[_state]