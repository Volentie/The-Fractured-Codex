class_name Player extends CharacterBody3D

var translation: Dictionary = {
	"position": Vector3(),
	"rotation": Vector3()
}

const VU3 = {
	"x": Vector3(1, 0, 0),
	"y": Vector3(0, 1, 0),
	"z": Vector3(0, 0, 1),
	"c": Vector3(0, 0, 0)
}

func go_forward():
	translation["position"] += VU3.z

func go_backward():
	translation["position"] -= VU3.z

func go_left():
	translation["position"] -= VU3.x

func go_right():
	translation["position"] += VU3.x
	
func go_up():
	translation["position"] += VU3.y

func clear_translation():
	translation["position"] = VU3.c

func update_transform(input_method: StringName, action: StringName):
	# Apply corresponding translation
	print(input_method, action)
