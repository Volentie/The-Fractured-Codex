class_name custom_inputs extends Node3D

signal handler(input_method: StringName, input_mapped: StringName)

const input_methods = [&"holding", &"pressed"]

func _input(event):
	match event:
		"go_forward":
			handler.emit(&"pressed", &"go_forward")
		"go_backward":
			handler.emit(&"pressed", &"go_backward")
		"go_left":
			handler.emit(&"pressed", &"go_left")
		"go_right":
			handler.emit(&"pressed", &"go_right")
		"go_up":
			handler.emit(&"pressed", &"go_up")