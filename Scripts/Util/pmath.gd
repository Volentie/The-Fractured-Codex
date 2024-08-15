extends Object

class Vec3:
    var obj = {}

    func magnitude() -> float:
        return sqrt(obj.x * obj.x + obj.y * obj.y + obj.z * obj.z)

    func _init(x: float, y: float, z: float) -> void:
        obj.x = x
        obj.y = y
        obj.z = z