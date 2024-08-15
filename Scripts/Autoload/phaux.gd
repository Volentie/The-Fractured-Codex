extends Node3D

static var _name = "Phaux"
static var version = 0.2
static var pretty = "-=:[" + _name + " v" + str(version) + "]:=-"

func type(obj) -> String:
	return type_string(typeof(obj))

func error(msg: String, line: int = -1):
	print(self.pretty, "ERROR: ", msg)
	if line >= 0:
		print(self.pretty, "Line: ", line)

func debug(array_msg, insert_space: bool=true) -> bool:
	assert(array_msg is Array or array_msg is String, "debug() expects an Array or String, got: " + type(array_msg))
	if array_msg is Array:
		var space = " " if insert_space else ""
		array_msg = "\t" + space.join(array_msg)
	print(self.pretty, array_msg)
	return true

func get_util(script_name: String) -> Object:
	var script = ResourceLoader.load("res://Scripts/Util/" + script_name + ".gd")
	if script == null:
		error("Failed to load script: " + script_name)
		return null
	return script.instantiate()
