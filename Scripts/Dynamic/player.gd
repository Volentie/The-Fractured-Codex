class_name Player extends CharacterBody3D

# Configuration and bindings
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
	"go_up",
	"add_run"
]

var config = Physics.config
var world_config = config["world"]
var player_config = config["player"]
var player_accel = player_config.accel
var player_walk_accel = player_accel["walk"]
var player_jump_accel = player_accel["jump"]
var player_run_accel = player_accel["run"]
var player_mass = player_config.mass
var constraints_config = config["constraints"]
var translation = Physics.translation
var min_vel = constraints_config.velocity["min"]
var max_vel = constraints_config.velocity["max"]
var min_vel_v = Vector3(min_vel, min_vel, min_vel)
var max_vel_v = Vector3(max_vel, max_vel, max_vel)
var desaccelerate_factor = constraints_config.desaccelerate_factor
var desaccelerate_round = constraints_config.desaccelerate_round

# States
var state = {
	"walking": false,
	"running": false,
	"moving": false,
	"motion": false,
	"jumping": false,
	"falling": false,
}

# Node references
@onready var camera = $player_camera

# Variables
var last_mouse_pos: Vector2
var acceleration_scale: Vector3 = player_walk_accel

# Functions
# TODO: Implement state machine, this is not good yet, I have to rethink this
func set_moving():
	state["moving"] = true
	
func set_motion():
	state["motion"] = true

func set_idle():
	state["walking"] = false
	state["running"] = false
	acceleration_scale = player_walk_accel

func set_still():
	state["moving"] = false
	state["motion"] = false
	state["jumping"] = false
	state["falling"] = false

func set_walking():
	state["walking"] = true
	state["running"] = false
	acceleration_scale = player_walk_accel

func set_running():
	state["running"] = true
	state["walking"] = false
	acceleration_scale = player_run_accel

func set_jumping():
	state["jumping"] = true
	state["falling"] = false
	state["moving"] = true
	acceleration_scale = player_jump_accel

func set_falling():
	state["falling"] = true
	state["jumping"] = false
	state["moving"] = false

func apply_force(force: Vector3) -> void:
	assert(force and force is Vector3, "Invalid force")
	if !state["motion"]:
		set_motion()
	translation["force"] = force
	translation["accel"] = translation["force"] / player_mass
	translation["velocity"] += translation["accel"]

func accelerate(direction: Vector3) -> void:
	apply_force(direction * acceleration_scale)

func get_camera_relative_axis(axis: String) -> Vector3:
	var cam_basis = camera.global_transform.basis
	if axis == "x":
		return cam_basis.x
	elif axis == "y":
		return cam_basis.y
	elif axis == "z":
		return cam_basis.z
	else:
		Phaux.error("Invalid axis: " + axis)
		return VU3.c

func get_normalized_camera_relative_axis(axis: String) -> Vector3:
	var basis_vec: Vector3 = get_camera_relative_axis(axis)
	basis_vec.y = 0
	return basis_vec.normalized()

func add_run() -> void:
	if state["walking"]:
		set_running()

func go_forward() -> void:
	accelerate(-get_normalized_camera_relative_axis("z"))

func go_backward() -> void:
	accelerate(get_normalized_camera_relative_axis("z"))

func go_left() -> void:
	accelerate(-get_normalized_camera_relative_axis("x"))

func go_right() -> void:
	accelerate(get_normalized_camera_relative_axis("x"))
	
func go_up() -> void:
	if is_on_floor():
		set_jumping()
		accelerate(VU3.y)

func apply_gravity() -> void:
	apply_force(VU3.y * -world_config.gravity)

func update_values(constraint: bool) -> void:
	velocity = translation["velocity"]
	if constraint:
		velocity = velocity.clamp(min_vel_v, max_vel_v)

func breathe():
	# Apply gravity if not grounded
	if !is_on_floor():
		apply_gravity()
	# Update values	
	update_values(true)
	# Desaccelerate so we don't keep moving forever
	desaccelerate()
	# Move
	move_and_slide()
	# Camera translation
	camera_translation()

func get_mouse_pos() -> Vector2:
	var viewport = get_viewport()
	return viewport.get_mouse_position()

func camera_translation():
	var viewport = get_viewport()
	var mouse_pos = get_mouse_pos()
	var center = Vector2(viewport.size.x / 2, viewport.size.y / 2)
	var delta = mouse_pos - center
	var sensitivity = 0.1
	var camera_rotation = camera.rotation_degrees
	camera_rotation.x -= delta.y * sensitivity
	camera_rotation.x = clamp(camera_rotation.x, -90, 90)
	camera_rotation.y -= delta.x * sensitivity
	camera.rotation_degrees = camera_rotation
	# Reset cursor to center
	viewport.warp_mouse(center)


func desaccelerate():
	
	# Desaccelerate and round to 0 if close enough
	if translation["velocity"].length() <= desaccelerate_round:
		translation["velocity"] *= VU3.y
	else:
		translation["velocity"] *= Vector3(desaccelerate_factor, 1, desaccelerate_factor)
	

func update_transform(input_method: StringName, action: StringName) -> void:
	assert(input_method in CustomInputs.input_methods and action in map, "Invalid input_method or action")
	var callO = Callable(self, action)
	if callO.is_valid():
		callO.call()
	else:
		Phaux.error("Invalid action: " + action)

func _process(_delta):
	if not WindowManagement.window_has_focus:
		return

	# Check for input
	for custom_action in map:
		if Input.is_action_pressed(custom_action):
			update_transform(&"holding", custom_action)

	# Update values	
	breathe()
