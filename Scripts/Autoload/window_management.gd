extends Node

var window_has_focus = false

func hide_cursor() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    window_has_focus = true

func show_cursor() -> void:
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    window_has_focus = false

func _ready() -> void:
    hide_cursor()

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_IN:
        hide_cursor()
    elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        show_cursor()