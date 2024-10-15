class_name Player extends CharacterBody3D

# Configuration and bindings
const VU3 = {
	"x": Vector3(1, 0, 0),
	"y": Vector3(0, 1, 0),
	"z": Vector3(0, 0, 1),
	"c": Vector3(0, 0, 0)
}

const map = [
	"move_forward",
	"move_backward",
	"move_left",
	"move_right",
	"action_jump",
	"speedmode_run"
]

var config = Physics.config
var world_config = config["world"]
var player_config = config["player"]
var player_accel = player_config.accel
var player_walk_accel = player_accel["walk"]
var player_jump_accel = player_accel["jump"]
var player_run_accel = player_accel["run"]
var constraints_config = config["constraints"]
var translation = Physics.translation
var min_vel = constraints_config.velocity["min"]
var max_vel = constraints_config.velocity["max"]
var min_vel_v = Vector3(min_vel, min_vel, min_vel)
var max_vel_v = Vector3(max_vel, max_vel, max_vel)
var ply_state = PlayerState
var input_list: Array = []

# Physics
var player_mass = player_config.mass

# Node references
@onready var camera = $player_camera

# Variables
var last_mouse_pos: Vector2
static var acceleration_scale: Vector3
static var cur_delta: float

# Methods
static func set_acceleration_scale(_scale: Vector3) -> void:
	acceleration_scale = _scale

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

func hold_speedmode_run() -> void:
	ply_state.speed_mode.switch("Run")

func release_speedmode_run() -> void:
	ply_state.speed_mode.switch("Walk")

func hold_move_forward() -> void:
	Physics.accelerate(-get_normalized_camera_relative_axis("z"))

func hold_move_backward() -> void:
	Physics.accelerate(get_normalized_camera_relative_axis("z"))

func hold_move_left() -> void:
	Physics.accelerate(-get_normalized_camera_relative_axis("x"))

func hold_move_right() -> void:
	Physics.accelerate(get_normalized_camera_relative_axis("x"))
	
func hold_action_jump() -> void:
	if is_on_floor():
		self.velocity += player_jump_accel * cur_delta

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

func update_input_list(input_method: StringName, action: StringName) -> void:
	if input_method == &"hold":
		input_list.append(action)
	elif input_method == &"release":
		input_list.erase(action)
	update_motion_state()

func update_transform(input_method: StringName, action: StringName) -> void:
	var callO = Callable(self, input_method + "_" + action)
	if callO.is_valid():
		if action.begins_with("move"):
			update_input_list(input_method, action)
		callO.call()

func update_motion_state() -> void:
	if input_list.size() == 0:
		ply_state.move.switch("Still")
	else:
		ply_state.move.switch("Motion")

func _physics_process(delta: float):
	# Update delta var
	cur_delta = delta
	if not WindowManagement.window_has_focus:
		return

	# Check for input
	for custom_action in map:
		if Input.is_action_pressed(custom_action):
			update_transform(&"hold", custom_action)
		if Input.is_action_just_released(custom_action):
			update_transform(&"release", custom_action)

	camera_translation()
	Physics.apply_physics(self)