class_name Player extends CharacterBody3D

const config = {
	"gravity": 0.5,
	"walk_power": 1.1,
	"jump_power": 10,
}

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

func go_forward(_scale: float = 1) -> void:
	translation["velocity"] -= VU3.z * _scale

func go_backward(_scale: float = 1) -> void:
	translation["velocity"] += VU3.z * _scale

func go_left(_scale: float = 1) -> void:
	translation["velocity"] -= VU3.x * _scale

func go_right(_scale: float = 1) -> void:
	translation["velocity"] += VU3.x * _scale
	
func go_up(_scale: float = 1) -> void:
	translation["velocity"] += VU3.y * _scale

func clear_velocity():
	translation["velocity"] = VU3.c
	velocity = VU3.c

func apply_transform(move: bool) -> void:
	velocity = translation["velocity"]
	if move:
		move_and_slide()

func move_and_clear() -> void:
	apply_transform(true)
	clear_velocity()

func apply_gravity() -> void:
	translation["velocity"] -= VU3.y * config.gravity
	move_and_clear()

func update_transform(input_method: StringName, action: StringName) -> String:
	assert(input_method in custom_inputs.input_methods and action in map, "Invalid input_method or action")

	var callO = Callable(self, action)
	if callO.is_valid():
		if action == "go_up":
			if is_on_floor():
				callO.call(config.jump_power)
				return "jump"
		else:
			callO.call(config.walk_power)
			return "walk"
	else:
		Plog.error("Invalid action: " + action)
	return "Error"

func _process(_delta):
	var movement_type
	# Apply gravity if not grounded
	if !is_on_floor():
		apply_gravity()

	# Check for input
	for custom_action in map:
		if Input.is_action_pressed(custom_action):
			movement_type = update_transform(&"holding", custom_action)
	
	# Check if velocity has changed to move
	if translation["velocity"] != Vector3.ZERO:
		if movement_type == "walk":
			move_and_clear()
		elif movement_type == "jump":
			apply_transform(true)