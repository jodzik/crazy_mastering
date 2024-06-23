extends RigidBody2D

var _teleport_to: Vector2
var _is_teleport_needed: bool = false

func _integrate_forces(state):
	if _is_teleport_needed:
		_is_teleport_needed = false
		state.transform.origin = _teleport_to

func teleport(pos: Vector2):
	_teleport_to = pos
	_is_teleport_needed = true
