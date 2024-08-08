class_name player_move

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

static var state: State = State.IDLE

func state_exists(_state) -> bool:
    assert(_state in State, "Invalid state: " + _state)
    return true

func set_state(_state: String):
    assert(_state in State, "Invalid state: " + _state)