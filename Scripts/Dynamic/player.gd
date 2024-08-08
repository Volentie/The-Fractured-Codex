class_name Player extends CharacterBody3D

var translation: Dictionary = {
	"velocity": Vector3(),
	"rotation": Vector3()
}

const VU3 = {
	"x": Vector3(1, 0, 0),
	"y": Vector3(0, 1, 0),
	"z": Vector3(0, 0, 1),
	"c": Vector3(0, 0, 0)
}

const map = [
	"go_forward",
	"go_backward",
	"go_left",
	"go_right",
	"go_up"
]

func _ready():
	set_physics_process(true)
	set_process_input(true)
	set_process(true)

func go_forward():
	translation["velocity"] -= VU3.z

func go_backward():
	translation["velocity"] += VU3.z

func go_left():
	translation["velocity"] -= VU3.x

func go_right():
	translation["velocity"] += VU3.x
	
func go_up():
	translation["velocity"] += VU3.y

func clear_velocity():
	translation["velocity"] = VU3.c

func update_transform(input_method: StringName, action: StringName) -> bool:
	if input_method != &"holding":
		Phaux.debug("Invalid input_method")
		return false

	var callO = Callable(self, action)
	if callO.is_valid():
		callO.call()
	else:
		return Phaux.error("Invalid action: " + action)
	
	velocity = translation["velocity"]
	return true

func move_and_clear() -> void:
	move_and_slide()
	clear_velocity()

func apply_gravity() -> void:
	translation["velocity"] -= VU3.y
	move_and_clear()

func _process(_delta):
	# Apply gravity
	apply_gravity()

	# Check for input
	for custom_action in map:
		if Input.is_action_pressed(custom_action):
			update_transform(&"holding", custom_action)
	
	
	# Check if velocity has changed to move
	if translation["velocity"] != Vector3.ZERO:
		move_and_clear()
	
