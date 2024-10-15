extends Node3D

const config = {
	"world": {
		"gravity": 10,
		"materials": {
			"friction": {
				"wood": 0.3,
				"air": 0.01,
			},
			"density": {
				"air": 0.1,
			}
		}
	},
	"player": {
		"mass": 1,
		"accel": {
			"walk": Vector3(4, 1, 4),
			"run": Vector3(8, 1, 8),
			"jump": Vector3(1, 200, 1),
		}
	},
	"constraints": {
		"velocity": {
			"max": 100,
			"min": -100,
		},
	}
}

var translation = {
	"accel": Vector3(0, 0, 0),
	"force": Vector3(0, 0, 0),
	#"friction": Vector3(0, 0, 0),
}

const forces = {
	"gravity": Vector3(0, -config.world.gravity, 0),
}

var player: Node3D

func accelerate(direction: Vector3) -> void:
	player.velocity += direction * player.acceleration_scale * player.cur_delta

# func apply_friction() -> void:
# 	var u = -player.velocity.normalized()  # Friction opposes the direction of velocity
# 	var friction_magnitude = config.world.materials.friction.wood * -forces.gravity.y
# 	translation["friction"] = u * friction_magnitude
	
# 	# Only apply friction when the body is moving
# 	if player.velocity.length() > 0.01 and player.is_on_floor():
# 		player.velocity += translation["friction"] * player.cur_delta

func limit_velocity() -> void:
	if player.is_on_floor() and player.velocity.length() <= 0.11:
		player.velocity = Vector3.ZERO

func desaccelerate() -> void:
	# Desaccelerate player over time smoothly
	if player.is_on_floor():
		player.velocity = lerp(player.velocity, Vector3.ZERO, 0.05)

func apply_physics(this: Node3D) -> void:
	player = this
	# Apply gravity
	player.velocity += forces.gravity * player.cur_delta
	
	# Apply friction to slow down the body
	#apply_friction()
	
	# Desaccelerate
	desaccelerate()
	
	# Constraint velocity
	limit_velocity()
	
	# Move the body based on its updated velocity
	player.move_and_slide()