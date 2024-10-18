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
@onready var walk_stream = $walk_stream
@onready var jump_stream = $jump_stream

# Constants
const run_speed: float = 5.0
const walk_speed: float = 3.0
const jump_scale: float = 2.5
const gravity_scale: float = 9.8

# Variables
var speed: float = walk_speed
var mouse_input: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.1
var jump_clk: bool = false

# State
var mode = StateMachine.new("Mode", {
	"Walking": State.new("Walking"),
	"Running": State.new("Running"),
	"Idle": State.new("Idle"),
	"Air": State.new("Air")
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
	mode.switch("Idle")
	speed_mode.switch("Walk")

	# Mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_rotation() -> void:
	head.rotation_degrees.x -= mouse_input.y * mouse_sensitivity
	rotation_degrees.y -= mouse_input.x * mouse_sensitivity
	# Clamp x camera rotation
	head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)
	mouse_input = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_input += event.relative

func _physics_process(delta: float) -> void:
	handle_rotation()
	move_and_slide()

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

	var dir_force: Vector3 = direction * speed
	var force = Vector3(dir_force.x, velocity.y, dir_force.z)

	# Ground logic
	if is_on_floor():
		# Handle ground movement
		# If the player is moving, lerp faster to the new velocity
		if direction.length() > 0:
			# Handle walking/running state
			if speed_mode.get_cur_state_name() == "Run":
				mode.switch("Running")
			else:
				mode.switch("Walking")
			velocity = lerp(velocity, force, 0.9)
		# If not, lerp slower to 0
		else:
			# Switch to idle state
			mode.switch("Idle")
			velocity = lerp(velocity, force, 0.2)

		# Jump
		if Input.is_action_just_pressed("action_jump"):
			velocity.y += (jump_scale * 150) * delta
			jump_clk = !jump_clk
	else:
		# Switch to air mode
		mode.switch("Air")
		# Handle air movement (more like gliding)
		velocity = lerp(velocity, force, 0.1)
		# Apply gravity
		velocity.y -= (gravity_scale * 2.5) * delta

# Handle sounds
func _process(_delta: float) -> void:
	PlayerSound.handle_sounds(self, {
		"walk_stream": walk_stream,
		"jump_stream": jump_stream
	})