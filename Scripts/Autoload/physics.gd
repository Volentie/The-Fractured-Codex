extends Node3D

# Physics configuration
# Net force = mass * acceleration | Acceleration = Net force / mass
# F = M * A | A = F / M
# Friction (vector) = -1 * mass * normal_force * velocity_unit_vector

const config = {
	"world": {
		"gravity": 0.5,
	},
	"player": {
		"mass": 1,
		"accel": {
			"walk": 0.4,
			"jump": 10,
		}
	},
	"constraints": {
		"velocity": {
			"max": 100,
			"min": -100,
		}
	}
}

var translation = {
	"velocity": Vector3(0, 0, 0),
	"accel": Vector3(0, 0, 0),
	"force": Vector3(0, 0, 0),
	"friction": Vector3(0, 0, 0),
	"normal": Vector3(0, 0, 0),
	"net_force": Vector3(0, 0, 0),
	"accel_unit": Vector3(0, 0, 0),
	"velocity_unit": Vector3(0, 0, 0),
	"friction_unit": Vector3(0, 0, 0),
	"normal_unit": Vector3(0, 0, 0),
	"net_force_unit": Vector3(0, 0, 0),
}

func net_force() -> void:
	translation["net_force"] = translation["force"] + translation["friction"] + translation["normal"] + translation["gravity"]

func apply_force(force: Vector3) -> void:
	translation["force"] = force
	translation["accel"] = translation["force"] / config.player.mass
	translation["accel_unit"] = translation["accel"].normalized()

func apply_friction(normal: Vector3) -> void:
	translation["normal"] = normal
	translation["friction"] = -1 * config.player.mass * translation["normal"] * translation["velocity_unit"].normalized()
	translation["friction_unit"] = translation["friction"].normalized()

func apply_gravity() -> void:
	translation["force"] = Vector3(0, -config.world.gravity, 0)
	translation["accel"] = translation["force"] / config.player.mass
	translation["accel_unit"] = translation["accel"].normalized()

func apply_normal(normal: Vector3) -> void:
	translation["normal"] = normal
	translation["normal_unit"] = translation["normal"].normalized()

func apply_velocity() -> void:
	translation["velocity"] += translation["accel"]
	translation["velocity_unit"] = translation["velocity"].normalized()

# This doesn't work as intended, I need to get back to it some other time
# func get_velocity() -> bool:
# 	var cur_script = get_script()
# 	var obj = cur_script.get("velocity")
# 	if "velocity" in cur_script:
# 		print(true)
# 		return true
# 	print(false, obj)
# 	return false
