class_name Player extends CharacterBody3D

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

# Physics has to be loaded for us to get translation from it
var config = Physics.config
var world_config = config["world"]
var player_config = config["player"]
var player_accel = player_config.accel
var player_walk_accel = player_accel["walk"]
var player_jump_accel = player_accel["jump"]
var constraints_config = config["constraints"]
var translation = Physics.translation
var min_vel = constraints_config.velocity["min"]
var max_vel = constraints_config.velocity["max"]
var min_vel_v = Vector3(min_vel, min_vel, min_vel)
var max_vel_v = Vector3(max_vel, max_vel, max_vel)
var desaccelerate_factor = constraints_config.desaccelerate_factor
@onready var camera = $player_camera

var last_mouse_pos: Vector2

func accelerate(vec: Vector3, _scale = player_walk_accel) -> void:
	assert(vec and vec is Vector3, "Invalid vector")
	translation["accel"] = vec * _scale
	translation["velocity"] += translation["accel"]

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
		accelerate(VU3.y, player_jump_accel)

func clear_accel():
	translation["accel"] = VU3.c

func clear_velocity():
	translation["velocity"] = VU3.c

func apply_gravity() -> void:
	accelerate(VU3.y, -world_config.gravity)

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
	var clear = Vector3(0, translation["velocity"].y, 0)
	# Desaccelerate and round to 0 if close enough
	if translation["velocity"].length() < 0.1:
		translation["velocity"] = clear
	else:
		# TODO: confliting with apply_gravity
		translation["velocity"] = translation["velocity"].lerp(clear, desaccelerate_factor)
	

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
