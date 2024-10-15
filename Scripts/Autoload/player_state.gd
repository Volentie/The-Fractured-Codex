extends Node

var move = StateMachine.new("Move", {
	"Still": State.new("Still"),
	"Motion": State.new("Motion")
})

var speed_mode = StateMachine.new("SpeedMode", {
	"Run": State.new("Run", func() -> void: Player.set_acceleration_scale(Physics.config.player.accel.run)),
	"Walk": State.new("Walk", func() -> void: Player.set_acceleration_scale(Physics.config.player.accel.walk))
})

func _ready():
	move.switch("Still")
	speed_mode.switch("Walk")
