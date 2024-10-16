extends CharacterBody3D

# Input Map
const input_map = [
	"move_forward",
	"move_backward",
	"move_left",
	"move_right",
	"action_jump",
	"speedmode_run"
]

# References
@onready var head = $player_camera

# Constants
const run_speed: float = 10.0
const walk_speed: float = 5.0
const jump_scale: float = 5.0
const gravity_scale: float = 9.8

# Variables
var speed: float = walk_speed
var mouse_input: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.1

# State
var energy = StateMachine.new("Energy", {
	"Potential": State.new("Potential"),
	"Kinetic": State.new("Kinetic")
})
var speed_mode = StateMachine.new("SpeedMode", {
	"Run": State.new("Run", func(): change_speed(run_speed)),
	"Walk": State.new("Walk", func(): change_speed(walk_speed)),
})

# Methods
func change_speed(_speed: float) -> void:
	speed = _speed

func _ready() -> void:
	# Set the initial state
	energy.switch("Potential")
	speed_mode.switch("Walk")

	# Mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_rotation() -> void:
	head.rotation_degrees.x -= mouse_input.y * mouse_sensitivity
	rotation_degrees.y -= mouse_input.x * mouse_sensitivity
	head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)
	mouse_input = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_input += event.relative

func _physics_process(delta: float) -> void:
	handle_rotation()

	# Movement
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= basis.z
	if Input.is_action_pressed("move_backward"):
		direction += basis.z
	if Input.is_action_pressed("move_left"):
		direction -= basis.x
	if Input.is_action_pressed("move_right"):
		direction += basis.x
	
	# Alter speed
	if Input.is_action_just_pressed("speedmode_run"):
		speed_mode.switch("Run")
	if Input.is_action_just_released("speedmode_run"):
		speed_mode.switch("Walk")
	
	# Move
	var force = direction.normalized() * speed
	velocity = Vector3(force.x, velocity.y, force.z)
	
	# Jump
	if is_on_floor() and Input.is_action_just_pressed("action_jump"):
		velocity.y = jump_scale
	
	# Apply gravity
	velocity.y -= gravity_scale * delta

	# Move
	move_and_slide()
	
	# Handle energy state
	if velocity.length() > 0:
		energy.switch("Kinetic")
	else:
		energy.switch("Potential")