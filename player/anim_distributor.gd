extends Node

class_name AnimDistributor


@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var target_rotation_left: float = 0.0:
	set(value):
		target_rotation_left = value
		_set_left(value)

@export_range(-180.0, 180.0, 0.1, "radians_as_degrees") var target_rotation_right: float = 0.0:
	set(value):
		target_rotation_right = value
		_set_right(value)

@export var right_joint_blend: JointBlend
@export var left_joint_blend: JointBlend
@export var invert_on_flip: bool = true
var is_flip: bool = false


func _ready():
	print("right_joint_blend: ", right_joint_blend.get_path())

func _set_right(value):
	if not is_node_ready():
		return

	var invert: float = 1
	if invert_on_flip:
		invert = -1

	if is_flip:
		left_joint_blend.target_rotation = value * invert
	else:
		right_joint_blend.target_rotation = value

func _set_left(value):
	if not is_node_ready():
		return

	var invert: float = 1
	if invert_on_flip:
		invert = -1

	if is_flip:
		right_joint_blend.target_rotation = value * invert
	else:
		left_joint_blend.target_rotation = value
